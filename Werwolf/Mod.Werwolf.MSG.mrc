;*************************************************************************************************
;*
;* Werwolf Message-Layer v1.2 � by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung
;*************************************************************************************************
;*
;* Message-Layer f�r das Werwolf-Spiel. Erlaubt das Spielen und Steuern des Spiels �ber Channel-
;* u. Query-Messages
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;*
;* - Channel -
;* !werwolf
;*          set
;*              an               - Aktiviert Werwolf im Channel (nur f�r Ops)
;*              aus              - Deaktiviert Werwolf im Channel (nur f�r Ops)
;*              rate             - Setzt die Rate der Werw�lfe (Wert: 20-50, nur f�r Ops)
;*              min              - Setzt die minimale Spieler-Anzahl (Wert: >=4, nur f�r Ops)
;*              max              - Setzt die maximale Spieler-Anzahl, 0 f�r unendlich (nur f�r Ops)
;*              assasine an/aus  - Schaltet die angegebene Spezial-F�higkeit an oder aus
;*              k�nig an/aus
;*              hexe an/aus
;*              heiliger an/aus
;*              liebende an/aus
;*              dieb an/aus
;*              seher an/aus
;*              slowtop10 an/aus - Aktiviert die langsame Ausgabe der Top10 
;*
;*          blacklist            - Zeigt die Liste der ausgeschlossenen Hostmasks an
;*              add hostmask     - F�gt eine neue Hostmask der zur Blacklist hinzu
;*              del hostmask/nr  - Entfernt die angegebene Hostmask aus der Blacklist
;*                                 es ist auch m�glich die Nummer der Hostmask anzugeben
;*
;*          start                - Startet ein Spiel im Channel
;*          reset                - Setzt ein aktuell laufendes Spiel zur�ck (nur f�r Ops)
;*          resetstats           - Setzt die Werwolf-Stats zur�ck (nur f�r Ops)
;*          pause                - Pausiert das aktuell laufende Spiel (nur f�r Ops)
;*          resume               - F�hrt ein pausiertes Spiel fort (nur f�r Ops)
;*          top10                - Zeigt die Werwolf-Statistik an
;*          myrank [nick]        - Zeigt die Statistik des angegebenen Nicks an
;*                                 ohne Angabe des Nicks wird die eigene Statistik angezeigt
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.speedspace-irc.eu
;* Port: 6667
;*
;*************************************************************************************************
;*                                          Credits
;*************************************************************************************************
;* Ein gro�es Dank geht an die vielen Tester, die mir bei der Entwicklung des Scripts mit Rat und
;* Tat zur Seite standen:
;*
;* Firefox, empi, MuuuH, LightShadow, Liath, toolx, BioHazaRD, Andy, SeaBear, knisterle, CyberDad
;* babapapa, blubbl, karl, Nebelsaenger, Shorty, tonyp, DancingBytes, Nemesis, keenbock,
;* BonsaiGirl, bonscott, s0m4, seraphim, Schatten, karaya1, f0s
;*
;*************************************************************************************************

on *:NICK: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  Mod.Werwolf.Rename %chan $nick $newnick
}

on *:QUIT: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  Mod.Werwolf.Leave %chan $nick
}

on *:PART:#: {
  if (!$Mod.Werwolf.IsPlayer($chan, $nick)) return
  Mod.Werwolf.Leave $chan $nick
}

on *:KICK:#: {
  if (!$Mod.Werwolf.IsPlayer($chan, $knick)) return
  Mod.Werwolf.Kick $chan $knick
}

on *:text:!werwolf start*:#: Mod.Werwolf.Start $chan $nick

on *:text:!go:#: Mod.Werwolf.Login $chan $nick

on *:text:!werwolf reset:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  if ($nick !isop $chan) return
  Mod.Werwolf.Reset $chan
  msg $chan $normal $+ Werwolf in $chan $hl(zur�ckgesetzt) $+ .
}

on *:text:!werwolf resetstats:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  if ($nick !isop $chan) return
  Mod.Werwolf.ResetStats
  msg $chan $normal $+ Werwolf-Stats $hl(zur�ckgesetzt) $+ .
}

on *:text:!werwolf info:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  notice $nick $normal $+ Werwolf Addon v1.2 � by $hl(www.eVolutionX-Project.de) $+  ( $+ $hl(eVolutionX-Project Team) $+ )
  notice $nick $normal $+ Regeln: $hl(http://www.dreamflasher.de/other-projects/werwolf-spiel)
}

on *:text:!werwolf pause:#: {
  if ($nick !isop $chan) return
  Mod.Werwolf.Pause $chan
}

on *:text:!werwolf resume:#: {
  if ($nick !isop $chan) return
  Mod.Werwolf.Resume $chan
}

