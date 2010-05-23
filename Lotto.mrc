;*************************************************************************************************
;*
;* Lotto Addon v1.0 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet die Lottozahlen in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !lotto bekommst du die letzten Lottozahlen gepostet.
;* Mit !lotto info bekommst du den Copyright angezeigt.
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
; - Trigger Befehl des Lotto Addons.
;*************************************************************************************************
on *:TEXT:!Lotto*:#:{
  if ($2 == info) { .notice $nick 14Lotto Addon v1.0 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Lotto-Flood., #, ., $cid))) {
    .timerMod.Lotto-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Lotto.sHTTP
    sockopen Mod.Lotto.sHTTP www.dielottozahlen.de 80
    sockmark Mod.Lotto.sHTTP # | set -u10 %Mod.Lotto.vRead 1
  }
  else {
    if ($timer($+(Mod.Lotto-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Lotto-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Lotto-vFlood., #, ., $cid, ., $nick) | .timerMod.Lotto-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Lotto-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Lotto-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Lotto-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.dielottozahlen.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Lotto.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET / HTTP/1.1
  sockwrite -n $sockname Host: www.dielottozahlen.de
  sockwrite -n $sockname $crlf

}

;*************************************************************************************************
; - Liest die Lotto Top10 aus und postet sie dann.
;*************************************************************************************************
on *:SOCKREAD:Mod.Lotto.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Lotto.sRead
  while ($sockbr) {
    if ($regex(%Mod.Lotto.sRead, /.*<font color="#666666">(.*)	<font size="4">(.*)</font><font color="#666666">(.*)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(.*)</font>.*/)) set -u10 %Mod.Lotto.vDate $regml(1) $regml(2) $+ $regml(3) $regml(4)
    if ($regex(%Mod.Lotto.sRead, /(.*)&nbsp;&nbsp; (.*)&nbsp;&nbsp; (.*)&nbsp;&nbsp; (.*)&nbsp;&nbsp; (.*)&nbsp;&nbsp; (.*)</font></b></font></td>/)) set -u10 %Mod.Lotto.vZahlen $+($regml(1), 14, $chr(44), 09 $regml(2), 14, $chr(44), 09 $regml(3), 14, $chr(44), 09 $regml(4), 14, $chr(44), 09 $regml(5), 14, $chr(44), 09 $regml(6))
    if ((!%Mod.Lotto.vZZ) && ($regex(%Mod.Lotto.sRead, /(.*)</font></b></td>/))) { if ($regml(1) isnum) set -u10 %Mod.Lotto.vZZ $v1 }
    elseif ((!%Mod.Lotto.vSZ) && ($regex(%Mod.Lotto.sRead, /(.*)</font></b></td>/))) { if ($regml(1) isnum) set -u10 %Mod.Lotto.vSZ $v1 }
    if ($regex(%Mod.Lotto.sRead, /<pre style="margin-top: 3; margin-bottom: 3" class="text">Ziehungsreihenfolge: (.*)</pre>/)) set -u10 %Mod.Lotto.vReihenfolge $replace($regml(1), $chr(44), $+(14, $chr(44), 09))
    if ($regex(%Mod.Lotto.sRead, /.*<span style="font-weight: 400">Spiel</span><font size="4">77:</font></font> (.*) <font color="#3333CC">.*Super</span><font size="4">6: </font></font>(.*)</pre>/)) {
      var %Mod.Lotto.vSpiel77 = $remove($regml(1) $regml(2), <span style="font-weight: 400">, </span>), %Mod.Lotto.vSuper6 = $gettok(%Mod.Lotto.vSpiel77, 4-5, 32)
      .msg $1 14-=(09 %Mod.Lotto.vDate 14)=-=(14 Lottozahlen:09 %Mod.Lotto.vZahlen 00•14 ZZ:09 %Mod.Lotto.vZZ 00•14 SZ:09 %Mod.Lotto.vSZ 00•14 Ziehungsreihenfolge:09 %Mod.Lotto.vReihenfolge 00•14 Spiel77:09 $gettok(%Mod.Lotto.vSpiel77, 1-3, 32) 00•14 Super6:09 %Mod.Lotto.vSuper6 14)=-
      sockclose Mod.Lotto.sHTTP | unset %Mod.Lotto.* | halt
    }
    sockread %Mod.Lotto.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
