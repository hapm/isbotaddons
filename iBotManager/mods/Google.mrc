;*************************************************************************************************
;*
;* Google Addon v1.8 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei Google.de nach dem Suchbegriff und postet die Links in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !Google <Suchbegriff> startest du eine Web Suche.
;* Mit !Google -n <Suchbegriff> startest du eine News Suche.
;* Mit !Google -b <Suchbegriff> startest du eine Bilder Suche.
;* Mit !Google -bl <Suchbegriff> startest du eine Blog Suche.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.8
;*   Fixed: Die Google News Suche funktionierte nicht.
;*
;* v1.7
;*   Fixed: Die Google News Suche funktionierte nicht.
;*   Fixed: Die Google Blogs Suche funktionierte nicht.
;*
;* v1.6
;*   Fixed: Die Google Web Suche funktionierte nicht.
;*
;* v1.5
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*   Fixed: Es kam keine Meldung, wenn eine Funktion falsch angegeben wurde.
;*   Removed: Übesetzer, weil er nicht korrekt ausgelesen werden konnte.
;*
;* v1.4
;*   Removed: Die Google Video suche, denn der Webcode is nicht mehr zu verarbeiten ...
;*
;* v1.3
;*   Added: !<Sprache> <Text> übersetzt den Text in eine andere Sprache.
;*   Added: !google -t zeigt welche Sprachen der Translator anbietet.
;*   Added: !google -bl <Suchbegriff> - Google Blogsuche.
;*   Fixed: Wenn keine Treffer gefunden, kam nicht immer die Fehlermeldung
;*
;* v1.2
;*   Fixed: Google-Bilder wurden nicht mehr richtig gepostet..
;*
;* v1.1
;*   Fixed: Bei Google-Bilder wurden nicht immer alle Links gepostet.
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
on *:UNLOAD:{ .timerMod.Google* off | unset %Mod.Google* }