on *:text:!werwolf top10:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  if ($timer($+(Mod.Werwolf.FloodProt., $chan))) return
  $+(.timerMod.Werwolf.FloodProt., $chan) 1 180 noop
  var %window = @Mod.Werwolf.wSort
  Mod.Werwolf.SortStats
  if (!$line(%window, 0)) {
    msg $chan $normal $+ Keine Top10 f�r Werwolf verf�gbar...
    window -c %window
    return
  }
  msg $chan $normal $+ - $hl(Werwolf Stats) $normal $+ -
  var %i = 1, %nick, %points, %games, %current
  while (%i <= 10) {
    %current = $line(%window, %i)
    if (!%current) break
    %nick = $gettok(%current, 1, 44)
    %points = $gettok(%current, 2, 44)
    %games = $gettok(%current, 3, 44)
    if ($hget(Mod.Werwolf.hConfig, msg.slowtop10)) .timer 1 %i msg $chan $special $+  $+ %i $+ )  $+ $normal $+ %nick ( $+ $hl(%points) $iif(%points == 1, Punkt, Punkte) / $hl(%games) $iif(%games == 1, Spiel, Spiele) $+ , Rate: $hl($round($calc(%points / %games * 100), 1) $+ % ) $+ ) 
    else msg $chan $special $+  $+ %i $+ )  $+ $normal $+ %nick ( $+ $hl(%points) $iif(%points == 1, Punkt, Punkte) / $hl(%games) $iif(%games == 1, Spiel, Spiele) $+ , Rate: $hl($round($calc(%points / %games * 100), 1) $+ % ) $+ ) 
    inc %i
  }
  window -c %window
}

on *:text:!werwolf kick *:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  if ($nick !isop $chan) return
  Mod.Werwolf.Kick $chan $3
}

on *:text:!werwolf myrank*:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  var %window = @Mod.Werwolf.wSort
  var %nick = $iif($3 == $null, $nick, $3)
  Mod.Werwolf.SortStats
  var %nr = $fline(%window, %nick $+ $chr(44) $+ *, 1)
  if (!%nr) {
    msg $chan $normal $+ F�r $hl(%nick) sind keine Infos verf�gbar
    window -c %window
    return
  }
  var %current = $line(%window, %nr)
  var %nick = $gettok(%current, 1, 44)
  var %points = $gettok(%current, 2, 44)
  var %games = $gettok(%current, 3, 44)
  msg $chan $hl(%nick) ist aktuell auf dem $hl(%nr $+ ten) Platz mit $hl(%points) $iif(%points == 1, Punkt, Punkten) in $hl(%games) $iif(%games == 1, Spiel, Spielen)
  window -c %window
}

on *:text:!werwolf showset:#: {
  notice $nick $normal $+ - $hl(Aktuelle Konfiguration) -
  notice $nick $normal $+ Aktiv in: $hllist($Mod.Werwolf.Config().ActiveChans)
  notice $nick $normal $+ Werwolfrate: $hl($Mod.Werwolf.Config().Rate $+ % )
  var %specials
  if ($Mod.Werwolf.Config(assasine).IsActive) %specials = $addtok(%specials, Assasine, 44)
  if ($Mod.Werwolf.Config(king).IsActive) %specials = $addtok(%specials, K�nig, 44)
  if ($Mod.Werwolf.Config(witch).IsActive) %specials = $addtok(%specials, Hexe, 44)
  if ($Mod.Werwolf.Config(lovers).IsActive) %specials = $addtok(%specials, Liebende, 44)
  if ($Mod.Werwolf.Config(hollyman).IsActive) %specials = $addtok(%specials, Heiliger, 44)
  if ($Mod.Werwolf.Config(seer).IsActive) %specials = $addtok(%specials, Seher, 44)
  if ($Mod.Werwolf.Config(thief).IsActive) %specials = $addtok(%specials, Dieb, 44)
  notice $nick $normal $+ Aktive Specials: $hllist(%specials)
  notice $nick $normal $+ Spieler-Limit von $hl($Mod.Werwolf.Config().MinPlayer) bis $hl($iif($Mod.Werwolf.Config().MaxPlayer == 0, unendlich, $Mod.Werwolf.Config().MaxPlayer))
}

on *:text:!werwolf set *:#: {
  if ($nick !isop $chan) return
  if ($3 == an) {
    var %chan = $iif($4 == $null, $chan, $4)
    if ($nick !isop %chan) return
    var %result = $Mod.Werwolf.Set(e, %chan)
    if ($gettok(%result, 1, 32)) .msg $chan $normal $+ Werwolf wurde $hl(aktiviert) f�r %chan $+ .
    else {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == already_set) .msg $chan $normal $+ Werwolf ist $hl(bereits aktiv) in %chan $+ .
    }
  }
  elseif ($3 == aus) {
    var %chan = $iif($4 == $null, $chan, $4)
    var %result = $Mod.Werwolf.Set(d, %chan)
    if ($gettok(%result, 1, 32)) .msg $chan $normal $+ Werwolf wurde $hl(deaktiviert) in %chan $+ .
    else {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == already_set) .msg $chan $normal $+ Werwolf ist $hl(nicht aktiv) in %chan $+ .
    }
  }
  elseif ($3 == rate) {
    var %result = $Mod.Werwolf.Set(r, $4)
    if ($gettok(%result, 1, 32)) .msg $chan $normal $+ Die Wahrscheinlichkeit das man Wolf wird betr�gt nun $hl($Mod.Werwolf.Config().Rate $+ %) $+ .
    else {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == wrong_value) .msg $chan $normal $+ Bitte gib einen Wert von $hl(20) bis $hl(50) an.
    }
  }
  elseif ($3 == min) {
    var %result = $Mod.Werwolf.Set(m, $4)
    if ($gettok(%result, 1, 32)) .msg $chan $normal $+ Die minimale Spielerzahl betr�gt nun $hl($Mod.Werwolf.Config().MinPlayer) $+ .
    else {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == wrong_value) .msg $chan $normal $+ Bitte gib eine Zahl gr��er oder gleich $hl(4) ein.
    }
  }
  elseif ($3 == max) {
    var %result = $Mod.Werwolf.Set(n, $4)
    if ($gettok(%result, 1, 32)) .msg $chan $normal $+ Die maximale Spielerzahl betr�gt nun $hl($iif($Mod.Werwolf.Config().MaxPlayer == 0, unendlich, $Mod.Werwolf.Config().MaxPlayer)) $+ .
    else {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == wrong_value) .msg $chan $normal $+ Bitte gib eine Zahl ein.
    }
  }
  elseif ($3 == slowtop10) {
    if ($4 !isin an aus) {
      .msg $chan $normal $+ Du musst entweder $hl(an) oder $hl(aus) angeben.
      return      
    }
    var %value = $replace($4, an, $true, aus, $false)
    if (%value == $hget(Mod.Werwolf.hConfig, msg.slowtop10)) .msg $chan $hl($3) ist $hl($iif(%value == $true, bereits, nicht) aktiv) $+ .
    else {
      hadd Mod.Werwolf.hConfig msg.slowtop10 %value
      .msg $chan $hl($3) wurde $hl($iif(%value == $true, aktiviert, deaktiviert)) $+ .
    }
  }
  elseif ($3 isin k�nig hexe heiliger liebende assasine dieb seher) {
    var %option = $replace($3, k�nig, king, hexe, witch, heiliger, hollyman, liebende, lovers, dieb, thief, seher, seer)
    var %value = $iif($4 == an, $true, $iif($4 == aus, $false, $null))
    if (%value == $null) {
      .msg $chan $normal $+ Du musst entweder $hl(an) oder $hl(aus) angeben.
      return
    }
    var %result = $Mod.Werwolf.Set($iif(%value = $true, e, d), %option)
    if ($gettok(%result, 1, 32)) .msg $chan $hl($3) wurde $hl($iif(%value == $true, aktiviert, deaktiviert)) $+ .
    else {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == already_set) .msg $chan $hl($3) ist $hl($iif(%value == $true, bereits, nicht) aktiv) $+ .
    }
  }
}

