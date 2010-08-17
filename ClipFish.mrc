;*************************************************************************************************
;*
;* ClipFish Addon v1.2 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei ClipFish.de nach dem Suchbegriff und postet die Links in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !clipfish bekommst du die neusten ClipFish Videos angezeigt.
;* Mit !clipfish <Suchbegriff> kannst du eine Suche bei ClipFish starten.
;* Mit !clipfish -d <ClipFish Link> bekommst du ein Download Link für den Video Link.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Fixed: Die Ergebnisse wurden nicht gepostet.
;*
;* v1.1
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
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
on *:UNLOAD:{ .timerMod.ClipFish* off | unset %Mod.ClipFish* }

;*************************************************************************************************
; - Trigger Befehl des ClipFish Addon.
;*************************************************************************************************
on *:TEXT:!clipfish*:#:{
  if (!$timer($+(Mod.ClipFish-Flood., #, ., $cid))) {
    if ($left($2, 1) != $chr(45)) {
      .timerMod.ClipFish-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.ClipFish.sHTTP
      sockopen Mod.ClipFish.sHTTP www.clipfish.de 80
      sockmark Mod.ClipFish.sHTTP # 3 www.clipfish.de $iif($2-, $+(/suche/?search=, $replace($strip($2-), +, $chr(32)), &submit.x=0&submit.y=0), /videos/neu/) $strip($2-)
      set %Mod.ClipFish.vRead 1
    }
    else {
      if ($2 == -d) {
        if ($3-) {
          if (*clipfish.de/video/* iswm $3-) {
            var %Mod.ClipFish.vLink = http://www. $+ $iif($left($3-, 4) == www., $gettok($3-, 2-, 46), $3-)
            .timerMod.ClipFish-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.ClipFish.sHTTP
            sockopen Mod.ClipFish.sHTTP www.grabit.to 80
            sockmark Mod.ClipFish.sHTTP # 0 www.grabit.to $+(/index.php?txt_url=, %Mod.ClipFish.vLink)
            .timerMod.ClipFish.tSearch 1 5 .msg # 14Der gewünschte Videolink wurde nicht erkannt. Die ausgewählte Webseite wird eventuell nicht unterstützt, oder die URL ist fehlerhaft! 
          }
          else .notice $nick 14Du musst einen richtigen09 Clipfish Link 14angeben!
        }
        else .notice $nick 14Du hast vergessen einen 07Clipfish Link14 mit anzugeben.
      }
    }
  }
  else {
    if ($timer($+(Mod.ClipFish-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.ClipFish-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.ClipFish-vFlood., #, ., $cid, ., $nick) | .timerMod.ClipFish-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.ClipFish-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.ClipFish-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.ClipFish-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.ClipFish.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.ClipFish.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $4 HTTP/1.1
  sockwrite -n $sockname Host: $3
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.ClipFish.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.ClipFish.sRead
  while ($sockbr) {
    if ($regex(%Mod.ClipFish.sRead, /.*<p><strong><a href="(.*)"><img src="images/dlbtn.gif" alt="Download Kommentar zum Video &quot;(.*)&quot;" title=".*" width="244" height="43" border="0" /></a></strong></p>/)) {
      .timerMod.ClipFish.tSearch off | .msg $1 14 $+ $Mod.ClipFish.aReplace($regml(2)) 00-09 $regml(1) | sockclose Mod.ClipFish.sHTTP | unset %Mod.ClipFish.* | halt
    }
    if ($regex(%Mod.ClipFish.sRead, /.*Vielleicht interessierst du dich.*/)) {
      .msg $1 14Deine Suche nach "09 $+ $5 $+ 14" hat leider keinen Treffer ergeben. | sockclose Mod.ClipFish.sHTTP | unset %Mod.ClipFish.* | halt
    }
    if ($regex(%Mod.ClipFish.sRead, /.*<a href="(.*)" ><img src="http://bilder.clipfish.de/media/.*" alt="(.*)-Video" title=".*-Video" /></a>.*/)) {
      if (/video/* iswm $regml(1)) {
        .timer 1 %Mod.ClipFish.vRead .msg $1 00 $+ %Mod.ClipFish.vRead $+ . 14 $+ $regml(2) 00-09 www.clipfish.de $+ $regml(1) 
        if (%Mod.ClipFish.vRead == $2) { sockclose Mod.ClipFish.sHTTP | unset %Mod.ClipFish.* | halt }
        inc %Mod.ClipFish.vRead
      }
    }
    sockread %Mod.ClipFish.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht HTML Zeichen gegen ASCII Zeichen aus:
; - $Mod.ClipFish.aReplace(Text)
;*************************************************************************************************
alias -l Mod.ClipFish.aReplace if (($isid) && ($1-)) return $replace($1-, <b>, , </b>, , &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß, &#39;, ')

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
