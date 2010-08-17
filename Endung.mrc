;*************************************************************************************************
;*
;* Endung Addon v1.2 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet Informationen über eine Dateiendung in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !endung <Dateiendung> zeigt dir Informationen über die Dateiendung.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Fixed: Auf neues Format der Seite angepasst.
;*
;* v1.1
;*   Added: Flood-Protection.
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
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Endung* off | unset %Mod.Endung* }

;*************************************************************************************************
; - Trigger Befehl des Endung Addons.
;*************************************************************************************************
on *:TEXT:!endung*:#:{
  if (!$timer($+(Mod.Endung-Flood., #, ., $cid))) {
    if ($2) {
      .timerMod.Endung-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Endung.sHTTP
      sockopen Mod.Endung.sHTTP www.endungen.de 80
      sockmark Mod.Endung.sHTTP # 3 $2
      set -u10 %Mod.Endung.vRead 1
    }
    else .notice $nick 14Du hast vergessen eine09 Endung 14anzugeben!
  }
  else {
    if ($timer($+(Mod.Endung-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Endung-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Endung-vFlood., #, ., $cid, ., $nick) | .timerMod.Endung-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Endung-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Endung-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Endung-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.endungen.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Endung.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /ResultList/ResultList.aspx?searchExtension= $+ $3 $+ &searchDescription=&searchProgram=&searchPlatform=win;mac;unix;os2&searchMode=contains&showAmazon=false HTTP/1.1
  sockwrite -n $sockname Host: www.endungen.de
  sockwrite -n $sockname Connection: close
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Daten aus und postet sie.
;*************************************************************************************************
on *:SOCKREAD:Mod.Endung.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Endung.sRead
  while ($sockbr) {
    if ($regex(%Mod.Endung.sRead, /<span id=.*>Es .* (.*) Treffer gefunden.*</span>.*/)) {
      .timer 1 0 .msg $1 14Es $iif($regml(1) == 1, wurde, wurden) $+ 09 $replace($regml(1), kein, keine) 14Treffer für die Endung09 $3 14auf09 www.endungen.de 14gefunden.
      if ($regml(1) == kein) { sockclose Mod.Endung.sHTTP | unset %Mod.Endung.* | halt }
    }
    if (*<img border='0' src='./../Images/logowin.gif' />* iswm %Mod.Endung.sRead) set -u10 %Mod.Endung.vOS $iif(%Mod.Endung.vOS, 09Windows14 -09 $ifmatch, 09Windows 14)
    if (*<img border='0' src='./../Images/logomacos.gif' />* iswm %Mod.Endung.sRead) set -u10 %Mod.Endung.vOS $iif(%Mod.Endung.vOS, 09Apple14 -09 $ifmatch, 09Apple 14)
    if (*<img border='0' src='./../Images/logolinux.gif' />* iswm %Mod.Endung.sRead) set -u10 %Mod.Endung.vOS $iif(%Mod.Endung.vOS, 09Linux14 -09 $ifmatch, 09Linux 14)
    if (*<img border='0' src='./../Images/logoos2.gif' />* iswm %Mod.Endung.sRead) set -u10 %Mod.Endung.vOS $iif(%Mod.Endung.vOS, 09OS214 -09 $ifmatch, 09OS2 14)
    if ($regex(%Mod.Endung.sRead, /<td width="55"><font color="#006600">([^<]*)</font></td><td><font color="#006600">([^<]*)</font></td><td><font color="#006600"><a href='[^']*' target='_blank'>([^<]*)</a></font></td><td><font color="#006600"><a href='/)) {
      .timer 1 %Mod.Endung.vRead .msg $1 08 $+ %Mod.Endung.vRead $+ . 14Endung:09 $regml(1) 00•14 Beschreibung:09 $regml(2) 00•14 Programm:09 $regml(3) 00•14 Plattform:09 %Mod.Endung.vOS 
      if (%Mod.Endung.vRead == $2) { sockclose Mod.Endung.sHTTP | unset %Mod.Endung.* | halt }
      unset %Mod.Endung.vOS | inc %Mod.Endung.vRead
    }
    sockread %Mod.Endung.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
