;* (c) 2010 by IrcShark (www.ircshark.net)
;* Version 0.1
;* Autor: Alpha,Andy
;*********************
;* IS.http <flags> <URL:port> <cbalias> <file> <binvar> <timeout> <mark>
;* Will return the reqid: $IS.http(<flags>, <URL:port>, <cbalias>, <file>, <binvar>, <timeout>, <mark>)
;*********************
;** Flags
;*********************
; -f = File output
; -p = Post request
; -b = Output in a binary variable
; -a = Callback alias for the status
; -m = Save some information (same like sockmark)
; -t = Set timeout in sec.
;*********************
;** Prop.
;** $IS.http(<reqid>).PROP
;*********************
; url = returns given URL
; server = returns the server
; port = returns the port
; method = returns the HTTP method
; cbalias = returns the given cbalias
; file = returns the given filename
; bvar = returns the given binary variable
; mark = returns given marks
; len = returnd Content-Length (can only use after the script has received the HTTP header) 
; timeout = retuns the secs till the timeout occur
;*********************
;** ERROR
;*********************
; 100 - No parameters given
; 101 - Link is invalid, maybe wrong chars?
; 102 - The given binary variable isn't valid
; 103 - The callback alias isn't in any scripts. Maybe it isn't global?
; 104 - An error ocurr while opening the socket. Details from HTTP-Server are in the error string.
; 105 - Given request id not found. (Prop.)
; 106 - Error while read sockets.
; 107 - The timeout value isn't a number
;*********************
alias IS.http {
  if (!$1-) return -100

  ;*** Returns information to the scripter
  if (($1 isnum) && (!$2-) && ($prop)) {
    if (!$hget(IS.http, $+($1, .bvar))) return -105
    
    if ($prop == url) return $gettok($hget(IS.http, $+($1, .prop)), 1, 32)
    elseif ($prop == server) return $gettok($hget(IS.http, $+($1, .prop)), 2, 32)
    elseif ($prop == port) return $gettok($hget(IS.http, $+($1, .prop)), 3, 32)
    elseif ($prop == method) return $gettok($hget(IS.http, $+($1, .prop)), 4, 32)
    elseif ($prop == cbalias) return $hget(IS.http, $+($1, .cbalias))
    elseif ($prop == file) return $hget(IS.http, $+($1, .file))
    elseif ($prop == bvar) return $hget(IS.http, $+($1, .binout))
    elseif ($prop == mark) return $hget(IS.http, $+($1, .mark))
    elseif ($prop == len) return $iif($hget(IS.http, $+($1, .len)), $v1, 0)
    elseif ($prop == timeout) return $iif($timer(IS.http.timeout. $+ %reqid).secs, $v1, 0)
    else return
  }
  
  var %params = $1-, %method, %url, %server, %port = 80, %resource = /, %reqid

  ;*** Creates the Hash Table for storing all the data
  if (!$hget(IS.http)) {
    hmake IS.http 50
    hadd IS.http lastid 0
  }

  ;** Sets the request id
  if ($hget(IS.http, 0).item >= 500) {
    var %a = $v1, %b = 1
    
    while (%a >= %b) {
        if (!$hget(IS.http, $+(%b, .bvar))) {
            %reqid = %b
            break
        }
        
        inc %b
    }
    
    if (!%reqid) hinc IS.http lastid
  }
  else {
    if ($hget(IS.http, 0).item > 1) hinc IS.http lastid
    else hadd IS.http lastid 1
    
    %reqid = $hget(IS.http, lastid)
   }

  ;*** Checks the parameters for flags and put them in to a var
  if ($left($1, 1) == -) {
    var %flags = $mid($1, 2)
    %params = $2-
  }

  ;*** Checks the validity of given URL and splits it into server, port and resource
  %url = $gettok(%params, 1, 32)
  if (!$regex(%url, /(?:http://)?([-A-Z0-9.]+(?::[0-9]+)?)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[-A-Z0-9+&@#/%=~_|!:,.;]*)?/i)) {
    IS.http.dec %reqid
    return -101
  }

  %params = $gettok(%params, 2-, 32)
  %server = $regml(1)

  if ($+($regml(2), $regml(3)) != $null) %resource = $v1

  if ($regex(%server, /([-A-Z0-9.]+)(?::([0-9]+))/i)) { 
    %server = $regml(1)
    %port = $regml(2)
  }

  ;*** Sets the HTTP method
  %method = GET
  if (p isin %flags) %method = POST

  ;*** Sets the binary variable with the HTTP-Header
  bset -t $+(&IS.http.request., %reqid) 1 %method %resource HTTP/1.1 $+ $crlf $+ Host: %server $+ $crlf $+ Connection: close $+ $crlf $+ $crlf
  hadd -b IS.http $+(%reqid, .bvar) $+(&IS.http.request., %reqid)
  hadd IS.http $+(%reqid, .prop) %url %server %port %method

  ;*** Checks for a callback alias
  if (a isin %flags) {
    var %cbalias = $gettok(%params, 1, 32)   

    if (!$isalias(%cbalias)) {
        IS.http.dec %reqid
        return -103
    }
    
    %params = $gettok(%params, 2-, 32)
    hadd IS.http $+(%reqid, .cbalias) %cbalias
  }

  ;*** Checks for a given file
  if (f isin %flags) {
    if ($left(%params, 1) == $chr(34)) {
      var %file = $mid(%params, 1, $calc($pos(%params, $chr(34), 2) + 1))
      %params = $mid(%params, $calc($pos(%params, $chr(34), 2) + 1))
    }
    else {
      var %file = $gettok(%params, 1, 32)
      %params = $gettok(%params, 2-, 32)
    }

    hadd IS.http $+(%reqid, .file) %file
  }

  ;*** Checks for a given binary variable
  if (b isin %flags) {
    var %binout = $gettok(%params, 1, 32)

    if ($left(%binout, 1) != $chr(38)) {
        IS.http.dec %reqid
        return -102
    }

    %params = $gettok(%params, 2-, 32)
    hadd IS.http $+(%reqid, .binout) %binout
  }
  
  ;*** Checks for given timeout
  if (t isin %flags) {
    var %timeout = $gettok(%params, 1, 32)
    
    if (%timeout !isnum) {
        IS.http.dec %reqid
        return -107
    }
    
    hadd IS.http $+(%reqid, .timeout) %timeout
    %params = $gettok(%params, 2-, 32)
  }
  
  ;*** Checks for given marks
  if (m isin %flags) hadd IS.http $+(%reqid, .mark) %params

  ;*** Opens the socket
  sockopen $+(IS.http.socket., %reqid) %server %port
  sockmark $+(IS.http.socket., %reqid) %reqid

  ;*** Will return the request id if the alias was called as an identifier
  if ($isid) return %reqid
}

on *:SOCKOPEN:IS.http.socket.*: {
  var %reqid = $sock($sockname).mark

  if ($sockerr > 0) {
    IS.http.cb %reqid ERROR Cannot open socket: $sock($sockname).wsmsg
    hdel -w IS.http $+(%reqid, .*)
    return -104
  }
  
  if ($hget(IS.http, $+(%reqid, .timeout))) .timerIS.http.timeout. $+ %reqid 0 $v1 IS.http.timeout %reqid
  
  sockwrite $sockname $hget(IS.http, $+(%reqid, .bvar))
  
  IS.http.cb %reqid CONNECTED
}

on *:SOCKREAD:IS.http.socket.*: {  
  var %reqid = $sock($sockname).mark, %file = $hget(IS.http, $+(%reqid, .file)), %bin = $hget(IS.http, $+(%reqid, .binout))
  if (($hget(IS.http, $+(%reqid, .timeout))) && ($timer(IS.http.timeout. $+ %reqid))) .timerIS.http.timeout. $+ %reqid off
  
  if (%bin) noop $hget(IS.http, $+(%reqid, .source), %bin)
  
  if ($sockerr > 0) {
    IS.http.cb %reqid ERROR Cannot read socket: $sock($sockname).wsmsg
    hdel -w IS.http $+(%reqid, .*)
    return -106
  }
  
  ;*** Reads the http header into a normal variable and then the source code into the binary variable
  if (!$hget(IS.http, $+(%reqid, .readbin))) sockread %IS.http.sockread
  else sockread &IS.http.sockread
  
  while ($sockbr) {
    ;*** Changes to binary varibale
    if ((!$hget(IS.http, $+(%reqid, .readbin))) && (%IS.http.sockread == $null)) hadd IS.http $+(%reqid, .readbin) $true
    
    ;*** Sends the HTTP-Header to the callback alias
    if (!$hget(IS.http, $+(%reqid, .readbin))) {
        if (Content-Length: isin %IS.http.sockread) hadd IS.http $+(%reqid, .len) $gettok($v2, 2, 32)
        
        IS.http.cb %reqid HEADER %IS.http.sockread
    }
    
    ;*** Reads the source code into the binary variable or file
    if (($hget(IS.http, $+(%reqid, .readbin))) && ($bvar(&IS.http.sockread, 0) > 0)) {
        if (%file) bwrite $v1 -1 -1 &IS.http.sockread
        if (%bin) bcopy %bin $iif($bvar(%bin, 0), $v1, 1) &IS.http.sockread 1 $bvar(&IS.http.sockread, 0)
        if ((!%bin) && (!%file)) {
            var %a = 1, %b
        
            while ($bfind(&IS.http.sockread, %a, 10) || $bfind(&IS.http.sockread, %a, 13)) {
                %b = $v1
                if ($v1 > $v2 && $v2 != 0) %b = $v2
                
                if ($bvar(&IS.http.sockread, %a, $calc(%b - %a)).text) IS.http.cb %reqid LINE $v1
                %a = %b + 1
            }
        
            IS.http.cb %reqid LINE $bvar(&IS.http.sockread, %a, $bvar(&IS.http.sockread, 0) - %a + 1).text
        }
        
        IS.http.cb %reqid READ $sockbr
    }
    
    ;*** Reads the http header into a normal variable and then the source code into the binary variable
    if (!$hget(IS.http, $+(%reqid, .readbin))) sockread %IS.http.sockread
    else sockread &IS.http.sockread
  }
  
  if (%bin) hadd -b IS.http $+(%reqid, .source) %bin
}

on *:SOCKCLOSE:IS.http.socket.*: {
  var %reqid = $sock($sockname).mark
  unset %IS.http.*  
  IS.http.cb %reqid DONE
  hdel -w IS.http $+(%reqid, .*)
}

;*** Gives data to the callback alias
alias -l IS.http.cb {
    if ($hget(IS.http, $+($1, .cbalias))) $v1 $1-
}

;*** Reduces lastid by 1 and remove created items in hash table
;* /IS.http.dec <reqID>
alias -l IS.http.dec {
    hdec IS.http lastid

    if ($1) hdel -w IS.http $+($v1, .*)
}

alias IS.http.timeout {
    if ($1) {
        IS.http.cb $1 TIMEOUT after $hget(IS.http, $+(%reqid, .timeout)) sec.
        hdel -w IS.http $+(%reqid, .*)
    }
}

alias mycba echo -s Da: $1-