;*************************************************************************************************
;*
;* Bash Addon v1.4 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest ein Zitat von www.German-Bash.org aus.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !bash wird zufällig ein Zitat ausgelesen.
;* Mit !bash <NR> wird Zitat Nr. <NR> ausgelesen.
;* Mit !bash new wird dir der neuste Eintrag angezeigt.
;* Mit !bash info siehst du den Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Added: !bash new um den neusten Eintrag zu sehen.
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*   Fixed: Wenn ein Satz im Zitat zu lang war wurde er nicht bis zum Ende gepostet.
;*   Fixed: Wenn ein Link im Zitat war, dann wurde der HTML Quellcode mit gepostet.
;*
;* v1.3
;*   Fixed: Variable %Mod.Bash.sRead wurde nicht entfernt.
;*
;* v1.2
;*   Fixed: Umlaute wurden nicht richtig angezeigt.
;*   Fixed: Wenn Zitat nicht gefunden wurde kam keine Fehler Messages.
;*
;* v1.1
;*   Fixed: Zitate wurden manchmal nicht bis zu Ende gepostet.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.MindForge.org
;* Port: 6667
;* Channel: #IrcShark
;*
;* Befehl: /server -m irc.MindForge.org -j #IrcShark
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Bash* off | unset %Mod.Bash* }

;*************************************************************************************************
; - Trigger Befehle vom Bash Addon.
;*************************************************************************************************
on *:TEXT:!bash*:#:{
  if ($2 == info) { .notice $nick 14Bash Addon v1.4 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Bash-Flood., #, ., $cid))) {
    if ($2) {
      if ($2 == new) var %Mod.Bash.vURL = /action/latest
      elseif ($remove($2, $chr(35)) isnum) var %Mod.Bash.vURL = $+(/index.php?id=, $remove($2, $chr(35)), &action=show) $remove($2, $chr(35))
      else { .notice $nick 14Die 09Nr.14 wird mit den Zahlen von 090-914 angegeben. Für den neusten Eintrag tipp 09!bash new | halt }
    }
    else var %Mod.Bash.vURL = /action/random
    .timerMod.Bash-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Bash.sHTTP
    sockopen Mod.Bash.sHTTP german-bash.org 80
    sockmark Mod.Bash.sHTTP # %Mod.Bash.vURL
    set -u20 %Mod.Bash.tRead 1
  }
  else {
    if ($timer($+(Mod.Bash-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Bash-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Bash-vFlood., #, ., $cid, ., $nick) | .timerMod.Bash-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Bash-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Bash-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Bash-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.German-Bash.org
;*************************************************************************************************
on *:SOCKOPEN:Mod.Bash.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $2 HTTP/1.1
  sockwrite -n $sockname Host: german-bash.org
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Zitat aus.
;*************************************************************************************************
on *:SOCKREAD:Mod.Bash.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Bash.sRead
  while ($sockbr) {
    if (<p class="error"> isin %Mod.Bash.sRead) { .msg $1 14Ein Zitat mit der 09Nr. $3 14existiert nicht. | sockclose Mod.Bash.sHTTP | unset %Mod.Bash.* | halt }
    if ($regex(%Mod.Bash.sRead, /.*<a title="Zitat (.*) den .*" href=".*" ><span>.*/)) .msg $1 14Zitat aus 09www.German-Bash.org14 (04 $+ $regml(1) $+ 14):
    if ($regex(%Mod.Bash.sRead, /<div class="zitat">/)) set -u20 %Mod.Bash.vRead $true
    if ((%Mod.Bash.vRead == $true) && ($regex(%Mod.Bash.sRead, /(.*)</span>/))) {
      if ($len($remove($regml(1), $chr(32))) > 1) {
        var %Mod.Bash.vRemove = $iif(%Mod.Bash.vRead == 1, $gettok($remove($regml(1), <span class="quote_zeile">, $chr(9)), 1-, 32), $remove($regml(1), <span class="quote_zeile">, $chr(9)))
        %Mod.Bash.vText = $replace(%Mod.Bash.vRemove, &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß)
        if ($regex(%Mod.Bash.vText, /(.*)<a href=".*>(.*)</a>(.*)/)) var %Mod.Bash.vText = $regml(1) $regml(2) $regml(3)
        if ($len(%Mod.Bash.vText) > 400) {
          var %Mod.Bash.vCount = $calc($count(%Mod.Bash.vText, $chr(32)) / 2)
          .timer 1 %Mod.Bash.tRead .msg $1 $+(14, $gettok(%Mod.Bash.vText, 1- $+ %Mod.Bash.vCount, 32), )
          .timer 1 %Mod.Bash.tRead .msg $1 $+(14, $gettok(%Mod.Bash.vText, $calc(%Mod.Bash.vCount + 1) $+ -, 32), )
        }
        else .timer 1 %Mod.Bash.tRead .msg $1 $+(14, %Mod.Bash.vText, )
        inc %Mod.Bash.tRead
      }
    }
    if ((%Mod.Bash.vRead == $true) && ($regex(%Mod.Bash.sRead, /</div>/))) { sockclose Mod.Bash.sHTTP | unset %Mod.Bash.* | halt }
    sockread %Mod.Bash.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
