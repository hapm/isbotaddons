;*************************************************************************************************
;*
;* SMS Addon v1.2 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest einen SMS spruch von www.sms3.de aus und postet ihn.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !sms kannst du dir ein SMS Spruch anzeigen lassen.
;* Mit !sms info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert
;*
;* v1.1
;*   Fixed: Sms Sprüche wurden nicht mehr gepostet.
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
on *:UNLOAD:{ .timerMod.Sms* off | unset %Mod.Sms* }

;*************************************************************************************************
; - Trigger Befehl des SMS Addons.
;*************************************************************************************************
on *:TEXT:!sms*:#:{
  if ($2 == info) { .notice $nick 14SMS Addon v1.2 © by 09www.IrcShark.de14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Sms-Flood., #, ., $cid))) {
    .timerMod.Sms-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Sms.sHTTP
    sockopen Mod.Sms.sHTTP www.kranklachen.at 80
    sockmark Mod.Sms.sHTTP #
  }
  else {
    if ($timer($+(Mod.Sms-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Sms-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Sms-vFlood., #, ., $cid, ., $nick) | .timerMod.Sms-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Sms-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Sms-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Sms-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.sms3.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Sms.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /SmsSprueche/ HTTP/1.1
  sockwrite -n $sockname Host: www.kranklachen.at
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest ein Spruch aus und postet ihn.
;*************************************************************************************************
on *:SOCKREAD:Mod.Sms.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Sms.sRead
  while ($sockbr) {
    if ($regex(%Mod.Sms.sRead, /</table><br><span class="text">(.*)</span><br><br>.*</td>/)) {
      .msg $1 09 $+ $replace($regml(1), <br>, $chr(32)) | sockclose Mod.Sms.sHTTP | unset %Mod.Sms.* | halt
    }
    sockread %Mod.Sms.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