on *:text:!werwolf blacklist*:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  if ($2 != blacklist) return
  if (!$3) {
    var %count = $Mod.Werwolf.Blacklist(0), %i
    %i = 1
    if (%count == 0) {
      notice $nick $normal $+ Die Blacklist ist aktuell $hl(leer) $+ .
      return
    }
    while (%i <= %count) {
      notice $nick $hl(%i $+ .) $Mod.Werwolf.Blacklist(%i)
      inc %i
    }
  }
  elseif ($3 == add) {
    Mod.Werwolf.BlacklistAdd $4
    if ($gettok($result, 1, 32)) {
      notice $nick $normal $+ Die Hostmask $hl($4) wurde erfolgreich hinzugef�gt.
    }
    elseif ($gettok($result, 2, 32) == already_set) {
      notice $nick $normal $+ Die Hostmask $hl($4) ist bereits in der Blacklist.
    }
  }
  elseif ($3 == del) {
    Mod.Werwolf.BlacklistDel $4
    if ($gettok($result, 1, 32)) {
      notice $nick $normal $+ Eintrag $hl($4) erfolgreich gel�scht.
    }
    elseif ($gettok($result, 2, 32) == wrong_value) {
      notice $nick $normal $+ Eintrag $hl($4) nicht gefunden.
    }
  }
}

on *:text:!vote *:#: {
  var %chan = $chan
  if ($Mod.Werwolf.Info(%chan).State == day) {
    var %result = $Mod.Werwolf.DayVote(%chan, $nick, $2)
    if (!$gettok(%result, 1, 32)) {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == no_player) .notice $nick $hl($2) ist kein B�rger aus dem Dorf.
      elseif (%cause == already_set) .notice $nick $normal $+ Du hast deine Stimme bereits abgegeben.
    }
  }
  elseif ($Mod.Werwolf.Info(%chan).State == afternoon) {
    if ($nick != $Mod.Werwolf.Info(%chan).King) return
    var %class = $Mod.Werwolf.Info(%chan, $nick).PlayerClass
    if ((%class != wulfs) && (%class != people)) return
    var %result = $Mod.Werwolf.KingVote(%chan, $2)
    if (!$gettok(%result, 1, 32)) {
      var %cause = $gettok(%result, 2, 32)
      if (%cause == no_player) .notice $nick $normal $+ Der von dir gew�hlte B�rger $hl($2) steht nicht zur Wahl.
    }
  }
}

on *:text:!missing:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  var %chan = $chan
  if ($Mod.Werwolf.Info(%chan).State != day) return
  var %class = $Mod.Werwolf.Info(%chan, $nick).PlayerClass
  if ((%class != wulfs) && (%class != people)) return
  msg %chan $normal $+ Folgende B�rger m�ssen noch abstimmen: $hllist($Mod.Werwolf.Info(%chan).NeedToVote) $+ .
}

on *:text:!spieler:#: {
  if (!$Mod.Werwolf.Config($chan).IsActive) return
  var %chan = $chan
  if ($Mod.Werwolf.Info(%chan).State != day) return
  var %class = $Mod.Werwolf.Info(%chan, $nick).PlayerClass
  if ((%class != wulfs) && (%class != people)) return
  msg %chan $normal $+ Folgende Spieler sind noch dabei: $hllist($Mod.Werwolf.Info(%chan).Alive) $+ .
}

