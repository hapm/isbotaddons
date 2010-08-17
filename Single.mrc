;*************************************************************************************************
;*
;* Single Addon v1.2 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet die Single Top10 in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !Single bekommst du die Singles Top10 gepostet.
;* Mit !Single info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Fixed: Die Platzierung wurde falsch gezählt daher wurde Platz 10. nicht mehr gepostet.
;*
;* v1.1
;*   Fixed: mix1 hat eine Änderung vorgenommen so das die Top10 nicht ausgelesen wurde
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
; - Entfernt die Timer & Variablen beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Single.* off | unset %Mod.Single* }

;*************************************************************************************************
; - Trigger Befehl des Single Addons.
;*************************************************************************************************
on *:TEXT:!single*:#:{
  if ($2 == info) { .notice $nick 14Single Addon v1.1 © by 09www.IrcShark.de14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Single-Flood., #, ., $cid))) {
    .timerMod.Single-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Single.sHTTP
    sockopen Mod.Single.sHTTP www.mix1.de 80
    sockmark Mod.Single.sHTTP # $iif($2 == 20, 1) | set -u10 %Mod.Single.vRead 0
  }
  else {
    if ($timer($+(Mod.Single-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Single-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Single-vFlood., #, ., $cid, ., $nick) | .timerMod.Single-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Single-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Single-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Single-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite dc-crossroads.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.Single.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /charts/singlecharts.htm HTTP/1.1
  sockwrite -n $sockname Host: www.mix1.de
  sockwrite -n $sockname $crlf
  .msg $1 14-=( Die aktuellen 09Single Top1014 )=-
}

;*************************************************************************************************
; - Liest die Single Top10 aus und postet sie dann.
;*************************************************************************************************
on *:SOCKREAD:Mod.Single.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread 400 &temp
  set %Mod.Single.sRead $right(%Mod.Single.sRead, 400) $+ $bvar(&temp,1,400).text
  var %regex = /<td width="340">.*?<(?:strong>(?:<a .[^>]*>(.*?)</A></strong>|(.*?)</strong>)|a .[^>]*><strong>(.*?)</strong>)(?:</A>)?<bR><font class=b>(.*?)?<br>/gis
  while ($sockbr) {
    if ($regex(%Mod.Single.sRead, %regex)) {
      var %count = $regml(0)
      var %i = 1
      while (%i < %count) {
        inc %Mod.Single.vRead
        var %titel = $replace($regml(%i), $crlf, $chr(32), $cr, $chr(32), $lf, $chr(32), <br>, $chr(32))
        inc %i
        var %artist = $replace($regml(%i), $crlf, $chr(32), $cr, $chr(32), $lf, $chr(32), <br>, $chr(32))
        inc %i
        if (%Mod.Single.vRead == 6) {
          .msg $1 %Mod.Single.vList
          unset %Mod.Single.vList
        }
        set -u10 %Mod.Single.vList %Mod.Single.vList $+(09, %Mod.Single.vRead, .14) %artist - %titel
      }
      if (%count > 0) %Mod.Single.sRead = $mid(%Mod.Single.sRead, $calc($regml(%count).pos + $len($regml(%count))))
    }
    sockread 400 &temp
    set %Mod.Single.sRead $right(%Mod.Single.sRead, 400) $+ $bvar(&temp,1,$sockbr).text
    if (%Mod.Single.vRead == 10) {
      .msg $1 %Mod.Single.vList 
      sockclose Mod.Single.sHTTP
      unset %Mod.Single.*
      halt
    }
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
