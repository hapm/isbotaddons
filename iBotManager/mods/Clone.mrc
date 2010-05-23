;*************************************************************************************************
;*
;* Clone Addon v1.3 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Wenn ein User den Channel betritt guckt der Bot nach Clones und warnt ihn, dass er parten soll.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !clone add <Host> fügst du ein <Host> in die Datenbank hinzu das Clone haben darf.
;* Mit !clone del <Host/Nr> löschst du ein <Host> oder eine <Nr> aus der Datenabank. (Die <Nr> bekommst du bei !clone list angezeigt)
;* Mit !clone list [Search] kannst du ganze Liste wiedergeben oder wenn [Search] angegeben ist, werden die Treffer gepostet.
;* Mit !clone set <on/off> schaltest du Clone-Such-Funktion im Channel an bzw. aus.
;* Mit !clone set warn <Text> stellst du den Warnungs Text ein, wenn <Text> nicht angegeben wird, bekommstdu den aktuellen Text angezeigt.
;* Mit !clone set time <Sekunden> stellst du ein wie lange der Ban dauern soll, wenn <Sekunden> nicht angegeben werden, bekommst du die aktuellen Werte angezeigt.
;* Mit !clone set kicks <Zahl> stellst du ein wie viele Kicks es vor einem Ban geben soll, wenn <Zahl> nicht angegeben wird, bekommst du die aktuellen Werte angezeigt.
;* Mit !clone set kick <TEXT> stellst du ein Kick-Grund ein, wenn <Text> nicht angegeben wird, bekommst du die aktuellen Werte angezeigt.
;* Mit !clone set kick <on/off> stellst du ein, dass der Clone nicht gekickt wird bzw. gekickt wird.
;* Mit !clone set ban <Text> stellst du den Ban-Grund ein, wenn <Text> nicht angegeben wird, bekommst du die aktuellen Werte angezeigt.
;* Mit !clone set secs <Sekunden> stellst du ein in welchen Zeitabständen der Kick erfolgen soll, wenn <Sekunden> nicht angegeben werden, bekommst du die aktuellen Werte angezeigt.
;* Mit !clone info siehst du das Copyright.
;*
;* Bei den Texten kannst du folgende Werte nutzen:
;*    <time> - Zeigt wieder wie lange der Ban drin steht.
;*    <nick> - Gibt den Nick des Clones wieder.
;*    <secs> - Gibt wieder wie lang der Clone Zeit hat den Channel zu verlassen.
;*  z.B. Hey <nick> du wurdest für <time> gebannt, denn du hattest <secs> Zeit den Clone zu entfernen!
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.3
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Added: On Quit & On Kick Event, wenn Clone Quit macht oder gekickt wird, wird Clone aus Datenbank entfernt.
;*   Changed: Op überprüfung, nun werden auch die Stati * und ! geprüft.
;*   Fixed: Bot reagiert, wenn nur Bot und ein anderer mit gleichen Host wie Bot jointe.
;*   Fixed: Farbe wurde nicht gespeichert bei den Texten.
;*   Fixed: Timer wurde bei Unload nicht beendet.
;*   Fixed: Es wurde nicht geprüft ob man bei 'set kicks/secs/time' ne Zahl angibt oder nicht.
;*
;* v1.1
;*   Fixed: !clone list postete Werte, die nicht angezeigt werden sollten.
;*   Fixed: Die Standartwerte wurden nicht richtig eingestellt.
;*   Added: !clone set kick <on/off> das ermöglicht die kick Funktion ein bzw. auszuschalten.
;*   Added: !clone info für Copyright.
;*   Changed: Alias Mod.Clone.aIal wurde entfernt, für die Alias wird who genutzt, ist schneller.
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
; - Lädt Dateien beim Laden.
;*************************************************************************************************
on *:LOAD:{
  if ($exists($Mod.Clone.aFile)) {
    if ($hget(Mod.Clone.hHost)) hfree Mod.Clone.hHost
    if ($hget(Mod.Clone.hSet)) hfree Mod.Clone.hSet
    hmake Mod.Clone.hHost 10000
    hmake Mod.Clone.hSet 10000
    hload -i Mod.Clone.hHost $Mod.Clone.aFile Host
    hload -i Mod.Clone.hSet $Mod.Clone.aFile Set
  }
  Mod.Clone.aHash
}

