;*************************************************************************************************
;*
;* OFDB Addon v1.1 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei ofdb.de nach dem angegebenen Film und postet die Ergebnisse in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !ofdb <Suchbegriff> startest du eine Film Suche.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Fixed: Es kam keine Fehlermeldung wenn kein Suchbegriff angegeben wurde.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.mindforge.org
;* Port: 6667
;* Channel: #IrcShark
;*
;* Befehl: /server -m irc.mindforge.org -j #IrcShark
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.OFDB* off | unset %Mod.OFDB* }

;*************************************************************************************************
; - Trigger Befehl des OFDB Addon.
;*************************************************************************************************
on *:TEXT:!ofdb*:#:{
  if (!$timer($+(Mod.OFDB-Flood., #, ., $cid))) {
    if ($2-) {
      .timerMod.OFDB-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.OFDB.sHTTP
      sockopen Mod.OFDB.sHTTP www.ofdb.de 80
      sockmark Mod.OFDB.sHTTP # $strip($2-)
      set -u10 %Mod.OFDB.vRead 1
    }
    else .notice $nick 14Du hast keinen09 Suchbegriff 14angegeben!
  }
  else {
    if ($timer($+(Mod.OFDB-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.OFDB-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.OFDB-vFlood., #, ., $cid, ., $nick) | .timerMod.OFDB-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.OFDB-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.OFDB-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.OFDB-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.ofdb.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.OFDB.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  var %content = Kat=DTitel&SText= $+ $2-
  sockwrite -n $sockname POST /view.php?page=suchergebnis HTTP/1.1 
  sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
  sockwrite -n $sockname Host: www.ofdb.de
  sockwrite -n $sockname Content-Length: $len(%content)
  sockwrite -n $sockname Cookie: ofdb_ret=view.php%253Fpage%253Dstart $+ $crlf $+ $crlf
  sockwrite $sockname %content
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.OFDB.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  var %chan = $1
  sockread 200 &temp
  set %Mod.OFDB.sRead $left(%Mod.OFDB.sRead, 200) $+ $replace($bvar(&temp,1,200).text, <br>, $chr(9), <tr>, $chr(9))
  while ($sockbr) {
    tokenize 9 %Mod.OFDB.sRead
    var %i = $calc($0 - 1)
    while (%i) {
      if ($regex($eval($ $+ %i, 2), /.*\d\. <a href="([^"]*)".*?">(.*?)<font/)) {
        if (%Mod.OFDB.vRead > 4) {
          sockclose Mod.OFDB.sHTTP | unset %Mod.OFDB.* | halt
        }
        inc %Mod.OFDB.vRead
        var %url = $regml(1)
        var %text = $remhtml($regml(2))
        if ($numtok(%text, 47) > 1) %text = $gettok(%text,-2-,47)
        %text = $gettok(%text, 1, 44)
        .timer 1 %Mod.OFDB.vRead .msg %chan 14-=(09 OFDB 14)=(09 %text 14)=( http://www.ofdb.de/ $+ %url 14)=-
      }
      dec %i
    }
    set %Mod.OFDB.sRead = $eval($ $+ $0, 2)
    sockread 200 &temp
    set %Mod.OFDB.sRead $left(%Mod.OFDB.sRead, 200) $+ $replace($bvar(&temp,1,200).text, <br>, $chr(9), <tr>, $chr(9))
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
alias -l remhtml {
  var %result
  noop $regsub($1-, /</?[a-z][a-z0-9]*[^<>]*>/g, , %result)
  return %result
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
