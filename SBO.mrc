;*************************************************************************************************
;*
;* SBO Addon v1.0 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest ein Zitat von www.School-Bash.org aus.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !sbo wird zufällig ein Zitat ausgelesen.
;* Mit !sbo <NR> wird Zitat Nr. <NR> ausgelesen.
;* Mit !sbo new wird dir der neuste Eintrag angezeigt.
;* Mit !sbo info siehst du den Copyright.
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
on *:UNLOAD:{ .timerMod.SBO* off | unset %Mod.SBO* }

;*************************************************************************************************
; - Trigger Befehle vom SBO Addon.
;*************************************************************************************************
on *:TEXT:!sbo*:#:{
  if ($2 == info) { .notice $nick 14SBO Addon v1.0 © by 09www.IrcShark.de14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.SBO-Flood., #, ., $cid))) {
    if ($2) {
      if ($2 == new) var %Mod.SBO.vURL = /latest
      elseif ($remove($2, $chr(35)) isnum) var %Mod.SBO.vURL = $+(/single.php?id=, $remove($2, $chr(35)))
      else { .notice $nick 14Die 09Nr.14 wird mit den Zahlen von 090-914 angegeben. Für den neusten Eintrag tipp 09!sbo new | halt }
    }
    else var %Mod.SBO.vURL = /random
    ;.timerMod.SBO-Flood. $+ $+(#, ., $cid) 1 40 halt | 
    sockclose Mod.SBO.sHTTP
    sockopen Mod.SBO.sHTTP www.school-bash.org 80
    sockmark Mod.SBO.sHTTP # %Mod.SBO.vURL
    set -u20 %Mod.SBO.vRead 1
  }
  else {
    if ($timer($+(Mod.SBO-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.SBO-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.SBO-vFlood., #, ., $cid, ., $nick) | .timerMod.SBO-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.SBO-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.SBO-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.SBO-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.School-Bash.org
;*************************************************************************************************
on *:SOCKOPEN:Mod.SBO.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $2 HTTP/1.1
  sockwrite -n $sockname Host: www.school-bash.org
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Zitat aus.
;*************************************************************************************************
on *:SOCKREAD:Mod.SBO.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.SBO.sRead
  while ($sockbr) {
    if ($regex(%Mod.SBO.sRead, /.*<a href="/single.*">#(.*)</a><b>.*/)) set -u10 %Mod.SBO.vNR $regml(1)
    if (*<td class="quote_bl"> iswm %Mod.SBO.sRead) { set -u10 %Mod.SBO.vStart 1 | .msg $1 14Zitat aus09 www.School-Bash.Org14 (04# $+ %Mod.SBO.vNR $+ 14): }
    if (%Mod.SBO.vStart) {
      var %txt = $remove(%Mod.SBO.sRead, $chr(9), <br, />, <i>, </i>)
      if (*<*td*>* !iswm %txt) { .timer 1 %Mod.SBO.vRead .msg $1 14 $+ $replace($v2, &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32)) | inc %Mod.SBO.vRead }
    }
    if (*<td class="quote_br">* iswm %Mod.SBO.sRead) { sockclose Mod.SBO.sHTTP | unset %Mod.SBO* | halt }
    sockread %Mod.SBO.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
