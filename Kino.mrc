;*************************************************************************************************
;*
;* Kino Addon v1.2 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet die Kino Top10 in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !kino bekommst du die Kino Top10 gepostet.
;* Mit !kino info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Fixed: Die Top 10 wurde nicht gepostet.
;*
;* v1.1
;*   Fixed: Die Top 10 wurde nicht gepostet.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.mindforge.org
;* Port: 6667
;* Channel: #IrcShark
;*
;* Befehl: /server -m irc.midnforge.org -j #IrcShark
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer & Variablen beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Kino.* off | unset %Mod.Kino* }

;*************************************************************************************************
; - Trigger Befehl des Kino Addons.
;*************************************************************************************************
on *:TEXT:!kino*:#:{
  if ($2 == info) { .notice $nick 14Kino Addon v1.2 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Kino-Flood., #, ., $cid))) {
    .timerMod.Kino-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Kino.sHTTP
    sockopen Mod.Kino.sHTTP de.movies.yahoo.com 80
    sockmark Mod.Kino.sHTTP # | set -u10 %Mod.Kino.vRead 1
  }
  else {
    if ($timer($+(Mod.Kino-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Kino-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Kino-vFlood., #, ., $cid, ., $nick) | .timerMod.Kino-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Kino-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Kino-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Kino-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite de.movies.yahoo.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.Kino.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /kino-charts/ HTTP/1.1
  sockwrite -n $sockname Host: de.movies.yahoo.com
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Kino Top10 aus und postet sie dann.
;*************************************************************************************************
on *:SOCKREAD:Mod.Kino.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Kino.sRead
  while ($sockbr) {
    if ($regex(%Mod.Kino.sRead, /<td><strong><a href=".*index-.*.html">(.*)</a></strong><br>.*#8230;</td>/)) {
      set -u10 %Mod.Kino.vName %Mod.Kino.vName $+(09, %Mod.Kino.vRead, .14) $regml(1)
      inc %Mod.Kino.vRead
    }
    if (*</body>* iswm %Mod.Kino.sRead) {
      .msg $1 14-=( Aktuelle 09Kino Top 1014 )=-
      .msg $1 $left(%Mod.Kino.vName, $calc($pos(%Mod.Kino.vName, 6.) - 1))
      .msg $1 $+(09, $gettok($mid(%Mod.Kino.vName, $pos(%Mod.Kino.vName, 6.)), 1, 32), , $remove($mid(%Mod.Kino.vName, $pos(%Mod.Kino.vName, 6.)), 6.))
      sockclose Mod.Kino.sHTTP | unset %Mod.Kino* | halt
    }
    sockread %Mod.Kino.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
