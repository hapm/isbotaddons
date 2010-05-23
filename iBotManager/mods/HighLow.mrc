;*************************************************************************************************
;*
;* HighLow Addon v1.1 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Ein kleines Zahlenratespiel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !hl startet man das Spiel.
;* Mit !hl <Zahl> rät man. (Das startet das Spiel, wenn's nicht gestartet ist)
;* Mit !hl stats [nick] bekommst du deine Stats bzw. die vom [nick] angezeigt.
;* Mit !hl speed bekommst du angezeigt wer am schnellsten die Zahl erraten hat.
;* Mit !hl slow bekommst du angezeigt wer am langsamsten die Zahl erraten hat.
;* Mit !hl info bekommst du das Copyright angezeigt.
;*
;* [Nur ab Halfop ausführbar]
;*  Mit !hl on aktiviert man das Spiel im Channel.
;*  Mit !hl off deaktiviert man das Spiel im Channel.
;*  Mit !hl stop beendest du das aktuell laufende Spiel.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
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
; - Lädt die Dateien wenn welche vorhanden.
;*************************************************************************************************
on *:LOAD:{
  if (($isdir($Mod.HL.aFile)) && ($findfile($Mod.HL.aFile, *.hsh, 0))) {
    var %a = $scon(0)
    while (%a) {
      scon %a
      var %b = $chan(0)
      while (%b) {
        if ($ini($Mod.HL.aFile($scon(%a).network), $chan(%b))) {
          hmake Mod.HL.hData. $+ $+($chan(%b), ., $scon(%a).network) 10000
          hload -i Mod.HL.hData. $+ $+($chan(%b), ., $scon(%a).network) $Mod.HL.aFile($scon(%a).network) $chan(%b)
        }
        dec %b
      }
      dec %a
    }
  }
}

;*************************************************************************************************
; - Entfernt und Stopt alles beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  .timerMod.HL* off | hfree -w Mod.HL.hData.*
  if ($isdir($Mod.HL.aFile)) {
    if ($findfile($Mod.HL.aFile, *.hsh, 0)) {
      noop $input(Soll die Dateien im Ordner HighLow gelöscht werden?, yv, Dateien Löschen?)
      if ($! == $yes) { noop $findfile($Mod.HL.aFile, *.hsh, 0, .remove $1-) | .rmdir $Mod.HL.aFile }
    }
    else .rmdir $Mod.HL.aFile
  }
}

;*************************************************************************************************
; - Lädt die Ignore Datei beim mIRC Start.
;*************************************************************************************************
on *:START:{
  if (($isfile($Mod.HL.aFile(Ignore))) && ($lines($Mod.HL.aFile(Ignore)) != 0)) {
    if ($hget(Mod.HL.hIgnore)) hfree $ifmatch
    hmake Mod.HL.hIgnore 1000
    hload Mod.HL.hIgnore $Mod.HL.aFile(Ignore)
  }
}

