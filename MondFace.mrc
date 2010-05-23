;*************************************************************************************************
;*
;* MondFace Addon v1.4 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* MondFace ist ein kleines Spiel für den mIRC Bot. Das Script reagiert drauf wenn einer einen
;* Punkt, Komma oder Strich schreibt.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;*
;* Ein Punkt für das erste Auge, ein zweiter Punkt für das zweite Auge. ein Komma für die Nase und
;* ein Strich für den Mund.
;* Mit !mondface all siehst du die erzeugten MondFaces die in dem Channel erstellt wurden.
;* Mit !mondface stat siehst man an wie vielen MondFaces man mitgewirkt hat.
;* Mit !mondface stat nick sieht man an wie vielen MondFaces der Nick mitgewirkt hat.
;* Mir !mondface info wird der Copyright angezeigt.
;* Mit !mondface help bekommst du Hilfe.
;* 
;* [Geht nur ab Halfop Status]
;* Mit !mondface reset kann man das Spiel von vorne anfangen lassen.
;* Mit !mondface on schaltet man das Spiel aktiviert.
;* Mit !mondface off schaltet man das Spiel deaktiviert.
;* Mit !mondface list siehst du wo das Spiel deaktivert  ist.
;* Mit !mondface level sieht man wie weit der MondFace Level ist.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.3
;*   Fixed: Wenn Leerzeichen im Pfad gabs probleme mit den Dateien.
;*
;* v1.2
;*   Fixed: Die Daten wurden nicht richtig geladen.
;*   Added: Support für ! und * Statuse.
;*
;* v1.1
;*   Fixed: Beim Addon Laden kam Meldung das Dateien im Ordner sind obwohl leer ist.
;*   Added: Flood Protection ... 1 min zwischen den Gesichtsteilen ... 2 min nach erstellung des Gesichtes.
;*   Added: Trigger !mf ... nun kann man !mondface oder !mf nehmen.
;*   Added: Wenn User schon was gesetzt hat bekommt er Notice.
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
; - Lädt die Dateien beim laden des Addons.
;*************************************************************************************************
on *:LOAD: if (($exists($Mod.MondFace.aFile)) && ($findfile($Mod.MondFace.aFile, *.hsh, 0))) noop $findfile($Mod.MondFace.aFile, *.hsh, 0, Mod.MondFace.aLoad $1-)

;*************************************************************************************************
; - Entfernt die Dateien beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($findfile($Mod.MondFace.aFile, *.hsh, 0)) {
    noop $input(Soll die Dateien im Ordner MondFace gelöscht werden?, yv, Dateien Löschen?)
    if ($! == $yes) {
      noop $findfile($Mod.MondFace.aFile, *.*, 0, .remove $1-) | noop $finddir($Mod.MondFace.aFile, *Serv*, 0, .rmdir $1-)
      noop $finddir($Mod.MondFace.aFile, *, 0, .rmdir $1-) | .rmdir $Mod.MondFace.aFile
    }
  }
  if ($hget(Mod.MondFace.hData)) hfree Mod.MondFace.hData
  .timerMod.MondFace.tFlood* off
}

;*************************************************************************************************
; - Lädt alle Hash files die sich im Ordner MondFace befinden.
;*************************************************************************************************
on *:START: if ($exists($Mod.MondFace.aFile)) noop $findfile($Mod.MondFace.aFile, *.hsh, 0, Mod.MondFace.aLoad $1-)

