;*************************************************************************************************
;*
;* Orakel Addon v1.2 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Antwortet auf die gestellten Fragen, die Fragen werden aus einer txt Datei zufällig ausgelesen.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !orakel <FRAGE> kannst du das Orakel antworten lassen.
;* Mit !orakel info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.1
;*   Fixed: Gab probleme wenn leerzeichen im Pfad.
;*   Added: Wenn Orakel.txt nicht vorhanden ist, wird es ausm Internet geladen.
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
; - Lädt die Orakel.txt beim laden des Addons.
;*************************************************************************************************
on *:LOAD: Mod.Orakel.aLoad

;*************************************************************************************************
; - Entfernt die Orakel.txt beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($isfile($Mod.Orakel.aFile)) {
    noop $input(Soll die Datei Orakel.txt gelöscht werden?, yv, Datei Löschen?)
    if ($! == $yes) .remove -b $Mod.Orakel.aFile
  }
  unset %Mod.Orakel.*
  .timerMod.Orakel* off
}

;*************************************************************************************************
; - Prüft beim Starten ob die Orakel.txt vorhanden ist, wenn nicht lädt er sie.
;*************************************************************************************************
on *:START: Mod.Orakel.aLoad

;*************************************************************************************************
; - Trigger Befehl des Orakel Addon.
;*************************************************************************************************
on *:TEXT:!orakel*:#:{
  if ($2 == info) { .notice $nick 14Orakel Addon v1.2 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if (!$timer($+(Mod.Orakel-Flood., #, ., $cid))) {
    if ($2-) {
      if ($isfile($Mod.Orakel.aFile)) { .timerMod.Orakel-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 14Das 09Orakel14 sagt:04 $read($Mod.Orakel.aFile) }
      else { .msg # 14Es stehen keine 09Einträge14 in meiner Datenbank. Bitte versuch es später noch einmal. | Mod.Orakel.aLoad }
    }
    else .notice $nick 14Du hast vergessen deine 09Frage14 zu stellen!
  }
  else {
    if ($timer($+(Mod.Orakel-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Orakel-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Orakel-vFlood., #, ., $cid, ., $nick) | .timerMod.Orakel-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Orakel-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Orakel-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Orakel-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.eVolutionX-Project.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Orakel.sHTTP:{
  if ($sockerr > 0) halt
  sockwrite -n $sockname GET /dl/Orakel.txt HTTP/1.1
  sockwrite -n $sockname Host: www.eVolutionX-Project.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Schreibt die Orakel.txt
;*************************************************************************************************
on *:SOCKREAD:Mod.Orakel.sHTTP:{
  if ($sockerr > 0) halt
  sockread %Mod.Orakel.sRead
  while ($sockbr) {
    if (%Mod.Orakel.sRead == >-EOF-<) { sockclose Mod.Orakel.sHTTP | unset %Mod.Orakel.* | halt }
    if ((%Mod.Orakel.sRead == $null) && ($sockbr > 0)) set %Mod.Orakel.vRead 1
    if (%Mod.Orakel.vRead) {
      if ((%Mod.Orakel.sRead != $null) && ($sockbr > 0)) {
        if (%Mod.Orakel.vRead == 1) { write -cn $Mod.Orakel.aFile %Mod.Orakel.sRead | inc %Mod.Orakel.vRead }
        else write -n $Mod.Orakel.aFile $crlf $+ %Mod.Orakel.sRead
      }
    }
    sockread %Mod.Orakel.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad der Datei wieder:
; - $Mod.Orakel.aFile
;*************************************************************************************************
alias -l Mod.Orakel.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem/Orakel.txt, ")
}

;*************************************************************************************************
; - Lädt Orakel.txt runter:
; - /Mod.Orakel.aLoad
;*************************************************************************************************
alias -l Mod.Orakel.aLoad { if ((!$isfile($Mod.Orakel.aFile)) && (!$sock(Mod.Orakel.sHTTP))) sockopen Mod.Orakel.sHTTP www.eVolutionX-Project.de 80 }

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