;*************************************************************************************************
; - Trigger Befehle vom HighLow Addon.
;*************************************************************************************************
on *:TEXT:!hl*:#:{
  if ($2 == info) { .notice $nick 14HighLow Addon v1.1 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if ($2 == on) {
    if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
      if (($hget(Mod.HL.hIgnore, #)) && ($ifmatch == $network)) {
        hdel Mod.HL.hIgnore # | hsave Mod.HL.hIgnore $Mod.HL.aFile(Ignore)
        .notice $nick 09HighLow14 ist jetzt im Channel09 # 14aktiviert!
      }
      else .notice $nick 09HighLow14 ist schon im Channel09 # 14aktiviert!
    }
    else .notice $nick 14Du hast keine09 Rechte 14dafür!
    halt
  }
  if ($2 == off) {
    if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
      if (!$hget(Mod.HL.hIgnore, #)) {
        Mod.HL.aStop # $network $nick | hadd -m Mod.HL.hIgnore # $network | hsave Mod.HL.hIgnore $Mod.HL.aFile(Ignore)
        .notice $nick 09HighLow14 ist jetzt im Channel09 # 14deaktiviert!
      }
      else .notice $nick 09HighLow14 ist schon im Channel09 # 14deaktiviert!
    }
    else .notice $nick 14Du hast keine09 Rechte 14dafür!
    halt
  }
  if (!$hget(Mod.HL.hIgnore, #)) {
    if ($2 == stop) {
      if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
        if ($hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.RUN)) {
          .timerMod.HL.* off
          .msg # 14Das aktuelle09 HighLow 14Spiel wurde von09 $nick 14beendet. Das Spiel lief09 $duration($round($calc(($ticks - $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.TICKS)) / 1000), 0)) 14lang.
          hdel -w Mod.HL.hData. $+ $+(#, ., $network) Mod.*
        }
        else .notice $nick 14Aktuell 09leuft14 kein Spiel!
      }
      else .notice $nick 14Du hast keine09 Rechte 14dafür!
      halt
    }
    if ($2 == stats) {
      if ($3) {
        .msg # 09 $+ $3 14hat an09 $iif($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $3), 2, 32), $ifmatch, 0) 14von09 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), GESAMT), $ifmatch, 0) 14Spielen mit gemacht. Dabei hat09 $3 $iif($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $3), 1, 32), $ifmatch, 0) 14gewonnen! $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEEDNICK) == $3, Aktuell hält09 $3 14den09 Speed Rekord 14mit09 $duration($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED))) $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOWNICK) == $3, $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED), 14und den09 Lam0r Rekord14 mit09 $duration($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW)), 14Aktuell hält09 $3 14den09 Lam0r Rekord14 mit09 $duration($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW))))  
        halt
      }
      else {
        .msg # 09Du14 hast bei09 $iif($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $nick), 2, 32), $ifmatch, 0) 14von09 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), GESAMT), $ifmatch, 0) 14Spielen mitgemacht. Dabei hast du09 $iif($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $nick), 1, 32), $ifmatch, 0) 14gewonnen! $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEEDNICK) == $nick, Aktuell hälst du den09 Speed Rekord 14mit09 $duration($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED))) $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOWNICK) == $nick, $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED), 14und den09 Lam0r Rekord14 mit09 $duration($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW)), 14Aktuell hälst du den09 Lam0r Rekord14 mit09 $duration($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW))))  
        halt
      }
    }
    if ($2 == speed) {
      .msg # 14Aktuell hält09 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEEDNICK), $ifmatch, keiner) 14den 09Speed Rekord14 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED), mit09 $duration($ifmatch)) 
      halt
    }
    if ($2 == slow) {
      .msg # 14Aktuell hält09 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOWNICK), $ifmatch, keiner) 14den 09Lam0r Rekord14 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW), mit09 $duration($ifmatch)) 
      halt
    }
    if (!$2) { if (!$hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.RUN)) { Mod.HL.aStart | halt } }
    if ($2 isnum 1-300) {
      if (!$timer($+(Mod.HL., $cid, ., #, ., $nick))) {
        if ($hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.RUN)) Mod.HL.aCheck $2
        else { Mod.HL.aStart | Mod.HL.aCheck $2 }
      }
      else .notice $nick 14Du darfst erst in09 $timer($+(Mod.HL., $cid, ., #, ., $nick)).secs 14Sek. wieder!
    }
    else .notice $nick 14Du musst eine09 Zahl 14zwischen 09114 und 0930014 angeben!
  }
}

;*************************************************************************************************
; - Lädt die Daten vom Channel beim joinen.
;*************************************************************************************************
on *:JOIN:#:{
  .timerMod.HLO.Part. $+ $+(#, ., $network) off
  if (!$hget(Mod.HL.hData. $+ $+(#, ., $network))) .timerMod.HLO.Join. $+ $+(#, ., $network) 1 5 Mod.HL.aLoad # $network
}

;*************************************************************************************************
; - Entlädt die Daten beim parten des Channels.
;*************************************************************************************************
on *:PART:#:{
  .timerMod.HLO.Join. $+ $+(#, ., $network) off
  if ($hget(Mod.HL.hData. $+ $+(#, ., $network))) .timerMod.HLO.Part. $+ $+(#, ., $network) 1 10 .hfree Mod.HL.hData. $+ $+(#, ., $network)
}

;*************************************************************************************************
; - Entlädt die Daten beim diconnecten des Channels.
;*************************************************************************************************
on *:DISCONNECT: hfree -w Mod.HL.hData.*. $+ $network

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Lädt die Dateien für den Channel:
; - Mod.HL.aLoad $chan $network
;*************************************************************************************************
alias -l Mod.HL.aLoad {
  var %a = $ini($Mod.HL.aFile($2), 0)
  while (%a) {
    if ($ini($Mod.HL.aFile($2), %a) == $1) {
      hmake Mod.HL.hData. $+ $+($1, ., $2) 10000
      hload -i Mod.HL.hData. $+ $+($1, ., $2) $Mod.HL.aFile($2) $1
    }
    dec %a
  }
}

;*************************************************************************************************
; - Startet das Spiel:
; - Mod.HL.aStart
;*************************************************************************************************
alias -l Mod.HL.aStart {
  hadd -m Mod.HL.hData. $+ $+(#, ., $network) Mod.RUN $true
  hadd -m Mod.HL.hData. $+ $+(#, ., $network) Mod.NUM $rand(1, 300)
  hadd -m Mod.HL.hData. $+ $+(#, ., $network) Mod.TICKS $ticks
  hinc -m Mod.HL.hData. $+ $+(#, ., $network) GESAMT 1
  hsave -i Mod.HL.hData. $+ $+(#, ., $network) $Mod.HL.aFile($network) #
  .msg # 14Das 09HighLow14 Spiel ist jetzt gestartetet! Wähle eine Zahl Zwischen 09114 und 0930014 aus!
  .timerMod.HL.Play 1 1200 Mod.HL.aStop # $network
}

;*************************************************************************************************
; - Beendet das Spiel, wenn keiner mehr Spielt:
; - Mod.HL.aStop $chan $network
;*************************************************************************************************
alias -l Mod.HL.aStop {
  .timerMod.HL.* off
  .msg $1 14Das09 HighLow 14Spiel wurde jetzt beendet, weil $iif($3, 09 $+ $3 14es ausgeschaltet hat und keiner mehr spielt) $+ ! Die gesuchte Zahl war:09 $hget(Mod.HL.hData. $+ $+($1, ., $2), Mod.NUM) 14- Dauer:09 $duration($round($calc(($ticks - $hget(Mod.HL.hData. $+ $+($1, ., $2), Mod.TICKS)) / 1000), 0)) 14- Versuche:09 $iif($hget(Mod.HL.hData. $+ $+($1, ., $2), Mod.VERSUCHE), $ifmatch, 0) 
  hdel -w Mod.HL.hData. $+ $+($1, ., $2) Mod.*
  hsave -i Mod.HL.hData. $+ $+($1, ., $2) $Mod.HL.aFile($2) $1
}

;*************************************************************************************************
; - Prüft ob die Zahl höher/kleine ist oder ob die richtige erraten wurde. Verwaltet die Stats:
; - Mod.HL.aCheck <Zahl>
;*************************************************************************************************
alias -l Mod.HL.aCheck {
  .timerMod.HL.Play 1 1200 Mod.HL.aStop # $network
  hinc -m Mod.HL.hData. $+ $+(#, ., $network) Mod.VERSUCHE 1
  if ((!$hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.IGNORE)) || ($nick $+ , !isin $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.IGNORE))) {
    hadd -m Mod.HL.hData. $+ $+(#, ., $network) $nick $iif($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $nick), 1, 32), $ifmatch, 0) $calc($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $nick), 2, 32) + 1)
    hadd -m Mod.HL.hData. $+ $+(#, ., $network) Mod.IGNORE $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.IGNORE), $ifmatch) $nick $+ ,
  }
  if (!$hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.NUMS)) hadd -m Mod.HL.hData. $+ $+(#, ., $network) Mod.NUMS $+($chr(44), $1, $chr(44))
  else {
    if ($+($chr(44), $1, $chr(44)) isin $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.NUMS)) {
      .timerMod.HL. $+ $+($cid, ., #, ., $nick) 1 60 .notice $nick 14Du darfst jetzt 09weiter14 Spielen!
      .msg # 14Die Zahl09 $1 14wurde schon gennant! - Die gesuchte Zahl ist $iif($1 < $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.NUM), größer, kleiner) als09 $1 
      halt
    }
    else hadd -m Mod.HL.hData. $+ $+(#, ., $network) Mod.NUMS $+($hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.NUMS), $1, $chr(44))
  }
  if ($1 == $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.NUM)) {
    .timerMod.HL.* off
    var %ticks = $round($calc(($ticks - $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.TICKS)) / 1000), 0)
    .msg # 14Wir haben einen Gewinner! Herzlichen Glückwunsch09 $nick 14- Dauer:09 $duration(%ticks) 14- Versuche:09 $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.VERSUCHE), $ifmatch, 0) 
    if ((%ticks < $hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED)) || (!$hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED))) {
      .msg # 09 $+ $nick 14hat $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEEDNICK) == $nick, seinen eigenen09 Speed Rekord14 gebrochen!, einen neuen09 Speed Rekord 14gesetzt!)
      hadd -m Mod.HL.hData. $+ $+(#, ., $network) SPEED %ticks | hadd -m Mod.HL.hData. $+ $+(#, ., $network) SPEEDNICK $nick
    }
    elseif ($hget(Mod.HL.hData. $+ $+(#, ., $network), SPEED)) {
      if ((%ticks > $hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW)) || (!$hget(Mod.HL.hData. $+ $+(#, ., $network), SLOW))) {
        .msg # 09 $+ $nick 14hat $iif($hget(Mod.HL.hData. $+ $+(#, ., $network), SLOWNICK) == $nick, seinen eigenen09 Lam0r Rekord14 gebrochen!, einen neuen 09Lam0r Rekord14 gesetzt!)
        hadd -m Mod.HL.hData. $+ $+(#, ., $network) SLOW %ticks | hadd -m Mod.HL.hData. $+ $+(#, ., $network) SLOWNICK $nick
      }
    }
    hadd -m Mod.HL.hData. $+ $+(#, ., $network) $nick $calc($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $nick), 1, 32) + 1) $iif($gettok($hget(Mod.HL.hData. $+ $+(#, ., $network), $nick), 2, 32), $ifmatch, 0)
    hdel -w Mod.HL.hData. $+ $+(#, ., $network) Mod.* | hsave -i Mod.HL.hData. $+ $+(#, ., $network) $Mod.HL.aFile($network) # | halt
  }
  elseif ($1 < $hget(Mod.HL.hData. $+ $+(#, ., $network), Mod.NUM)) .msg # 14Die gesuchte 09Zahl14 ist größer als09 $1 
  else .msg # 14Die gesuchte 09Zahl14 ist kleiner als09 $1 
  .timerMod.HL. $+ $+($cid, ., #, ., $nick) 1 60 .notice $nick 14Du darfst jetzt 09weiter14 Spielen!
}

;*************************************************************************************************
; - Gibt den Pfad zu den Dateien wieder:
; - $Mod.HL.aFile
;*************************************************************************************************
alias -l Mod.HL.aFile {
  if (!$isdir(System)) mkdir System
  if (!$isdir(System\HighLow)) mkdir System\HighLow
  if ($1) return $+(", $mircdirSystem\HighLow\, $1, .hsh, ")
  else return $+(", $mircdirSystem\HighLow\, ")
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
