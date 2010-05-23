;*************************************************************************************************
;*
;* KFZ Addon v1.0 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Gibt dir Informationen welche KFZ Zeichen welche Region bzw. Land hat.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !kfz <NR> bekommst die die <NR> KFZ angezeigt.
;* Mit !kfz <ZEICHEN> bekommst du die Informationen angezeigt.
;* Mit !kfz <KREIS/LAND> bekommst du die Informationen angezeigt.
;* Mit !kfz info siehst du die Copyright.
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
; - Lädt Hash Table beim Laden des Addons.
;*************************************************************************************************
on *:LOAD: Mod.KFZ.aLoad

;*************************************************************************************************
; - Löscht Hash Table beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($isfile($Mod.KFZ.aFile)) {
    noop $input(Soll die KFZ.hsh gelöscht werden?, qy, Löschen)
    if ($!) .remove -b $Mod.KFZ.aFile
  }
  if ($hget(Mod.KFZ.hData)) hfree $ifmatch
  unset %Mod.KFZ.*
  .timerMod.KFZ* off
}

;*************************************************************************************************
; - Lädt Hash Table beim Starten.
;*************************************************************************************************
on *:START: Mod.KFZ.aLoad

;*************************************************************************************************
; - Trigger Befehle des KFZ Addons.
;*************************************************************************************************
on *:TEXT:!kfz*:#:{
  if ($2 == info) { .notice $nick 14KFZ Addon v1.0 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.KFZ-Flood., #, ., $cid))) {
    if ($2) {
      if ($hget(Mod.KFZ.hData)) {
        if ($2 isnum) {
          if ($hget(Mod.KFZ.hData, $2)) { .timerMod.KFZ-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 14-=( KFZ Nr.09 $2 14)=-=(14 Kennzeichen:09 $gettok($ifmatch, 1, 9) 00-14 Kreis:09 $gettok($ifmatch, 2, 9) 00-14 Land:09 $iif($gettok($ifmatch, 3, 9), $ifmatch, -) 14)=- }
          else .notice $nick 14Du hast eine  falsche09 Zahl 14angegeben! Wähle eine Zahl zwischen 09114 und 09559
        }
        else {
          if ($len($2) isnum 1-3) {
            if ($hfind(Mod.KFZ.hData, $+($2, $chr(9), *), 1, w).data) {
              var %data = $hget(Mod.KFZ.hData, $ifmatch) | .timerMod.KFZ-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 14-=( KFZ Nr.09 $ifmatch 14)=-=(14 Kennzeichen:09 $gettok(%data, 1, 9) 00-14 Kreis:09 $gettok(%data, 2, 9) 00-14 Land:09 $iif($gettok(%data, 3, 9), $ifmatch, -) 14)=-
            }
          }
          else {
            if ($hfind(Mod.KFZ.hData, $+(*, $chr(9), *, $2, *, $chr(9), *), 0, w).data > 1) {
              var %a = $ifmatch
              while (%a) {
                var %hfind = $hfind(Mod.KFZ.hData, $+(*, $chr(9), *, $2-, *, $chr(9), *), %a, w).data, %data = %data %hfind 14(08 $+ $gettok($hget(Mod.KFZ.hData, %hfind), 2, 9) $+ 14) $iif(%a != 1, 00-09)
                dec %a
              }
              .msg # 14Ergebnisse (08!kfz <Nummer>14):09 %data 
            }
            else {
              if (!$ifmatch) .msg # 14Es wurden leider keine Ergebnisse für09 $2 14gefunden.
              else { var %data = $hget(Mod.KFZ.hData, $hfind(Mod.KFZ.hData, $+(*, $chr(9), *, $2-, *, $chr(9), *), 1, w).data) | .timerMod.KFZ-Flood. $+ $+(#, ., $cid) 1 40 halt | .msg # 14-=( KFZ Nr.09 $hfind(Mod.KFZ.hData, %data).data 14)=-=(14 Kennzeichen:09 $gettok(%data, 1, 9) 00-14 Kreis:09 $gettok(%data, 2, 9) 00-14 Land:09 $iif($gettok(%data, 3, 9), $ifmatch, -) 14)=- }
            }
          }
        }
      }
      else { .notice $nick 14Die Datenbank ist09 leer14! Bitte versuche es später noch einmal. | Mod.KFZ.aLoad }
    }
    else .notice $nick 14Du hast nix angegeben! Syntax:09 !kfz <1-559>14,09 !kfz <Kennzeichen>14 oder09 !kfz <Kreis> 14Beispiel:09 !kfz 15 14,09 !kfz COE 14oder09 !kfz Coesfeld
  }
  else {
    if ($timer($+(Mod.KFZ-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.KFZ-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.KFZ-vFlood., #, ., $cid, ., $nick) | .timerMod.KFZ-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.KFZ-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.KFZ-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.KFZ-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.eVolutionX-Project.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.KFZ.sHTTP:{
  if ($sockerr > 0) halt
  sockwrite -n $sockname GET /dl/KFZ.hsh HTTP/1.1
  sockwrite -n $sockname Host: www.eVolutionX-Project.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Lädt KFZ.hsh herunter.
;*************************************************************************************************
on *:SOCKREAD:Mod.KFZ.sHTTP:{
  if ($sockerr > 0) halt
  if (%Mod.KFZ.vRead != 1) sockread %Mod.KFZ.sRead
  else sockread &Mod.KFZ.sRead
  while ($sockbr) {
    if ((%Mod.KFZ.sRead == $null) && ($sockbr > 0) && (%Mod.KFZ.vRead != 1)) set -u10 %Mod.KFZ.vRead 1
    elseif ((%Mod.KFZ.vRead) && ($sockbr > 0)) bwrite $Mod.KFZ.aFile -1 -1 &Mod.KFZ.sRead
    if (%Mod.KFZ.vRead != 1) sockread %Mod.KFZ.sRead
    else sockread &Mod.KFZ.sRead
  }
}

;*************************************************************************************************
; - Entfernt Variables und lädt Hash Table.
;*************************************************************************************************
on *:SOCKCLOSE:Mod.KFZ.sHTTP:{
  if ($hget(Mod.KFZ.hData)) hfree $ifmatch
  hmake Mod.KFZ.hData 559 | hload Mod.KFZ.hData $Mod.KFZ.aFile
  unset %Mod.KFZ.* | bunset &Mod.KFZ.sRead
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad der KFZ.hsh Datei wieder:
; - $Mod.KFZ.aFile
;*************************************************************************************************
alias -l Mod.KFZ.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem\KFZ.hsh, ")
}

;*************************************************************************************************
; - Lädt Hash Table:
; - /Mod.KFZ.aLoad
;*************************************************************************************************
alias -l Mod.KFZ.aLoad {
  if ($isfile($Mod.KFZ.aFile)) {
    if ($hget(Mod.KFZ.hData)) hfree $ifmatch
    hmake Mod.KFZ.hData 559 | hload Mod.KFZ.hData $Mod.KFZ.aFile
  }
  else Mod.KFZ.aDownLoad
}

;*************************************************************************************************
; - Lädt KFZ.hsh herunter:
; - /Mod.KFZ.aDownLoad
;*************************************************************************************************
alias -l Mod.KFZ.aDownLoad { if (!$sock(Mod.KFZ.sHTTP)) { if ($isfile($Mod.KFZ.aFile)) .remove -b $Mod.KFZ.aFile | sockopen Mod.KFZ.sHTTP www.eVolutionX-Project.de 80 } }

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
