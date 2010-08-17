;*************************************************************************************************
;*
;* Werwolf Addon v1.2 © by www.eVolutionX-Project.net (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung
;*************************************************************************************************
;*
;* Bringt das bekannte Gruppenspiel Werwolf ins IRC. Wer es kennt weiß worum es hier geht.
;* Solltest du jedoch zu der Gruppe gehören die es nicht kennt: http://www.dreamflasher.de/werwolf-spiel
;* Und nun viel Spaß beim zerwfleischen und erhängen.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.eVolutionX-Project.net
;* Port: 6667 bis 6669
;* SSL Port: +6697
;*
;*************************************************************************************************
;*                                          Credits
;*************************************************************************************************
;*
;* Ein großes Dank geht an die vielen Tester, die mir bei der Entwicklung des Scripts mit Rat und
;* Tat zur Seite standen:
;*
;* Firefox, empi, MuuuH, LightShadow, Liath, toolx, BioHazaRD, Andy, SeaBear, knisterle, CyberDad
;* babapapa, blubbl, karl, Nebelsaenger, Shorty, tonyp, DancingBytes, Nemesis, keenbock,
;* BonsaiGirl, bonscott, s0m4, seraphim, Schatten, karaya1
;*
;*************************************************************************************************
;* Events Start
;*************************************************************************************************

on 1:start: {
  Mod.Werwolf.LoadConfig
  Mod.Werwolf.LoadStats
}

on 1:exit: {
  Mod.Werwolf.SaveStats
  Mod.Werwolf.SaveConfig
}

on 1:load: {
  if (!$script(Mod.Werwolf.MSG.mrc)) {
    if (!$isfile($scriptdir $+ Mod.Werwolf.MSG.mrc)) {
      echo -a 04Das Script Mod.Werwolf.MSG.mrc wurde nicht gefunden. Bitte kopiere es in das selbe Verzeichnis wie $nopath($script)
      echo -a 04Werwolf-Spiel konnte nicht geladen werden!!!
      unload -rs $script
      return
    }
    else {
      load -rs $scriptdir $+ Mod.Werwolf.MSG.mrc
    }
    echo -a 14 $+ $Mod.Werwolf.Version (09www.eVolutionX-Project.net14) geladen und bereit!
  }
}

on 1:unload: {
  if ($script(Mod.Werwolf.MSG.mrc)) {
    unload -rs $script(Mod.Werwolf.MSG.mrc)
    echo -a 14 $+ $Mod.Werwolf.Version (09www.eVolutionX-Project.net14) entladen!
  }
}
;*************************************************************************************************
;* Events Ende
;*************************************************************************************************

;*************************************************************************************************
;* Mod.Werwolf.Aliases zur Steuerung des Spiels
;*************************************************************************************************
;* - Setzt verschiedene Einstellungen des Spiels
;* -> /Mod.Werwolf.Set -edrmn
;*************************************************************************************************
alias Mod.Werwolf.Set {
  var %hash = Mod.Werwolf.hConfig
  var %flag = $remove($1, -)
  var %result
  tokenize 32 $2-
  if (%flag == r) {
    if ($1 !isnum 20-50) %result = $false wrong_value
    else {
      hadd -m %hash werwolfrate $1
      %result = $true
    }
  }
  elseif ((%flag == e) || (%flag == d)) {
    var %set
    if (%flag == e) %set = $true
    else %set = $false
    if ($1 isin king hollyman witch thief lovers assasine seer) {
      %result = $true
      if (%set == $Mod.Werwolf.Config($1).IsActive) %result = $false already_set
      else hadd %hash $lower($1) %set
    }
    elseif (#* iswm $1) {
      var %chan = $iif($1 == $null, $chan, $1)
      %result = $true
      if (%set == $Mod.Werwolf.Config(%chan).IsActive) %result = $false already_set
      else {
        if (%set) hadd %hash activechans $addtok($hget(%hash, activechans), %chan, 44))
        elseif ($hget(%hash, activechans) == $1) hdel %hash activechans
        else hadd %hash activechans $remtok($hget(%hash, activechans), %chan, 1, 44))
      }
    }
    else %result = $false wrong_value
  }
  elseif (%flag == m) {
    if (($1 !isnum) || ($1 < 4)) %result = $false wrong_value
    else {
      hadd %hash minplayer $1
      %result = $true
    }
  }
  elseif (%flag == n) {
    if (($1 !isnum) || ($1 < 0)) %result = $false wrong_value
    else {
      hadd %hash maxplayer $1
      %result = $true
    }
  }
  else %result = $false unkown_flag
  return %result
}

alias Mod.Werwolf.Blacklist {
  var %hash = Mod.Werwolf.hBlacklist
  if ($1 isnum) {
    return $hget(%hash, $1).item
  }
  else {
    if ($hfind(%hash, $1, 1, W)) return $true
    return $false
  }
}

alias Mod.Werwolf.BlacklistAdd {
  if ($Mod.Werwolf.Blacklist($1)) return $false already_set
  hadd -m Mod.Werwolf.hBlacklist $1 $true
  return $true
}

alias Mod.Werwolf.BlacklistDel {
  if ($1 isnum) {
    if (($Mod.Werwolf.Blacklist(0) < $1) || ($1 < 1)) return $false wrong_value
    hdel Mod.Werwolf.hBlacklist $Mod.Werwolf.Blacklist($1)
    return $true
  }
  else {
    var %count = $hfind(Mod.Werwolf.hBlacklist, $1, 0, w)
    if (!%count) return $false wrong_value
    hdel -w Mod.Werwolf.hBlacklist $1
    return %count
  }
}

;*************************************************************************************************
;* - Gibt verschiedene Einstellungen des Spiels zurück
;* -> $Mod.Werwolf.Config(king).IsActive
;*************************************************************************************************
alias Mod.Werwolf.Config {
  var %hash = Mod.Werwolf.hConfig
  var %result
  if ($prop == Rate) {
    %result = $hget(%hash, werwolfrate)
    if (!%result) %result = 25
  }
  elseif ($prop == ActiveChans) return $hget(%hash, activechans)
  elseif ($prop == IsActive) {
    if ($1 isin witch hollyman king seer) {
      %result = $hget(%hash, $1)
      if (%result == $null) %result = $true
    }
    elseif ($1 isin thief lovers assasine) {
      %result = $hget(%hash, $1)
      if (%result == $null) %result = $false
    }
    elseif ($istok($hget(%hash, activechans), $1, 44)) %result = $true
    else %result = $false
  }
  elseif ($prop == MinPlayer) %result = $iif($hget(%hash, minplayer) == $null, 8, $hget(%hash, minplayer))
  elseif ($prop == MaxPlayer) {
    %result = $iif($hget(%hash, maxplayer) == $null, 0, $hget(%hash, maxplayer))
    var %minplayer = $iif($hget(%hash, minplayer) == $null, 8, $hget(%hash, minplayer))
    if ((%result > 0) && ( %result < %minplayer)) {
      %result = %minplayer
    }
  }
  return %result
}

