;*************************************************************************************************
;*
;* MyVideo Addon v1.5 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei MyVideo.de nach dem Suchbegriff und postet die Links in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !MyVideo bekommst du die neusten MyVideo Videos angezeigt.
;* Mit !MyVideo <Suchbegriff> kannst du eine Suche für den Suchbegriff starten.
;* Mit !MyVideo -m <Suchbegriff> kannst du eine Suche nach Musikvideos starten.
;* Mit !MyVideo -d <MyVideo Link> bekommst du ein Download Link für den Video Link.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.5
;*   Fixed: Die neusten MyVideo Videos wurden nicht gepostet.
;*
;* v1.4
;*   Fixed: Der Titel wurde nicht richtig ausgelsen.
;*   Fixed: Es kam keine Meldung wenn kein passendes Video zum Suchbegriff gefunden wurde.
;*
;* v1.3
;*   Added: !myvideo -m <Suchbegriff> um nach Musikvideos zu suchen.
;*   Fixed: Gab Probleme bei Umlauten im Suchbegriff.
;*   Changed: Auf neue HP von MyVideo angepasst.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Fixed: Wenn Leerzeichen im Suchbegriff wurde der nicht richtig verarbeitet.
;*   Fixed: Nicht überall wurden die Umlaute richtig replaced.
;*
;* v1.1
;*   Added: Titel des Videos beim posten.
;*   Added: Wenn man kein suchbegriff angibt bekommt man die neusten MyVideo Videos gepostet.
;*   Added: !myvideo -d <video link> womit man ein Download Link erhält um das Video zu laden.
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
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.MyVideo* off | unset %Mod.MyVideo* }

;*************************************************************************************************
; - Trigger Befehl des MyVideo Addon.
;*************************************************************************************************
on *:TEXT:!myvideo*:#:{
  if (!$timer($+(Mod.MyVideo-Flood., #, ., $cid))) {
    if ($2 == -m) {
      if ($3) var %Mod.MyVideo.vURL = 3 www.myvideo.de /news.php?rubrik=jfpry&searchWord= $+ $Mod.MyVideo.aURL($strip($3-)) $strip($3-)
      else { .notice $nick 14Du hast vergessen einen09 Suchbegriff 14anzugeben! | halt }
    }
    elseif ($2 == -d) {
      if ($3) {
        if (*myvideo.de/watch/* iswm $3-) {
          var %Mod.MyVideo.vURL = 0 www.grabit.to $+(/index.php?txt_url=, http://www., $iif($left($3-, 4) == www., $gettok($3-, 2-, 46), $3-))
          .timerMod.MyVideo.tSearch 1 5 .msg # 14Der gewünschte Videolink wurde nicht erkannt. Die ausgewählte Webseite wird eventuell nicht unterstützt, oder die URL ist fehlerhaft! 
        }
        else .notice $nick 14Du musst einen richtigen09 MyVideo Link 14angeben!
      }
      else { .notice $nick 14Du hast vergessen ein 09MyVideo Link14 mit anzugeben. | halt }
    }
    else var %Mod.MyVideo.vURL = 3 www.myvideo.de $iif($2-, $+(/Videos_A-Z?searchWord=, $Mod.MyVideo.aURL($strip($ifmatch))), /Videos_A-Z/Neueste) $strip($2-)
    .timerMod.MyVideo-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.MyVideo.sHTTP
    sockopen Mod.MyVideo.sHTTP $iif($2 == -d, www.grabit.to, www.MyVideo.de) 80
    sockmark Mod.MyVideo.sHTTP # %Mod.MyVideo.vURL
    set -u10 %Mod.MyVideo.vRead 1
  }
  else {
    if ($timer($+(Mod.MyVideo-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.MyVideo-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.MyVideo-vFlood., #, ., $cid, ., $nick) | .timerMod.MyVideo-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.MyVideo-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.MyVideo-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.MyVideo-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.MyVideo.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.MyVideo.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $4 HTTP/1.1
  sockwrite -n $sockname Host: $3
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.MyVideo.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.MyVideo.sRead
  while ($sockbr) {
    if ($regex(%Mod.MyVideo.sRead, /.*<p><strong><a href="(.*)"><img src="images/dlbtn.gif" alt="Download (.*)" title=".*" width="244" height="43" border="0" /></a></strong></p>/)) {
      .timerMod.MyVideo.tSearch off | .msg $1 14 $+ $Mod.MyVideo.aReplace($regml(2)) 00-09 $regml(1) | sockclose Mod.MyVideo.sHTTP | unset %Mod.MyVideo.* | halt
    }
    if (*Deine Suche konnte kein passendes Ergebnis gefunden werden* iswm %Mod.MyVideo.sRead) { .msg $1 14Keine Videos für09 $5- 14gefunden! | sockclose Mod.MyVideo.sHTTP | unset %Mod.MyVideo.* | halt }
    if ($regex(%Mod.MyVideo.sRead, /.*<a id=.* href='/watch/(.*)' title='(.*)' class='.*'>.*</a>.*/)) {
      if (*type=rss* !iswm $regml(1)) {
        .timer 1 %Mod.MyVideo.vRead .msg $1 09 $+ %Mod.MyVideo.vRead $+ . 14 $+ $Mod.MyVideo.aReplace($gettok($regml(2), 1, 39)) 00-09 www.MyVideo.de/watch/ $+ $gettok($regml(1), 1, 39) 
        if (%Mod.MyVideo.vRead == $2) { sockclose Mod.MyVideo.sHTTP | unset %Mod.MyVideo.* | halt }
        inc %Mod.MyVideo.vRead
      }
    }
    sockread %Mod.MyVideo.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht HTML Zeichen gegen ASCII Zeichen aus:
; - $Mod.MyVideo.aReplace(Text)
;*************************************************************************************************
alias -l Mod.MyVideo.aReplace if (($isid) && ($1-)) return $replace($1-, <b>, , </b>, , &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß, &#039;, ')

;*************************************************************************************************
; - Tauscht ASCII Zeichen gegen HTML Zeichen aus:
; - $Mod.MyVideo.aURL(Text)
;*************************************************************************************************
alias -l Mod.MyVideo.aURL if (($isid) && ($1-)) return $replace($1-, ü, $+($chr(37), C3%BC), ö, $+($chr(37), C3%B6), ä, $+($chr(37), C3%A4), ß, $+($chr(37), C3%9F), $chr(40), $+($chr(37), 28), $chr(41), $+($chr(37), 29), $chr(39), $+($chr(37), 27), /, $+($chr(37), 2F), ", $+($chr(37), 22), $chr(32), +, ?, $+($chr(37), 3F))

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
