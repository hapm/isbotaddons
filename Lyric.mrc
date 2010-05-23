;*************************************************************************************************
;*
;* Lyric Addon v1.1 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei Magistrix.de nach dem Song und postet die Links in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !lyric <Artist> - <Titel> kannst du eine Suche bei Magistrix starten.
;* Mit !lyric info bekommst du die Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Added: Flood-Protection.
;*   Added: !lyric info um Copyright anzuzeigen.
;*   Changed: Code gesäubert und verbessert.
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
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Lyric* off | unset %Mod.Lyric* }

;*************************************************************************************************
; - Trigger Befehl des Lyrics Addons.
;*************************************************************************************************
on *:TEXT:!lyric*:#:{
  if ($2 == info) { .notice $nick 14Lyric Addon v1.4 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
  if (!$timer($+(Mod.Lyric-Flood., #, ., $cid))) {
    if (* - * iswm $2-) {
      var %interpret = $replace($left($gettok($2-, 1, 45), $calc($len($gettok($2-, 1, 45)) - 1)), $chr(32), +), %title = $replace($right($gettok($2-, 2, 45), $calc($len($gettok($2-, 2, 45)) - 1)), $chr(32), +)
      .timerMod.Lyric-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Lyrics.sHTTP
      sockopen Mod.Lyrics.sHTTP www.magistrix.de 80
      sockmark Mod.Lyrics.sHTTP # 3 $+(/lyrics/search?title=, %title, &lang=0&artist=, %interpret, &pagelen=50&text=&order=title)
      set -u10 %Mod.Lyrics.vRead 1
    }
    else .notice $nick 14Du hast vergessen den 09Artisten14 oder den 09Titel14 mit anzugeben (08z.B. !lyric Azad - Eines Tages14).
  }
  else {
    if ($timer($+(Mod.Lyric-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Lyric-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Lyric-vFlood., #, ., $cid, ., $nick) | .timerMod.Lyric-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Lyric-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Lyric-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Lyric-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.magistrix.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Lyrics.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $3- HTTP/1.1
  sockwrite -n $sockname Host: www.magistrix.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.Lyrics.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Lyrics.sRead
  while ($sockbr) {
    if ($regex(%Mod.Lyrics.sRead, /.*Es konnte leider keine Songtexte.*/)) .msg $1 14Es konnte leider 09keine14 Songtexte, die auf das Suchmuster passen, gefunden werden. 
    if ($regex(%Mod.Lyrics.sRead, /.*<b>Suchergebnis <small>(.*)</small></b>.*/)) .msg $1 14Die Songtext Suche ergab09 $remove($gettok($regml(1), 1, 32), $chr(40)) 14Treffer. 
    if ($regex(%Mod.Lyrics.sRead, /.*</a>.*<a href="(.*)" class="lyricIcon bgMove">.*/)) {
      .timer 1 %Mod.Lyrics.vRead .msg $1 14 $+ http://lyrics.songtext.name/ $+ $regml(1) 
      if (%Mod.Lyrics.vRead == $2) { sockclose Mod.Lyrics.sHTTP | unset %Mod.Lyrics.* | halt }
      inc %Mod.Lyrics.vRead 1
    }
    sockread %Mod.Lyrics.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