;*************************************************************************************************
; - Entfernt Dateien beim Entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($exists($Mod.Clone.aFile)) {
    noop $input(Soll die Datei Clone.hsh gelöscht werden?, yv, Datei Löschen?)
    if ($! == $yes) .remove -b $Mod.Clone.aFile
  }
  if ($hget(Mod.Clone.hHost)) hfree Mod.Clone.hHost
  if ($hget(Mod.Clone.hSet)) hfree Mod.Clone.hSet
  .timerMod.Clone.* off
}

;*************************************************************************************************
; - Lädt Hash Tables beim mIRC Start.
;*************************************************************************************************
on *:START:{
  if ($exists($Mod.Clone.aFile)) {
    if ($hget(Mod.Clone.hHost)) hfree Mod.Clone.hHost
    if ($hget(Mod.Clone.hSet)) hfree Mod.Clone.hSet
    hmake Mod.Clone.hHost 10000
    hmake Mod.Clone.hSet 10000
    hload -i Mod.Clone.hHost $Mod.Clone.aFile Host
    hload -i Mod.Clone.hSet $Mod.Clone.aFile Set
  }
  Mod.Clone.aHash
}

;*************************************************************************************************
; - Prüft nach Clones beim Chan Join.
;*************************************************************************************************
on *:JOIN:#:{
  if ($nick != $me) {
    if (!$hfind(Mod.Clone.hHost, $address($nick, 15), 0, W)) {
      if (!$hget(Mod.Clone.hSet, Mod.Clone. $+ $+(#, ., $network))) Mod.Clone.aScan # $nick $network
    }
  }
  else .timer 1 2 who #
}

;*************************************************************************************************
; - Löscht User aus Datenbank, wenn Chan Part.
;*************************************************************************************************
on *:PART:#:{
  if ($nick != $me) {
    if ($hget(Mod.Clone.hSet, Mod.Clone.n $+ $+(#, ., $network, ., $nick))) {
      if ($timer(Mod.Clone. $+ $+(#, ., $network, ., $nick))) .timerMod.Clone. $+ $+(#, ., $network, ., $nick) off
      hdel Mod.Clone.hSet Mod.Clone.n $+ $+(#, ., $network, ., $nick)
      hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
    }
  }
}

;*************************************************************************************************
; - Löscht User aus Datenbank, wenn Quit.
;*************************************************************************************************
on *:Quit:{
  if ($nick != $me) {
    var %a = 1, %b = $chan(0)
    while (%a <= %b) {
      if ($hget(Mod.Clone.hSet, Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick))) {
        if ($timer(Mod.Clone. $+ $+($chan(%a), ., $network, ., $nick))) .timerMod.Clone. $+ $+($chan(%a), ., $network, ., $nick) off
        hdel Mod.Clone.hSet Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick)
        hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
      }
      inc %a 1
    }
  }
}

;*************************************************************************************************
; - Löscht User aus Datenbank, wenn er gekickt wird.
;*************************************************************************************************
on *:KICK:#:{
  if ($knick != $me) {
    if ($hget(Mod.Clone.hSet, Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick))) .timer 1 20 Mod.Clone.aKick # $knick $network
  }
}

;*************************************************************************************************
; - Löscht User aus Datenbank, wenn er Ban von anderen User bekommt.
;*************************************************************************************************
on *:BAN:#:{
  if ($nick != $me) {
    if ($hget(Mod.Clone.hSet, Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick))) {
      if ($timer(Mod.Clone. $+ $+(#, ., $network, ., $nick))) .timerMod.Clone. $+ $+(#, ., $network, ., $nick) off
      hdel Mod.Clone.hSet Mod.Clone.n $+ $+(#, ., $network, ., $nick)
      hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
    }
  }
}

;*************************************************************************************************
; - Ändert die Werte auf neuen Nick, wenn der User Nickchange macht.
;*************************************************************************************************
on *:NICK:{
  if ($nick != $me) {
    var %a = 1, %b = $chan(0)
    while (%a <= %b) {
      if ($hget(Mod.Clone.hSet, Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick))) {
        .timerMod.Clone. $+ $+($chan(%a), ., $network, ., $nick) off
        .msg $chan(%a) $replace($hget(Mod.Clone.hSet, Mod.Clone.Warn), <nick>, $newnick, <time>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Time)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), <secs>, $replace($duration($iif(!$timer(Mod.Clone. $+ $+($chan(%a), ., $network, ., $nick)), $hget(Mod.Clone.hSet, Mod.Clone.Secs), $timer(Mod.Clone. $+ $+($chan(%a), ., $network, ., $nick)).secs) ), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), Sekundes, Sekunden, <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15))
        hinc -m Mod.Clone.hSet Mod.Clone.n $+ $+($chan(%a), ., $network, ., $newnick) $hget(Mod.Clone.hSet, Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick))
        hdel Mod.Clone.hSet Mod.Clone.n $+ $+($chan(%a), ., $network, ., $nick)
        hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
        .timerMod.Clone. $+ $+($chan(%a), ., $network, ., $newnick) 1 $iif(!$timer(Mod.Clone. $+ $+($chan(%a), ., $network, ., $nick)), $hget(Mod.Clone.hSet, Mod.Clone.Secs), $timer(Mod.Clone. $+ $+($chan(%a), ., $network, ., $nick)).secs) Mod.Clone.aCheck $chan(%a) $newnick $network 
      }
      inc %a 1
    }
  }
}