;*************************************************************************************************
;* - Startet ein Spiel im angegebenen Channel
;* -> /Mod.Werwolf.Start #chan Nick
;*************************************************************************************************
alias Mod.Werwolf.Start {
  var %chan = $iif($1 != $null, $1, $chan)
  if (%chan == $null) return $false no_chan
  if (!$Mod.Werwolf.Config(%chan).IsActive) return $false not_active
  if (($2 != $null) && ($Mod.Werwolf.Blacklist($ial($2)) == $true)) return $false blacklisted
  if ($Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  hmake %hash
  hadd %hash state login
  $+(.timerMod.Werwolf.Timeout., %chan) 1 120 Mod.Werwolf.Beginn %chan
  .signal -n Mod.Werwolf.Invite %chan
  return $true
}

;*************************************************************************************************
;* - Added einen angegebenen Spieler zum Spiel im angegeben Channel
;* -> /Mod.Werwolf.Login #chan playername
;*************************************************************************************************
alias Mod.Werwolf.Login {
  var %chan = $iif($0 > 1, $1, $chan)
  var %player  = $iif($0 > 1, $2, $1)
  if ($Mod.Werwolf.Config().MaxPlayer > 0) {
    if ($Mod.Werwolf.Info(%chan, 0).Player >= $Mod.Werwolf.Config().MaxPlayer) return $false full
  }
  if ($Mod.Werwolf.Info(%chan).State != login) return $false wrong_state
  if ($Mod.Werwolf.Blacklist($ial($nick))) return $false blacklisted
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.IsPlayer(%chan, %player)) return $false already_set
  hadd %hash player $addtok($hget(%hash, player), %player, 44)
  .signal -n Mod.Werwolf.LoggedIn %chan %player
  if ($Mod.Werwolf.Info(%chan, 0).Player == $Mod.Werwolf.Config().MaxPlayer) .timer 1 0 Mod.Werwolf.Beginn $1
  return $true
}

