;*************************************************************************************************
;*
;* Bundesliga Addon v1.3 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest die Bundesliga Tabelle aus und postet sie.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !bliga gibts die 1. Bundesliga Tabelle.
;* Mit !bliga2 gibts die 2. Bundesliga Tabelle.
;* Mit !bliga info siehst du den Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.3
;*   Fixed: Nues Format von 1ASport.de führte dazu das die tabellen nicht mehr gepostet wurden
;*
;* v1.2
;*   Fixed: Die Buchstaben "A" und "N" wurden nicht angezeigt.
;*
;* v1.1
;*   Fixed: Die Tabellen wurden nicht mehr gepostet.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.MindForge.org
;* Port: 6667
;* Channel: #IrcShark
;*
;* Befehl: /server -m irc.MindForge.org -j #IrcShark
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Bundesliga* off | unset %Mod.Bundesliga* }

;*************************************************************************************************
; - Trigger Befehle vom Bundesliga Addon.
;*************************************************************************************************
on *:TEXT:!bliga*:#:{
  if ($2 == info) { .notice $nick 14Bundesliga Addon v1.3 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Bundesliga-Flood., #, ., $cid))) {
    .timerMod.Bundesliga-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Bundesliga.sHTTP
    sockopen Mod.Bundesliga.sHTTP www.1asport.de 80
    sockmark Mod.Bundesliga.sHTTP # $+(/sport/fussball/, $iif($1 == !bliga2, 2-), bundesliga/tabelle/) $iif($1 == !bliga2, 2., 1.) | set -u10 %Mod.Bundesliga.vRead 1 | set -u10 %Mod.Bundesliga.vBRead 1
  }
  else {
    if ($timer($+(Mod.Bundesliga-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Bundesliga-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Bundesliga-vFlood., #, ., $cid, ., $nick) | .timerMod.Bundesliga-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Bundesliga-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Bundesliga-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Bundesliga-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet www.1asport.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Bundesliga.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $2 HTTP/1.1
  sockwrite -n $sockname Host: www.1asport.de
  sockwrite -n $sockname $crlf
  .msg $1 14Die09 Tabelle 14der09 $3 Bundesliga14 wird  gelesen ...
}

;*************************************************************************************************
; - Liest die Tabelle und die Ergebnisse der 1. Bundesliga aus und postet die.
;*************************************************************************************************
on *:SOCKREAD:Mod.Bundesliga.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Bundesliga.sRead
  while ($sockbr) {
    if ($regex(%Mod.Bundesliga.sRead, /<tr class="zliga_content1">/)) set -u10 %Mod.Bundesliga.vReady 1
    if ((%Mod.Bundesliga.vReady) && ($regex(%Mod.Bundesliga.sRead, /<td>&nbsp;(.*)&nbsp;</td>/))) set -u10 %Mod.Bundesliga.vTeam $Mod.Bundesliga.aReplace($remove($regml(1), $+($chr(40), N, $chr(41)), $+($chr(40), A, $chr(41))))
    if ((%Mod.Bundesliga.vReady) && ($regex(%Mod.Bundesliga.sRead, /<td align="center">&nbsp;(.*)/))) {
      if (%Mod.Bundesliga.vBRead == 1) { set -u10 %Mod.Bundesliga.vGames $remove($regml(1), &nbsp;, </td>) }
      if (%Mod.Bundesliga.vBRead == 2) { set -u10 %Mod.Bundesliga.vGew $remove($regml(1), &nbsp;, </td>) }
      if (%Mod.Bundesliga.vBRead == 3) { set -u10 %Mod.Bundesliga.vUne $remove($regml(1), &nbsp;, </td>) }
      if (%Mod.Bundesliga.vBRead == 4) { set -u10 %Mod.Bundesliga.vVer $remove($regml(1), &nbsp;, </td>) }
      if (%Mod.Bundesliga.vBRead == 5) { set -u10 %Mod.Bundesliga.vTor $remove($regml(1), &nbsp;, </td>) }
      if (%Mod.Bundesliga.vBRead == 6) { set -u10 %Mod.Bundesliga.vDif $remove($regml(1), &nbsp;, </td>) }
      if (%Mod.Bundesliga.vBRead == 7) {
        var %Mod.Bundesliga.vPkt = $remove($regml(1), &nbsp;, </td>)
        .timer 1 %Mod.Bundesliga.vRead .msg $1 14 $+ %Mod.Bundesliga.vRead $+ . 09 $+ %Mod.Bundesliga.vTeam 14Sp:09 %Mod.Bundesliga.vGames 14Gew:09 %Mod.Bundesliga.vGew 14Un:09 %Mod.Bundesliga.vUne 14Ver:09 %Mod.Bundesliga.vVer 14Tore:09 %Mod.Bundesliga.vTor 14Diff:09 %Mod.Bundesliga.vDif 14Pkt:09 %Mod.Bundesliga.vPkt 
        if (%Mod.Bundesliga.vRead == 18) { sockclose Mod.Bundesliga.sHTTP | unset %Mod.Bundesliga.* | halt }
        inc %Mod.Bundesliga.vRead | set -u10 %Mod.Bundesliga.vBRead 0
      }
      inc %Mod.Bundesliga.vBRead
    }
    sockread %Mod.Bundesliga.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht HTML Zeichen gegen ASCII Zeichen aus:
; - $Mod.Bundesliga.aReplace(Text)
;*************************************************************************************************
alias -l Mod.Bundesliga.aReplace if (($isid) && ($1-)) return $replace($1-, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &nbsp;, $chr(32), &#39;, ')

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