on *:text:!stehlen *:?: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  if ($Mod.Werwolf.Info(%chan).State == paused) return
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($nick != $Mod.Werwolf.Info(%chan).Thief) return
  var %result = $mod.Werwolf.Steal(%chan, $2)
  if ($gettok(%result, 1, 32)) msg $nick $normal $+ Du hast $hl($2) bestohlen und bist nun $hl($iif($Mod.Werwolf.Info(%chan, $nick).PlayerClass == wulfs, Werwolf, normaler B�rger)) $+ .
  else {
    var %cause = $gettok(%result, 2, 32)
    if (%cause == no_player) .msg $nick $hl($2) ist kein B�rger aus dem Dorf
    elseif (%cause == same_class) .msg $nick $normal $+ Pech gehabt, aber $2 ist auch $hl($iif($Mod.Werwolf.Info(%chan, $nick).PlayerClass == wulfs, Werwolf, normaler B�rger)) $+ , deine Chance als Dieb hast du vertan.
  }
}

on *:text:!ziel *:?: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  if ($Mod.Werwolf.Info(%chan).Assasine != $nick) return
  var %result = $Mod.Werwolf.SetAssasineAim(%chan, $2)
  if ($gettok(%result, 1, 32)) msg $nick $normal $+ Sollte $hl($2) morgen Abend am Galgen h�ngen hast du gewonnen.
  else {
    var %cause = $gettok(%result, 2, 32)
    if (%cause == already_set) .msg $nick $normal $+ Du hast bereits $hl($Mod.Werwolf.Info(%chan).AssasineAim) als Ziel gew�hlt.
    if (%cause == no_player) .msg $nick $hl($2) ist kein B�rger aus dem Dorf.
  }
}

on 1:text:!sehen *:?: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  if ($Mod.Werwolf.Info(%chan).Seer != $nick) return
  var %result = $Mod.Werwolf.See(%chan, $2)
  if ($gettok(%result, 1, 32)) msg $nick $hl($2) ist ein $hl($iif($gettok(%result, 2, 32) == wulfs, Werwolf, normaler B�rger)) $+ .
  else {
    var %cause = $gettok(%result, 2, 32)
    if (%cause == no_player) msg $nick $hl($2) ist kein B�rger aus dem Dorf.
    elseif (%cause == seer_done) msg $nick $normal $+ Du musst warten bis deine Kr�fte sich wieder aufgeladen haben.
  }
}

on 1:text:!gift *:?: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  if ($Mod.Werwolf.Info(%chan).Witch != $nick) return
  var %result = $Mod.Werwolf.WitchKill(%chan, $2)
  if ($gettok(%result, 1, 32)) msg $nick $normal $+ Du schleichst dich bei $hl($2) ins Haus und verabreichst deinem Opfer im Schlaf das $hl(Gift) $+ .
  else {
    var %cause = $gettok(%result, 2, 32)
    if (%cause == witch_killed) msg $nick $normal $+ Du hast in diesem Spiel schon jemanden vergiftet und hast kein Gift mehr �brig.
    elseif (%casue == no_player) msg $nick $hl($2) ist kein B�rger aus dem Dorf.
  }
}

on 1:text:!belebe*:?: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  if ($nick != $Mod.Werwolf.Info(%chan).Witch) return
  var %result = $Mod.Werwolf.WitchHeal(%chan, $2)
  if ($gettok(%result, 1, 32)) .msg $nick $normal $+ Du verabreichst deinen Wiederbelebungs-Trank und $hl($Mod.Werwolf.Info(%chan).WitchHealed) beginnt wieder zu atmen.
  else {
    var %cause = $gettok(%result, 2, 32)
    if (%cause == already_set) .msg $nick $normal $+ Du hast in diesem Spiel schon jemanden wiederbelebt und hast keinen Wiederbelebungs-Trank mehr �brig.
    elseif (%cause == no_player) .msg $nick $normal $+ Du musst angeben wen du wiederbeleben willst
    elseif (%cause == not_dieing) .msg $nick $hl($2) ist diese Nacht nicht gestorben
  }
}

on *:text:*:?: {
  var %chan = $Mod.Werwolf.PlaysIn($nick)
  if (!%chan) return
  if ($Mod.Werwolf.Info(%chan).State == paused) return
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).State == night) {
    var %wulfs = $Mod.Werwolf.Info(%chan).Wulfs
    if ($istok(%wulfs, $nick, 44)) {
      haltdef
      if ($left($1, 1) == !) {
        if ($1 == !team) .msg $nick $normal $+ Liste der W�lfe: $hllist($Mod.Werwolf.Info(%chan).Wulfs) $+ .
        if ($1 == !b�rger) .msg $nick $normal $+ Liste der B�rger: $hllist($Mod.Werwolf.Info(%chan).People) $+ .
        if ($1 == !zerfleisch) {
          var %result = $Mod.Werwolf.NightVote(%chan, $nick, $2)
          if ($gettok(%result, 1, 32)) .msg $nick $normal $+ Deine Stimme wurde an $hl($2) vergeben.
          else {
            var %cause = $gettok(%result, 2, 32)
            if (%cause == no_player) .msg $nick $hl($2) ist kein B�rger aus dem Dorf.
            elseif (%cause == already_set) .msg $nick $normal $+ Du hast deine Stimme bereits abgegeben.
          }
        }
      }
      else {
        if (%wulfs == $nick) return
        Mod.Werwolf.WulfcomSend %chan $nick $1-
      }
    }
  }
}

on 1:SIGNAL:Mod.Werwolf.Invite: .msg $1 $normal $+ Wer hat Lust auf eine Runde $hl(Werwolf) $+ ? Gebt $hl(!go) ein um euch anzumelden. Das Spiel beginnt automatisch in $hl(2) Minuten.

