;*************************************************************************************************
;*
;* TopTen Addon v1.1 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Mit dem TopTen Addon kannst du verschiedene Stats für deinen Channel abrufen. Es ist auch
;* möglich das ein User seine eigenen Stats abruft.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;*
;* !top10 <places/modes/words/letters/smilies/kicks/kicker/bans/baner/unbaner/actions/joins/quits/nickchanges/lines>
;* !top20 <places/modes/words/letters/smilies/kicks/kicker/bans/baner/unbaner/actions/joins/quits/nickchanges/lines>
;* !top10 info zeigt die Copyright an.
;* !stats für deine eigenen Stats.
;* !stats <Nick> für die Stats von dem <Nick>
;* 
;* [Geht nur ab Halfop]
;*   Mit !top10 ignore add <Nick> fügst du einen Nick in die Ignoreliste.
;*   Mit !top10 ignore del <Nick> löscht du einen Nick aus der Ignoreliste.
;*   Mit !top10 ignore del * löscht du die komplette User Ignoreliste.
;*   Mit !top10 ignore list chan siehst du alle Chans die in der Ignoreliste sind.
;*   Mit !top10 ignore list nick siehst du alle Nickss die in der Ignoreliste sind.
;*   Mit !top10 on schaltest du das TopTen Script im Channel an.
;*   Mit !top10 off schaltest du das TopTen Script im Channel aus.
;*   Mit !top10 clean <1-20> kannst du die Stats säubern.
;*   Mit !top10 backup erstellst du ein Backup der Stats.
;*   Mit !top10 backup load kannst du die Backups wiederherstellen.
;*   Mit !top10 reset stellst du alle Stats auf 0.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Fixed: Die Top10 Modes wurde nicht angezeigt.
;*
;*************************************************************************************************
;*                                         IRC Kontakt
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
; - Lädt die Stats.
;*************************************************************************************************
on *:LOAD:{
  if (($isdir($Mod.TopTen.aFile)) && ($findfile($Mod.TopTen.aFile, *.hsh, 0))) {
    var %a = $scon(0)
    while (%a) {
      scon %a | var %b = $chan(0)
      while (%b) { Mod.TopTen.aFindfile $network $chan(%b) | dec %b }
      Mod.TopTen.aIgnoreChans $network
      dec %a
    }
  }
}

