;*************************************************************************************************
;*
;* Lag Addon v1.2 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Zeigt verschiedene Informationen über den Lag des mIRC Bots.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !lag siehst du alle Informationen über den Lag des Bots.
;* Mit !lag info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.1
;*   Changed: Die CTCP Meldung im Statusfenster wird nun nicht mehr angezeigt.
;*   Fixed: Der Durchschnitt wurde falsch gespeichert sowie berechnet.
;*   Fixed: Wenn leerzeichen im Pfad, dann gabs probleme mit der Datei.
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
; - Lädt die Datei beim laden des Addons.
;*************************************************************************************************
on *:LOAD:{
  if ($isfile($Mod.Lag.aFile)) {
    if ($hget(Mod.Lag.hData)) hfree Mod.Lag.hData
    hmake Mod.Lag.hData
    hload Mod.Lag.hData $Mod.Lag.aFile
  }
}

;*************************************************************************************************
; - Entfernt die Datei beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($isfile($Mod.Lag.aFile)) {
    noop $input(Soll die Datei Lag.hsh gelöscht werden?, yv, Datei Löschen?)
    if ($! == $yes) .remove -b $Mod.Lag.aFile
  }
  if ($hget(Mod.Lag.hData)) hfree Mod.Lag.hData
}

;*************************************************************************************************
; - Lädt die Lag liste.
;*************************************************************************************************
on *:START:{
  if ($exists($Mod.Lag.aFile)) {
    if ($hget(Mod.Lag.hData)) hfree Mod.Lag.hData
    hmake Mod.Lag.hData
    hload Mod.Lag.hData $Mod.Lag.aFile 50
  }
}

;*************************************************************************************************
; - Trigger für Lag Addons.
;*************************************************************************************************
on *:TEXT:!lag*:#:{
  if ($2 == info) { .notice $nick 14Lag Addon v1.2 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if (!$timer($+(Mod.Lag-Flood., #, ., $cid))) { .timerMod.Lag-Flood. $+ $+(#, ., $cid) 1 40 halt | .ctcp $me Mod.Lag.cLag $ticks # }
  else {
    if ($timer($+(Mod.Lag-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Lag-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Lag-vFlood., #, ., $cid, ., $nick) | .timerMod.Lag-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Lag-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Lag-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Lag-vFlood.*
  }
}

;*************************************************************************************************
; - Bearbeitet die Informationen und Postet sie dan.
;*************************************************************************************************
ctcp ^*:Mod.Lag.cLag:?:{
  haltdef
  if ($nick == $me) {
    var %lag = $calc($ticks - $2)
    if (!$hget(Mod.Lag.hData, MAX)) hadd -m Mod.Lag.hData MAX 1
    if (!$hget(Mod.Lag.hData, MIN)) hadd -m Mod.Lag.hData MIN 99999999
    if (%lag > $hget(Mod.Lag.hData, MAX)) hadd -m Mod.Lag.hData MAX %lag
    if (%lag < $hget(Mod.Lag.hData, MIN)) hadd -m Mod.Lag.hData MIN %lag
    hinc -m Mod.Lag.hData GESAMT %lag | hinc -m Mod.Lag.hData START 1
    var %durchs = $round($calc($hget(Mod.Lag.hData, GESAMT) / $hget(Mod.Lag.hData, START)), 0)
    .msg $3 14-=( Lag-09O14-Meter )=-=( Max.:09 $hget(Mod.Lag.hData, MAX) $+ ms 00•14 Min.:09 $hget(Mod.Lag.hData, MIN) $+ ms 00•14 Aktuell:09 %lag $+ ms 00•14 Durchschnitt:09 %durchs $+ ms 14)=-
    hsave Mod.Lag.hData $Mod.Lag.aFile
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad zur Datei wieder:
; - $Mod.Lag.aFile
;*************************************************************************************************
alias -l Mod.Lag.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem\Lag.hsh, ")
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
