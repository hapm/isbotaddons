;*************************************************************************************************
;*
;* Album Addon v1.2 © by www.ircshark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet die Album Top10 in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !album bekommst du die Albums Top10 gepostet.
;* Mit !album info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Fixed: mix1 hat eine Änderung vorgenommen so das die Top10 nicht ausgelesen wurde
;* v1.2
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
on *:UNLOAD:{ .timerMod.Album.* off | unset %Mod.Album* }

;*************************************************************************************************
; - Trigger Befehl des Album Addons.
;*************************************************************************************************
on *:TEXT:!album*:#:{
  if ($2 == info) { .notice $nick 14Album Addon v1.2 © by 09www.ircshark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Album-Flood., #, ., $cid))) {
    .timerMod.Album-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Album.sHTTP
    sockopen Mod.Album.sHTTP www.mix1.de 80
    sockmark Mod.Album.sHTTP # | set -u10 %Mod.Album.vRead 0
  }
  else {
    if ($timer($+(Mod.Album-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Album-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Album-vFlood., #, ., $cid, ., $nick) | .timerMod.Album-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Album-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Album-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Album-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite mix1.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.Album.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /charts/longplaycharts.htm HTTP/1.1
  sockwrite -n $sockname Host: www.mix1.de
  sockwrite -n $sockname $crlf
  .msg $1 14-=( Die aktuellen 09Album Top1014 )=-
}

;*************************************************************************************************
; - Liest die Album-Top10 aus und postet sie dann.
;*************************************************************************************************
on *:SOCKREAD:Mod.Album.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread 400 &temp
  set %Mod.Album.sRead $right(%Mod.Album.sRead, 400) $+ $bvar(&temp,1,400).text
  ;var %regex = /<td width="290">.*?<(?:b>(?:<a .[^>]*>(.*?)</A></b>|(.*?)</b>)|a .[^>]*><b>(.*?)</b>)(?:</A>)?<bR><font class=b>(.*?)?<br>/gis
  var %regex = /<a class=t href="[^"]*"><strong>([^<]*)[^f]*font class=b>([^<]*)/gis
  while ($sockbr) {
    if ($regex(%Mod.Album.sRead, %regex)) {
      var %count = $regml(0)
      var %i = 1
      while (%i < %count) {
        inc %Mod.Album.vRead
        var %titel = $replace($regml(%i), $crlf, $chr(32), $cr, $chr(32), $lf, $chr(32), <br>, $chr(32))
        inc %i
        var %artist = $replace($regml(%i), $crlf, $chr(32), $cr, $chr(32), $lf, $chr(32), <br>, $chr(32))
        inc %i
        if (%Mod.Album.vRead == 6) {
          .msg $1 %Mod.Album.vList
          unset %Mod.Album.vList
        }
        set -u10 %Mod.Album.vList %Mod.Album.vList $+(09, %Mod.Album.vRead, .14) %artist - %titel
      }
      if (%count > 0) %Mod.Album.sRead = $mid(%Mod.Album.sRead, $calc($regml(%count).pos + $len($regml(%count))))
    }
    sockread 400 &temp
    set %Mod.Album.sRead $right(%Mod.Album.sRead, 400) $+ $bvar(&temp,1,$sockbr).text
    if (%Mod.Album.vRead == 10) {
      .msg $1 %Mod.Album.vList 
      sockclose Mod.Album.sHTTP
      unset %Mod.Album.*
      halt
    }
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
