;*************************************************************************************************
;*
;* Wiki Addon v1.2 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest Ergebnisse für den Suchbegriff bei www.wikipedia.de aus und postet die.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !wiki <Suchbegriff> bekommst du die Ergebnisse für den Suchbegriff angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.1
;*   Fixed: Umlaute wurden nicht richtig angezeigt.
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
on *:UNLOAD:{ .timerMod.Wiki* off | unset %Mod.Wiki* }

;*************************************************************************************************
; - Trigger Befehl des Wiki Addons.
;*************************************************************************************************
on *:TEXT:!wiki*:#:{
  if (!$timer($+(Mod.Wiki-Flood., #, ., $cid))) {
    if ($2-) {
      .timerMod.Wiki-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Wiki.sHTTP
      sockopen Mod.Wiki.sHTTP wiki.suche.web.de 80
      sockmark Mod.Wiki.sHTTP # 3 $replace($strip($2-), $chr(32), +)
      set -u10 %Mod.Wiki.vRead 1 | set -u10 %Mod.Wiki.vTimer 1
    }
    else .notice $nick 14Du hast vergessen einen09 Suchbegriff 14anzugeben!
  }
  else {
    if ($timer($+(Mod.Wiki-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Wiki-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Wiki-vFlood., #, ., $cid, ., $nick) | .timerMod.Wiki-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Wiki-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Wiki-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Wiki-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite http://wiki.suche.web.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Wiki.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /wiki/?su= $+ $Mod.Wiki.aURL($3) HTTP/1.1
  sockwrite -n $sockname Host: wiki.suche.web.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Daten aus und postet sie.
;*************************************************************************************************
on *:SOCKREAD:Mod.Wiki.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Wiki.sRead
  while ($sockbr) {
    if (*Es wurden keine Seiten, die mit dem* iswm %Mod.Wiki.sRead) {
      .msg $1 14Es wurden keine Seiten, die mit dem Suchbegriff $+("09, $replace($3, +, $chr(35)), 14") übereinstimmen gefunden.
      sockclose Mod.Wiki.sHTTP | unset %Mod.Wiki.* | halt
    }
    if ($regex(%Mod.Wiki.sRead, / $+ $str($chr(9), 9) $+ <dd>(.*)</dd>/)) { .timer 1 1 .msg $1 14Es wurden09 $gettok($regml(1), 1, 40) 14Treffer erzielt. | inc %Mod.Wiki.vTimer 2 }
    if ((!%Mod.Wiki.aStop) && ($regex(%Mod.Wiki.sRead, /<h3><a href="(.*)">(.*)</a></h3>/))) { .timer 1 %Mod.Wiki.vTimer .msg $1 09 $+ $Mod.Wiki.aReplace($regml(2)) 15 $+ $Mod.Wiki.aReplace($regml(1)) | inc %Mod.Wiki.vTimer | set %Mod.Wiki.aStop 1 }
    if ($regex(%Mod.Wiki.sRead, /.*<p>(.*)</p>.*/)) { 
      .timer 1 %Mod.Wiki.vTimer .msg $1 14 $+ $Mod.Wiki.aReplace($regml(1)) | inc %Mod.Wiki.vTimer | unset %Mod.Wiki.aStop
      if (%Mod.Wiki.vRead == $2) { sockclose Mod.Wiki.sHTTP | unset %Mod.Wiki.* | halt }
      inc %Mod.Wiki.vRead
    }
    sockread %Mod.Wiki.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht HTML Code in ASCII um:
; - $Mod.Wiki.aReplace(<Text>)
;*************************************************************************************************
alias -l Mod.Wiki.aReplace {
  if (($isid) && ($1-)) return $replace($1-, <b>, , </b>, , <strong>, , </strong>, , &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß, &#39;, ')
}

;*************************************************************************************************
; - Tauscht ASCII Zeichen gegen HTML Zeichen aus:
; - $Mod.Wiki.aURL(Text)
;*************************************************************************************************
alias -l Mod.Wiki.aURL if (($isid) && ($1-)) return $replace($1-, ü, $+($chr(37), C3%BC), ö, $+($chr(37), C3%B6), ä, $+($chr(37), C3%A4), ß, $+($chr(37), C3%9F), $chr(40), $+($chr(37), 28), $chr(41), $+($chr(37), 29), $chr(39), $+($chr(37), 27), /, $+($chr(37), 2F), ", $+($chr(37), 22), $chr(32), +, ?, $+($chr(37), 3F))

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