;*************************************************************************************************
; - Trigger Befehl des Google Addon.
;*************************************************************************************************
on *:TEXT:!*:#:{
  if (!$timer($+(Mod.Google-Flood., #, ., $cid))) {
    if ($1 == !google) {
      if ($left($2, 1) != $chr(45)) {
        if (!$2-) { .notice $nick 14Du hast vergessen einen 09Suchbegriff14 anzugeben. | halt }
        var %Mod.Google.vURL = 3 www.google.de $+(/search?hl=de&as_qdr=all&q=, $urlencode($strip($2-)), &btnG=Suche&meta=) $2- | set -u10 %Mod.Google.vRead 1
      }
      else {
        if ($2 == -n) {
          if (!$3-) { .notice $nick 14Du hast vergessen einen 07Suchbegriff14 anzugeben. | halt }
          var %Mod.Google.vURL = 3 news.google.de $+(/news?pz=1&hl=de&ned=de&q=, $replace($strip($3-), $chr(32), +)) $3-
          set -u10 %Mod.Google.vRead 1 | .timerMod.Google.tNews 1 4 .msg # 14Es wurden keine mit Ihrer Suchanfrage -09 $3- 14übereinstimmenden Dokumente gefunden.
        }
        elseif ($2 == -bl) {
          if (!$3-) { .notice $nick 14Du hast vergessen einen 07Suchbegriff14 anzugeben. | halt }
          var %Mod.Google.vURL = 3 blogsearch.google.de $+(/blogsearch?hl=de&q=, $replace($strip($3-), $chr(32), +)) $3-
          set -u10 %Mod.Google.vRead 1 | .timerMod.Google.tBlog 1 4 .msg # 14Es wurden keine mit Ihrer Suchanfrage -09 $3- 14übereinstimmenden Dokumente gefunden.
        }
        elseif ($2 == -b) {
          if (!$3-) { .notice $nick 14Du hast vergessen einen 07Suchbegriff14 anzugeben. | halt }
          var %Mod.Google.vURL = 3 www.google.de $+(/images?hl=de&q=, $replace($strip($3-), $chr(32), +), &btnG=Bilder-Suche) $3- | set -u10 %Mod.Google.vRead 1
        }
        else { .notice $nick 14Du hast eine falsche09 Funktion 14angegeben!08 Syntax: !google $+(<-n, $chr(124), -bl, $chr(124), -b>) [Suchbegriff] | halt }
      }
      if (%Mod.Google.vURL) {
        .timerMod.Google-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Google.sHTTP
        sockopen Mod.Google.sHTTP $gettok(%Mod.Google.vURL, 2, 32) 80
        sockmark Mod.Google.sHTTP # %Mod.Google.vURL
      }
    }
  }
  else {
    if ($timer($+(Mod.Google-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Google-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Google-vFlood., #, ., $cid, ., $nick) | .timerMod.Google-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Google-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Google-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Google-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.Google.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Google.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $4 HTTP/1.1
  sockwrite -n $sockname Host: $3
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.Google.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Google.sRead
  while ($sockbr) {
    if (/blog* iswm $4) {
      if ($regex(%Mod.Google.sRead, /.*><a href="(.*)" id="p-.*">.*</a><.*/)) {
        .timerMod.Google.tBlog off
        .timer 1 %Mod.Google.vRead .msg $1 12G4o8o12g9l4e14-Blog:09 $gettok($regml(1), 1, 34) 
        if (%Mod.Google.vRead == $2) { sockclose Mod.Google.sHTTP | unset %Mod.Google.* | halt }
        inc %Mod.Google.vRead
      }
    }
    elseif (/images* iswm $4) {
      if ($regex(%Mod.Google.sRead, /.*:" $+ $chr(44) $+ "http://(.*)" $+ $chr(44) $+ ".*/)) {
        if ((*.jpg"* iswm $regml(1)) || (*.gif"* iswm $regml(1)) || (*.png"* iswm $regml(1))) {
          .timer 1 %Mod.Google.vRead .msg $1 12G4o8o12g9l4e14-Bilder:09 http:// $+ $gettok($regml(1), 1, 34) 
          if (%Mod.Google.vRead == $2) { sockclose Mod.Google.sHTTP | unset %Mod.Google.* | halt }
          inc %Mod.Google.vRead
        }
      }
    }
    elseif (/search* iswm $4) {
      if ($regex(%Mod.Google.sRead, /.*<h3 class=r><a href="(.*)".*/)) {
        .timer 1 %Mod.Google.vRead .msg $1 12G4o8o12g9l4e14:09 $gettok($regml(1), 1, 34) 
        if (%Mod.Google.vRead == $2) { sockclose Mod.Google.sHTTP | unset %Mod.Google.* | halt }
        inc %Mod.Google.vRead
      }
    }
    elseif (/news* iswm $4) {
      if ($regex(%Mod.Google.sRead, /<h2 class="title"> *<a target="[^"]*" class="[^"]*" href="([^"]*)"/i)) {
        .timerMod.Google.tNews off
        if (*http://www.google.de/* !iswm $regml(1)) {
          .timer 1 %Mod.Google.vRead .msg $1 12G4o8o12g9l4e14-News:09 $gettok($regml(1), 1, 34) 
          if (%Mod.Google.vRead == $2) { sockclose Mod.Google.sHTTP | unset %Mod.Google.* | halt }
          inc %Mod.Google.vRead
        }
      }
    }
    if ((.*>Es wurden keine.* iswm %Mod.Google.sRead) || (*übereinstimmenden Dokumente gefunden.<* iswm %Mod.Google.sRead)) {
      .timerMod.Google.t* off
      if ($2 == F) .msg $1 14Es wurden keine mit Ihrer Suchanfrage -09 $remove($4, /search?hl=de&as_qdr=all&q=, &btnG=Suche&meta, =) 14übereinstimmenden Dokumente gefunden.
      else .msg $1 14Es wurden keine mit Ihrer Suchanfrage -09 $5- 14übereinstimmenden Dokumente gefunden.
      sockclose Mod.Google.sHTTP | unset %Mod.Google.* | halt
    }
    sockread %Mod.Google.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht den Text gegen URL String aus (Thx an ^Vampire^ für den Snippet):
; - $urlencode(Text)
;*************************************************************************************************
alias -l urlencode return $regsubex($1-,/\G(.)/g,$iif(($prop && \1 !isalnum) || !$prop,$chr(37) $+ $base($asc(\1),10,16),\1))

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
