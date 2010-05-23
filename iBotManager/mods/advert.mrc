
on *:LOAD:{
  if ($exists($Mod.Advert.aFile)) {
    var %Mod.Advert.vInput = $input(Die Datei Advert.hsh wurde gefunden. Sollen die Daten geladen werden?, yv, Daten Laden?)
    if (%Mod.Advert.vInput == $yes) {
      if ($hget(Mod.Advert.hData)) {
        hfree Mod.Advert.hData
      }
      if ($hget(Mod.Advert.hSet)) {
        hfree Mod.Advert.hSet
      }
      if ($hget(Mod.Advert.hHost)) {
        hfree Mod.Advert.hHost
      }
      hmake Mod.Advert.hData 10000
      hload -i Mod.Advert.hData $Mod.Advert.aFile Data
      hmake Mod.Advert.hSet 10000
      hload -i Mod.Advert.hSet $Mod.Advert.aFile Set
      hmake Mod.Advert.hHost 10000
      hload -i Mod.Advert.hHost $Mod.Advert.aFile Host
    }
  }
  else {
    hmake Mod.Advert.hData 10000
    hmake Mod.Advert.hSet 10000
    hmake Mod.Advert.hHost 10000
  }
  echo 14Das09 Advert 14Addon v1.0 © by 09www.eVolutionX-Project.eu14 (09eVolutionX-Project Team14) wurde erflogreich geladen! Viel Spaß :)
}

