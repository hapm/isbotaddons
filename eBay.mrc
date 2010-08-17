;*************************************************************************************************
;*
;* eBay Addon v1.5 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei eBay nach dem Suchbegriff und postet wie viele Treffer er gefunden hat und postet vier von den Treffern in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !ebay <Suchbegriff> kannst du eine Suche bei eBay starten.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.5
;*   Fixed: Es wurden keine Suchergebnisse mehr gepostet.
;*   Changed: Es werden mehr Informationen angezeigt z.B. Versandkosten, Gebote, Aktuelle Gebot, Zeit ...
;*
;* v1.4
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.3
;*   Changed: Den Text 'Für XXXX wurden...'  etwas geändert, denn der gesuchte Artikel hatte statt leerzeichen ein minus gehabt.
;*   Fixed: Die Variable '%Mod.eBay.vRead' wurde nicht immer korrekt entfernt.
;*   Removed: !ebay help/info ... denn das könnte im Suchbegriff vorkommen und statt den Ergebnissen gibts halt den Info bzw. help Text.
;*
;* v1.2
;*   Added: Die Anzahl der erzielten Treffer für Suchbegriffe.
;*
;* v1.1
;*   Removed: Die Anzahl der Treffer, wurden nie angezeigt bzw. selten. Hab dafür den Such Link rein gebaut.
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
on *:UNLOAD:{ .timerMod.eBay.* off | unset %Mod.eBay* }

;*************************************************************************************************
; - Trigger Befehl des eBay Addons.
;*************************************************************************************************
on *:TEXT:!ebay*:#:{
  if (!$timer($+(Mod.eBay-Flood., #, ., $cid))) {
    if ($2-) {
      .timerMod.eBay-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.eBay.sHTTP
      sockopen Mod.eBay.sHTTP shop.ebay.de 80
      sockmark Mod.eBay.sHTTP # $replace($2-, $chr(32), $chr(45)) 4 $2-
      set -u10 %Mod.eBay.vRead 1
    }
    else .notice $nick 14Du hast vergessen einen09 Suchbegriff 14anzugeben!
  }
  else {
    if ($timer($+(Mod.eBay-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.eBay-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.eBay-vFlood., #, ., $cid, ., $nick) | .timerMod.eBay-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.eBay-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.eBay-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.eBay-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite http://search.ebay.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.eBay.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET / $+ $2 HTTP/1.1
  sockwrite -n $sockname Host: shop.ebay.de
  sockwrite -n $sockname $crlf | 
  .timerMod.eBay.tFound. $+ $2 1 4 .msg $1 14Es wurden leider09 keine 14Treffer erzielt für09 $2 
}

;*************************************************************************************************
; - Liest die Anzahl der Treffer und postet drei Artikel von den Treffern.
;*************************************************************************************************
on *:SOCKREAD:Mod.eBay.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.eBay.sRead
  while ($sockbr) {
    ; echo -s %Mod.eBay.sRead
    if ($regex(%Mod.eBay.sRead, /<a href="http://cgi.ebay.de/[^"]*hash=item([^"]*)"[^>]*>([^<]*)</a>.*?<td class="bids bin1">([^<]*)</td><td class="prices"><div class="g-b">EUR ([^<]*)</div><span class="ship fee">\+EUR ([^<]*)</span></td><td class="time  time [^"]*">([^<]*)</td>/)) {
      var %Mod.eBay.vArtNr = $gettok($regml(1), 1, 38), %Mod.eBay.vDesc = $remove($regml(2), <wbr/>), %Mod.eBay.vGebote = $gettok($gettok($regml(3), 1, 60), 1, 32), %Mod.eBay.vEUR = $regml(4), %Mod.eBay.vVersand = $regml(5), %Mod.eBay.vTimeTemp = $replace($regml(5), &#160;)
      if (*<* iswm %Mod.eBay.vTimeTemp) var %Mod.eBay.vTime = $gettok(%Mod.eBay.vTimeTemp, 1, 60)
      else var %Mod.eBay.vTime = %Mod.eBay.vTimeTemp
      .timerMod.eBay.tFound. $+ $2 off
      .timer 1 %Mod.eBay.vRead .msg $1 00 $+ %Mod.eBay.vRead $+ . 14 $+ $remove(%Mod.eBay.vDesc, $chr(95)) (09 $+ %Mod.eBay.vArtNr $+ 14):
      .timer 1 %Mod.eBay.vRead .msg $1     08• 14Gebote:09 %Mod.eBay.vGebote 14Aktuelles Gebot:09 %Mod.eBay.vEUR  € 14Versand:09 %Mod.eBay.vVersand € 14Zeit:09 %Mod.eBay.vTime 
      if ($3 == %Mod.eBay.vRead) { sockclose Mod.eBay.sHTTP | unset %Mod.eBay.* | halt }
      inc %Mod.eBay.vRead
    }
    sockread %Mod.eBay.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