on 1:SIGNAL:Mod.Werwolf.LoggedIn: {
  .msg $1 $hl($2) ( $+ $Mod.Werwolf.Info($1, 0).Player $+ ) spielt mit.
  .notice $2 $normal $+ Solltest du einen $hl(Query-Blocker) besitzen, bitte nimm mich auf die $hl(Friend-Liste), da ich dich eventuell per Query anspreche.
}

on 1:SIGNAL:Mod.Werwolf.MissingPlayer: {
  var %chan = $1, %player = $2
  if (%player == 0) .msg %chan $normal $+ Leider hat sich $hl(kein) Spieler angemeldet, es m�ssen jedoch $hl(mindestens $Mod.Werwolf.Config().MinPlayer) sein um Werwolf spielen zu k�nnen.
  elseif (%player == 1) .msg %chan $normal $+ Leider hat sich nur $hl(%player) Spieler angemeldet, es m�ssen jedoch $hl(mindestens $Mod.Werwolf.Config().MinPlayer) sein um Werwolf spielen zu k�nnen.
  else .msg %chan $normal $+ Leider haben sich nur $hl(%player) Spieler angemeldet, es m�ssen jedoch $hl(mindestens $Mod.Werwolf.Config().MinPlayer) sein um Werwolf spielen zu k�nnen.
}

on 1:SIGNAL:Mod.Werwolf.Init: .msg $1 $hl($Mod.Werwolf.Info($1, 0).Player) Mitspieler sind der Einladung gefolgt. Vergabe der Rollen hat begonnen...

on 1:SIGNAL:Mod.Werwolf.Initiated: {
  var %chan = $1, %wulfs = $Mod.Werwolf.Info(%chan).Wulfs, %people = $Mod.Werwolf.Info(%chan).People
  .msg %chan $normal $+ Es war einmal ein kleines Dorf mit $hl($Mod.Werwolf.Info(%chan, 0).Player) Einwohnern. Bislang ging dort alles friedlich zu, bis zu dieser $hl(Nacht) $+ ...
  .msg %wulfs $normal $+ In deinen Adern flie�t alles au�er menschliches Blut. Du bist ein $hl(Werwolf) $+ .
  .msg %wulfs $normal $+ Halte dieses Query zur internen Kommunikation mit deinen Wolfsbr�dern ge�ffnet.
  .msg %wulfs $normal $+ Liste der W�lfe: $hllist(%wulfs) $+ .
  .notice %people $normal $+ Willkommen in unserem kleinen D�rfchen. Du bist ein $hl(normaler B�rger) $+ .
  var %lovers = $Mod.Werwolf.Info(%chan).Lovers, %thief = $Mod.Werwolf.Info(%chan).Thief, %king = $Mod.Werwolf.Info(%chan).King
  var %hollyman = $Mod.Werwolf.Info(%chan).Hollyman, %witch = $Mod.Werwolf.Info(%chan).Witch, %seer = $Mod.Werwolf.Info(%chan).Seer
  var %assasine = $Mod.Werwolf.Info(%chan).Assasine
  if (%assasine) .msg %assasine $normal $+ Du bist $hl(Assasine) $+ . Gebe hier jetzt mit $hl(!ziel <nick>) ein, wer als erster am Galgen h�ngen wird. Liegst du richtig, hast du gewonnen.
  if (%lovers) {
    .notice $gettok(%lovers, 1, 44) $normal $+ Du bist verliebt in $hl($gettok(%lovers, 2, 44)) $+ . Haltet euch gegenseitig am Leben, oder geht zusammen in den Tot.
    .notice $gettok(%lovers, 2, 44) $normal $+ Du bist verliebt in $hl($gettok(%lovers, 1, 44)) $+ . Haltet euch gegenseitig am Leben, oder geht zusammen in den Tot.
  }
  if (%king) {
    .msg %chan $normal $+ Der K�nig unseres kleinen Dorfes ist $hl(%king) $+ .
    .notice %king $normal $+ Du wurdest gerade zum $hl(K�nig) ernannt.
  }
  if (%thief) .msg %thief $normal $+ Du bist $hl(Dieb) und kannst hier w�hrend des ganzen Spieles einmal $hl(!stehlen <nick>) eingeben um mit $hl(<nick>) den Charakter (Werwolf/B�rger) zu tauschen.
  if (%hollyman) .notice %hollyman $normal $+ Des weiteren bist du ein $hl(Heiliger) und hast dadurch die Macht, dich vor Gestalten des Teufels zu sch�tzen.
  if (%seer) .msg %seer $normal $+ Du bist $hl(Seher) $+ , jede Nacht kannst du hier einmal $hl(!sehen <nick>) eingeben um zu erfahren ob <nick> $hl(Werwolf) oder $hl(B�rger) ist.
  if (%witch) .msg %witch $normal $+ Du bist die $hl(Hexe) $+ . In der Nacht kannst du hier einmal mit $hl(!gift <nick>) jemanden vergiften.
}

on 1:SIGNAL:Mod.Werwolf.WulfcomEnabled: .msg $Mod.Werwolf.Info($1).Wulfs $normal $+ Wulf-Com $hl(aktiviert) $+ . Du kannst nun �ber Eingabe in diesem Fenster mit deinen Wolfbr�dern ein Opfer ausw�hlen.

on 1:SIGNAL:Mod.Werwolf.WulfcomDisabled: .msg $Mod.Werwolf.Info($1).Wulfs $normal $+ Wulf-Com $hl(deaktiviert) $+ . Bei Tag musst du im Channel mit deinen Wolfbr�dern kommunizieren.