;*************************************************************************************************
; - Trigger Befehle des Clone Addons.
;*************************************************************************************************
on *:TEXT:!clone*:#:{
  if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
    if ($2) {
      if ($2 == info) { .notice $nick 14Clone Addon v1.3 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
      if ($2 == add) {
        if ($3) {
          if (!$hfind(Mod.Clone.hHost, $3, 0, W)) {
            hadd -m Mod.Clone.hHost $3 $iif($hget(Mod.Clone.hHost, 0).item == 0, 1, $calc($hget(Mod.Clone.hHost, 0).item + 1))
            hsave -i Mod.Clone.hHost $Mod.Clone.aFile Host
            .notice $nick 14Der Host09 $3 14wurde erfoglreich in die Datenbank hinzugefügt!
          }
          else .notice $nick 14Ein Host mit der gleichen Wirkung, wie09 $3 14steht in der Datenbank, deshalb wird er nicht hinzugefügt!
        }
        else .notice $nick 14Du hast vergessen den09 Host 14anzugeben!
      }
      if ($2 == del) {
        if ($3) {
          if ($hget(Mod.Clone.hHost, 0).item) {
            if ($3 isnum) {
              if ($hget(Mod.Clone.hHost, 0).item >= $3) {
                var %a = $hget(Mod.Clone.hHost, $3).item
                hdel Mod.Clone.hHost $hget(Mod.Clone.hHost, $3).item
                hsave -i Mod.Clone.hHost $Mod.Clone.aFile Host
                .notice $nick 14Der Host09 %a 14wurde erfolgreich gelöscht!
              }
              else .notice $nick 14Die Zahl09 $3 14ist zu hoch, soviele Einträge stehen nicht in der Datenbank!
            }
            else {
              if ($hfind(Mod.Clone.hHost, $3, 0, w)) {
                if ($hfind(Mod.Clone.hHost, $3, 0, w) == 1) {
                  var %a = $hfind(Mod.Clone.hHost, $3, 1, w)
                  hdel Mod.Clone.hHost $hfind(Mod.Clone.hHost, $3, 1, w)
                  hsave -i Mod.Clone.hHost $Mod.Clone.aFile Host
                  .notice $nick 14Der Host09 %a 14wurde erfolgreich gelöscht!
                }
                else {
                  var %a = 1, %b = $hfind(Mod.Clone.hHost, $3, 0, w)
                  while (%a <= %b) {
                    var %Mod.Clone.vList = %Mod.Clone.vList  $+ $rand(2, 13) $+ $hfind(Mod.Clone.hHost, $3, $hfind(Mod.Clone.hHost, $3, 0, w), w) $+ 
                    hdel Mod.Clone.hHost $hfind(Mod.Clone.hHost, $3, $hfind(Mod.Clone.hHost, $3, 0, w), w)
                    inc %a 1
                  }
                  hsave -i Mod.Clone.hHost $Mod.Clone.aFile Host
                  .notice $nick 09 $+ %b 14Hosts wurden gelöscht: %Mod.Clone.vList
                }
              }
              else .notice $nick 14Es steht kein Host, der09 $3 14heißt, in der Datenbank!
            }
          }
          else .notice $nick 14Die 09Datenbank14 ist leer!
        }
        else .notice $nick 14Du hast vergessen einen09 Host 14oder die 09Nummer14 des Hosts anzugeben!
      }
      if ($2 == list) {
        if ($hget(Mod.Clone.hHost, 0).item) {
          if ($3) {
            var %a = 1, %b = $hfind(Mod.Clone.hHost, $3, 0, w)
            while (%a <= %b) {
              var %Mod.Clone.vList = %Mod.Clone.vList  $+ $rand(2, 13) $+ $chr(35) $+ $hget(Mod.Clone.hHost, $hfind(Mod.Clone.hHost, $3, %a, w)) $hfind(Mod.Clone.hHost, $3, %a, w) $+ 
              inc %a 1
            }
            .notice $nick 09 $+ %b 14Treffer für09 $3 14gefunden: %Mod.Clone.vList
          }
          else {
            var %a = 1, %b = $hget(Mod.Clone.hHost, 0).item
            while (%a <= %b) {
              var %Mod.Clone.vList = %Mod.Clone.vList  $+ $rand(2, 13) $+ $chr(35) $+ $hget(Mod.Clone.hHost, $hget(Mod.Clone.hHost, %a).item) $hget(Mod.Clone.hHost, %a).item $+ 
              inc %a 1
            }
            .notice $nick 09 $+ %b $iif(%b == 1, 14Eintrag, 14Einträge) gefunden: %Mod.Clone.vList
          }
        }
        else .notice $nick 14Die 09Datenbank14 ist leer!
      }
      if ($2 == set) {
        if ($3) {
          if ($3 == on) {
            if ($hget(Mod.Clone.hSet, Mod.Clone. $+ $+(#, ., $network)) == off) {
              hdel -m Mod.Clone.hSet Mod.Clone. $+ $+(#, ., $network)
              hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
              .notice $nick 14Der09 Clone 14Scanner ist nun an!
            }
            else .notice $nick 14Der 09Clone14 Scanner ist schon an!
          }
          if ($3 == off) {
            if (!$hget(Mod.Clone.hSet, Mod.Clone. $+ $+(#, ., $network))) {
              hadd -m Mod.Clone.hSet Mod.Clone. $+ $+(#, ., $network) off
              hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
              .notice $nick 14Der09 Clone 14Scanner ist nun aus!
            }
            else .notice $nick 14Der 09Clone14 Scanner ist schon aus!
          }
          if ($3 == warn) {
            if ($4-) {
              hadd -m Mod.Clone.hSet Mod.Clone.WARN $replace($4-, $chr(3), <k>, $chr(2), <b>, $chr(31), <u>, $chr(15), <o>)
              hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
              .notice $nick 14Der 09Warnungs14-Text wurde erfolgreich geändert!
            }
            else {
              if ($hget(Mod.Clone.hSet, Mod.Clone.WARN)) .notice $nick 14Warnung Messages: $replace($hget(Mod.Clone.hSet, Mod.Clone.WARN), <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15)) 
              else .notice $nick 14Es sind keine09 Werte 14gesetzt!
            }
          }
          if ($3 == time) {
            if ($4) {
              if ($4 != $hget(Mod.Clone.hSet, Mod.Clone.Time))  {
                if ($4 isnum) {
                  hadd -m Mod.Clone.hSet Mod.Clone.Time $4
                  hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
                  .notice $nick 14Der Clone wird für09 $replace($duration($4), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen) 14gebannt!
                }
                else .notice $nick 14Bitte gib Zahlen von09 0 - 914an!
              }
              else .notice $nick 14Der Clone wird schon für09 $replace($duration($4), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen) 14gebannt!
            }
            else {
              if ($hget(Mod.Clone.hSet, Mod.Clone.Time)) .notice $nick 14Der Clone wird für09 $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Time)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen) 14gebannt!
              else .notice $nick 14Es sind keine09 Werte 14gesetzt!
            }
          } 
          if ($3 == kicks) {
            if ($4) {
              if ($4 != $hget(Mod.Clone.hSet, Mod.Clone.Kicks))  {
                if ($4 isnum) {
                  hadd -m Mod.Clone.hSet Mod.Clone.Kicks $4
                  hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
                  .notice $nick 14Der Clone wird09 $4 14gekickt bevor er Ban bekommt!
                }
                else .notice $nick 14Bitte gib Zahlen von09 0 - 914an!
              }
              else .notice $nick 14Der Clone wird schon 09 $hget(Mod.Clone.hSet, Mod.Clone.Kicks) 14mal gekickt bevor er gebannt wird!
            }
            else {
              if ($hget(Mod.Clone.hSet, Mod.Clone.Kicks)) .notice $nick 14Der Clone wird09 $hget(Mod.Clone.hSet, Mod.Clone.Kicks) 14mal gekickt bevor er Ban bekommt!
              else .notice $nick 14Es sind keine09 Werte 14gesetzt!
            }
          }
          if ($3 == kick) {
            if ($4 == on) {
              if ($hget(Mod.Clone.hSet, Mod.Clone.Kick $+ $+(#, ., $network)) == off) {
                hdel -m Mod.Clone.hSet Mod.Clone.Kick $+ $+(#, ., $network)
                hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
                .notice $nick 14Die 09Kick14 Funktion ist wieder an!
              }
              else .notice $nick 14Die 09Kick14 Funktion ist schon an!
              return
            }
            if ($4 == off) {
              if (!$hget(Mod.Clone.hSet, Mod.Clone.Kick $+ $+(#, ., $network))) {
                hadd -m Mod.Clone.hSet Mod.Clone.Kick $+ $+(#, ., $network) off
                hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
                .notice $nick 14Die 09Kick14 Funktion ist nun aus!
              }
              else .notice $nick 14Die 09Kick14 Funktion ist schon aus!
              return
            }
            if ($4-) {
              hadd -m Mod.Clone.hSet Mod.Clone.Kick $replace($4-, $chr(3), <k>, $chr(2), <b>, $chr(31), <u>, $chr(15), <o>)
              hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
              .notice $nick 14Der Kick 09Grund14 wurde erfolgreich gespeichert!
            }
            else {
              if ($hget(Mod.Clone.hSet, Mod.Clone.Kick)) .notice $nick 14Kick Messages: $replace($hget(Mod.Clone.hSet, Mod.Clone.Kick), <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15)) 
              else .notice $nick 14Es sind keine09 Werte 14gesetzt!
            }
          }
          if ($3 == ban) {
            if ($4-) {
              hadd -m Mod.Clone.hSet Mod.Clone.Ban $replace($4-, $chr(3), <k>, $chr(2), <b>, $chr(31), <u>, $chr(15), <o>)
              hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
              .notice $nick 14Der Ban 09Grund14 wurde erfolgreich gespeichert!
            }
            else {
              if ($hget(Mod.Clone.hSet, Mod.Clone.Ban)) .notice $nick 14Ban Messages: $replace($hget(Mod.Clone.hSet, Mod.Clone.Ban), <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15)) 
              else .notice $nick 14Es sind keine09 Werte 14gesetzt!
            }
          }
          if ($3 == secs) {
            if ($4) {
              if ($4 isnum) {
                hadd -m Mod.Clone.hSet Mod.Clone.Secs $4
                hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
                .notice $nick 14Der Clone wird09 $4 Sekunden14 lang gewarnt bis zum ersten Kick!
              }
              else .notice $nick 14Bitte gib Zahlen von09 0 - 914an!
            }
            else {
              if ($hget(Mod.Clone.hSet, Mod.Clone.Secs)) .notice $nick 14Der Clone wird09 $hget(Mod.Clone.hSet, Mod.Clone.Secs) Sekunden14 lang gewarnt bis zum ersten Kick!
              else .notice $nick 14Es sind keine09 Werte 14gesetzt!
            }
          }
        }
        else .notice $nick 14Du hast vergessen eine 09Funktion14 anzugeben!08 Syntax: !clone set <on/off/warn/time/kicks/kick (on/off)/ban/secs>
      }
    }
    else .notice $nick 14Du hast vergessen eine 09 Funktion14 anzugeben!08 Syntax: !clone <add/del/list/set/scan/info>
  }
  else .notice $nick 14Du hast keine09 Rechte 14dafür!
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         ALIASES Start
;*************************************************************************************************
; - Stellt die Standartwerte ein, wenn keine Werte gesetzt sind:
; - Mod.Clone.aHash
;*************************************************************************************************
alias Mod.Clone.aHash {
  if (!$hget(Mod.Clone.hSet, Mod.Clone.Kicks)) hadd -m Mod.Clone.hSet Mod.Clone.Kicks 2
  if (!$hget(Mod.Clone.hSet, Mod.Clone.Time)) hadd -m Mod.Clone.hSet Mod.Clone.Time 3600
  if (!$hget(Mod.Clone.hSet, Mod.Clone.Secs)) hadd -m Mod.Clone.hSet Mod.Clone.Secs 20
  if (!$hget(Mod.Clone.hSet, Mod.Clone.Ban)) {
    var %a = 14Du wurdest für09 <time> 14gebannt, weil hier keine09 Clones 14erlaubt sind!
    hadd -m Mod.Clone.hSet Mod.Clone.Ban $replace(%a, $chr(3), <k>, $chr(2), <b>, $chr(31), <u>, $chr(15), <o>)
  }
  if (!$hget(Mod.Clone.hSet, Mod.Clone.Kick)) {
    var %a = 14Bitte lass den 09Clone14 aus dem Channel!
    hadd -m Mod.Clone.hSet Mod.Clone.Kick $replace(%a, $chr(3), <k>, $chr(2), <b>, $chr(31), <u>, $chr(15), <o>)
  }
  if (!$hget(Mod.Clone.hSet, Mod.Clone.Warn)) {
    var %a = 14Hey,09 <nick> 14bitte hol dein Clone aus dem Channel! Du hast dafür09 <secs> 14Zeit, sonst gibts09 <time> 14Ban!
    hadd -m Mod.Clone.hSet Mod.Clone.Warn $replace(%a, $chr(3), <k>, $chr(2), <b>, $chr(31), <u>, $chr(15), <o>)
  }
  hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
}

;*************************************************************************************************
; - Startet die Warnungen und verwaltet Kicks und Bans:
; - Mod.Clone.aCheck # $nick $network
;*************************************************************************************************
alias Mod.Clone.aCheck {
  if ($hget(Mod.Clone.hSet, Mod.Clone.n $+ $+($1, ., $3, ., $2)) == $hget(Mod.Clone.hSet, Mod.Clone.Kicks)) {
    if ($left($nick($1, $me).pnick, 1) isin ~*&!@%) {
      if ($2 ison $1) ban -ku $+ $hget(Mod.Clone.hSet, Mod.Clone.Time) $1 $2 $replace($hget(Mod.Clone.hSet, Mod.Clone.Ban), <nick>, $2, <time>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Time)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), <secs>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Secs)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), Sekundes, Sekunden, <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15))
    }
    .timerMod.Clone. $+ $+($1, ., $3, ., $2) off
    hdel Mod.Clone.hSet Mod.Clone.n $+ $+($1, ., $3, ., $2)
    hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
  }
  else {
    if ($left($nick($1, $me).pnick, 1) isin ~*&!@%) {
      if ($2 ison $1) kick $1 $2 $replace($hget(Mod.Clone.hSet, Mod.Clone.Kick), <nick>, $2, <time>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Time)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), <secs>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Secs)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), Sekundes, Sekunden, <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15))
    }
    .timerMod.Clone. $+ $+($1, ., $3, ., $2) off
  }
}

