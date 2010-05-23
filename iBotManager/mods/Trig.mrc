;*************************************************************************************************
;*
;* Trig Addon v1.2 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Mit diesem Addon kannst du Triggers verwalten.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !trig add <Trigname> <Text> fügst du ein Trigger hinzu der dann den <Text> wiedergibt.
;* Mit !trig add -i <Trigername> <Item> <Text> fügst du ein Trigger mit Item hinzu der dann den <Text> wiedergibt.
;* Mit !trig del <Trigname> löscht du den Trigger.
;* Mit !trig del -i <Trigername> <Item> löscht du das Item vom Trigger.
;* Mit !trig list bekommst du die verfügbaren Triggers angezeigt.
;* Mit !trig info siehst du die Copyright.
;*
;* Note: Du kannst folgendes in deinem Text verwenden:
;*         &nick  - Gibt den Nick wieder der den Trigger aufruft.
;*         &chan - Gibt den Channel wieder wo der Trigger aufgerufen wird.
;*         &wert - Gibt den Wert wieder den der User im Trigger angibt.
;*         z.B. !trig add !test Hey &nick sucht im Chan &chan nach &wert 
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.1
;*   Fixed: Wenn Leerzeichen im Pfad gabs probleme mit den Dateien.
;*   Added: Man kann nun Triggers mit Items adden.
;*   Added: Man kann jetzt &chan, &nick und &wert im Text nutzen.
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
; - Lädt die Trig.hsh wenn vorhanden.
;*************************************************************************************************
on *:LOAD:{
  if ($isfile($Mod.Trig.aFile)) {
    if ($hget(Mod.Trig.hData)) hfree Mod.Trig.hData
    hmake Mod.Trig.hData 10000
    hload Mod.Trig.hData $Mod.Trig.aFile
  }
}

;*************************************************************************************************
; - Entfernt die Trig.hsh beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($isfile($Mod.Trig.aFile)) {
    noop $input(Soll die Datei Trig.hsh gelöscht werden?, yq, Datei Löschen?)
    if ($! == $true) .remove -b $Mod.Trig.aFile
  }
  if ($hget(Mod.Trig.hData)) hfree Mod.Trig.hData
}

;*************************************************************************************************
; - Lädt die Trig liste.
;*************************************************************************************************
on *:START:{
  if ($exists($Mod.Trig.aFile)) {
    if ($hget(Mod.Trig.hData)) hfree Mod.Trig.hData
    hmake Mod.Trig.hData 10000
    hload Mod.Trig.hData $Mod.Trig.aFile
  }
}

