;*************************************************************************************************
;*
;* Witz Addon v1.3 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest ein Witz von www.dein-witz.de aus und postet ihn.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !witz kannst du dir ein Witz anzeigen lassen.
;* Mit !witz info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.3
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Fixed: Der Witz wurde nicht richtig geteilt, wenn er zu lang war.
;*
;* v1.1
;*   Fixed: Wenn Witz zu lang war wurde nicht alles gepostet.
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
on *:UNLOAD:{ .timerMod.Witz* off | unset %Mod.Witz* }

;*************************************************************************************************
; - Trigger Befehl des Witz Addons.
;*************************************************************************************************
on *:TEXT:!witz*:#:{
  if ($2 == info) { .notice $nick 14Witz Addon v1.3 © by 09www.IrcShark.de14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Witz-Flood., #, ., $cid))) {
    .timerMod.Witz-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Witz.sHTTP
    sockopen Mod.Witz.sHTTP www.dein-witz.de 80
    sockmark Mod.Witz.sHTTP #
  }
  else {
    if ($timer($+(Mod.Witz-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Witz-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Witz-vFlood., #, ., $cid, ., $nick) | .timerMod.Witz-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Witz-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Witz-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Witz-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.dein-witz.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Witz.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /index.php?nav=zufall HTTP/1.1
  sockwrite -n $sockname Host: www.dein-witz.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Witz aus und postet ihn.
;*************************************************************************************************
on *:SOCKREAD:Mod.Witz.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Witz.sRead
  while ($sockbr) {
    if ($regex(%Mod.Witz.sRead, /<tr><td class="witz_text">(.*)</td></tr>/)) {
      if ($len($regml(1)) >= 425) {
        var %count = $round($calc($count($regml(1), $chr(32)) / 2), 0)
        .msg $1 09 $+ $Mod.Witz.aReplace($gettok($regml(1), 1- $+ %count, 32)) 
        .msg $1 09 $+ $Mod.Witz.aReplace($gettok($regml(1), $calc(%count + 1) $+ -, 32)) 
      }
      else .msg $1 09 $+ $Mod.Witz.aReplace($regml(1)) 
      sockclose Mod.Witz.sHTTP | unset %Mod.Witz.* | halt
    }
    sockread %Mod.Witz.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Replaced die UTF-8 Sachen:
; - $Mod.Witz.aReplace(<Text>)
;*************************************************************************************************
alias -l Mod.Witz.aReplace {
  if (($isid) && ($1-)) { return $replace($1-, &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß, &#39;, ') }
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