;*************************************************************************************************
;* - Zeigt ob Werwolf im angegebenen Channel aktiv ist
;* -> $Mod.Werwolf.IsActive(#chan)
;*************************************************************************************************
alias Mod.Werwolf.IsActive {
  var %chan = $iif($1 == $null, $chan, $1)
  return $istok(%Mod.Werwolf.vActiveChans, %chan, 44)
}

;*************************************************************************************************
;* - Zeigt ob im angegebenen Channel aktuell ein Werwolf-Spiel läuft
;* -> $Mod.Werwolf.IsPlaying(#chan)
;*************************************************************************************************
alias Mod.Werwolf.IsPlaying {
  var %chan = $iif($1 == $null, $chan, $1)
  if ($hget(Mod.Werwolf.hGame. $+ %chan)) return $true
  else return $false
}

;*************************************************************************************************
;* - Zeigt ob der angegebene Spielername im Spiel im angegenen Channel mitspielt
;* -> $Mod.Werwolf.IsPlayer(#chan, playername)
;*************************************************************************************************
alias Mod.Werwolf.IsPlayer {
  if ($0 == 2) var %chan = $1, %nick = $2
  elseif ($0 == 1) var %chan = $chan, %nick = $1
  elseif ($0 == 0) var %chan = $chan, %nick = $nick
  if ($istok($Mod.Werwolf.Info(%chan).Player,%nick,44)) return $true
  else return $false
}

;*************************************************************************************************
;* - Zeigt in welchem Channel der angegebene Spieler gerade spielt.
;* -> $Mod.Werwolf.PlaysIn(playername)
;*************************************************************************************************
alias Mod.Werwolf.PlaysIn {
  var %nick = $iif($1 == $null, $nick, $1)
  var %tables = $hget(0), %chan
  while (%tables) {
    if (Mod.Werwolf.hGame.* iswm $hget(%tables)) {
      %chan = $gettok($v2, 4, 46)
      if ($Mod.Werwolf.IsPlayer(%chan, %nick)) return %chan
    }
    dec %tables
  }
}

;*************************************************************************************************
;* - Zeigt ob der angegebene ich Spieler im angegebenen Channel schon gevoted hat
;* -> $Mod.Werwolf.HasVoted(#chan, playername)
;*************************************************************************************************
alias Mod.Werwolf.HasVoted {
  var %chan = $1, %nick = $2
  if (!%nick) return $false
  return $istok($Mod.Werwolf.Info(%chan).Voted, %nick, 44)
}

alias Mod.Werwolf.Beginn {
  var %chan = $1
  if ($Mod.Werwolf.Info(%chan).State != login) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  hadd %hash state init
  var %player = $Mod.Werwolf.Info(%chan, 0).Player
  if (%player < $Mod.Werwolf.Config().MinPlayer) {
    .signal -n Mod.Werwolf.MissingPlayer %chan %player
    Mod.Werwolf.Reset %chan
    return $false no_player
  }
  .signal -n Mod.Werwolf.Init %chan
  Mod.Werwolf.ApplyClasses %chan
  Mod.Werwolf.ApplySpecials %chan
  .signal -n Mod.Werwolf.Initiated %chan
  Mod.Werwolf.Night %chan
  return $true
}

;*************************************************************************************************
;* - Setzt ein Spiel im angegeben Channel zurück
;* -> /Mod.Werwolf.Reset #chan
;*************************************************************************************************
alias Mod.Werwolf.Reset {
  Mod.Werwolf.ResetRound $1
  hfree -w $+(Mod.Werwolf.hGame., $1, *)
  $+(.timerMod.Werwolf.Start., $1) off
}

;*************************************************************************************************
;* - Gibt Spielinterne Informationen zurück
;* -> $Mod.Werwolf.Info(#chan).State
;*************************************************************************************************
alias Mod.Werwolf.Info {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (!$Mod.Werwolf.IsPlaying(%chan)) return
  if ($prop == State) return $hget(%hash, state)
  elseif ($prop == Player) {
    if ($2 == $null) return $hget(%hash, player)
    elseif ($2 == 0) return $numtok($hget(%hash, player), 44)
    elseif ($2 isnum) return $gettok($hget(%hash, player), $2, 44)
    elseif ($findtok($hget(%hash, player), $2, 1, 44)) return $gettok($hget(%hash, player), $v1, 44)
  }
  elseif ($prop == PlayerClass) {
    if ($istok($hget(%hash, wulfs), $2, 44)) return wulfs
    elseif ($istok($hget(%hash, people), $2, 44)) return people
    return $null
  }
  elseif ($prop == Wulfs) return $hget(%hash, wulfs)
  elseif ($prop == People) return $hget(%hash, people)
  elseif ($prop == DeadWulfs) return $hget(%hash, deadwulfs)
  elseif ($prop == DeadPeople) return $hget(%hash, deadpeople)
  elseif ($prop == Alive) {
    var %dead = $hget(%hash, deadpeople) $+ , $+ $hget(%hash, deadwulfs)
    var %alive = $hget(%hash, player)
    var %count = $numtok(%dead, 44)
    while (%count) {
      %alive = $remtok(%alive, $gettok(%dead, %count, 44), 1, 44)
      dec %count
    }
    return %alive
  }
  elseif ($prop == NeedToVote) {
    var %dead = $hget(%hash, deadpeople) $+ , $+ $hget(%hash, deadwulfs) $+ $iif($hget(%hash, voted) != $null, $chr(44) $+ $hget(%hash, voted), $null) $+ $iif($hget(%hash, state) == night, $chr(44) $+ $hget(%hash, people), $null)
    var %alive = $hget(%hash, player)
    var %count = $numtok(%dead, 44)
    while (%count) {
      %alive = $remtok(%alive, $gettok(%dead, %count, 44), 1, 44)
      dec %count
    }
    return %alive
  }
  elseif ($prop == VotedPoints) return $gettok($hget(%hash, voteresults), 1, 32)
  elseif ($prop == VotedPeople) return $gettok($hget(%hash, voteresults), 2-, 32)
  elseif ($prop == Voted) return $hget(%hash, voted)
  elseif ($prop == Hollyman) return $hget(%hash, hollyman)
  elseif ($prop == Thief) return $hget(%hash, thief)
  elseif ($prop == Lovers) return $hget(%hash, lovers)
  elseif ($prop == Seer) return $hget(%hash, seer)
  elseif ($prop == SeerDone) return $hget(%hash, seerdone)
  elseif ($prop == Assasine) return $hget(%hash, assasine)
  elseif ($prop == AssasineAim) return $hget(%hash, assasineaim)
  elseif ($prop == King) return $hget(%hash, king)
  elseif ($prop == Witch) return $hget(%hash, witch)
  elseif ($prop == WitchKilled) return $hget(%hash, witchkilled)
  elseif ($prop == WitchHealed) return $hget(%hash, witchhealed)
  elseif ($prop == Dieing) return $hget(%hash, dieing)
  elseif ($prop == WulfcomState) return $hget(%hash, wulfcom)
  elseif ($prop == PauseLeftSec) return $hget(%hash, pauseleftsec)
  elseif ($prop == PauseNextCmd) return $hget(%hash, pausenextcmd)
  elseif ($prop == PauseState) return $hget(%hash, pausestate)
}

;*************************************************************************************************
;* - Setzt die aktuelle Runde im Spiel auf Anfang
;* -> /Mod.Werwolf.ResetRound #chan
;*************************************************************************************************
alias Mod.Werwolf.ResetRound {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  Mod.Werwolf.ResetVote %chan
  if ($hget(%hash)) {
    hdel %hash seerdone
    hdel %hash coteresults
  }
  $+(.timerMod.Werwolf.Timeout., %chan) off
}

;*************************************************************************************************
;* - Ändert die Tageszeit im angegenen Channel zur Nacht
;* -> /Mod.Werwolf.Night #chan
;*************************************************************************************************
alias Mod.Werwolf.Night {
  var %chan = $1
  if (!$Mod.Werwolf.IsPlaying(%chan)) return
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  Mod.Werwolf.SetWulfcom %chan $true
  hadd %hash state night
  .signal -n Mod.Werwolf.Night %chan
  $+(.timerMod.Werwolf.Timeout., %chan) 1 180 Mod.Werwolf.NightEnd %chan
}

;*************************************************************************************************
;* - Beendet die Nacht im angegenen Channel
;* -> /Mod.Werwolf.NightEnd #chan
;*************************************************************************************************
alias Mod.Werwolf.NightEnd {
  var %chan = $1
  if ($Mod.Werwolf.Info(%chan).State != night) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %wulfs = $Mod.Werwolf.Info(%chan).Wulfs
  var %maxpoints = 0, %current, %people, %count = $hfind(%hash, V.*, 0, w)
  while (%count) {
    %current = $hfind(%hash, V.*, %count, w)
    if ($hget(%hash, %current) > %maxpoints) {
      %people = $gettok(%current, 2, 46)
      %maxpoints = $hget(%hash, %current)
    }
    elseif ($hget(%hash, %current) == %maxpoints) {
      %people = $addtok(%people, $gettok(%current, 2, 46), 44)
    }
    dec %count
  }
  .signal -n Mod.Werwolf.NightEnd %chan %maxpoints %people
  if ($numtok(%people, 44) == 1) {
    if ($Mod.Werwolf.Info(%chan).Hollyman == %people) hdel %hash hollyman
    else Mod.Werwolf.Die %chan %people
  }
  if (($Mod.Werwolf.Info(%chan).Assasine) && (!$Mod.Werwolf.Info(%chan).AssasineAim)) hdel %hash assasine
  Mod.Werwolf.ResetRound %chan
  .timer 1 0 Mod.Werwolf.Morning %chan
  return $true
}

;*************************************************************************************************
;* - Ändert die Tageszeit im angegenen Channel zum Morgen
;* -> /Mod.Werwolf.Morning #chan
;*************************************************************************************************
alias Mod.Werwolf.Morning {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  hadd %hash state morning
  Mod.Werwolf.SetWulfcom %chan $false
  var %witch = $Mod.Werwolf.Info(%chan).Witch
  var %dieing = $Mod.Werwolf.Info(%chan).Dieing
  .signal -n Mod.Werwolf.Morning %chan
  if ($Mod.Werwolf.Info(%chan).WitchKilled) %dieing = $remtok(%dieing, $Mod.Werwolf.Info(%chan).WitchKilled, 1, 44)
  if ((%witch != $null) && (%dieing != $null) && ($Mod.Werwolf.Info(%chan).WitchHealed == $null) && (!$istok(%dieing, %witch, 44))) {
    $+(.timerMod.Werwolf.Timeout., %chan) 1 20 Mod.Werwolf.MorningEnd %chan
  }
  else Mod.Werwolf.MorningEnd %chan
}

;*************************************************************************************************
;* - Beendet den Morgen im angegenen Channel
;* -> /Mod.Werwolf.MorningEnd #chan
;*************************************************************************************************
alias Mod.Werwolf.MorningEnd {
  var %chan = $1
  if ($Mod.Werwolf.Info(%chan).State != morning) return $false wrong_state
  var %dieing = $Mod.Werwolf.Info(%chan).Dieing
  var %lovers = $Mod.Werwolf.Info(%chan).Lovers
  var %lover1dead, %lover2dead
  var %lover1, %lover2
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  .signal -n Mod.Werwolf.MorningEnd %chan
  if (%lovers) {
    %lover1 = $gettok(%lovers, 1, 44)
    %lover2 = $gettok(%lovers, 2, 44)
    %lover1dead = $istok(%dieing, %lover1, 44)
    %lover2dead = $istok(%dieing, %lover2, 44)
    if (%lover1dead && !%lover2dead) {
      .signal -n Mod.Werwolf.LoverDied %chan %lover1 %lover2
      Mod.Werwolf.Die %chan %lover2
      hdel %hash lovers
    }
    if (%lover2dead && !%lover1dead) {
      .signal -n Mod.Werwolf.LoverDied %chan %lover2 %lover1
      Mod.Werwolf.Die %chan %lover1
      hdel %hash lovers
    }
  }
  .timer 1 0 Mod.Werwolf.Day %chan
  return $true
}

;*************************************************************************************************
;* - Ändert die Tageszeit im angegenen Channel zum Tag
;* -> /Mod.Werwolf.Day #chan
;*************************************************************************************************
alias Mod.Werwolf.Day {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  hadd %hash state day
  var %died = $Mod.Werwolf.Info(%chan).Dieing
  .signal -n Mod.Werwolf.Day %chan $numtok(%died, 44)
  Mod.Werwolf.Died %chan
  if ($Mod.Werwolf.CheckWin(%chan)) return
  .signal -n Mod.Werwolf.EnableVote %chan
  $+(.timerMod.Werwolf.Timeout., %chan) 1 180 Mod.Werwolf.DayEnd %chan
}

;*************************************************************************************************
;* - Beendet den Tag im angegenen Channel
;* -> /Mod.Werwolf.DayEnd #chan
;*************************************************************************************************
alias Mod.Werwolf.DayEnd {
  var %chan = $1
  if ($Mod.Werwolf.Info(%chan).State != day) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %maxpoints = 0, %current, %people, %count = $hfind(%hash, V.*, 0, w)
  while (%count) {
    %current = $hfind(%hash, V.*, %count, w)
    if ($hget(%hash, %current) > %maxpoints) {
      %people = $gettok(%current, 2, 46)
      %maxpoints = $hget(%hash, %current)
    }
    elseif ($hget(%hash, %current) == %maxpoints) {
      %people = $addtok(%people, $gettok(%current, 2, 46), 44)
    }
    dec %count
  }
  hadd %hash voteresults %maxpoints %people
  .signal -n Mod.Werwold.DisableVote %chan
  .timer 1 0 Mod.Werwolf.Afternoon %chan
  return $true
}

;*************************************************************************************************
;* - Ändert die Tageszeit im angegenen Channel zum Abend
;* -> /Mod.Werwolf.Afternoon #chan
;*************************************************************************************************
alias Mod.Werwolf.Afternoon {
  var %chan = $1, %maxpoints = $Mod.Werwolf.Info(%chan).VotedPoints, %people = $Mod.Werwolf.Info(%chan).VotedPeople
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %king = $Mod.Werwolf.Info(%chan).King
  hadd %hash state afternoon
  .signal -n Mod.Werwolf.Afternoon %chan
  if ($numtok(%people, 44) > 1 && %king) {
    %people = $remtok(%people, %king, 1, 44)
    if ($numtok(%people, 44) > 1) {
      $+(.timerMod.Werwolf.Timeout., %chan) 1 20 Mod.Werwolf.AfternoonEnd %chan
      return
    }
    else {
      inc %maxpoints
      hadd %hash voteresults %maxpoints %people
    }
  }
  Mod.Werwolf.AfternoonEnd %chan
}

;*************************************************************************************************
;* - Beendet den Abend im angegenen Channel
;* -> /Mod.Werwolf.AfternoonEnd #chan
;*************************************************************************************************
alias Mod.Werwolf.AfternoonEnd {
  var %chan = $1
  if ($Mod.Werwolf.Info(%chan).State != afternoon) return $false wrong_state
  var %maxpoints = $Mod.Werwolf.Info(%chan).VotedPoints, %people = $Mod.Werwolf.Info(%chan).VotedPeople
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %assasine = $Mod.Werwolf.Info(%chan).Assasine
  if (%assasine && (%people == $Mod.Werwolf.Info(%chan).AssasineAim)) {
    var %class = $Mod.Werwolf.Info(%chan, %assasine).PlayerClass
    hadd %hash deadpeople $remtok($addtok($hget(%hash, deadpeople), $hget(%hash, people), 44), %assasine, 1, 44)
    hadd %hash deadwulfs $remtok($addtok($hget(%hash, deadwulfs), $hget(%hash, wulfs), 44), %assasine, 1, 44)
    hdel %hash lovers
    hdel %hash wulfs
    hdel %hash people
    hadd %hash %class %assasine
    Mod.Werwolf.CheckWin %chan
    return
  }
  .signal -n Mod.Werwolf.AfternoonEnd %chan
  hdel %hash assasine
  hdel %hash assasineaim
  if ($numtok(%people, 44) == 1) {
    Mod.Werwolf.Die %chan %people
    var %lovers = $Mod.Werwolf.Info(%chan).Lovers
    if (%lovers) {
      if ($istok(%lovers, %people, 44)) {
        .signal -n Mod.Werwolf.LoverDied %chan %people $remtok(%lovers, %people, 1, 44)
        Mod.Werwolf.Die %chan $remtok(%lovers, %people, 1, 44)
        hdel %hash lovers
      }
    }
    Mod.Werwolf.Died %chan
    if ($Mod.Werwolf.CheckWin(%chan)) return $true
  }
  Mod.Werwolf.ResetRound %chan
  .timer 1 0 Mod.Werwolf.Night %chan
  return $true
}

alias Mod.Werwolf.SetWulfcom {
  var %chan = $1
  if (!$Mod.Werwolf.IsPlaying(%chan)) return
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($2) {
    hadd %hash wulfcom $true
    .signal -n Mod.Werwolf.WulfcomEnabled %chan
  }
  else {
    hadd %hash wulfcom $false
    .signal -n Mod.Werwolf.WulfcomDisabled %chan
  }
}

;*************************************************************************************************
;* - Sendet Text über die Wulfcom
;* -> /Mod.Werwolf.WulfcomSend #chan sender text
;*************************************************************************************************
alias Mod.Werwolf.WulfcomSend {
  var %chan = $1, %sender = $2, %text = $3-
  if ($Mod.Werwolf.Info(%chan, %sender).PlayerClass != wulfs) return $false no_wulf
  if (!$Mod.Werwolf.Info(%chan).WulfcomState) return $false wrong_state
  .signal -n Mod.Werwolf.WulfcomSent %chan %sender %text
  return $true
}

;*************************************************************************************************
;* - Votet am Tag wer an den Galgen soll
;* -> /Mod.Werwolf.DayVote #chan voter votes
;*************************************************************************************************
alias Mod.Werwolf.DayVote {
  var %chan = $1, %voter = $2, %votes = $3
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %class = $Mod.Werwolf.Info(%chan, %voter).PlayerClass
  if ((%class != wulfs) && (%class != people)) return $false not_playing
  if ((!$istok($Mod.Werwolf.Info(%chan).People, %votes, 44)) && (!$istok($Mod.Werwolf.Info(%chan).Wulfs, %votes, 44))) return $false no_player
  if ($Mod.Werwolf.HasVoted(%chan, $nick)) return $false already_set
  hadd %hash voted $addtok($hget(%hash, voted), %voter, 44)
  %votes = $Mod.Werwolf.Info(%chan, %votes).Player
  if ($hget(%hash, V. $+ %votes)) hinc %hash $+(V., %votes)
  else hadd %hash $+(V., %votes) 1
  .signal -n Mod.Werwolf.DayVoted %chan %voter %votes
  Mod.Werwolf.CheckVoteEnd %chan
  return $true
}

;*************************************************************************************************
;* - König-Stimme am Abend im angegeben Channel
;* -> /Mod.Werwolf.KingVote #chan votes
;*************************************************************************************************
alias Mod.Werwolf.KingVote {
  var %chan = $1, %votes = $2
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).State != afternoon) return $false wrong_state
  var %maxpoints = $Mod.Werwolf.Info(%chan).VotedPoints, %people = $Mod.Werwolf.Info(%chan).VotedPeople
  if ($numtok(%people, 44) < 2) return $false not_needed
  if (!$istok(%people, %votes, 44)) return $false no_player
  %votes = $Mod.Werwolf.Info(%chan, %votes).Player
  inc %maxpoints
  hadd %hash voteresults %maxpoints %votes
  .signal -n Mod.Werwolf.KingVoted %chan %votes
  .timer 1 0 Mod.Werwolf.AfternoonEnd %chan
  return $true
}

;*************************************************************************************************
;* - Votet in der Nacht wer zerfleischt werden soll
;* -> /Mod.Werwolf.DayVote #chan voter votes
;*************************************************************************************************
alias Mod.Werwolf.NightVote {
  var %chan = $1, %voter = $2, %votes = $3
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %wulfs = $Mod.Werwolf.Info(%chan).Wulfs
  if (!$istok(%wulfs, %voter, 44)) return $false no_wulf
  if ($Mod.Werwolf.Info(%chan).State != night) return $false wrong_state
  if (!$istok($Mod.Werwolf.Info(%chan).People, %votes, 44)) return $false no_player
  if ($Mod.Werwolf.HasVoted(%chan, $nick)) return $false already_set
  hadd %hash voted $addtok($hget(%hash, voted), %voter, 44)
  %votes = $Mod.Werwolf.Info(%chan, %votes).Player
  if ($hget(%hash, V. $+ %votes)) hinc %hash $+(V., %votes)
  else hadd %hash $+(V., %votes) 1
  .signal -n Mod.Werwolf.NightVoted %chan %voter %votes
  Mod.Werwolf.CheckVoteEnd %chan
  return $true
}

alias Mod.Werwolf.CheckVoteEnd {
  var %chan = $1
  var %state = $Mod.Werwolf.Info(%chan).State
  if (%state !isin night day) return $false wrong_state
  if (%state == night) {
    if ($numtok($Mod.Werwolf.Info(%chan).Voted, 44) == $numtok($Mod.Werwolf.Info(%chan).Wulfs, 44)) .timer 1 0 Mod.Werwolf.NightEnd %chan
  }
  elseif (%state == day) {
    if ($numtok($Mod.Werwolf.Info(%chan).Voted, 44) == $numtok($Mod.Werwolf.Info(%chan).Alive, 44)) .timer 1 0 Mod.Werwolf.DayEnd %chan
  }
}

;*************************************************************************************************
;* - Setzt das, vom Assasine gewählte Ziel
;* -> /Mod.Werwolf.SetAssasineAim #chan aim
;*************************************************************************************************
alias Mod.Werwolf.SetAssasineAim {
  var %chan = $1, %aim = $2
  if (!%chan) return
  if ($Mod.Werwolf.Info(%chan).State != night) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).AssasineAim) return $false already_set
  if (!$istok($Mod.Werwolf.Info(%chan).Alive, %aim, 44)) return $false no_player
  %aim = $Mod.Werwolf.Info(%chan, %aim).Player
  hadd %hash assasineaim %aim
  return $true
}

;*************************************************************************************************
;* - Überprüft für den Seher einen anderen Bürger
;* -> $Mod.Werwolf.See(#chan, aim)
;*************************************************************************************************
alias Mod.Werwolf.See {
  var %chan = $1, %see = $2
  if ($Mod.Werwolf.Info(%chan).State != night) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).SeerDone) return $false seer_done
  var %class = $Mod.Werwolf.Info(%chan, %see).PlayerClass
  if (!%class) return $false no_player
  hadd %hash seerdone $true
  return $true %class
}