on 1:SIGNAL:Mod.Werwolf.Night: .msg $Mod.Werwolf.Info($1).Wulfs $normal $+ Tippe $hl(!zerfleisch <Nick>) um deine Stimme f�r den B�rger $hl(<Nick>) abzugeben.

on 1:SIGNAL:Mod.Werwolf.NightEnd: {
  var %chan = $1, %maxpoints = $2, %people = $3-
  var %wulfs = $Mod.Werwolf.Info(%chan).Wulfs
  if ($numtok(%people, 44) > 1) .msg %wulfs $normal $+ Ihr konntet euch bis zum morgengrauen nicht einigen, wen von $hllist(%people) ihr zerfleischen wollt.
  elseif ($numtok(%people, 44) == 0) .msg %wulfs $normal $+ Ihr konntet euch bis zum morgengrauen nicht einigen, wen ihr zerfleischen wollt.
  else {
    .msg %wulfs $normal $+ Eure Wahl fiel auf $hl(%people) mit $hl(%maxpoints) Stimmen
    if ($Mod.Werwolf.Info(%chan).Hollyman == %people) {
      .msg %wulfs $normal $+ Bei eurem Versuch $hl(%people) zu rei�en umgibt ihn $hl(die Aura Gottes) $+ . Ihr habt keine Chance und gebt letztendlich auf.
      .notice %people $normal $+ Du wirst von leisen Ger�uschen geweckt, pl�tzlich bist du umzingelt von Werw�lfen. Du schaffst es gerade noch deine $hl(heiligen Kr�fte) freizusetzen und �berlebst so den Angriff.
    }
    else .notice %people $normal $+ Du wirst von leisen Ger�uschen geweckt, pl�tzlich bist du von Werw�lfen umzingelt und wirst zerfleischt.
  }
  if ($Mod.Werwolf.Info(%chan).Assasine && !$Mod.Werwolf.Info(%chan).AssasineAim) {
    .msg %assasine $normal $+ Du hast dich in der Nacht nicht auf ein Ziel festlegen k�nnen, du bist ab jetzt nich mehr Assasine.
  }
}

on 1:SIGNAL:Mod.Werwolf.Morning: {
  var %chan = $1
  var %dieing = $Mod.Werwolf.Info(%chan).Dieing
  var %witch = $Mod.Werwolf.Info(%chan).Witch
  if ($Mod.Werwolf.Info(%chan).WitchKilled) %dieing = $remtok(%dieing, $Mod.Werwolf.Info(%chan).WitchKilled, 1, 44)
  if ((%witch != $null) && (%dieing != $null) && ($Mod.Werwolf.Info(%chan).WitchHealed == $null) && (!$istok(%dieing, %witch, 44))) {
    if ($numtok(%dieing, 44) > 1) .msg %witch $normal $+ Du findest bei deinem Morgen-Spaziergang $hl($replace(%dieing, $chr(44), $normal und $special)) tot auf der Erde liegen. Du hast $hl(20 Sekunden) zeit um einen von ihnen durch $hl(!belebe <nick>) einen Wiederbelebungs-Trank zu verabreichen bevor es zu sp�t ist.
    else .msg %witch $normal $+ Du findest bei deinem Morgen-Spaziergang $hl(%dieing) tot auf der Erde liegen. Du hast $hl(20 Sekunden) zeit %dieing durch $hl(!belebe) einen Wiederbelebungs-Trank zu verabreichen bevor es zu sp�t ist.
  }
}

on 1:SIGNAL:Mod.Werwolf.LoverDied: {
  var %chan = $1, %dead = $2, %alive = $3
  if ($Mod.Werwolf.Info(%chan).State == morning) {
    .notice %alive $normal $+ Bei deinem morgendlichen Spaziergang findest du einen K�rper leblos auf dem Boden liegen. Ohhh nein ... es ist ... es ist $hl(%dead) $+ .
    .notice %alive $normal $+ Du kannst den Schmerz �ber den Verlust deiner gro�en Liebe nicht mehr aushalten und folgst ihr in den Tot.
  }
  else .notice %alive $normal $+ Du kannst den Schmerz �ber den Verlust deiner gro�en Liebe $hl(%dead) nicht mehr aushalten und folgst ihr in den Tot.
}

on 1:SIGNAL:Mod.Werwolf.Day: {
  var %chan = $1, %died = $numtok($Mod.Werwolf.Info(%chan).Dieing, 44)
  if (%died == 1) .msg %chan $normal $+ Am Morgen erwachen alle Dorfbewohner und stellen mit Entsetzen fest, dass $hl(einer) unter ihnen get�tet wurde...
  elseif (%died > 1) .msg %chan $normal $+ Am Morgen erwachen alle Dorfbewohner und stellen mit Entsetzen fest, dass $hl(%died) unter ihnen get�tet wurde...
  else .msg %chan $normal $+ Am Morgen erwachen alle Dorfbewohner und stellen fest, dass es diese Nacht ausnahmsweise verbl�ffend r�hig geblieben ist.
}

on 1:SIGNAL:Mod.Werwolf.EnableVote: {
  var %chan = $1
  .msg %chan $normal $+ Alle B�rger versammeln sich auf dem Dorfplatz um dar�ber zu diskutieren, wer heute Abend am Galgen baumeln soll.
  .msg %chan $normal $+ Zu Beginn werden die verbliebenen B�rger vorgetragen: $hllist($Mod.Werwolf.Info(%chan).Alive) $+ .
  .msg %chan $normal $+ Tippe $hl(!vote <nick>) um deine Stimme f�r den B�rger $hl(<nick>) abzugeben.
}

