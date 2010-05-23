;*************************************************************************************************
;*
;* Game Addon v1.1 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet die Game Top10 in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !game bekommst du die Games Top10 gepostet.
;* Mit !game <1-10> kannst du die weitere Infos über das Game in der Top10 wiedergeben lassen.
;* Mit !game info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Fixed: In den weiteren Infos über ein Top10 Game war HTML Code enthalten.
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
; - Entfernt die Timer & Variablen beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Game.* off | unset %Mod.Game* }

;*************************************************************************************************
; - Trigger Befehl des Game Addons.
;*************************************************************************************************
on *:TEXT:!game*:#:{
  if ($2 == info) { .notice $nick 14Game Addon v1.0 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if (!$timer($+(Mod.Game-Flood., #, ., $cid))) {
    if ($2) {
      if ($2 isnum 1-10) var %Mod.Game.vMore = $2
      else { .notice $nick 14Du kannst nur eine Zahl von 09114 bis 091014 angeben! | halt }
    }
    .timerMod.Game-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Game.sHTTP
    sockopen Mod.Game.sHTTP www.gamestar.de 80
    sockmark Mod.Game.sHTTP # %Mod.Game.vMore | set -u10 %Mod.Game.vRead 1
  }
  else {
    if ($timer($+(Mod.Game-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Game-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Game-vFlood., #, ., $cid, ., $nick) | .timerMod.Game-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Game-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Game-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Game-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.gamestar.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Game.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /charts/ HTTP/1.1
  sockwrite -n $sockname Host: www.gamestar.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Game Top10 oder Top20 aus und postet sie dann.
;*************************************************************************************************
on *:SOCKREAD:Mod.Game.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Game.sRead
  while ($sockbr) {
    if ($2) {
      if ($regex(%Mod.Game.sRead, /<div class="number"> $+ $2 $+ </div>/)) set -u20 %Mod.Game.vStart 1
      if ((%Mod.Game.vStart) && ($regex(%Mod.Game.sRead, /<a href="/_misc/games/redirecttogame.cfm.*" class="headline" style="font-size:11px;">(.*) </a>/))) set -u10 %Mod.Game.vName $regml(1)
      if ((%Mod.Game.vStart) && (<div class="leftcol">Publisher:</div> isin %Mod.Game.sRead)) set -u10 %Mod.Game.vPub y
      if ((%Mod.Game.vStart) && (%Mod.Game.vPub == y) && ($regex(%Mod.Game.sRead, /<a href="/index.cfm.*" class="link">(.*)</a>/))) set -u10 %Mod.Game.vPub $regml(1)
      if ((%Mod.Game.vStart) && (<div class="leftcol">Entwickler:</div> isin %Mod.Game.sRead)) set -u10 %Mod.Game.vEnt y
      if ((%Mod.Game.vStart) && (%Mod.Game.vEnt == y) && ($regex(%Mod.Game.sRead, /<a href="/index.cfm.*" class="link">(.*)</a>/))) set -u10 %Mod.Game.vEnt $regml(1)
      if ((%Mod.Game.vStart) && (<div class="leftcol">Genre:</div> isin %Mod.Game.sRead)) set -u10 %Mod.Game.vGen y
      if ((%Mod.Game.vStart) && (%Mod.Game.vGen == y) && ($regex(%Mod.Game.sRead, /<div class="rightcol">(.*)</div>/))) {
        set -u10 %Mod.Game.vGen $gettok($regml(1), 1, 60)
        if ($regex(%Mod.Game.sRead, /.*<div class="leftcol">USK:</div>.*<div class="rightcol">(.*)</div>.*/)) set -u10 %Mod.Game.vUSK $gettok($regml(1), 1, 60)
        if ($regex(%Mod.Game.sRead, /.*<div class="leftcol">Preis:.*<div class="rightcol">(.*)/)) set -u10 %Mod.Game.vEUR $replace($regml(1), &euro;, €)
      }
      if ((%Mod.Game.vStart) && (<div class="elementshort_foot_nav2"><img src="/img/0.gif" height="8" alt=""/></div> isin %Mod.Game.sRead)) {
        .msg $1 14-=(09 $2 $+ . %Mod.Game.vName 14)=-=(14 Publisher:09 %Mod.Game.vPub 14Entwickler:09 %Mod.Game.vEnt 14Genre:09 %Mod.Game.vGen 14USK:09 %Mod.Game.vUSK 14Preis:09 %Mod.Game.vEUR 14)=-
        sockclose Mod.Game.sHTTP | unset %Mod.Game.* | halt
      }
    }
    else {
      if ($regex(%Mod.Game.sRead, /<a href="/_misc/games/redirecttogame.cfm.*" class="headline" style="font-size:11px;">(.*) </a>/)) {
        set -u10 %Mod.Game.vName %Mod.Game.vName $+(09, %Mod.Game.vRead, .14) $regml(1) | inc %Mod.Game.vRead
      }
      if (%Mod.Game.vRead == 11) {
        .msg $1 14-=( Die aktuellen 09Game Top1014 von 09www.gamestar.de14 )=-
        .msg $1 $left(%Mod.Game.vName, $calc($pos(%Mod.Game.vName, 6.) - 1))
        .msg $1 $+(09, $gettok($mid(%Mod.Game.vName, $pos(%Mod.Game.vName, 6.)), 1, 32), , $remove($mid(%Mod.Game.vName, $pos(%Mod.Game.vName, 6.)), 6.))
        sockclose Mod.Game.sHTTP | unset %Mod.Game.* | halt
      }
    }
    sockread %Mod.Game.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