;*************************************************************************************************
;* - Vergiftet das angegeben Ziel
;* -> /Mod.Werwolf.WitchKill #chan aim
;*************************************************************************************************
alias Mod.Werwolf.WitchKill {
  var %chan = $1, %aim = $2
  if ($Mod.Werwolf.Info(%chan).State != night) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).WitchKilled) return $false witch_killed
  var %class = $mod.Werwolf.Info(%chan, %aim).PlayerClass
  if (!%class) return $false no_player
  %aim = $Mod.Werwolf.Info(%chan, %aim).Player
  Mod.Werwolf.Die %chan %aim
  hadd %hash witchkilled %aim
  return $true
}

;*************************************************************************************************
;* - Heilt das angegeben Ziel
;* -> /Mod.Werwolf.WitchHeal #chan aim
;*************************************************************************************************
alias Mod.Werwolf.WitchHeal {
  var %chan = $1, %aim = $2
  if (!%chan) return $false no_chan
  if ($Mod.Werwolf.Info(%chan).State != morning) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %dieing = $Mod.Werwolf.Info(%chan).Dieing
  if ($Mod.Werwolf.Info(%chan).WitchKilled) %dieing = $remtok(%dieing, $Mod.Werwolf.Info(%chan).WitchKilled, 1, 44)
  if ((!%aim) && ($numtok(%dieing, 44) == 1)) %aim = %dieing
  if ($Mod.Werwolf.Info(%chan).WitchHealed) return $false already_set
  if (!%aim) return $false no_player
  if (!$istok(%dieing, %aim, 44)) return $false not_dieing
  %aim = $Mod.Werwolf.Info(%chan, %aim).Player
  hadd %hash dieing $remtok($Mod.Werwolf.Info(%chan).Dieing, %aim, 1, 44)
  hadd %hash witchhealed %aim
  .timer 1 0 Mod.Werwolf.MorningEnd %chan
  return $true
}

