;*************************************************************************************************
;*
;* HartWeich Addon v1.4 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sagt einen Harmlosen oder einen Harten Spruch zu einem User.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !weich <NICK> sagst du einen Weichei-Spruch.
;* Mit !weich info bekommst du den Copyright angezeigt.
;* Mit !hart <NICK> sagst du einen Harten Spruch.
;* Mit !hart info bekommst du den Copyright angeziegt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Fixed: Die Flood Variable wurde nicht beim entladen gelöscht.
;*
;* v1.3
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Changed: Wenn man kein Nick angibt dann spricht man sich selber an.
;*   Fixed: Die Befehl-Beschreibung war nicht richtig.
;*   Fixed: Es gab probleme wenn ein leerzeichen im Pfad war.
;*   Fixed: Bei Addon Unload kam keine abfrage ob man die txt Datein löschen möchte.
;*   Added: Wenn man Addon ladet und die Hart.txt und Weich.txt nicht vorhanden sind, so werden sie ausm Internet geladen.
;*
;* v1.1
;*   Fixed: Es wurde nicht geprüft ob User im Channel ist.
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
; - Ladet die Hart.txt und Weich.txt beim Laden des Addons.
;*************************************************************************************************
on *:LOAD: Mod.HartWeich.aLoad

;*************************************************************************************************
; - Entfernt Weich.txt und Hart.txt beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if (($isfile($Mod.HartWeich.aFile(1))) || ($isfile($Mod.HartWeich.aFile(2)))) {
    noop $input(Soll die Dateien Hart.txt & Weich.txt gelöscht werden?, yv, Datei Löschen?)
    if ($! == $yes) { .remove -b $Mod.HartWeich.aFile(1) | .remove -b $Mod.HartWeich.aFile(2) }
  }
  unset %Mod.HartWeich*
  .timerMod.HartWeich* off
}

;*************************************************************************************************
; - Prüft beim Starten ob die txt Dateien vorhanden sind, wenn nicht lädt er sie.
;*************************************************************************************************
on *:START: Mod.HartWeich.aLoad

;*************************************************************************************************
; - Trigger Befehl des HartWeich Addon.
;*************************************************************************************************
on *:TEXT:!*:#:{
  if (!$timer($+(Mod.HartWeich-Flood., #, ., $cid))) {
    if ($1 == !weich) {
      if ($2 == info) { .notice $nick 14HartWeich Addon v1.3 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
      if ($isfile($Mod.HartWeich.aFile(2))) {
        if (($2) && ($2 != $nick)) {
          if ($2 ison #) { .timerMod.HartWeich-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 09 $+ $nick 14sagt zu09 $2 $+ 14:09 $read($Mod.HartWeich.aFile(2))  }
          else .notice $nick 14Der User09 $2 14ist nicht im Channel!
        }
        else { .timerMod.HartWeich-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 09 $+ $nick 14sagt zu sich selber:09 $read($Mod.HartWeich.aFile(2))  }
      }
      else { .notice $nick 14Es stehen keine 09Einträge14 in meiner Datenbank. Bitte versuch es später noch einmal. | Mod.HartWeich.aLoad }
    }
    if ($1 == !hart) {
      if ($2 == info) { .notice $nick 14HartWeich Addon v1.3 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
      if ($isfile($Mod.HartWeich.aFile(1))) {
        if (($2) && ($2 != $nick)) {
          if ($2 ison #) { .timerMod.HartWeich-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 09 $+ $nick 14sagt zu09 $2 $+ 14:09 $read($Mod.HartWeich.aFile(1))  }
          else .notice $nick 14Der User09 $2 14ist nicht im Channel!
        }
        else { .timerMod.HartWeich-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 09 $+ $nick 14sagt zu sich selber:09 $read($Mod.HartWeich.aFile(1))  }
      }
      else { .notice $nick 14Es stehen keine 09Einträge14 in meiner Datenbank. Bitte versuch es später noch einmal. | Mod.HartWeich.aLoad }
    }
  }
  else {
    if ($timer($+(Mod.HartWeich-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.HartWeich-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.HartWeich-vFlood., #, ., $cid, ., $nick) | .timerMod.HartWeich-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.HartWeich-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.HartWeich-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.HartWeich-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.eVolutionX-Project.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.HartWeich.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) halt
  sockwrite -n $sockname GET /dl/ $+ $1 HTTP/1.1
  sockwrite -n $sockname Host: www.eVolutionX-Project.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Schreibt Hart.txt und Weich.txt
;*************************************************************************************************
on *:SOCKREAD:Mod.HartWeich.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) halt
  sockread %Mod.HartWeich.sRead
  while ($sockbr) {
    if (%Mod.HartWeich.sRead == >-EOF-<) { sockclose Mod.HartWeich.sHTTP | unset %Mod.HartWeich.* | Mod.HartWeich.aLoad | halt }
    if ((%Mod.HartWeich.sRead == $null) && ($sockbr > 0)) set -u10 %Mod.HartWeich.vRead 1
    if ((%Mod.HartWeich.vRead) && ($1 == Hart.txt)) {
      if ((%Mod.HartWeich.sRead != $null) && ($sockbr > 0)) {
        if (%Mod.HartWeich.vRead == 1) { write -cn $Mod.HartWeich.aFile(1) %Mod.HartWeich.sRead | inc %Mod.HartWeich.vRead }
        else write -n $Mod.HartWeich.aFile(1) $crlf $+ %Mod.HartWeich.sRead
      }
    }
    if ((%Mod.HartWeich.vRead) && ($1 == Weich.txt)) {
      if ((%Mod.HartWeich.sRead != $null) && ($sockbr > 0)) {
        if (%Mod.HartWeich.vRead == 1) { write -cn $Mod.HartWeich.aFile(2) %Mod.HartWeich.sRead | inc %Mod.HartWeich.vRead }
        else write -n $Mod.HartWeich.aFile(2) $crlf $+ %Mod.HartWeich.sRead
      }
    }
    sockread %Mod.HartWeich.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad zur Datei wieder:
; - $Mod.HartWeich.aFile
;*************************************************************************************************
alias -l Mod.HartWeich.aFile {
  if (!$isdir(System)) mkdir System
  if ($1 == 1) return $+(", $mircdirSystem\Hart.txt, ")
  elseif ($1 == 2) return $+(", $mircdirSystem\Weich.txt, ")
}

;*************************************************************************************************
; - Lädt die Hart.txt oder/und Weich.txt runter:
; - Mod.HartWeich.aLoad
;*************************************************************************************************
alias -l Mod.HartWeich.aLoad {
  if (!$isfile($Mod.HartWeich.aFile(1))) var %datei Hart.txt
  elseif (!$isfile($Mod.HartWeich.aFile(2))) var %datei Weich.txt
  if ((!$sock(Mod.HartWeich.sHTTP)) && (%datei)) {
    sockopen Mod.HartWeich.sHTTP www.eVolutionX-Project.de 80
    sockmark Mod.HartWeich.sHTTP %datei
  }
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
