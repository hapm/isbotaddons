;*************************************************************************************************
;*
;* Chuck Norris Addon v1.2 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet ein Chuck Norris Zitat in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !chuck kannst du ein Chuck Norris Zitat wiedergeben lassen.
;* Mit !chuck info siehst du den Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*   Changed: Es wird nun per Zufall ein Zitat ausgelesen.
;*
;* v1.1
;*   Fixed: Wenn Zitat zu lang wurde er nicht bis zum Ende gepostet.
;*   Fixed: Wenn leerzeichen im Pfad ging Addon nicht richtig.
;*   Fixed: Beim entladen wurde die variable '%Mod.Chuck.vLine' nicht entfernt.
;*   Fixed: Am anfang wurde der erste Zitat 2x gepostet und der letzte Zitat wurde ausgelassen.
;*   Added: Wenn Chuck.txt nicht vorhanden, wird die ausm Internet geladen.
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
; - Lädt die Chuck.txt wenn nicht existiert.
;*************************************************************************************************
on *:LOAD: Mod.Chuck.aLoad

;*************************************************************************************************
; - Entfernt die Chuck.txt beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($isfile($Mod.Chuck.aFile)) {
    noop $input(Soll die Datei Chuck.txt gelöscht werden?, yv, Datei Löschen?)
    if ($! == $yes) .remove -b $Mod.Chuck.aFile
  }
  .timerMod.Chuck* off | unset %Mod.Chuck*
}

;*************************************************************************************************
; - Prüft beim Starten ob die Chuck.txt vorhanden ist, wenn nicht lädt er sie.
;*************************************************************************************************
on *:START: Mod.Chuck.aLoad

;*************************************************************************************************
; - Trigger Befehl des Chuck Norris Addon.
;*************************************************************************************************
on *:TEXT:!chuck*:#:{
  if ($2 == info) { .notice $nick 14Chuck Norris Addon v1.2 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if (!$timer($+(Mod.Chuck-Flood., #, ., $cid))) {
    if (($isfile($Mod.Chuck.aFile)) && ($lines($Mod.Chuck.aFile))) {
      .timerMod.Chuck-Flood. $+ $+(#, ., $cid) 1 40 halt | var %Mod.Chuck.vText = $read($Mod.Chuck.aFile)
      if ($len(%Mod.Chuck.vText) > 400) {
        var %Mod.Chuck.vCount = $calc($count(%Mod.Chuck.vText, $chr(32)) / 2)
        .msg # 09 $+ $gettok(%Mod.Chuck.vText, 1- $+ %Mod.Chuck.vCount, 32) 
        .msg # 09 $+ $gettok(%Mod.Chuck.vText, $calc(%Mod.Chuck.vCount + 1) $+ -, 32)
      }
      else .msg # 09 $+ %Mod.Chuck.vText 
    }
    else { .msg # 14Es stehen keine 09Einträge14 in meiner Datenbank. Bitte versuche es später noch einmal. | Mod.Chuck.aLoad }
  }
  else {
    if ($timer($+(Mod.Chuck-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Chuck-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Chuck-vFlood., #, ., $cid, ., $nick) | .timerMod.Chuck-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Chuck-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Chuck-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Chuck-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.eVolutionX-Project.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Chuck.sHTTP:{
  if ($sockerr > 0) halt
  sockwrite -n $sockname GET /dl/Chuck.txt HTTP/1.1
  sockwrite -n $sockname Host: www.eVolutionX-Project.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Schreibt die Chuck.txt
;*************************************************************************************************
on *:SOCKREAD:Mod.Chuck.sHTTP:{
  if ($sockerr > 0) halt
  sockread %Mod.Chuck-sRead
  while ($sockbr) {
    if (%Mod.Chuck-sRead == >-EOF-<) { sockclose Mod.Chuck.sHTTP | unset %Mod.Chuck-* | halt }
    if ((%Mod.Chuck-sRead == $null) && ($sockbr > 0) && (!%Mod.Chuck-vRead)) set -u50 %Mod.Chuck-vRead 1
    elseif ((%Mod.Chuck-vRead) && (%Mod.Chuck-sRead != $null) && ($sockbr > 0)) {
      if (%Mod.Chuck-vRead == 1) { write -cn $Mod.Chuck.aFile %Mod.Chuck-sRead | inc %Mod.Chuck-vRead }
      else write -n $Mod.Chuck.aFile $crlf $+ %Mod.Chuck-sRead
    }
    sockread %Mod.Chuck-sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad zur Datei wieder:
; - $Mod.Chuck.aFile
;*************************************************************************************************
alias Mod.Chuck.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem\Chuck.txt, ")
}

;*************************************************************************************************
; - Lädt Chuck.txt runter:
; - /Mod.Chuck.aLoad
;*************************************************************************************************
alias -l Mod.Chuck.aLoad { if ((!$isfile($Mod.Chuck.aFile)) && (!$sock(Mod.Chuck.sHTTP))) sockopen Mod.Chuck.sHTTP www.eVolutionX-Project.de 80 }

;*************************************************************************************************
;*                                         ALIASES Ende
;*************************************************************************************************