on 1:SIGNAL:Mod.Werwolf.Afternoon: {
  var %chan = $1, %people = $Mod.Werwolf.Info(%chan).VotedPeople
  var %king = $Mod.Werwolf.Info(%chan).King
  if ($numtok(%people, 44) > 1 && %king) {
    %people = $remtok(%people, %king, 1, 44)
    if ($numtok(%people, 44) > 1) {
      .msg %chan $normal $+ Der K�nig $hl(%king) hat nun das letzte Wort, wer von diesen B�rgern an den Galgen kommt: $hllist(%people) $+ .
      .notice %king $normal $+ Du hast $hl(20 Sekunden) Zeit um mit $hl(!vote <nick>) einen der folgenden B�rger an den Galgen zu bef�rdern: $hllist(%people) $+ .
      return
    }
    else .msg %chan $normal $+ Der K�nig hat sein Machtwort gesprochen, $hl(%people) soll am Galgen h�ngen.
  }
}

on 1:SIGNAL:Mod.Werwolf.AfternoonEnd: {
  var %chan = $1, %maxpoints = $Mod.Werwolf.Info(%chan).VotedPoints, %people = $Mod.Werwolf.Info(%chan).VotedPeople
  if ($numtok(%people, 44) > 1) {
    .msg %chan $normal $+ Da Ihr euch bis zum abendgrauen nicht einigen konntet, wen von $hllist(%people) ihr erh�ngen wollt werden die Verhandlungen auf morgen vertagt.
  }
  elseif ($numtok(%people, 44) == 0) {
    .msg %chan $normal $+ Da Ihr euch bis zum abendgrauen nicht einigen konntet, wen ihr erh�ngen wollt werden die Verhandlungen auf morgen vertagt.
  }
  else {
    .msg %chan $normal $+ Eure Wahl fiel auf $hl(%people) mit $hl(%maxpoints) Stimmen.
    .msg %chan $normal $+ Es dauerte nicht lang da baumelte $hl(%people) auch schon am Strick.
  }
  .msg %chan $normal $+ Es wird dunkel und die Dorfbewohner gehen zu Bett und schlafen.
}

on 1:SIGNAL:Mod.Werwolf.Died: {
  var %chan = $1, %nr = $2, %name = $3, %class = $4
  .msg %chan $normal $+ Nach der Autopsie der $iif(%nr > 1, %nr $+ ten, $null) Leiche ist klar, es handelt sich um $hl(%name) $+ , $hl(%name) war ein $hl($iif(%class == people, normaler B�rger, Werwolf)) $+ .
}

on 1:SIGNAL:Mod.Werwolf.NewKing {
  var %chan = $1, %newking = $2
  .msg %chan $normal $+ Da der K�nig $hl($Mod.Werwolf.Info(%chan).King) abgedankt hat, wurde ein neuer K�nig ernannt. Sein Name ist $hl(%newking) $+ .
}

on 1:SIGNAL:Mod.Werwolf.Winner: {
  var %chan = $1, %type = $2, %winners = $3
  if (%type == wulfs) .msg %chan $normal $+ Die $hl(W�lfe) ( $+ $$hllist(%winners) $+ ) haben alle Menschen get�tet und haben damit $hl(gewonnen) $+ .
  elseif (%type == people) .msg %chan $normal $+ Die $hl(B�rger) ( $+ $$hllist(%winners) $+ ) konnten alle W�lfe t�ten und haben damit $hl(gewonnen) $+ .
  elseif (%type == lovers) .msg %chan $normal $+ Die $hl(Liebenden) ( $+ $hllist(%winners) $+ ) haben �berlebt, und wenn sie nicht gestorben sind, dann leben sie noch Heute.
  elseif (%type == assasine) .msg %chan $normal $+ Der Assasine $hl(%winners) hat seine Zielperson $hl($Mod.Werwolf.Info(%chan).AssasineAim) an den Galgen bekommen und damit $hl(gewonnen) $+ .
  elseif (%type == none) .msg %chan $normal $+ Nanu, wo sind denn alle? Das Dorf ist leer. Anscheinend hat $hl(gar keiner) �berlebt.
  close -m $replace($Mod.Werwolf.Info(%chan).Player, $chr(44), $chr(32))
}

on 1:SIGNAL:Mod.Werwolf.Paused: .msg $1 $normal $+ Das Spiel wurde $hl(pausiert) $+ !

on 1:SIGNAL:Mod.Werwolf.Resumed: .msg $1 $normal $+ Das Spiel geht $hl(weiter) $+ !

on 1:SIGNAL:Mod.Werwolf.DayVoted: .msg $1 $hl($2) $+ 's Wahl f�r den Galgen fiel auf $hl($3) $+ .

on 1:SIGNAL:Mod.Werwolf.KingVoted: .msg $1 $normal $+ Der K�nig hat sein Machtwort gesprochen, $hl($2) soll am Galgen h�ngen.

on 1:SIGNAL:Mod.Werwolf.NightVoted: {
  var %chan = $1, %voter = $2, %votes = $3
  var %wulfs = $remtok($Mod.Werwolf.Info(%chan).Wulfs, %voter, 1, 44)
  if (%wulfs) .msg %wulfs $hl(%voter) $+ 's Wahl f�r die Zerfleischung fiel auf $hl(%votes) $+ .
}