on *:TEXT:*:#:{
  if (*#* iswm $strip($1-)) {
    if ($hget(Mod.Advert.hSet, Mod.Advert.Status) == on) {
      if (!$hfind(Mod.Advert.hHost, $address($nick, 15), 0, W)) {
        if ($matchtok($strip($1-), $chr(35), 0, 32) == 1) {
          if ($left($matchtok($strip($1-), $chr(35), 1, 32), 1) == $chr(35)) {
            set -u5 %Mod.Advert.vRaw # $nick
            raw -q list $matchtok($strip($1-), $chr(35), 1, 32)
          }
        }
        else {
          set -u5 %Mod.Advert.vRaw # $nick
          var %a = 1, %b = $matchtok($strip($1-), $chr(35), 0, 32)
          while (%a <= %b) {
            if ($left($matchtok($strip($1-), $chr(35), %a, 32), 1) == $chr(35)) {
              raw -q list $matchtok($strip($1-), $chr(35), %a, 32)
            }
            inc %a 1
          }
        }
      }
    }
  }
  if ($1 == !advert) {
    if ($2) {
      if ($2 == info) {
        .notice $nick 14Advert Addon v1.1 © by 09www.eVolutionX-Project.eu14 (09eVolutionX-Project Team14)
        return
      }
      if ($2 == add) {

      }
      if ($2 == set) {
        if ($3) {
          if ($3 == on) {
            if ($hget(Mod.Advert.hSet, Mod.Advert.Status) == off) {
              hadd -m Mod.Advert.hSet Mod.Advert.Status On
              hsave -i Mod.Advert.hSet $Mod.Advert.aFile Set
              .notice $nick 14Das09 Advert Addon14 ist nun an!
            }
            else {
              .notice $nick 14Das09 Advert Addon14 ist schon an!
            }
          }
          if ($3 == off) {
            if ($hget(Mod.Advert.hSet, Mod.Advert.Status) == on) {
              hadd -m Mod.Advert.hSet Mod.Advert.Status off
              hsave -i Mod.Advert.hSet $Mod.Advert.aFile Set
              .notice $nick 14Das09 Advert Addon14 ist nun aus!
            }
            else {
              .notice $nick 14Das09 Advert Addon14 ist schon aus!
            }
          }
          if ($3 == add) {
            if ($4) {
              if (!$hfind(Mod.Advert.hHost, $4, 0, W)) {
                hadd -m Mod.Advert.hHost $4 $iif($hget(Mod.Advert.hHost, 0).item == 0, 1, $calc($hget(Mod.Advert.hHost, 0).item + 1))
                hsave -i Mod.Advert.hHost $Mod.Advert.aFile Host
                .notice $nick 14Der Host09 $4 14darf nun Werbung machen!
              }
              else {
                .notice $nick 14Ein Host mit der gleichen wirkung wie09 $4 14steht in der Datenbank, deshalb wird er nicht hinzugefügt!
              }
            }
            else {
              .notice $nick 14Du hast vergessen den09 Host 14anzugeben!
            }
          }
          if ($3 == del) {
            if ($4) {
              if ($hget(Mod.Advert.hHost, 0).item) {
                if ($4 isnum) {
                  if ($hget(Mod.Advert.hHost, 0).item >= $4) {
                    var %a = $hget(Mod.Advert.hHost, $4).item
                    hdel Mod.Advert.hHost $hget(Mod.Advert.hHost, $4).item
                    hsave -i Mod.Advert.hHost $Mod.Advert.aFile Host
                    .notice $nick 14Der Host09 %a 14wurde erfolgreich gelöscht!
                  }
                  else {
                    .notice $nick 14Die Zahl09 $4 14ist zu hoch, denn soviele Einträge stehen nicht in der Datenbank!
                  }
                }
                else {
                  if ($hfind(Mod.Advert.hHost, $4, 0, w)) {
                    if ($hfind(Mod.Advert.hHost, $4, 0, w) == 1) {
                      var %a = $hfind(Mod.Advert.hHost, $4, 1, w)
                      hdel Mod.Advert.hHost $hfind(Mod.Advert.hHost, $4, 1, w)
                      hsave -i Mod.Advert.hHost $Mod.Advert.aFile Host
                      .notice $nick 14Der Host09 %a 14darf nun keine Werbung mehr machen!
                    }
                    else {
                      var %a = 1, %b = $hfind(Mod.Advert.hHost, $4, 0, w)
                      while (%a <= %b) {
                        if (%Mod.Advert.vList) {
                          var %Mod.Advert.vList = %Mod.Advert.vList  $+ $rand(2, 13) $+ $hfind(Mod.Advert.hHost, $4, $hfind(Mod.Advert.hHost, $4, 0, w), w) $+ 
                          hdel Mod.Advert.hHost $hfind(Mod.Advert.hHost, $4, $hfind(Mod.Advert.hHost, $4, 0, w), w)
                        }
                        else {
                          var %Mod.Advert.vList =  $+ $rand(2, 13) $+ $hfind(Mod.Advert.hHost, $4, $hfind(Mod.Advert.hHost, $4, 0, w), w) $+ 
                          hdel Mod.Advert.hHost $hfind(Mod.Advert.hHost, $4, $hfind(Mod.Advert.hHost, $4, 0, w), w)
                        }
                        inc %a 1
                      }
                      hsave -i Mod.Advert.hHost $Mod.Advert.aFile Host
                      .notice $nick 09 $+ %b 14Hosts wurden gelöscht: %Mod.Advert.vList
                    }
                  }
                  else {
                    .notice $nick 14Es steht kein Host der09 $4 14heißt in der Datenbank!
                  }
                }
              }
              else {
                .notice $nick 14Die 09Datenbank14 ist leer!
              }
            }
            else {
              .notice $nick 14Du hast vergessen einen09 Host 14oder die 09Nummer14 des Hosts anzugeben!
            }
          }
          if ($3 == list) {
            if ($hget(Mod.Advert.hHost, 0).item) {
              if ($4) {
                var %a = 1, %b = $hfind(Mod.Advert.hHost, $4, 0, w)
                while (%a <= %b) {
                  if (%Mod.Advert.vList) {
                    var %Mod.Advert.vList = %Mod.Advert.vList  $+ $rand(2, 13) $+ $chr(35) $+ $hget(Mod.Advert.hHost, $hfind(Mod.Advert.hHost, $4, %a, w)) $hfind(Mod.Advert.hHost, $4, %a, w) $+ 
                  }
                  else {
                    var %Mod.Advert.vList =  $+ $rand(2, 13) $+ $chr(35) $+ $hget(Mod.Advert.hHost, $hfind(Mod.Advert.hHost, $4, %a, w)) $hfind(Mod.Advert.hHost, $4, %a, w) $+ 
                  }
                  inc %a 1
                }
                .notice $nick 09 $+ %b 14Treffer für09 $4 14gefunden: %Mod.Advert.vList
              }
              else {
                var %a = 1, %b = $hget(Mod.Advert.hHost, 0).item
                while (%a <= %b) {
                  if (%Mod.Advert.vList) {
                    var %Mod.Advert.vList = %Mod.Advert.vList  $+ $rand(2, 13) $+ $chr(35) $+ $hget(Mod.Advert.hHost, $hget(Mod.Advert.hHost, %a).item) $hget(Mod.Advert.hHost, %a).item $+ 
                  }
                  else {
                    var %Mod.Advert.vList =  $+ $rand(2, 13) $+ $chr(35) $+ $hget(Mod.Advert.hHost, $hget(Mod.Advert.hHost, %a).item) $hget(Mod.Advert.hHost, %a).item $+ 
                  }
                  inc %a 1
                }
                .notice $nick 09 $+ %b $iif(%b == 1, 14Eintrag, 14Einträge) gefunden: %Mod.Advert.vList
              }
            }
            else {
              .notice $nick 14Die 09Datenbank14 ist leer!
            }
          }
          if ($3 == op) {
            if ($4) {
              if ($4 == on) {
                if ($hget(Mod.Advert.hSet, Mod.Advert.Op) == off) {
                  hadd -m Mod.Advert.hSet Mod.Advert.Op On
                  hsave -i Mod.Advert.hSet $Mod.Advert.aFile Set
                  .notice $nick 14Die09 Ops 14dürfen nun Werbung machen!
                }
                else {
                  .notice $nick 14Die09 Ops 14dürfen schon Werbung machen!
                }
              }
              elseif ($4 == off) {
                if ($hget(Mod.Advert.hSet, Mod.Advert.Op) == on) {
                  hadd -m Mod.Advert.hSet Mod.Advert.Op off
                  hsave -i Mod.Advert.hSet $Mod.Advert.aFile Set
                  .notice $nick 14Die09 Ops 14dürfen nun keine Werbung mehr machen!
                }
                else {
                  .notice $nick 14Die09 Ops 14dürfen schon keine Werbung machen!
                }
              }
              else {
                .notice $nick 14Du hast vergessen09 On 14oder09 Off 14anzugeben!
              }
            }
            else {
              .notice $nick 14Du hast vergessen09 On 14oder09 Off 14anzugeben!
            }
          }

        }
        else {
          .notice $nick Set
        }
      }
    }
    else {
      .notice $nick null
    }
  }
}

alias Mod.Advert.aHash {
  if (!$hget(Mod.Advert.hSet, Mod.Advert.Op)) {
    hadd -m Mod.Advert.hSet Mod.Advert.Op on
  }
  if (!$hget(Mod.Advert.hSet, Mod.Advert.Status)) {
    hadd -m Mod.Advert.hSet Mod.Advert.Status On
  }
  hsave -i Mod.Advert.hSet $Mod.Advert.aFile Set
}

raw 322:*:{
  if ($left($nick($gettok(%Mod.Advert.vRaw, 1, 32), $me).pnick, 1) isin ~&@%) {
    .kick $gettok(%Mod.Advert.vRaw, 1, 32) $gettok(%Mod.Advert.vRaw, 2, 32) Channel Werbung
  }
}

alias Mod.Advert.aFile {
  if (!$isdir(System)) {
    mkdir System
  }
  return $mircdirSystem\Advert.hsh
}
