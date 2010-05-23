;*************************************************************************************************
;*
;* Xrel Addon v1.1 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht nach Releases zum Suchbegriff bei www.xrel.to
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !xrel <Suchbegriff> startest du die Suche.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
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
on *:UNLOAD:{ .timerMod.Xrel* off | unset %Mod.Xrel* }

;*************************************************************************************************
; - Trigger Befehl des Xrel Addons.
;*************************************************************************************************
on *:TEXT:!xrel*:#:{
  if (!$timer($+(Mod.Xrel-Flood., #, ., $cid))) {
    if ($2-) {
      .timerMod.Xrel-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Xrel.sHTTP
      sockopen Mod.Xrel.sHTTP www.xrel.to 80
      sockmark Mod.Xrel.sHTTP # 3 $replace($strip($2-), $chr(32), +) $2-
      set -u10 %Mod.Xrel.vRead 1
    }
    else .notice $nick 14Du hast vergessen einen 09Suchbegriff14 anzugeben!
  }
  else {
    if ($timer($+(Mod.Xrel-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Xrel-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Xrel-vFlood., #, ., $cid, ., $nick) | .timerMod.Xrel-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Xrel-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Xrel-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Xrel-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.xrel.to
;*************************************************************************************************
on *:SOCKOPEN:Mod.Xrel.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $+(/index.php?inc=8.1&search=, $3, &=Suchen...) HTTP/1.1
  sockwrite -n $sockname Host: www.xrel.to
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.Xrel.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Xrel.sRead
  while ($sockbr) {
    if (*<center>Keine Releases unter angegebenen Kriterien verfügbar!</center>* iswm %Mod.Xrel.sRead) {
      .msg $1 14Keine Releases für09 $4- 14verfügrbar! | sockclose Mod.Xrel.sHTTP | unset %Mod.Xrel.* | halt
    }
    if ($regex(%Mod.Xrel.sRead, /<td width="47"><font class="sub" style="color:black;">(.*)</font>.*/)) set -u10 %Mod.Xrel.vDate $regml(1)
    if ($regex(%Mod.Xrel.sRead, /.*<font class="sub"><font class="sub">(.*)</font></font>.*/)) set -u10 %Mod.Xrel.vTime $regml(1)
    if ($regex(%Mod.Xrel.sRead, /.*<a href="/index.php.*inc=2.1&id=.*">(.*)</a>.*/)) set -u10 %Mod.Xrel.vName $regml(1)
    if ($regex(%Mod.Xrel.sRead, /<td width="90"><font class="sub">(.*)</font></td>/)) {
      if ($gettok($regml(1), 1, 32) == $regml(1)) set -u10 %Mod.Xrel.vSound $ifmatch
    }
    if ($regex(%Mod.Xrel.sRead, /.*<a href="/index.php.*inc=3.6&kind=.*">(.*)</a>.*/)) set -u10 %Mod.Xrel.vArt $regml(1)
    if ($regex(%Mod.Xrel.sRead, /.*<a href="/index.php.*inc=3.5&group=.*">(.*)</a>.*/)) set -u10 %Mod.Xrel.vGroup $regml(1)
    if ($regex(%Mod.Xrel.sRead, /<td width="360"><font class="sub">(.*)</font></td>/)) set -u10 %Mod.Xrel.vDatei $regml(1)
    if ($regex(%Mod.Xrel.sRead, /<td width="90"><font class="sub">(.*) (.*)</font></td>/)) set -u10 %Mod.Xrel.vDVD $regml(1) $regml(2)
    if ($regex(%Mod.Xrel.sRead, /<a href="/index.php.*inc=7.1.1&id=.*"><font class="sub">Kommentare (.*)</font></a>/)) {
      var %Mod.Xrel.vKommentar = $remove($regml(1), $chr(40), $chr(41))
      .timer 1 %Mod.Xrel.vRead .msg $1 14-=( Datum:09 %Mod.Xrel.vDate %Mod.Xrel.vTime 00•14 Beschr.:09 %Mod.Xrel.vName 00•14 Dateiname:09 %Mod.Xrel.vDatei 00•14 Format:09 %Mod.Xrel.vArt 00•14 Sound:09 %Mod.Xrel.vSound 00•14 Group:09 %Mod.Xrel.vGroup 00•14 Kommentare:09 %Mod.Xrel.vKommentar 14)=-
      if (%Mod.Xrel.vRead == $2) { sockclose Mod.Xrel.sHTTP | unset %Mod.Xrel.* | halt }
      inc %Mod.Xrel.vRead
    }
    sockread %Mod.Xrel.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