;*************************************************************************************************
; - Scannt nach Clones im Channel:
; - Mod.Clone.aScan # $nick $network
;*************************************************************************************************
alias Mod.Clone.aScan {
  if (($1) && ($2) && ($3) && ($2 ison $1) && ($ialchan($address($2, 2), $1, 0) > 1)) {
    Mod.Clone.aHash
    var %a = 1, %b = $ialchan($address($2, 2), $1, 0)
    while (%a <= %b) {
      if (($ialchan($address($2, 2), $1, %a).nick != $me) && ($ialchan($address($2, 2), $1, %a).nick != $2)) {
        var %Mod.Clone.vNick = %Mod.Clone.vNick 09 $+ $ialchan($address($2, 2), $1, %a).nick $+ 14
        if (%a == %b) {
          .msg $1 14-=(14Clone für09 $address($2, 2) 14gefunden)=-=(  $+ $replace($gettok(%Mod.Clone.vNick , 1- $+ $count(%Mod.Clone.vNick , $chr(32)), 32), $chr(32), $chr(44) $+ $chr(32)) und09  $ialchan($address($2, 2), $1, %a).nick $+ 14)=-
          if (!$hget(Mod.Clone.hSet, Mod.Clone.Kick $+ $+($1, ., $3))) {
            .timer 1 2 .msg $1 $replace($hget(Mod.Clone.hSet, Mod.Clone.Warn), <nick>, $2, <time>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Time)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), <secs>, $replace($duration($hget(Mod.Clone.hSet, Mod.Clone.Secs)), sec, $chr(32) $+ Sekunde, secs, $chr(32) $+ Sekunden, min, $chr(32) $+ Minute, mins, $chr(32) $+ Minuten, hr, $chr(32) $+ Stunde, hrs, $chr(32) $+ Stunden, day, $chr(32) $+ Tag, days, $chr(32) $+ Tage, wk, $chr(32) $+ Woche, wks, $chr(32) $+ Wochen), Sekundes, Sekunden, <k>, $chr(3), <b>, $chr(2), <u>, $chr(31), <o>, $chr(15))
            hinc -m Mod.Clone.hSet Mod.Clone.n $+ $+($1, ., $3, ., $2) 1
            hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
            .timerMod.Clone. $+ $+($1, ., $3, ., $2) 1 $hget(Mod.Clone.hSet, Mod.Clone.Secs) Mod.Clone.aCheck $1 $2 $3
          }
        }
      }
      inc %a 1
    }
  }
}

;*************************************************************************************************
; - Löscht Clone aus Datenbank, wenn gekickt wird:
; - Mod.Clone.aKick # $nick $network
;*************************************************************************************************
alias Mod.Clone.aKick {
  if ($timer(Mod.Clone. $+ $+($1, ., $3, ., $2))) .timerMod.Clone. $+ $+($1, ., $3, ., $2) off
  hdel Mod.Clone.hSet Mod.Clone.n $+ $+($1, ., $3, ., $2)
  hsave -i Mod.Clone.hSet $Mod.Clone.aFile Set
}

;*************************************************************************************************
; - Path wiedergabe:
; - $Mod.Clone.aFile
;*************************************************************************************************
alias Mod.Clone.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem\Clone.hsh, ")
}

;*************************************************************************************************
;*                                         ALIASES Ende
;*************************************************************************************************