;*************************************************************************************************
; - Reagiert auf die !mondface Befehle, Punkte, Komma und Strich.
;*************************************************************************************************
on *:TEXT:*:#:{
  if (!$hfind($+(Mod.MondFace.h, $network, .Ignore), #)) {
    if ($nick $+ , !isin $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), NICKS) $+ ,) {
      if ($1 == $chr(46)) {
        if (!$hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL)) {
          if (!$timer(Mod.MondFace.tFlood $+ $+(., $network, ., #))) {
            hadd -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) NICKS $nick
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) LEVEL 1
            hsave $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) $Mod.MondFace.aFile(1, $network, $remove(#, $chr(35)))
            .timerMod.MondFace.tFlood $+ $+(., $network, ., #) 1 60 return
            .msg # 14Oha was ist das? Ein 09Punkt14? Na das kann ja was werden 08^^
          }
          else .notice $nick 04Flood-Protect:14 Versuchs in09 $replace($duration($timer(Mod.MondFace.tFlood $+ $+(., $network, ., #)).secs), mins, $chr(32) $+ Minuten, min, $chr(32) $+ Minute, secs, $chr(32) $+ Sekunden, sec, $chr(32) $+ Sekunde) 14noch einmal!
        }
        elseif ($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL) == 1) {
          if (!$timer(Mod.MondFace.tFlood $+ $+(., $network, ., #))) {
            hadd -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) NICKS $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), NICKS) $+ , $nick
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) LEVEL 1
            hsave $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) $Mod.MondFace.aFile(1, $network, $remove(#, $chr(35)))
            .timerMod.MondFace.tFlood $+ $+(., $network, ., #) 1 60 return
            .msg # 14Ahhhh, noch ein 09Punkt14!!! Ihr legt es wohl drauf an!!!
          }
          else .notice $nick 04Flood-Protect:14 Versuchs in09 $replace($duration($timer(Mod.MondFace.tFlood $+ $+(., $network, ., #)).secs), mins, $chr(32) $+ Minuten, min, $chr(32) $+ Minute, secs, $chr(32) $+ Sekunden, sec, $chr(32) $+ Sekunde) 14noch einmal!
        }
      }
      if ($1 == $chr(44)) {
        if ($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL) == 2) {
          if (!$timer(Mod.MondFace.tFlood $+ $+(., $network, ., #))) {
            hadd -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) NICKS $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), NICKS) $+ , $nick
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) LEVEL 1
            hsave $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) $Mod.MondFace.aFile(1, $network, $remove(#, $chr(35)))
            .timerMod.MondFace.tFlood $+ $+(., $network, ., #) 1 60 return
            .msg # 14Also, jetzt seit ihr aber 09wirklich14 nah dran!!!
          }
          else .notice $nick 04Flood-Protect:14 Versuchs in09 $replace($duration($timer(Mod.MondFace.tFlood $+ $+(., $network, ., #)).secs), mins, $chr(32) $+ Minuten, min, $chr(32) $+ Minute, secs, $chr(32) $+ Sekunden, sec, $chr(32) $+ Sekunde) 14noch einmal!
        }
      }
      if ($1 == $chr(45)) {
        if ($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL) == 3) {
          if (!$timer(Mod.MondFace.tFlood $+ $+(., $network, ., #))) {
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) ALL 1
            hdel $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) LEVEL
            .msg # 09Punkt14,09 Punkt14,09 Komma14,09 Strich14, fertig ist das 09Mondgesicht14! Mondgesicht Nr.09 $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), ALL) 14erstellt von09 $replace($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), NICKS), $chr(44), 14 $+ $chr(44) $+ 09) 14und09 $nick 
            var %nick = $remove($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), NICKS), $chr(44)), %nick1 = $gettok(%nick, 1, 32), %nick2 = $gettok(%nick, 2, 32), %nick3 = $gettok(%nick, 3, 32)
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) %nick1 1
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) %nick2 1
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) %nick3 1
            hinc -m $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) $nick 1
            hdel $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) NICKS
            hsave $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) $Mod.MondFace.aFile(1, $network, $remove(#, $chr(35)))
            .timerMod.MondFace.tFlood $+ $+(., $network, ., #) 1 120 return
          }
          else .notice $nick 04Flood-Protect:14 Versuchs in09 $replace($duration($timer(Mod.MondFace.tFlood $+ $+(., $network, ., #)).secs), mins, $chr(32) $+ Minuten, min, $chr(32) $+ Minute, secs, $chr(32) $+ Sekunden, sec, $chr(32) $+ Sekunde) 14noch einmal!
        }
      }
    }
    else {
      if (($1 == $chr(45)) || ($1 == $chr(46)) || ($1 == $chr(44))) {
        var %pos = $findtok($replace($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), NICKS), $chr(44) $+ $chr(32), $chr(46)), $nick, 1, 46)
        if (%pos isin 1, 2) var %pos = ein09 Auge
        else var %pos = eine09 Nase
        .notice $nick 14Du hast schon %pos 14gesetzt!
      }
    }
  }
  if (($1 == !mondface) || ($1 == !mf)) {
    if ($2) {
      if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
        if (!$hfind(Mod.MondFace.hIgnore, #)) {
          if ($2 == reset) {
            hdel $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) NICKS
            hdel $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) LEVEL
            hsave $+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))) $Mod.MondFace.aFile(1, $network, $remove(#, $chr(35)))
            .timerMod.MondFace.tFlood $+ $+(., $network, ., #) off | .notice $nick 14Aktuelle fortschritt des 09MondFaces14 wurde gelöscht. 
          }
          if ($2 == level) {
            if ($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL) == 1) .notice $nick 14Es muss noch das09 zweite 14Auge gesetzt werden.
            elseif ($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL) == 2) .notice $nick 14Es muss noch die09 Nase 14gesetzt werden.
            elseif ($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), LEVEL) == 3) .notice $nick 14Es muss noch der09 Mund 14gesetzt werden.
            else .notice $nick 14Es muss noch das09 erste 14Auge gesetzt werden.
          }
        }
        if ($2 == on) {
          if ($hfind($+(Mod.MondFace.h, $network, .Ignore), #)) {
            hdel $+(Mod.MondFace.h, $network, .Ignore) #
            hsave $+(Mod.MondFace.h, $network, .Ignore) $Mod.MondFace.aFile(1, $network, Ignore)
            .notice $nick 09MondFace14 ist nun im Channel09 # 14aktiviert.
          }
          else .notice $nick 09MondFace14 ist schon im Channel09 # 14aktiviert.
        }
        if ($2 == off) {
          if ($hfind($+(Mod.MondFace.h, $network, .Ignore), #)) .notice $nick 09MondFace14 ist schon im Channel09 # 14deaktiviert.
          else {
            hadd -m $+(Mod.MondFace.h, $network, .Ignore) #
            hsave $+(Mod.MondFace.h, $network, .Ignore) $Mod.MondFace.aFile(1, $network, Ignore)
            .notice $nick 09MondFace14 ist nun im Channel09 # 14deaktiviert.
          }
        }
        if ($2 == list) {
          if ($hget($+(Mod.MondFace.h, $network, .Ignore), 0).item != 0) {
            var %a = $hget($+(Mod.MondFace.h, $network, .Ignore), 0).item, %i = 1
            while (%i <= %a) {
              var %Mod.MondFace.vIgnoreChans = %Mod.MondFace.vIgnoreChans $hget($+(Mod.MondFace.h, $network, .Ignore), %i).item
              if (%a == %i) .notice $nick 14Folgende 09Chans14 sind in meiner MondFace Ignoreliste:09 %Mod.MondFace.vIgnoreChans 
              inc %i 1
            }
            halt
          }
          else { .notice $nick 14Es stehen keine 09Chans14 in meiner Ignoreliste. | halt }
        }
      }
      if (!$hfind($+(Mod.MondFace.h, $network, .Ignore), #)) {
        if ($2 == info) .notice $nick 14MondFace Addon v1.4 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14)
        if ($2 == help) {
          notice $nick 14Punkte stehen für 09Augen14, Komma für 09Nase14 und Strich für den 09Mund14. Mit09 !mondface all 14kannst du sehen wie viele MondFace im Channel erstellt worden sind. Mit09 !mondface stat 14bekommst du deine MondFace stats angezeigt und mit09 !mondface stat <NICK> 14siehst du die MondFace Stats von09 <NICK>
          if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) .notice $nick 14Mit09 !mondface <ON/OFF> 14schaltest du MondFace im Channel aus oder an und mit09 !mondface list 14siehst du wo das Spiel aus ist. Mit09 !monface reset 14kannst du den Aktuellen Spielstand zurücksetzen. Mit09 !mondface level 14siehst du wie weit der MondFace level ist.
        }
        if ($2 == all) .msg # 14In diesem Channel wurden $iif($hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), ALL), schon09 $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), ALL), noch09 keine) 14Mondgesichter erstellt.
        if ($2 == stat) {
          if ($3) {
            if ($hfind($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), $3)) .msg # 09 $+ $3 14hat in09 # 14an09 $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), $3) 14von09 $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), ALL) 14Mondgesichter mitgewirkt.
            else .msg # 09 $+ $3 14hat noch an keinem 09Mondgesicht14 mitgewirkt.
          }
          else {
            if ($hfind($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), $nick)) .msg # 09Du14 hast in09 # 14an09 $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), $nick) 14von09 $hget($+(Mod.MondFace.h, $network, ., $remove(#, $chr(35))), ALL) 14Mondgesichter mitgewirkt.
            else .msg # 09Du14 hast noch an keinem 09Mondgesicht14 mitgewirkt.
          }
        }
      }
    }
    else {
      .notice $nick 14Punkte stehen für 09Augen14, Komma für 09Nase14 und Strich für den 09Mund14. Mit09 !mondface all 14kannst du sehen wie viele MondFace im Channel erstellt worden sind. Mit09 !mondface stat 14bekommst du deine MondFace stats angezeigt und mit09 !mondface stat <NICK> 14siehst du die MondFace Stats von09 <NICK>
      if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) .notice $nick 14Mit09 !mondface <ON/OFF> 14schaltest du MondFace im Channel aus oder an und mit09 !mondface list 14siehst du wo das Spiel aus ist. Mit09 !monface reset 14kannst du den Aktuellen Spielstand zurücksetzen. Mit09 !mondface level 14siehst du wie weit der MondFace level ist.
    }
  }
}
;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         ALIASES Start
;*************************************************************************************************
; - Path wiedergabe:
; - $Mod.MondFace.aFile(1, $network, $chan) gibt den Path zu den Hash files wieder.
;*************************************************************************************************
alias Mod.MondFace.aFile {
  if (!$isdir(System)) mkdir System
  if (!$isdir(System\MondFace)) mkdir System\MondFace
  if ($1 == 1) {
    if (!$isdir($+(Serv, $2))) mkdir System\MondFace\ $+ $+(Serv, $2)
    return $+(", $mircdirSystem\MondFace\, Serv, $2, \, $3, .hsh, ")
  }
  else return $+(", $mircdirSystem\MondFace\, ")
}

;*************************************************************************************************
; - Lädt die im Ordner enthaltene Hash Files:
; - Mod.MondFace.aLoad
;*************************************************************************************************
alias Mod.MondFace.aLoad {
  if ($1-) {
    var %1 = $right($gettok($1-, -2, 92), $calc($len($gettok($1-, -2, 92)) - 4)), %2 = $remove($gettok($1-, -1, 92), .hsh)
    if ($hget($+(Mod.MondFace.h, %1, ., %2))) hfree $+(Mod.MondFace.h, %1, ., %2)
    hmake $+(Mod.MondFace.h, %1, ., %2) 10000
    hload $+(Mod.MondFace.h, %1, ., %2) $1-
  }
}

;*************************************************************************************************
;*                                         ALIASES Ende
;*************************************************************************************************
