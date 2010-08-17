;*************************************************************************************************
;*
;* Glückskeks Addon v1.2 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest ein Glückskeks spruch von www.glueckskeks.com aus und postet ihn.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !glückskeks kannst du dir ein Zitat anzeigen lassen.
;* Mit !glückskeks info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Changed: Der Trigger kann nun auch mit aktiviertem UTF8 mit ü verwendet werden.
;*
;* v1.1
;*   Changed: Code gesäubert und verbessert.
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
; - Trigger Befehl des Glückskeks Addon.
;*************************************************************************************************
on $*:TEXT:/^!gl(ü|ue|Ã¼)ckskeks/i:#: {
  if ($2 == info) { .notice $nick 14Glückskeks Addon v1.2 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Glückskeks-Flood., #, ., $cid))) {
    .timerMod.Glückskeks-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Glückskeks.sHTTP
    sockopen Mod.Glückskeks.sHTTP www.glueckskeks.com 80
    sockmark Mod.Glückskeks.sHTTP #
  }
  else {
    if ($timer($+(Mod.Glückskeks-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Glückskeks-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Glückskeks-vFlood., #, ., $cid, ., $nick) | .timerMod.Glückskeks-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Glückskeks-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Glückskeks-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Glückskeks-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.glueckskeks.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.Glückskeks.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /start.php HTTP/1.1
  sockwrite -n $sockname Host: www.glueckskeks.com
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Glückskeks Spruch aus und postet ihn.
;*************************************************************************************************
on *:SOCKREAD:Mod.Glückskeks.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Glückskeks.sRead
  while ($sockbr) {
    if ($regex(%Mod.Glückskeks.sRead, /.*"(.*)"<br>/)) {
      .msg $1 09 $+ $replacecs($regml(1), &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32)) 
      sockclose Mod.Glückskeks.sHTTP | unset %Mod.Glückskeks.* | halt
    }
    sockread %Mod.Glückskeks.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