;*************************************************************************************************
;* - Bestiehlt das angegeben Ziel
;* -> /Mod.Werwolf.Steal #chan aim
;*************************************************************************************************
alias Mod.Werwolf.Steal {
  var %chan = $1
  if (!%chan) return $false no_chan
  if ((!$Mod.Werwolf.Info(%chan).State) || ($Mod.Werwolf.Info(%chan).State == paused)) return $false wrong_state
  var %thief = $Mod.Werwolf.Info(%chan).Thief, %aim = $2
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (!$istok($Mod.Werwolf.Info(%chan).Alive, $2, 44)) return $false no_player
  %aim = $Mod.Werwolf.Info(%chan, %aim).Player
  var %myclass = $Mod.Werwolf.Info(%chan, %thief).PlayerClass
  var %class = $Mod.Werwolf.Info(%chan, %aim).PlayerClass
  hdel %hash thief
  if (%myclass == %class) return $false same_class
  hadd %hash %class $remtok($hget(%hash, %class), $2, 1, 44)
  hadd %hash %myclass $remtok($hget(%hash, %myclass), $nick, 1, 44)
  hadd %hash %class $addtok($hget(%hash, %class), $nick, 44)
  hadd %hash %myclass $addtok($hget(%hash, %myclass), $2, 44)
  var %wulf = $iif(%class == wulfs, %thief, %aim), %people = $iif(%class == people, %thief, %aim)
  signal -n Mod.Werwolf.Stolen %chan %thief %aim
  var %wulfs = $remtok($Mod.Werwolf.Info(%chan).Wulfs, %wulf, 1, 44)
  if (%wulf == %aim) {
    if (%wulf == $Mod.Werwolf.Info(%chan).Seer) hdel %hash seer
    if (%wulf == $Mod.Werwolf.Info(%chan).Hollyman) hdel %hash hollyman
    if ((%wulf == $Mod.Werwolf.Info(%chan).Witch) && ($Mod.Werwolf.Info(%chan).State == morning)) .timer 1 0 Mod.Werwolf.MorningEnd %chan
    if (%wulf == $Mod.Werwolf.Info(%chan).Witch) hdel %hash witch
  }
  if ($Mod.Werwolf.Info(%chan).State == night) Mod.Werwolf.ResetVote %chan
  elseif ($Mod.Werwolf.Info(%chan).State == day) Mod.Werwolf.ResetVote %chan
  return $true
}

