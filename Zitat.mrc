;*************************************************************************************************
;*
;* Zitat Addon v1.4 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest ein Zitat von www.natune.net aus und postet sie.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !zitat kannst du dir ein Zitat anzeigen lassen.
;* Mit !zitat info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Fixed: Es wurden keine Zitate mehr gepostet.
;*
;* v1.3
;*   Added: Flood-Protection.
;*   Changed: Link geändert.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Fixed: Der Zitat wurde manchmal nicht gepostet. 
;*
;* v1.1
;*   Changed: Neue Link wo Zitate ausgelesen werden, alte Link ist off gegangen.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.SpeedSpace-IRC.eu
;* Port: 6667
;* Channel: #eVolutionX
;*
;* Befehl: /server -m irc.SpeedSpace-IRC.eu -j #eVolutionX
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Zitat* off | unset %Mod.Zitat* }

;*************************************************************************************************
; - Trigger Befehl des Zitat Addon.
;*************************************************************************************************
on *:TEXT:!zitat*:#:{
  if ($2 == info) { .notice $nick 14Zitat Addon v1.3 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if (!$timer($+(Mod.Zitat-Flood., #, ., $cid))) {
    .timerMod.Zitat-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Zitat.sHTTP
    sockopen Mod.Zitat.sHTTP natune.net 80
    sockmark Mod.Zitat.sHTTP #
  }
  else {
    if ($timer($+(Mod.Zitat-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Zitat-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Zitat-vFlood., #, ., $cid, ., $nick) | .timerMod.Zitat-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Zitat-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Zitat-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Zitat-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.natune.net
;*************************************************************************************************
on *:SOCKOPEN:Mod.Zitat.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /zitate/Zufalls5 HTTP/1.1
  sockwrite -n $sockname Host: natune.net
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Zitat aus und postet es.
;*************************************************************************************************
on *:SOCKREAD:Mod.Zitat.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Zitat.sRead
  while ($sockbr) {
    if ($regex(%Mod.Zitat.sRead, /.*<nobr><a href="zitate/autor/.*" title="Zitate von .*" target="_blank">(.*)</a>.*/)) set -u10 %Mod.Zitat.vAutor $regml(1)
    if ($regex(%Mod.Zitat.sRead, /.*<td valign="top" style="padding-bottom: 25px;" class="zitat">(.*)</td>/)) {
      .msg $1 $+(14, %Mod.Zitat.vAutor, 14:09) $replace($regml(1), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß)
      sockclose Mod.Zitat.sHTTP | unset %Mod.Zitat* | halt
    }
    sockread %Mod.Zitat.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
