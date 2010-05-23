;*************************************************************************************************
;*
;* YouTube Addon v1.6 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei YouTube.com nach dem Suchbegriff und postet die Links in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !youtube bekommst du die Top Rated (Today) Clips gepostet.
;* Mit !youtube <Suchbegriff> kannst du eine Suche bei YouTube starten.
;* Mit !youtube -d <YouTube Link> bekommst du ein YouTube Video download link.
;*
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.6
;*   Fixed: Beim Auslesen wurde der ganze HTML Quellcode ins Status Window gepostet.
;*
;* v1.5
;*   Fixed: Es kam keine Meldung wenn nichts für den Suchbegriff gefunden wurde.
;*   Fixed: Es wurden keine Suchergebnisse mehr gepostet.
;*
;* v1.4
;*   Added: Beschreibung des Videos wird nun mit gepostet.
;*   Added: Flood-Protection.
;*   Fixed: Gab probleme bei Umlauten im Suchbegriff.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.3
;*   Fixed: Die Umlaute und Sonderzeichen wurden nicht richtig angezeigt.
;*   Improved: Die Download Funktion verbessert und auf neue seite (www.grabit.to) eingestellt.
;*
;* v1.2
;*   Fixed: Es wurden keine Ergebnisse gepostet.
;*   Added: Titel des Videos beim posten.
;*   Added: Wenn man kein suchbegriff angibt bekommt man die ' Top Rated : (Today)' gepostet.
;*
;* v1.1
;*   Added: !youtube -d <YouTube Link> um download link fürs video wiederzugeben.
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
on *:UNLOAD:{ .timerMod.YouTube* off | unset %Mod.YouTube* }

;*************************************************************************************************
; - Trigger Befehl des YouTube Addon.
;*************************************************************************************************
on *:TEXT:!youtube*:#:{
  if (!$timer($+(Mod.YouTube-Flood., #, ., $cid))) {
    if ($2 == -d) {
      if ($3) {
        if (*youtube.com/watch?v=* iswm $3-) {
          var %Mod.YouTube.vURL = 0 www.grabit.to $+(/index.php?txt_url=, $replace($+(http://www., $iif($left($3-, 4) == www., $gettok($remove($3-, de.), 2-, 46), $remove($3-, de., http://))), /, $+($chr(37), 2F), :, $+($chr(37), 3A), =, $+($chr(37), 3D), ?, $+($chr(37), 3F)))
          .timerMod.YouTube.tSearch 1 5 .msg # 14Der gewünschte Videolink wurde nicht erkannt. Die ausgewählte Webseite wird eventuell nicht unterstützt, oder die URL ist fehlerhaft! 
        }
        else { .notice $nick 14Du musst einen richtigen09 YouTube Link 14angeben! | halt }
      }
      else { .notice $nick 14Du hast vergessen einen 07YouTube Link14 mit anzugeben. | halt }
    }
    else var %Mod.YouTube.vURL = 3 de.youtube.com $iif($2-, $+(/results?search_query=, $Mod.YouTube.aURL($strip($ifmatch)), &search=Suchen) $strip($2-), /browse?s=tr&t=t&c=0&l=)
    .timerMod.YouTube-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.YouTube.sHTTP
    sockopen Mod.YouTube.sHTTP $gettok(%Mod.YouTube.vURL, 2, 32) 80
    sockmark Mod.YouTube.sHTTP # %Mod.YouTube.vURL
    set -u10 %Mod.YouTube.vRead 1
  }
  else {
    if ($timer($+(Mod.YouTube-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.YouTube-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.YouTube-vFlood., #, ., $cid, ., $nick) | .timerMod.YouTube-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.YouTube-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.YouTube-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.YouTube-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.YouTube.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.YouTube.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $4 HTTP/1.1
  sockwrite -n $sockname Host: $3
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.YouTube.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.YouTube.sRead
  while ($sockbr) {
    if ($regex(%Mod.YouTube.sRead, /.*<p><strong><a href="(.*)"><img src="images/dlbtn.gif" alt="Download (.*)" title=".*" width="244" height="43" border="0" /></a></strong></p>.*/)) {
      .timerMod.YouTube.tSearch off | .msg $1 14 $+ $iif($regml(2), $Mod.YouTube.aReplace($ifmatch) 00-09 $-) $regml(1)
      sockclose Mod.YouTube.sHTTP | unset %Mod.YouTube.* | halt
    }
    if ($regex(%Mod.YouTube.sRead, /.*<div class="marT10">Keine Videos zu <span >.*</span> gefunden</div>.*/)) { .msg $1 14Keine Videos für09 $5- 14gefunden! | sockclose Mod.YouTube.sHTTP | unset %Mod.YouTube.* | halt }
    if (<div class="vllongTitle"> isin %Mod.YouTube.sRead) set -u10 %Mod.YouTube.vStart $true
    if ((%Mod.YouTube.vStart) && ($regex(%Mod.YouTube.sRead, /<a href="/watch(.*)" title="(.*)">.*</a>/))) {
      .timer 1 %Mod.YouTube.vRead .msg $1 14 $+ %Mod.YouTube.vRead $+ . 09 $+ $Mod.YouTube.aReplace($gettok($regml(2), 1, 34)) 00-14 www.youtube.com/watch $+ $gettok($regml(1), 1, 34) 
      if (%Mod.YouTube.vRead == $2) { sockclose Mod.YouTube.sHTTP | unset %Mod.YouTube.* | halt }
      inc %Mod.YouTube.vRead 1 | unset %Mod.YouTube.vStart
    }
    sockread %Mod.YouTube.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht HTML Zeichen gegen ASCII Zeichen aus:
; - $Mod.YouTube.aReplace(Text)
;*************************************************************************************************
alias -l Mod.YouTube.aReplace if (($isid) && ($1-)) return $replace($1-, <b>, , </b>, , &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß, &#39;, ')

;*************************************************************************************************
; - Tauscht ASCII Zeichen gegen HTML Zeichen aus:
; - $Mod.YouTube.aURL(Text)
;*************************************************************************************************
alias -l Mod.YouTube.aURL if (($isid) && ($1-)) return $replace($1-, ü, $+($chr(37), C3%BC), ö, $+($chr(37), C3%B6), ä, $+($chr(37), C3%A4), ß, $+($chr(37), C3%9F), $chr(40), $+($chr(37), 28), $chr(41), $+($chr(37), 29), $chr(39), $+($chr(37), 27), /, $+($chr(37), 2F), ", $+($chr(37), 22), $chr(32), +, ?, $+($chr(37), 3F))

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