;*************************************************************************************************
; - Entfernt die Stats.
;*************************************************************************************************
on *:Unload:{
  .timerMod.TopTen.* off | hfree -w Mod.TopTen.*
  if ($isdir($Mod.TopTen.aFile)) {
    if ($findfile($Mod.TopTen.aFile, *.hsh, 0)) {
      noop $input(Möchtest du alle Dateien die vom TopTen Addon erstellt worden sind löschen?, yv, Dateien Löschen?)
      if ($! == $yes) { noop $findfile($Mod.TopTen.aFile, *.hsh, 0, Mod.TopTen.aDelete $1-) | .timer 1 4 .rmdir $+(", $remove($Mod.TopTen.aFile, "), Ignore\") }
    }
    .timer 1 5 .rmdir $Mod.TopTen.aFile
  }
}

;*************************************************************************************************
; -Alle Befehle des Addons.
;*************************************************************************************************
on *:TEXT:*:#:{
  if ($1 == !stats) {
    if (!$Mod.TopTen.aIsIgnore($network, #)) { .notice $nick 09TopTen14 ist im Channel09 # 14deaktiviert. | halt }
    var %baner = $iif($hget($+(Mod.TopTen.hbaner., $network, ., #), %nick), $ifmatch, 0), %unbaner = $iif($hget($+(Mod.TopTen.hUnbaner., $network, ., #), %nick), $ifmatch, 0), %joins = $iif($hget($+(Mod.TopTen.hJoins., $network, ., #), %nick), $ifmatch, 0), %quits = $iif($hget($+(Mod.TopTen.hQuits., $network, ., #), %nick), $ifmatch, 0), %actions = $iif($hget($+(Mod.TopTen.hActions., $network, ., #), %nick), $ifmatch, 0)
    var %nick = $iif($2, $ifmatch, $nick), %places = $iif($hget($+(Mod.TopTen.hPlaces., $network, ., #), %nick), $ifmatch, 0), %words = $iif($hget($+(Mod.TopTen.hWords., $network, ., #), %nick), $ifmatch, 0), %letters = $iif($hget($+(Mod.TopTen.hLetters., $network, ., #), %nick), $ifmatch, 0), %lines = $iif($hget($+(Mod.TopTen.hLines., $network, ., #), %nick), $ifmatch, 0), %modes = $iif($hget($+(Mod.TopTen.hModes., $network, ., #), %nick), $ifmatch, 0), $&
      %smilies = $iif($hget($+(Mod.TopTen.hSmilies., $network, ., #), %nick), $ifmatch, 0), %kicks = $iif($hget($+(Mod.TopTen.hKicks., $network, ., #), %nick), $ifmatch, 0), %kicker = $iif($hget($+(Mod.TopTen.hKicker., $network, ., #), %nick), $ifmatch, 0), %bans = $iif($hget($+(Mod.TopTen.hBanns., $network, ., #), %nick), $ifmatch, 0), %nickchanges = $iif($hget($+(Mod.TopTen.hNickchanges., $network, ., #), %nick), $ifmatch, 0)
    .msg # 14-=( Stats für09 %nick 14)=-=( Places:09 %places 00-14 Words:09 %words 00-14 Letters:09 %letters 00-14 Lines:09 %lines 00-14 Smilies:09 %smilies 00-14 Kicked User:09 %kicker 00-14 Baned User:09 %baner 00-14 Gekickt:09 %kicks 00-14 Gebant:09 %bans 00-14 Unbaned:09 %unbaner 00-14 Joins:09 %joins 00-14 Quits:09 %quits 00-14 Nickchanges:09 %nickchanges 00-14 Actions:09 %actions 00-14 Modes:09 %modes 14)=-
  }
  if ($regex($1, /^(!top10|!top20)/)) {
    var %2 = $strip($2)
    if (%2) {
      if (%2 == info) .notice $nick 14TopTen Addon v1.1 © by 09www.IrcShark.de14 (09IrcShark Team14)
      elseif (%2 == nein) {
        var %timer = $iif($timer($+(Mod.TopTen.tClean, ., $network, ., #)), $+(Mod.TopTen.tClean, ., $network, ., #), $+(Mod.TopTen.tReset, ., $network, ., #)), %nick = $gettok($timer(%timer).com, 2, 32)
        if (($timer(%timer)) && ($nick == %nick)) {
          if (*Clean* iswm %timer) { .timer $+ %timer off | .notice %nick 14Die Säuberung wurde erfolgreich09 gestopt14! }
          elseif (*Backup* iswm %timer) { .timer $+ %timer off | .notice %nick 14Das laden der Backups wurde erfolgreich09 gestopt14! }
          else { .timer $+ %timer off | Mod.TopTen.aReset | .notice %nick 14Das Resetten wurde 09erfolgreich14 ausgeführt14! }
        }
      }
      elseif (%2 == ja) {
        var %timer = $iif($timer($+(Mod.TopTen.tBackup, ., $network, ., #)), $timer($ifmatch), $iif($timer($+(Mod.TopTen.tClean, ., $network, ., #)), $timer($ifmatch), $+(Mod.TopTen.tReset, ., $network, ., #))), %nick = $gettok($timer(%timer).com, 2, 32)
        if (($timer(%timer)) && ($nick == %nick)) {
          if (*Clean* iswm %timer) { .timer $+ %timer off | Mod.TopTen.aClean %Mod.TopTen.vClean %nick }
          elseif (*Backup* iswm %timer) { .timer $+ %timer off | Mop.TopTen.aBackupLoad %nick }
          else { .timer $+ %timer off | Mod.TopTen.aReset 1 | .notice %nick 14Backup wurde erstellt! - Die Stats wurden nun 09erfolgreich14 resettet. }
        }
      }
      elseif (%2 == reset) {
        .notice $nick 14Soll von den alten 09Stats14 ein Backup gemacht werden? Tipp 09!top10 ja14 oder 09!top10 nein14 dazu hast du 092014 Sek. Zeit!
        .timerMod.TopTen.tReset. $+ $+($network, ., #) 1 20 .notice $nick 14Du hast keine bestätigung abgegeben! Das 09Resetten14 wurde automatisch gestopt!
      }
      elseif (%2 == clean) {
        if ($3 isnum 1-20) {
          .notice $nick 14Bist du dir sicher das du alle User die gleich oder unter dem Wert09 $3 14sind zu löschen? Wenn ja dan tippe 09!top10 ja14 sonst09 !top10 nein 14du hast dazu 092014 Sek. Zeit!
          .timerMod.TopTen.tClean. $+ $+($network, ., #) 1 20 .notice $nick 14Du hast keine bestätigung abgegeben! Die 09Säuberung14 wurde automatisch gestopt! | set -u21 %Mod.TopTen.vClean $3
        }
        else .notice $nick 14Du musst eine Zahl zwischen 09114 und 092014 angeben!08 Syntax: !top10 clean <1-20>
      }
      elseif (%2 == backup) {
        if ($3 == load) {
          .notice $nick 14Sollen die aktuellen Stats durch das zuvor erstellte Backup 09ersetzt14 werden? Wenn ja dan tippe 09!top10 ja14 sonst09 !top10 nein14 Du hast dazu 092014 Sek. Zeit!
          .timerMod.TopTen.tBackup. $+ $+($network, ., #) 1 20 .notice $nick 14Du hast keine bestätigung abgegeben! Das 09wiederherstellen14 des Backups wurde automatisch gestopt!
        }
        else { Mod.TopTen.aBackup | .notice $nick 14Ein Backup von den Stats wurde 09erfolgreich14 erstellt. }
      }
      elseif (%2 == on) {
        if ($left($nick(#, $nick).pnick, 1) !isin ~*&!@%) { .notice $nick 14Du hast keine09 Rechte 14dafür! | halt }
        if ($Mod.TopTen.aIsIgnore($network, #)) .notice $nick 09TopTen14 ist schon im Channel09 # 14aktiviert.
        else {
          hdel $+(Mod.TopTen.hIgnore., $network, .Chans) #
          if (!$hget($+(Mod.TopTen.hIgnore., $network, .Chans), 0).item) hfree $+(Mod.TopTen.hIgnore., $network, .Chans)
          .notice $nick 09TopTen14 ist nun im Channel09 # 14aktiviert.
        }
      }
      elseif (%2 == off) {
        if ($left($nick(#, $nick).pnick, 1) !isin ~*&!@%) { .notice $nick 14Du hast keine09 Rechte 14dafür! | halt }
        if (!$Mod.TopTen.aIsIgnore($network, #)) .notice $nick 09TopTen14 ist schon im Channel09 # 14deaktiviert.
        else {
          Mod.TopTen.aInc $+(Ignore., $network, .Chans) # 0
          if (!$hget($+(Mod.TopTen.hIgnore., $network, .Chans), 0).item) hfree $+(Mod.TopTen.hIgnore., $network, .Chans)
          .notice $nick 09TopTen14 ist nun im Channel09 # 14deaktiviert.
        }
      }
      elseif (%2 == ignore) {
        if (!$Mod.TopTen.aIsIgnore($network, #)) { .notice $nick 09TopTen14 ist im Channel09 # 14deaktiviert. | halt }
        if ($left($nick(#, $nick).pnick, 1) !isin ~*&!@%) { .notice $nick 14Du hast keine09 Rechte 14dafür! | halt }
        if ($3 == add) {
          if (!$4) { .notice $nick 14Du hast vergessen einen 09Nick14 anzugeben. | halt }
          if ($4 == $me) { .notice $nick 14Du kannst mich nicht 09ignorieren14 lassen! | halt }
          if (#* iswm $4) { .notice $nick 14Gib einen09 Nick 14ohne einem 09#14 an! | halt }
          if (!$Mod.TopTen.aIsIgnore($network, #, $4)) .notice $nick 14Es steht schon eine User mit den Nick09 $4 14in meiner Liste.
          else { Mod.TopTen.aInc $+(Ignore., $network, ., #, .Nicks) $4 0 | .notice $nick 14Der Nick09 $4 14wurde erfolgreich hinzugefügt. } 
        }
        elseif ($3 == del) {
          if (!$4) { .notice $nick 14Du hast vergessen einen 09Nick14 mit anzugeben. | halt }
          if ($4 == $me) { .notice $nick 14Du kannst mich nicht 09löschen14 lassen! | halt }
          if ($4 == *) {
            if ($hget($+(Mod.TopTen.hIgnore., $network, ., #, .Nicks))) hfree $ifmatch
            .notice $nick 14Alle Einträge in der Nick 09Ignoreliste14 wurden erfolgreich gelöscht.
          }
          else {
            if (#* iswm $4) { .notice $nick 14Gib einen09 Nick 14ohne einem 09#14 an! | halt }
            if (!$Mod.TopTen.aIsIgnore($network, #, $4)) {
              hdel $+(Mod.TopTen.hIgnore., $network, ., #, .Nicks) $replace($4, $chr(91), $chr(171), $chr(93), $chr(187))
              .notice $nick 14Der Nick09 $4 14wurde erfolgreich gelöscht.
            }
            else .notice $nick 14Es steht kein User mit den Nick09 $4 14in meiner Liste.
          }
        }
        elseif ($3 == list) {
          if ($4 == chan) var %hsh = Chans
          elseif ($4 == nick) var %hsh = $+(#, .Nicks)
          else { .notice $nick 14Tippe 09!top10 ignore list nick14 um User in der liste zu sehen und 09!top10 ignore list chan14 um Chans in der liste zu sehen. | halt }
          if ($hget($+(Mod.TopTen.hIgnore., $network, ., %hsh), 0).item) {
            var %a = $ifmatch, %i = 1
            while (%i <= %a) {
              var %Mod.TopTen.vIgnore = %Mod.TopTen.vIgnore $hget($+(Mod.TopTen.hIgnore., $network, ., %hsh), %i).item $+ $iif(%a != %i, $+(14,  $chr(44), 09))
              if (%a == %i) .notice $nick 09 $+ $iif($4 == chan, Chans, Nicks) 14Ignoreliste:09 $replace(%Mod.TopTen.vIgnore, $chr(171), $chr(91), $chr(187), $chr(93)) $+ 
              inc %i 1
            }
          }
          else .notice $nick 14Es stehen keine09 $iif($4 == chan, Chans, Nicks) 14in meiner Ignoreliste.
        }
        else .notice $nick 14Du hast vergessen eine 09Funktion14 (08add14,08del14 oder 08list14) anzugeben!
      }
      elseif (%2 == places) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Places
      elseif (%2 == words) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Words
      elseif (%2 == letters) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Letters
      elseif (%2 == smilies) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Smilies
      elseif (%2 == kicks) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Kicks
      elseif (%2 == kicker) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Kicker
      elseif (%2 == bans) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Bans
      elseif (%2 == baner) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Baner
      elseif (%2 == unbaner) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Unbaner
      elseif (%2 == actions) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Actions
      elseif (%2 == joins) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Joins
      elseif (%2 == quits) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Quits
      elseif (%2 == nickchanges) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Nickchanges
      elseif (%2 == lines) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Lines
      elseif (%2 == modes) Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Modes
      else .msg # 14Such dir was aus:09 $1 14<08places14/08modes14/08words14/08letters14/08smilies14/08kicks14/08kicker14/08bans14/08baner14/08unbaner14/08actions14/08joins14/08quits14/08nickchanges14/08lines14>
    }
    else .msg # 14Such dir was aus:09 $1 14<08places14/08modes14/08words14/08letters14/08smilies14/08kicks14/08kicker14/08bans14/08baner14/08unbaner14/08actions14/08joins14/08quits14/08nickchanges14/08lines14>
  }
  if (($Mod.TopTen.aIsIgnore($network, #)) && ($Mod.TopTen.aIsIgnore($network, #, $nick))) {
    Mod.TopTen.aInc $+(Places., $network, ., #) $nick $count($strip($1-), $chr(32))
    Mod.TopTen.aInc $+(Words., $network, ., #) $nick $numtok($strip($1-), 32)
    Mod.TopTen.aInc $+(Letters., $network, ., #) $nick $len($remove($strip($1-), $chr(32)))
    Mod.TopTen.aInc $+(Lines., $network, ., #) $nick 1
    var %Mod.TopTen.vSmiliesCount = $count($strip($1-), : $+ $chr(40), :- $+ $chr(40), : $+ $chr(41), :- $+ $chr(41), ; $+ $chr(40), ;- $+ $chr(40), ; $+ $chr(41), ;- $+ $chr(41), :D, ;D, :-D, ;-D, :p, ;p, :-p, ;-p, :Þ, ;Þ, :-Þ, ;-Þ, :/, ;/, :-/, ;-/, x-D, xD, =p, =-p, =Þ, =-Þ, =D, =-D, = $+ $chr(41), =- $+ $chr(41), = $+ $chr(40), =- $+ $chr(40))
    if (%Mod.TopTen.vSmiliesCount) Mod.TopTen.aInc $+(Smilies., $network, ., #) $nick $iif($ifmatch <= 5, $v1, 5)
  }
}

;*************************************************************************************************
; - Zählt die Kicks und Kicker Stats.
;*************************************************************************************************
on *:KICK:#:{
  if (($nick != $me) && ($knick != $me)) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $knick)) Mod.TopTen.aInc $+(Kicks., $network, ., #) $knick 1
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(Kicker., $network, ., #) $nick 1
    }
  }
}

;*************************************************************************************************
; - Zählt die Bans und Baner Stats.
;*************************************************************************************************
on *:BAN:#:{
  if ($nick != $me) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $bnick)) Mod.TopTen.aInc $+(Bans., $network, ., #) $bnick 1
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(baner., $network, ., #) $nick 1
    }
  }
}

;*************************************************************************************************
; - Zählt die Unbaner Stats.
;*************************************************************************************************
on *:UNBAN:#:{
  if ($nick != $me) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(Unbaner., $network, ., #) $nick 1
    }
  }
}

;*************************************************************************************************
; - Zählt die Actions Stats.
;*************************************************************************************************
on *:ACTION:*:#:{
  if ($nick != $me) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(Actions., $network, ., #) $nick 1
    }
  }
}

;*************************************************************************************************
; - Zählt die Join Stats und ladet beim Channel join die Stats.
;*************************************************************************************************
on *:JOIN:#:{
  if ($nick != $me) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(Joins., $network, ., #) $nick 1
    }
  }
  else { if ($Mod.TopTen.aIsIgnore($network, #)) Mod.TopTen.aFindfile $network # $Mod.TopTen.aFile }
}

;*************************************************************************************************
; - Entfernt die Stats des Channels beim parten.
;*************************************************************************************************
on *:PART:#: hfree -w $+(Mod.TopTen.*., $network, ., #)

;*************************************************************************************************
; - Zählt die Mode Stats.
;*************************************************************************************************
on *:MODE:#:{
  if ($nick != $me) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(Modes., $network, ., #) $nick 1
    }
  }
}

;*************************************************************************************************
; - Zählt die Mode Stats.
;*************************************************************************************************
on *:RAWMODE:#:{
  if ($remove($1, +, -) isin vhoaq) {
    if ($Mod.TopTen.aIsIgnore($network, #)) {
      if ($Mod.TopTen.aIsIgnore($network, #, $nick)) Mod.TopTen.aInc $+(Modes., $network, ., #) $nick 1
    }
  }
}

;*************************************************************************************************
; - Zählt die Quit Stats und beim Netzwerk verlassen des Bots werden Stats vom Netzwerk entfernt.
;*************************************************************************************************
on *:QUIT:{
  if ($nick != $me) {
    var %a = $comchan($nick, 0), %b = 1
    while (%b <= %a) {
      var %chan = $comchan($nick, %b)
      if ($Mod.TopTen.aIsIgnore($network, %chan)) {
        if ($Mod.TopTen.aIsIgnore($network, %chan, $nick)) Mod.TopTen.aInc $+(Quits., $network, ., %chan) $nick 1
      }
      inc %b
    }
  }
  else .hfree -w $+(Mod.TopTen.*., $network, .*)
}

;*************************************************************************************************
; - Zählt die Nickchange Stats.
;*************************************************************************************************
on *:NICK:{
  if ($nick != $me) {
    var %a = $comchan($newnick, 0), %b = 1
    while (%b <= %a) {
      var %chan = $comchan($newnick, %b)
      if ($Mod.TopTen.aIsIgnore($network, %chan)) {
        if ($Mod.TopTen.aIsIgnore($network, %chan, $newnick)) Mod.TopTen.aInc $+(Nickchanges., $network, ., %chan) $nick 1
      }
      inc %b
    }
  }
}

;*************************************************************************************************
; - Speichert die Stats beim schließen des mIRCs.
;*************************************************************************************************
on *:EXIT: Mod.TopTen.aSave

;*************************************************************************************************
; - Startet Timer für die Sicherung der Stats und ladet die Ignore Daten.
;*************************************************************************************************
on *:CONNECT:{ Mod.TopTen.aIgnoreChans $network | .timerMod.TopTen.tSave 1 3600 Mod.TopTen.aSave }

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Ladet die Backups
; - /Mop.TopTen.aBackupLoad $nick
;*************************************************************************************************
alias -l Mop.TopTen.aBackupLoad {
  var %dir = $left($Mod.TopTen.aFile, $calc($len($Mod.TopTen.aFile) - 2))
  if ($isdir($+(%dir, -Backup\"))) {
    .timerMod.TopTen.* off | hfree -w Mod.TopTen.*
    noop $findfile($Mod.TopTen.aFile, *.hsh, 0, .remove $+(", $1-, "))
    noop $finddir($Mod.TopTen.aFile, *.*, 0, .rmdir $+(", $1-, "))
    .notice $1 14Die Backups wurden 09erfolgreich14 geladen!
  }
  else echo -s .notice $1 14Es sind 09keine14 Backups vorhanden!
}

;*************************************************************************************************
; - Erstellt Backup der Stats
; - /Mod.TopTen.aBackup
;*************************************************************************************************
alias -l Mod.TopTen.aBackup {
  Mod.TopTen.aSave | var %dir = $left($Mod.TopTen.aFile, $calc($len($Mod.TopTen.aFile) - 2))
  if (!$isdir($+(%dir, -Backup\"))) mkdir $+(%dir, -Backup\")
  else { noop $findfile($+(%dir, -Backup\"), *.hsh, 0, Mod.TopTen.aDelete $1-) | mkdir $+(%dir, -Backup\") }
  noop $finddir($Mod.TopTen.aFile, *, 0, mkdir $+(", $replace($1-, \TopTen\, \TopTen-Backup\), "))
  noop $findfile($Mod.TopTen.aFile, *.hsh, 0, .copy -o $+(", $1-, ") $+(", $replace($1-, \TopTen\, \TopTen-Backup\), "))
}

;*************************************************************************************************
; - Resetet die Stats mit oder ohne einen Backup
; - /Mod.TopTen.aReset <1>
;*************************************************************************************************
alias -l Mod.TopTen.aReset {
  if ($1) Mod.TopTen.aBackup
  var %a = 1 | noop $findfile($Mod.TopTen.aFile, *.hsh, 0, Mod.TopTen.aDelete %a $1-)
  while ($hget(%a)) { if (Mod.TopTen.hIgnore.* !iswm $ifmatch) hfree $v2 | inc %a }
}

;*************************************************************************************************
; - Räumt die Stats auf. User deren Stats unter den Wert sind, werden gelöscht
; - /Mod.TopTen.aClean <1-20> $nick
;*************************************************************************************************
alias -l Mod.TopTen.aClean {
  var %a = 1, %x
  while ($hget(%a)) {
    if (Mod.TopTen.h* iswm $hget(%a)) {
      if (Mod.TopTen.hIgnore.* !iswm $v2) {
        var %b = $v2, %c = $hget(%b, 0).item
        while (%c) {
          if ($1 >= $hget(%b, %c).data) { hdel %b $hget(%b, %c).item | inc %x }
          dec %c
        }
      }
    }
    inc %a
  }
  .notice $2 14Es $iif(%x == 1, wurde09, wurden09) $iif(%x, $ifmatch, keine) $iif(%x == 1, 14Eintrag der, 14Einträge die) unter dem Wert09 $1 $iif($%x == 1, 14war, 14waren) gelöscht!
}

;*************************************************************************************************
; - Löscht die Dateien und Ordner aus dem TopTen Addon
; - /Mod.TopTen.aDelete <1> <Pfad>
;*************************************************************************************************
alias -l Mod.TopTen.aDelete {
  var %file = $iif($1 == 1, $2-, $1-)
  if (($1 == 1) && (*Ignore* iswm %file)) halt
  .timer 1 1 .remove $+(", %file, ") | .timer 1 2 .rmdir $+(", $remove(%file, \ $+ $gettok(%file, -1, 92)), ")
}

;*************************************************************************************************
; - Ladet die Ignore Dateien für Chans
; - /Mod.TopTen.aIgnoreChans $network
;*************************************************************************************************
alias -l Mod.TopTen.aIgnoreChans {
  var %hsh = $+(Mod.TopTen.hIgnore., $1, .Chans), %file = $Mod.TopTen.aFile($1, Ignore\Chans)
  if ((!$hget(%hsh)) && ($isfile(%file))) { hmake %hsh 10000 | hload %hsh %file }
}

;*************************************************************************************************
; - Ladet die Stats Datei
; - /Mod.TopTen.aLoad # <Pfad>
;*************************************************************************************************
alias -l Mod.TopTen.aLoad {
  if ($ini($2-, $1)) {
    if ($gettok($2-, -3, 92) == Ignore) var %hsh = $+(Mod.TopTen.hIgnore., $gettok($gettok($2-, -1, 92), -2, 46), ., $1, ., $gettok($2-, -2, 92))
    else var %hsh = $+(Mod.TopTen.h, $gettok($2-, -2, 92), ., $gettok($gettok($2-, -1, 92), -2, 46), ., $1)
    if (!$hget(%hsh)) { hmake %hsh 10000 | hload -i %hsh $+(", $2-, ") $1 }
  }
}

;*************************************************************************************************
; - Gibt den Pfad an die Alias Mod.TopTen.aLoad weiter
; - /Mod.TopTen.aFindfile $network #
;*************************************************************************************************
alias -l Mod.TopTen.aFindfile { if ($Mod.TopTen.aIsIgnore($1, $2)) { var %chan = $2 | noop $findfile($Mod.TopTen.aFile, $+(*, $1, .hsh), 0, Mod.TopTen.aLoad %chan $1-) } }

;*************************************************************************************************
; - Speichert alle Stats
; - /Mod.TopTen.aSave
;*************************************************************************************************
alias -l Mod.TopTen.aSave {
  var %a = 1
  while ($hget(%a)) {
    if (Mod.TopTen.h* iswm $ifmatch) {
      var %table = $v2, %hsh = $remove(%table, Mod.TopTen.h)
      if ($gettok(%hsh, -1, 46) == Nicks) var %file = Ignore\Nicks
      elseif ($gettok(%hsh, -1, 46) == Chans) var %file = Ignore\Chans
      else var %file = $gettok(%hsh, 1, 46)
      hsave $iif($gettok(%hsh, 3, 46) != Chans, -i) %table $Mod.TopTen.aFile($gettok(%hsh, 2, 46), %file) $iif($gettok(%hsh, 3, 46) != Chans, $v1)
    }
    inc %a
  }
}

;*************************************************************************************************
; - Sortiert die Stats Hash Table
; - /Mod.TopTen.aSort <Hash Table>
;*************************************************************************************************
alias -l Mod.TopTen.aSort {
  if ($hget($1)) {
    var %hsh = $ifmatch, %a = $hget(%hsh, 0).item | window $+(@, %hsh) | window $+(@, %hsh, 1)
    while (%a) { aline -n $+(@, %hsh) $hget(%hsh, %a).item $hget(%hsh, %a).data | dec %a }
    filter -wwcteu 2 32 $+(@, %hsh) $+(@, %hsh, 1) | window -c $+(@, %hsh)
  }
}

;*************************************************************************************************
; - Liest die Stats aus und postet sie in den Channel
; - /Mod.TopTen.aMSG $iif($1 == !top10, 1, 2) $network # Places
;*************************************************************************************************
alias -l Mod.TopTen.aMSG {
  if (!$Mod.TopTen.aIsIgnore($2, $3)) { .notice $nick 09TopTen14 ist im Channel09 $3 14deaktiviert. | halt }
  if ($hget($+(Mod.TopTen.h, $4, ., $2, ., $3), 0).item) {
    Mod.TopTen.aSort $+(Mod.TopTen.h, $4, ., $2, ., $3)
    var %window = $+(@Mod.TopTen.h, $4, ., $2, ., $3, 1), %a = $line(%window, 0), %b = 1, %x = 1
    while (%b <= %a) {
      var %line = $line(%window, %x)
      if ($Mod.TopTen.aIsIgnore($2, $3, $gettok(%line, 1, 32))) var %topten = %topten $+(09, %x, .14) $replace($gettok(%line, 1, 32), $chr(171), $chr(91), $chr(187), $chr(93)) (08 $+ $gettok(%line, 2, 32) $+ 14)
      else dec %x
      if ($1 == 1) { if ((%x == %a) || (%x == 10)) { .msg $3 14Top10(09 $+ $4 $+ 14) %topten | window -c %window | halt } }
      elseif ($1 == 2) {
        if (%x == %a) { .msg $3 14Top20(09 $+ $4 $+ 14) %topten | window -c %window | halt }
        elseif (%x == 10) .msg $3 14Top20(09 $+ $4 $+ 14) %topten
        elseif (%x == 20) { .msg $3 14Top20(09 $+ $4 $+ 14) $gettok(%topten, 34-, 32) | window -c %window | halt }
      }
      inc %b | inc %x
    }
    if (!%topten) .msg $3 $+(14Top, $iif($1 == 1, 10, 20), , $chr(40), 09 , $4 , 14, $chr(41), 08 Keine Einträge vorhanden!)
  }
  else .msg $3 $+(14Top, $iif($1 == 1, 10, 20), , $chr(40), 09 , $4 , 14, $chr(41), 08 Keine Einträge vorhanden!)
}

;*************************************************************************************************
; - Gibt die Pfade wieder
; - $Mod.TopTen.aFile($network, <Funktion>)
;*************************************************************************************************
;# Mod.TopTen.aFile <Network> <Funktion>
alias -l Mod.TopTen.aFile {
  if (!$isdir(System)) mkdir System
  if (!$isdir(System\TopTen)) mkdir System\TopTen
  if (($1) && ($2-)) {
    if ((*Ignore* iswm $2-) && (!$isdir(Ignore))) mkdir System\TopTen\Ignore
    if (!$isdir($1-)) mkdir System\TopTen\ $+ $2-
    return $+(", $mircdirSystem\TopTen\, $2-, \, $1, .hsh")
  }
  else return $+(", $mircdirSystem\TopTen\, ")
}

;*************************************************************************************************
; - Erhöt den Zahl in den Stats für einen User
; - /Mod.TopTen.aInc <Hash Table> <Nick> <Num>
;*************************************************************************************************
alias -l Mod.TopTen.aInc {
  if (($1) && ($2) && ($3 isnum)) hinc -m $+(Mod.TopTen.h, $1) $replace($2, $chr(91), $chr(171), $chr(93), $chr(187)) $3
}

;*************************************************************************************************
; - Gibt wieder ob ein User oder ein Channel in der Ignoreliste steht
; - Channel: $Mod.TopTen.aIsIgnore($network, #)
; - Nick: $Mod.TopTen.aIsIgnore($network, #, $nick)
;*************************************************************************************************
alias -l Mod.TopTen.aIsIgnore {
  if (!$3) {
    if ($hfind($+(Mod.TopTen.hIgnore., $1, .Chans), $2)) return 0
    else return 1
  }
  else {
    if ($hfind($+(Mod.TopTen.hIgnore., $1, ., $2, .Nicks), $replace($3, $chr(91), $chr(171), $chr(93), $chr(187)), 0, W)) return 0
    else return 1
  }
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