;*************************************************************************************************
; - Befehle des Trig Addons.
;*************************************************************************************************
on *:TEXT:*:#:{
  if (($hfind(Mod.Trig.hData, $1)) || ($hfind(Mod.Trig.hData, $replace($1-, $chr(32), $chr(182))))) .msg # $replace($hget(Mod.Trig.hData, $ifmatch), &nick, $nick, &chan, $chan, &wert, $remove($1-, $ifmatch))
  if ($1 == !trig) {
    if ($2 == info) { .notice $nick 14Trig Addon v1.2 © by 09www.IrcShark.de14 (09IrcShark Team14) | halt }
    if ($2) {
      if ($2 == add) {
        if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
          if ($3 == -i) {
            if ($4) {
              if ($5) {
                if ($6-) {
                  if (!$hget(Mod.Trig.hData, $iif($left($4, 1) == $chr(33), $+($4, $chr(182), $5), $+($chr(33), $4, $chr(182), $5)))) {
                    hadd -m Mod.Trig.hData $iif($left($4, 1) == $chr(33), $+($4, $chr(182), $5), $+($chr(33), $4, $chr(182), $5)) $6-
                    hsave Mod.Trig.hData $Mod.Trig.aFile
                    .notice $nick 14Der Trigger09 $iif($left($4, 1) == $chr(33), $4 $5, $+($chr(33), $4) $5) 14mit dem Text09 $6- 14wurde erfolgreich gespeichert!
                  }
                  else .notice $nick 14Der Trigger09 $iif($left($4, 1) == $chr(33), $4 $5, $+($chr(33), $4) $5) 14existiert schon!
                }
                else .notice $nick 14Du hast vergessen den09 Trigger Text 14anzugeben!08 Syntax: !trig add -i <Trigname> <Item> <Text>
              }
              else .notice $nick 14Du hast vergessen den09 Item 14anzugeben!08 Syntax: !trig add -i <Trigname> <Item> <Text>
            }
            else .notice $nick 14Du hast vergessen den09 Trigger Namen 14anzugeben!08 Syntax: !trig add -i <Trigname> <Item> <Text>
            halt
          }
          if ($3) {
            if (!$hget(Mod.Trig.hData, $iif($left($3, 1) == $chr(33), $3, $chr(33) $+ $3))) {
              if ($4-) {
                hadd -m Mod.Trig.hData $iif($left($3, 1) == $chr(33), $3, $chr(33) $+ $3) $4-
                hsave Mod.Trig.hData $Mod.Trig.aFile
                .notice $nick 14Der Trigger09 $iif($left($3, 1) == $chr(33), $3, $chr(33) $+ $3) 14mit dem Text09 $4- 14wurde erfolgreich gespeichert!
              }
              else .notice $nick 14Du hast vergessen den09 Trigger Text 14anzugeben!08 Syntax: !trig add <Trigname> <Text>
            }
            else .notice $nick 14Der Trigger09 $iif($left($3, 1) == $chr(33), $3, $chr(33) $+ $3) 14existiert schon!
          }
          else .notice $nick 14Du hast vergessen den09 Trigger Namen 14anzugeben!08 Syntax: !trig add <Trigname> <Text>
        }
        else .notice $nick 14Du hast keine09 Rechte 14dafür!
      }
      elseif ($2 == del) {
        if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
          if ($3 == -i) {
            if ($4) {
              if ($5) {
                if ($hget(Mod.Trig.hData, $iif($left($4, 1) == $chr(33), $+($4, $chr(182), $5), $+($chr(33), $4, $chr(182), $5)))) {
                  hdel -m Mod.Trig.hData $iif($left($4, 1) == $chr(33), $+($4, $chr(182), $5), $+($chr(33), $4, $chr(182), $5))
                  hsave Mod.Trig.hData $Mod.Trig.aFile
                  .notice $nick 14Der Trigger09 $iif($left($4, 1) == $chr(33), $4 $5, $+($chr(33), $4) $5) 14 wurde erfolgreich gelöscht!
                }
                else .notice $nick 14Der Trigger09 $iif($left($4, 1) == $chr(33), $4 $5, $+($chr(33), $4) $5) 14existiert nicht!
              }
              else .notice $nick 14Du hast vergessen den09 Item 14anzugeben!08 Syntax: !trig del -i <Trigname> <Item>
            }
            else .notice $nick 14Du hast vergessen den09 Trigger Namen 14anzugeben!08 Syntax: !trig del -i <Trigname> <Item>
            halt
          }
          if ($3) {
            if ($hget(Mod.Trig.hData, $iif($left($3, 1) == $chr(33), $3, $chr(33) $+ $3))) {
              hdel -m Mod.Trig.hData $iif($left($3, 1) == $chr(33), $3, $chr(33) $+ $3)
              hsave Mod.Trig.hData $Mod.Trig.aFile
              .notice $nick 14Der Trigger09 $3 14wurde erfolgreich gelöscht!
            }
            else .notice $nick 14Der Trigger09 $3 14existiert nicht!
          }
          else .notice $nick 14Du hast vergessen den09 Trigger Namen14 anzugeben!
        }
        else .notice $nick 14Du hast keine09 Rechte 14dafür!
      }
      elseif ($2 == list) {
        if ($hget(Mod.Trig.hData, 0).item) {
          var %a = $hget(Mod.Trig.hData, 0).item
          while (%a) { var %Mod.Trig.vList = %Mod.Trig.vList $replace($hget(Mod.Trig.hData, %a).item, $chr(182), $chr(32)) $iif(%a != 1, 14-09) | dec %a }
          .notice $nick 14Triggers:09 %Mod.Trig.vList
        }
        else .notice $nick 14Die 09Datenbank14 ist leer!
      }
      else .notice $nick 14Du hast vergessen eine09 Funktion 14auszuwählen!08 Syntax: !trig <add/del/list>
    }
    else .notice $nick $iif($left($nick(#, $nick).pnick, 1) isin ~*&!@%, 14Du hast vergessen eine09 Funktion 14auszuwählen!08 Syntax: !trig <add/del/list>, 14Mit09 !trig list 14kannst du dir alle Trigger anzeigen lassen!) 
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad zur Datei wieder:
; - $Mod.Trig.aFile
;*************************************************************************************************
alias -l Mod.Trig.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem\Trig.hsh, ")
}

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
