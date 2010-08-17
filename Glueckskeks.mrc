;*************************************************************************************************
;*
;* Gl�ckskeks Addon v1.2 � by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest ein Gl�ckskeks spruch von www.glueckskeks.com aus und postet ihn.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !gl�ckskeks kannst du dir ein Zitat anzeigen lassen.
;* Mit !gl�ckskeks info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Changed: Der Trigger kann nun auch mit aktiviertem UTF8 mit � verwendet werden.
;*
;* v1.1
;*   Changed: Code ges�ubert und verbessert.
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
; - Trigger Befehl des Gl�ckskeks Addon.
;*************************************************************************************************
on $*:TEXT:/^!gl(�|ue|ü)ckskeks/i:#: {
  if ($2 == info) { .notice $nick 14Gl�ckskeks Addon v1.2 � by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Gl�ckskeks-Flood., #, ., $cid))) {
    .timerMod.Gl�ckskeks-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Gl�ckskeks.sHTTP
    sockopen Mod.Gl�ckskeks.sHTTP www.glueckskeks.com 80
    sockmark Mod.Gl�ckskeks.sHTTP #
  }
  else {
    if ($timer($+(Mod.Gl�ckskeks-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Gl�ckskeks-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Gl�ckskeks-vFlood., #, ., $cid, ., $nick) | .timerMod.Gl�ckskeks-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Gl�ckskeks-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Gl�ckskeks-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Gl�ckskeks-vFlood.*
  }
}

;*************************************************************************************************
; - �ffnet die Seite www.glueckskeks.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.Gl�ckskeks.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /start.php HTTP/1.1
  sockwrite -n $sockname Host: www.glueckskeks.com
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Gl�ckskeks Spruch aus und postet ihn.
;*************************************************************************************************
on *:SOCKREAD:Mod.Gl�ckskeks.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Gl�ckskeks.sRead
  while ($sockbr) {
    if ($regex(%Mod.Gl�ckskeks.sRead, /.*"(.*)"<br>/)) {
      .msg $1 09 $+ $replacecs($regml(1), &lt;, <, &gt;, >, &uuml;, �, &auml;, �, &ouml;, �, &quot;, ", &szlig;, �, &amp;, &, &ocirc;, �, &raquo;, �, &laquo;, �, &reg;, �, &deg;, �, &oacute;, �, &ograve;, �, &iquest;, �, &curren;, �, &nbsp;, $chr(32)) 
      sockclose Mod.Gl�ckskeks.sHTTP | unset %Mod.Gl�ckskeks.* | halt
    }
    sockread %Mod.Gl�ckskeks.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