;*************************************************************************************************
;* - Der angegebene Spieler wird in die Sterbeliste aufgenommen
;* -> /Mod.Werwolf.Die #chan player
;*************************************************************************************************
alias Mod.Werwolf.Die {
  var %chan = $1, %player = $2
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (!$Mod.Werwolf.Info(%chan, %player).PlayerClass) return $false no_player
  %player = $Mod.Werwolf.Info(%chan, %player).Player
  hadd %hash dieing $addtok($hget(%hash,dieing), %player, 44)
  return $true
}

;*************************************************************************************************
;* - Die Sterbeliste wird abgearbeitet
;* -> /Mod.Werwolf.Died #chan
;*************************************************************************************************
alias Mod.Werwolf.Died {
  var %chan = $1, %player, %class
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %dieing = $Mod.Werwolf.Info(%chan).Dieing
  var %count = $numtok(%dieing, 44)
  var %i = 1
  while (%i <= %count) {
    %player = $gettok(%dieing, %i, 44)
    %class = $Mod.Werwolf.Info(%chan, %player).PlayerClass
    Mod.Werwolf.Remove %chan %player
    .signal -n Mod.Werwolf.Died %chan %i %player %class
    inc %i
  }
  if ($istok(%dieing, $Mod.Werwolf.Info(%chan).King, 44)) {
    Mod.Werwolf.NewKing %chan
  }
  hdel %hash dieing
  return $true
}

;*************************************************************************************************
;* - Der angegebene Spieler hat das Dorf (den Channel) verlassen
;* -> /Mod.Werwolf.Leave #chan player
;*************************************************************************************************
alias Mod.Werwolf.Leave {
  var %chan = $1, %player = $2
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  if (!$Mod.Werwolf.IsPlayer(%chan, %player)) return $false no_player
  var %class = $Mod.Werwolf.Info(%chan, %player).PlayerClass
  if ((%class != wulfs) && (%class != People) && $Mod.Werwolf.Info(%chan).State != login) return $false not_alive
  .signal -n Mod.Werwolf.Left %chan %player
  if ($Mod.Werwolf.Info(%chan).King == %player) Mod.Werwolf.NewKing %chan
  Mod.Werwolf.Remove %chan %player
  Mod.Werwolf.CheckVoteEnd %chan
  return $true
}

;*************************************************************************************************
;* - Der angegebene Spieler wurde aus dem Dorf (dem Channel) geschmissen
;* -> /Mod.Werwolf.Kick #chan player
;*************************************************************************************************
alias Mod.Werwolf.Kick {
  var %chan = $1, %player = $2
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  if (!$Mod.Werwolf.IsPlayer(%chan, %player)) return $false no_player
  .signal -n Mod.Werwolf.Kicked %chan %player
  if ($Mod.Werwolf.Info(%chan).King == %player) Mod.Werwolf.NewKing %chan
  Mod.Werwolf.Remove %chan %player
  Mod.Werwolf.CheckVoteEnd %chan
  return $true
}

;*************************************************************************************************
;* - Entfernt einen Spieler und alle seine Eigenschaften
;* -> /Mod.Werwolf.Remove #chan player
;*************************************************************************************************
alias Mod.Werwolf.Remove {
  var %chan = $1, %player = $2
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).State == login) {
    hadd %hash player $remtok($hget(%hash, player), %player, 1, 44)
  }
  else {
    %class = $Mod.Werwolf.Info(%chan, %player).PlayerClass
    if ($Mod.Werwolf.Info(%chan).Thief == %player) hdel %hash thief
    if (%class == people) {
      if (%player == $Mod.Werwolf.Info(%chan).Seer) hdel %hash seer
      if (%player == $Mod.Werwolf.Info(%chan).Witch) hdel %hash witch
      if (%player == $Mod.Werwolf.Info(%chan).Hollyman) hdel %hash hollyman
      hadd %hash deadpeople $addtok($hget(%hash, deadpeople), %player, 44)
      hadd %hash people $remtok($hget(%hash, people), %player, 1, 44)
    }
    elseif (%class == wulfs) {
      hadd %hash deadwulfs $addtok($hget(%hash, deadwulfs), %player, 44)
      hadd %hash wulfs $remtok($hget(%hash, wulfs), %player, 1, 44)
    }
    if ($istok($Mod.Werwolf.Info(%chan).Dieing, %player, 44)) {
      if ($hget(%hash, dieing) == %player) hdel %hash dieing
      else hadd %hash dieing $remtok($hget(%hash, dieing), %player, 1, 44)
    }
  }
  return $true
}

;*************************************************************************************************
;* - Ermittelt einen neuen König für das Spiel im angegebenen Channel
;* -> /Mod.Werwolf.NewKing #chan
;*************************************************************************************************
alias Mod.Werwolf.NewKing {
  var %chan = $1
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %current, %alive
  %alive = $Mod.Werwolf.Info(%chan).Alive
  %current = $gettok(%alive, $rand(1, $numtok(%alive, 44)), 44)
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (%current) {
    .signal -n Mod.Werwolf.NewKing %chan %current
    hadd %hash king %current
  }
  else hdel %hash king
  return $true
}