on 1:SIGNAL:Mod.Werwolf.Stolen: {
  var %chan = $1, %thief = $2, %aim = $3
  var %thiefclass = $Mod.Werwolf.Info(%chan, %thief).PlayerClass
  var %aimclass = $Mod.Werwolf.Info(%chan, %aim).PlayerClass
  notice %aim $normal $+ Du wurdest gerade in einen $hl($iif(%aimclass == wulfs, Werwolf, normaler B�rger)) verwandelt.
  var %wulf = $iif(%thiefclass == wulfs, %thief, %aim), %people = $iif(%thiefclass == people, %thief, %aim)
  var %wulfs = $remtok($Mod.Werwolf.Info(%chan).Wulfs, %wulf, 1, 44)
  msg %wulfs $hl(%people) hat sein Wolfsblut verloren und ist nun B�rger, daf�r wurde $hl(%wulf) zum Werwolf.
  if ($Mod.Werwolf.Info(%chan).State == night) {
    msg %people $normal $+ Wulf-Com $hl(deaktiviert) $+ . Du bist nun normaler B�rger.
    msg %wulf $normal $+ Wulf-Com $hl(aktiviert) $+ . Du kannst nun �ber Eingabe in diesem Fenster mit deinen Wolfbr�dern ein Opfer ausw�hlen.
    msg %wulf $normal $+ Tippe $hl(!zerfleisch <Nick>) um deine Stimme f�r den B�rger $hl(<Nick>) abzugeben.
    msg %wulfs $normal $+ Ihr m�sst nun neu w�hlen, wen ihr zerfleischen wollt.
  }
  elseif (($Mod.Werwolf.Info(%chan).State == morning) || ($Mod.Werwolf.Info(%chan).State == afternoon)) {
    var %name1 = $iif($rand(1,2) == 1, %wulf, %people), %name2 = $iif(%name1 == %wulf, %people, %wulf)
    msg %chan $hl(%name1) und $hl(%name2) haben die Rollen getauscht.
  }
  elseif ($Mod.Werwolf.Info(%chan).State == day) {
    var %name1 = $iif($rand(1,2) == 1, %wulf, %people), %name2 = $iif(%name1 == %wulf, %people, %wulf)
    msg %chan $hl(%name1) und $hl(%name2) haben die Rollen getauscht, ihr m�sst nun neu w�hlen.
  }
}

on 1:SIGNAL:Mod.Werwolf.WulfcomSent: {
  var %chan = $1, %sender = $2, %text = $3-
  var %wulfs = $remtok($Mod.Werwolf.Info(%chan).Wulfs, %sender, 1, 44)
  .msg %wulfs $hl(<) $+ %sender $+ $hl(>) $+  %text
}

on 1:SIGNAL:Mod.Werwolf.Renamed: .msg $1 $normal $+ Der B�rger $hl($2) hat sich umtaufen lassen in $hl($3) $+ .

on 1:SIGNAL:Mod.Werwolf.Left: .msg $1 $normal $+ Der B�rger $hl($2) hat das Dorf verlassen.

on 1:SIGNAL:Mod.Werwolf.Kicked: .msg $1 $normal $+ Der B�rger $hl($2) wurde aus dem Dorf geschmissen.

alias -l Mod.Werwolf.NightWarn {
  var %chan = $1
  .msg $Mod.Werwolf.Info(%chan).Wulfs $normal $+ Die Nacht wird bald wieder zum Tage. Ihr habt noch $hl(30 Sekunden) zeit um eure Stimme abzugeben.
}

alias -l Mod.Werwolf.DayWarn {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  .msg %chan $normal $+ Der Tag wird allm�hlig zur Nacht. Die B�rger, die ihre Stimme noch nicht abgegeben haben, haben noch $hl(30 Sekunden) zeit.
}

alias -l Mod.Werwolf.SortStats {
  var %hash = Mod.Werwolf.hStats
  var %window = @Mod.Werwolf.wSort
  var %count = $hget(%hash, 0).item
  if (!%count) {
    return
  }
  if ($window(%window)) window -c %window
  window -h %window 0 0 0 0
  while (%count) {
    aline -n %window $replace($hget(%hash, %count).item, @, $chr(91), +, $chr(93)) $+ , $+ $hget(%hash, %count).data
    dec %count
  }
  filter -wwac %window %window Mod.Werwolf.SortMethod *
}

alias -l Mod.Werwolf.SortMethod {
  var %p1 = $gettok($1, 2, 44), %g1 = $gettok($1, 3, 44), %p2 = $gettok($2, 2, 44), %g2 = $gettok($2, 3, 44)
  if ((%g1 < 10) || (%g2 < 10)) {
    ; Punktevergleich falls jemand weniger als 10 Spiele hat
    if (%p1 > %p2) return -1
    if (%p2 > %p1) return 1
    if (%g1 > %g2) return 1
    if (%g2 > %g1) return -1
    return 0
  }
  var %rate1 = $calc(%p1 / %g1), %rate2 = $calc(%p2 / %g2)
  if (%rate1 > %rate2) return -1
  if (%rate2 > %rate1) return 1
  if (%g1 > %g2) return -1
  if (%g2 > %g1) return 1
  return 0
}

alias -l normal /return 14
alias -l special /return 09

alias -l hl /return $+($special, $1-, $normal)
alias -l hllist /return $special $+ $replace($1-, $chr(44), $+($normal, $chr(44), $chr(32), $special)) $+ $normal
