;*************************************************************************************************
;*
;* DVD Addon v1.4 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet die DVD Top10 in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !dvd bekommst du die DVD Top10 gepostet.
;* Mit !dvd info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Fixed: Die Top10 wurde nicht mehr ausgegeben wegen einer Seitenänderung.
;*
;* v1.3
;*   Fixed: Die Top10 wurde nicht mehr ausgegeben wegen einer Seitenänderung.
;*
;* v1.2
;*   Fixed: Die Top10 wurde nicht vollständig gepostet.
;*
;* v1.1
;*   Fixed: Die Top 10 wurde nicht gepostet.
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
; - Entfernt die Timer & Variablen beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.DVD.* off | unset %Mod.DVD* }

;*************************************************************************************************
; - Trigger Befehl des DVD Addons.
;*************************************************************************************************
on *:TEXT:!DVD*:#:{
  if ($2 == info) { .notice $nick 14DVD Addon v1.4 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.DVD-Flood., #, ., $cid))) {
    .timerMod.DVD-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.DVD.sHTTP
    sockopen Mod.DVD.sHTTP de.movies.yahoo.com 80
    sockmark Mod.DVD.sHTTP # | set -u10 %Mod.DVD.vRead 1
  }
  else {
    if ($timer($+(Mod.DVD-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.DVD-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.DVD-vFlood., #, ., $cid, ., $nick) | .timerMod.DVD-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.DVD-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.DVD-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.DVD-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite de.movies.yahoo.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.DVD.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /dvd-charts/ HTTP/1.1
  sockwrite -n $sockname Host: de.movies.yahoo.com
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die DVD Top10 aus und postet sie dann.
;*************************************************************************************************
on *:SOCKREAD:Mod.DVD.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.DVD.sRead
  while ($sockbr) {
    if ($regex(%Mod.DVD.sRead, /<td><strong><a href=".*html.*">(.*)</a></strong>.*</td>/)) {
      set -u10 %Mod.DVD.vName %Mod.DVD.vName $+(09, %Mod.DVD.vRead, .14) $regml(1)
      inc %Mod.DVD.vRead
    }
    if (*</body>* iswm %Mod.DVD.sRead) {
      .msg $1 14-=( Aktuelle 09DVD Top 1014 )=-
      .msg $1 $left(%Mod.DVD.vName, $calc($pos(%Mod.DVD.vName, 6.) - 1))
      .msg $1 $+(09, $gettok($mid(%Mod.DVD.vName, $pos(%Mod.DVD.vName, 6.)), 1, 32), , $remove($mid(%Mod.DVD.vName, $pos(%Mod.DVD.vName, 6.)), 6.))
      sockclose Mod.DVD.sHTTP | unset %Mod.DVD* | halt
    }
    sockread %Mod.DVD.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