;*************************************************************************************************
;* - Setzt das Voting im angegebenen Channel zurück
;* -> /Mod.Werwolf.ResetVote #chan
;*************************************************************************************************
alias Mod.Werwolf.ResetVote {
  var %chan = $1
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (!$hget(%hash)) return
  hdel -w %hash V.*
  hdel -w %hash voted
  return $true
}

;*************************************************************************************************
;* - Überprüft ob das Spiel von jemandem gewonnen wurde
;* -> $Mod.Werwolf.CheckWin(#chan)
;*************************************************************************************************
alias Mod.Werwolf.CheckWin {
  var %chan = $1
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %winner, %winnertype
  var %alive = $Mod.Werwolf.Info(%chan).Alive
  var %lovers = $Mod.Werwolf.Info(%chan).Lovers
  var %player = $Mod.Werwolf.Info(%chan).Player
  if ($numtok(%alive, 44) == 0) %winnertype = none
  elseif (($numtok(%alive, 44) == 1) && (%alive == $Mod.Werwolf.Info(%chan).Assasine)) %winnertype = assasine
  elseif (!$Mod.Werwolf.Info(%chan).Wulfs) %winnertype = people
  elseif (!$Mod.Werwolf.Info(%chan).People) %winnertype = wulfs
  elseif (($numtok(%alive, 44) == 2) && ( %lovers )) %winnertype = lovers
  if (!%winnertype) return
  if (%winnertype == wulfs) %winner = $Mod.Werwolf.Info(%chan).Wulfs $+ $iif($Mod.Werwolf.Info(%chan).DeadWulfs != $null, $chr(44) $+ $Mod.Werwolf.Info(%chan).DeadWulfs, $null)
  elseif (%winnertype == people) %winner = $Mod.Werwolf.Info(%chan).People $+ , $+ $Mod.Werwolf.Info(%chan).DeadPeople
  elseif (%winnertype == lovers) %winner = %lovers
  elseif (%winnertype == assasine) %winner = $Mod.Werwolf.Info(%chan).Assasine
  elseif (%winnertype == none) %winner = $null
  .signal -n Mod.Werwolf.Winner %chan %winnertype %winner
  Mod.Werwolf.Reset %chan
  var %count, %current, %stats, %points, %games
  %count = $numtok(%player, 44)
  while (%count) {
    %current = $gettok(%player, %count, 44)
    %stats = $hget(Mod.Werwolf.hStats, $replace(%current, $chr(91), @, $chr(93), +))
    if (%stats) {
      %points = $gettok(%stats, 1, 44)
      %games = $gettok(%stats, 2, 44)
    }
    else {
      %points = 0
      %games = 0
    }
    inc %games
    if ($istok(%winner, %current, 44)) {
      inc %points
      if ($istok($Mod.Werwolf.Info(%chan).Lovers, %current, 44)) inc %points
    }
    hadd Mod.Werwolf.hStats $replace(%current, $chr(91), @, $chr(93), +) %points $+ , $+ %games
    dec %count
  }
  return %winner
}

;*************************************************************************************************
;* - Bennent den angegebenen Spieler im angegebenen Channel um
;* -> /Mod.Werwolf.Rename #chan oldname newname
;*************************************************************************************************
alias Mod.Werwolf.Rename {
  var %chan = $1, %oldname = $2, %newname = $3
  if (!$Mod.Werwolf.IsPlaying(%chan)) return $false wrong_state
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (!$hget(%hash)) return $false not_playing
  if (!$Mod.Werwolf.IsPlayer(%chan, %oldname)) return $false not_playing
  if ($Mod.Werwolf.IsPlayer(%chan, %newname)) return $false already_exist
  hadd %hash player $reptok($hget(%hash, player), %oldname, %newname, 44)
  hadd %hash wulfs $reptok($hget(%hash, wulfs), %oldname, %newname, 44)
  hadd %hash people $reptok($hget(%hash, people), %oldname, %newname, 44)
  if ($hget(%hash, deadwulfs)) hadd %hash deadwulfs $reptok($v1, %oldname, %newname, 44)
  if ($hget(%hash, deadpeople)) hadd %hash deadpeople $reptok($v1, %oldname, %newname, 44)
  if ($hget(%hash, lovers)) hadd %hash lovers $reptok($v1, %oldname, %newname, 44)
  if ($hget(%hash, dieing)) hadd %hash dieing $reptok($v1, %oldname, %newname, 44)
  if ($hget(%hash, voted)) hadd %hash voted $reptok($v1, %oldname, %newname, 44)
  if ($hget(%hash, thief) == %oldname) hadd %hash thief %newname
  if ($hget(%hash, witch) == %oldname) hadd %hash witch %newname
  if ($hget(%hash, king) == %oldname) hadd %hash king %newname
  if ($hget(%hash, seer) == %oldname) hadd %hash king %newname
  if ($hget(%hash, assasine) == %oldname) hadd %hash assasine %newname
  if ($hget(%hash, hollyman) == %oldname) hadd %hash hollyman %newname
  var %vote = $hget(%hash, $+(V., %oldname))
  if (%vote) {
    hdel %hash $+(V., %oldname)
    hadd %hash $+(V., %newname) %vote
  }
  var %voted = $Mod.Werwolf.Info(%chan).VotedPeople
  var %points = $Mod.Werwolf.Info(%chan).VotedPoints
  if ((%voted) && ($istok(%voted, %oldname, 44))) hadd %hash voteresults %points $reptok(%voted, %oldname, %newname, 44)
  .signal -n Mod.Werwolf.Renamed %chan %oldname %newname
  return $true
}

;*************************************************************************************************
;* - Pausiert das Spiel im angegebenen Channel
;* -> /Mod.Werwolf.Pause #chan
;*************************************************************************************************
alias Mod.Werwolf.Pause {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if (($Mod.Werwolf.Info(%chan).State == none) || ($Mod.Werwolf.Info(%chan).State == paused) || ($Mod.Werwolf.Info(%chan).State == login)) return $false
  hadd %hash pausestate $Mod.Werwolf.Info(%chan).State
  hadd %hash state paused
  hadd %hash pauseleftsec $timer(Mod.Werwolf.Timeout. $+ %chan).secs
  hadd %hash pausenextcmd $timer(Mod.Werwolf.Timeout. $+ %chan).com
  $+(.timerMod.Werwolf.Timeout., %chan) off
  signal -n Mod.Werwolf.Paused %chan
  return $true
}

;*************************************************************************************************
;* - Setzt ein pausiertes Spiel im angegebenen Channel fort
;* -> /Mod.Werwolf.Resume #chan
;*************************************************************************************************
alias Mod.Werwolf.Resume {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  if ($Mod.Werwolf.Info(%chan).State != paused) return $false
  var %leftsec = $Mod.Werwolf.Info(%chan).PauseLeftSec, %nextcmd = $Mod.Werwolf.Info(%chan).PauseNextCmd
  var %state = $Mod.Werwolf.Info(%chan).PauseState
  hadd %hash state %state
  signal -n Mod.Werwolf.Resumed %chan
  $+(.timerMod.Werwolf.Timeout., %chan) 1 %leftsec %nextcmd
  return $true
}

;*************************************************************************************************
;* - Gibt den Pfad zur der Datei zurück, in der Werwolf seine Daten speichert
;* -> $Mod.Werwolf.INIFile
;*************************************************************************************************
alias Mod.Werwolf.INIFile return $qt($mircdirwerwolf.ini)

;*************************************************************************************************
;* - Gibt den Pfad zur der Datei zurück, in der Werwolf seine Daten speichert
;* -> $Mod.Werwolf.Version().Full
;*************************************************************************************************
alias Mod.Werwolf.Version {
  var %version = 1.2
  if ((!$prop) || ($prop == Full)) return Werwolf-Addon v $+ %version © by eVolutionX-Team
  if ($prop == Nr) return %version
}

;*************************************************************************************************
;* - Lädt die Config aus $Mod.Werwolf.INIFile
;*************************************************************************************************
alias Mod.Werwolf.LoadConfig {
  if ($hget(Mod.Werwolf.hConfig)) hfree Mod.Werwolf.hConfig
  if ($hget(Mod.Werwolf.hBlacklist)) hfree Mod.Werwolf.hBlacklist
  hmake Mod.Werwolf.hConfig
  hmake Mod.Werwolf.hBlacklist
  hload -i Mod.Werwolf.hConfig $Mod.Werwolf.INIFile Config
  hload -i Mod.Werwolf.hBlacklist $Mod.Werwolf.INIFile Blacklist
}

;*************************************************************************************************
;* - Speichert die Config in $Mod.Werwolf.INIFile
;*************************************************************************************************
alias Mod.Werwolf.SaveConfig {
  remini $Mod.Werwolf.INIFile Config
  remini $Mod.Werwolf.INIFile Blacklist
  hsave -ia Mod.Werwolf.hConfig $Mod.Werwolf.INIFile Config
  hsave -ia Mod.Werwolf.hBlacklist $Mod.Werwolf.INIFile Blacklist
}

;*************************************************************************************************
;*                                            Stat-Alias START
;*************************************************************************************************
;* - Speichert die Stats in $Mod.Werwolf.INIFile
;*************************************************************************************************
alias Mod.Werwolf.SaveStats {
  hsave -ia Mod.Werwolf.hStats $Mod.Werwolf.INIFile Stats
}

alias Mod.Werwolf.ResetStats {
  remini $Mod.Werwolf.INIFile Stats
  hfree Mod.Werwolf.hStats
  hmake Mod.Werwolf.hStats
}

;*************************************************************************************************
;* - Lädt die Stats aus $Mod.Werwolf.INIFile
;*************************************************************************************************
alias Mod.Werwolf.LoadStats {
  if ($hget(Mod.Werwolf.hStats)) hfree Mod.Werwolf.hStats
  hmake Mod.Werwolf.hStats
  hload -i Mod.Werwolf.hStats $Mod.Werwolf.INIFile Stats
}


;*************************************************************************************************
;*                                            Local-Aliases
;*************************************************************************************************
alias -l Mod.Werwolf.ApplyClasses {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %player = $Mod.Werwolf.Info(%chan, 0).Player
  var %type, %wolfname, %wulfs = $int($calc(%player * $Mod.Werwolf.Config().Rate / 100))
  %wulfs = $iif(%wulfs > 1, %wulfs, 1)
  if ($rand(1,8) > 6) inc %wulfs
  while (%player) {
    if ((%player > %wulfs) && (%wulfs > 0)) {
      if ($rand(1,100) <= $Mod.Werwolf.Config().Rate) %type = wulfs
      else %type = people
    }
    elseif (%wulfs = 0) %type = people
    else %type = wulfs
    %wolfname = $gettok($hget(%hash, player), %player, 44)
    hadd %hash %type $addtok($hget(%hash, %type), %wolfname, 44)
    if (%type == wulfs) dec %wulfs
    dec %player
  }
}

alias -l Mod.Werwolf.ApplySpecials {
  var %chan = $1
  var %hash = $+(Mod.Werwolf.hGame., %chan)
  var %people = $hget(%hash, player)
  var %current

  ; Die Liebenden
  var %lover = %people
  if ($Mod.Werwolf.Config(lovers).IsActive) {
    if ($numtok(%lover, 44) > 1) {
      %current = $gettok(%lover, $rand(1, $numtok(%lover, 44)), 44)
      %lover = $remtok(%lover, %current, 1, 44)
      %current = %current $+ , $+ $gettok(%lover, $rand(1, $numtok(%lover, 44)), 44)
      hadd %hash lovers %current
    }
  }

  ; Assasin
  if ($Mod.Werwolf.Config(assasine).IsActive) {
    %current = $gettok(%people, $rand(1, $numtok(%people, 44)), 44)
    hadd %hash assasine %current
  }


  ; König (auch bekannt als Hauptmann)
  if ($Mod.Werwolf.Config(king).IsActive) {
    %current = $gettok(%people, $rand(1, $numtok(%people, 44)), 44)
    hadd %hash king %current
  }

  ; Dieb
  if ($Mod.Werwolf.Config(thief).IsActive) {
    if ($numtok(%people, 44) > 0) {
      %current = $gettok(%people, $rand(1, $numtok(%people, 44)), 44)
      %people = $remtok(%people, %current, 1, 44)
      hadd %hash thief %current
    }
  }

  ; Nachfolgende Eigenschaften sind nur für Bürger, Wölfe werden hier deswegen entfernt
  var %wulfs = $Mod.Werwolf.Info(%chan).Wulfs
  var %count = $numtok(%wulfs, 44)
  while (%count) {
    %people = $remtok(%people, $gettok(%wulfs, %count, 44), 1, 44)
    dec %count
  }

  ; Heiliger
  if ($Mod.Werwolf.Config(hollyman).IsActive) {
    if ($numtok(%people, 44) > 0) {
      %current = $gettok(%people, $rand(1, $numtok(%people, 44)), 44)
      %people = $remtok(%people, %current, 1, 44)
      hadd %hash hollyman %current
    }
  }

  ; Seher
  if ($Mod.Werwolf.Config(seer).IsActive) {
    if ($numtok(%people, 44) > 0) {
      %current = $gettok(%people, $rand(1, $numtok(%people, 44)), 44)
      %people = $remtok(%people, %current, 1, 44)
      hadd %hash seer %current
    }
  }

  ; Hexe
  if ($Mod.Werwolf.Config(witch).IsActive) {
    if ($numtok(%people, 44) > 0) {
      %current = $gettok(%people, $rand(1, $numtok(%people, 44)), 44)
      %people = $remtok(%people, %current, 1, 44)
      hadd %hash witch %current
    }
  }
}
