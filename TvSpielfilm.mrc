;*************************************************************************************************
;*
;* TvSpielfilm Addon v1.5 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht nach dem Sender und postet das aktuell laufende Programm.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !tv info bekommst du die Copyright angezeigt.
;* Mit !tv sender bekommste eine Liste mit Sendern die TvSpielfilm anbietet.
;* Mit !tv <Sender> <Zeit> kannst du dir das laufende Programm posten lassen.
;* Mit !tv -g <Sender> <Zeit> kannst du dir anzeigen lassen was gestern auf dem Sender lief.
;* Mit !tv -m <Sender> <Zeit> kannst du dir anzeigen lassen was Morgen auf dem Sender leuft.
;* Mit !tv -ü <Sender> <Zeit> kannst du dir anzeigen lassen was Übermorgen auf dem Sender laufen wird.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.5
;*   Fixed: Änderung an der Seite TvSpielfilm.de.
;*
;* v1.4
;*   Fixed: Bei listen der Sender kam die Fehlermeldung das es den Sender "sender" nicht gibt.
;*
;* v1.3
;*   Added: Flood-Protection.
;*   Added: !tv -ü <Sender> <Zeit> um abzufragen was Übermorgen laufen wird.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Fixed: TV abfrage mit Zeit funktionierte nicht.
;*   Fixed: TV abfrage von gestern funktionierte nicht richtig.
;*
;* v1.1
;*   Fixed: Die Uhrzeit wurde manchmal nicht angezeigt.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.SpeedSpace-IRC.eu
;* Port: 6667
;* Channel: #IrcShark
;*
;* Befehl: /server -m irc.SpeedSpace-IRC.eu -j #IrcShark
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.TvSpielfilm* off | unset %Mod.TvSpielfilm* }

;*************************************************************************************************
; - Trigger Befehl des TvToday Addons.
;*************************************************************************************************
on *:TEXT:!tv*:#:{
  if ($2 == info) { .notice $nick 14TvSpielfilm Addon v1.6 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.TvSpielfilm-Flood., #, ., $cid))) {
    if ($left($2, 1) != $chr(45)) {
      if ($2-) {
        if ($2 == sender) {
          .timerMod.TvSpielfilm-Flood. $+ $+(#, ., $cid) 1 40 halt | .timer 1 1 .notice $nick  14Folgende 09Sender14 stehen dir zur Auswahl:
          .timer 1 2 .notice $nick 08ARD 00•08 ZDF 00•08 RTL 00•08 SAT1 00•08 PRO7 00•08 Kabel1 00•08 RTL2 00•08 Super RTL 00•08 VOX 00•08 ARTE 00•08 TELE5 00•08 3SAT 00•08 Das Vierte 00•08 Comedy Central 00•08 BAYERN 00•08 HESSEN 00•08 MDR 00•08 NDR 00•08 RBB 00•08 SÜDWEST 00•08 WDR 00•08 BRalpha 00•08 TV Berlin 00•08 HH1 00•08 ORF1 00•08 ORF2 00•08 ATVplus
          .timer 1 3 .notice $nick 08SF1 00•08 SF2 00•08 ARENA 00•08 Playboy TV 00•08 AXN 00•08 Kinowelt 00•08 Kabel1 Cassics 00•08 SAT1 Comedy 00•08 E! 00•08 Silverline 00•08 National Geographic 00•08 TV Gusto 00•08 Spiegel TV 00•08 BBC Prime 00•08 History Channel 00•08 NASN 00•08 Playhouse 00•08 Toon Disney 00•08 Premiere Start 00•08 Premiere Austria 00•08 Premiere1
          .timer 1 4 .notice $nick 08Premiere2 00•08 Premiere3 00•08 Premiere4 00•08 Disney Channel 00•08 Premiere Filmclassics 00•08 Premiere Filmfest 00•08 Premiere Nostalgie 00•08 Premiere Serie 00•08 Premiere Krimi 00•08 Goldstar TV 00•08 Heimatkanal 00•08 Animal Planet 00•08 Beate Uhse TV 00•08 Classica 00•08 Discovery Channel 00•08 JETIX 00•08 Junior 00•08 MGM 00•08 Planet
          .timer 1 5 .notice $nick 0813th Street 00•08 HIT24 00•08 Discovery Geschichte 00•08 Focus Gesundheit 00•08 Premiere Sport Portal 00•08 Premiere Direkt 00•08 Blue Movie 00•08 Blue Movie Extra 00•08 DWTV 00•08 EinsExtra 00•08 EinsFestival 00•08 EinsPlus 00•08 Theaterkanal 00•08 ZDF Doku 00•08 ZDF Info 00•08 DSF 00•08 Eurosport 00•08 MTV 00•08 VIVA 00•08 Kinderkanal 00•08 Nick
          .timer 1 6 .notice $nick 08Premiere Sci-Fi 00•08 Neun Live 00•08 QVC 00•08 TW1 00•08 Terra Nova 00•08 KTV 00•08 Bibel TV 00•08 Fashion TV 00•08 CNN 00•08 Euronews 00•08 N24 00•08 N-TV 00•08 Phoenix 00•08 Bloomberg TV 00•08 DMAX 00•08 NL1 00•08 NL2 00•08 NL3 00•08 BE1
          halt
        }
        if ($regex($2-, / (\d{2}|\d{1})/)) var %Mod.TvSpielfilm.vTime = $gettok($2-, -1, 32), %Mod.TvSpielfilm.vSender = $upper($remove($2-, $gettok($2-, -1, 32)))
        else var %Mod.TvSpielfilm.vTime = $gettok($time, 1, 58), %Mod.TvSpielfilm.vSender = $upper($2-)
        var %Mod.TvSpielfilm.vSender1 = $replace(%Mod.TvSpielfilm.vSender, Kabel1, K1, Super RTL, SUPER, Das Vierte, DVIER, Comedy Central, CC, BAYERN, BR, HESSEN, HR, NDR, N3, SÜDWEST, SWR, BRalpha, BRALP, TV Berlin, TVB, ATVplus, ATV, Playboy TV, PBOY, Kinowelt, KINOW, Kabel1 Classics, K1CLA, SAT1 Comedy, SAT1C, Silverline, SILVE, National Geographic, N-GEO, TV Gusto, GUSTO, Spiegel TV, SPTV, BBC Prime, BBC-P, History Channel, HISTO, Playhouse, PLAY, Toon Disney, TOON, Premiere Start, PRS, Premiere Austria, PAUS, Premiere1, PR1, Premiere2, PR2, Premiere3, PR3, Premiere4, PR4, Dosney Channel, DISNE, Premiere Filmclassics, PRFC, Premiere Filmfest, PRFF, Premiere Nostalgie, PRN, Premiere Serie, PRSER)
        %Mod.TvSpielfilm.vSender2 = $replace(%Mod.TvSpielfilm.vSender, Heimatkanal, HEIMA, Animal Planet, APLAN, Beate Uhse TV, BUTV, Classica, CLASS, Discovery Channel, Disco, JETIX, FOXKI, Junior, JUNIO, Planet, PLANE, Premiere Sci-Fi, SCIFI, 13th Street, 13TH, Discovery Geschichte, DISGE, Focus Gesundheit, FOGE, Premiere Sport Portal, PSPO1, Premiere Direkt, DIR1, Blue Movie, BLUM, Blue Movie Extra, BLUME, EinsExtra, EXTRA, EinsFestival, FES, EinsPlus, MUX, Theaterkanal, 2TK, ZDF Doku, ZDOKU, ZDF Info, ZINFO, Eurosport, EURO, Kinderkanal, kika, Neun Live, NLIVE, Terra Nova, TENO, Bibel TV, Bibel, Fashion TV, FATV, Euronews, EURON, N-TV, NTV, Phoenix, PHOEN, Bloomberg TV, BLM, Premiere Krimi, KRIMI, Goldstar TV, GOLD)
        %Mod.TvSpielfilm.vSender = $iif(%Mod.TvSpielfilm.vSender1, $ifmatch, %Mod.TvSpielfilm.vSender2) 
        .timerMod.TvSpielfilm-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.TvSpielfilm.sHTTP
        sockopen Mod.TvSpielfilm.sHTTP www.tvspielfilm.de 80
        sockmark Mod.TvSpielfilm.sHTTP # 4 $+(/tv-programm/sendungen/?page=1&order=time&date=, $asctime(yyyy-mm-dd), &tips=0&cat[]=SP&cat[]=SE&cat[]=RE&cat[]=U&cat[]=KIN&cat[]=SPO&time=day, &channel=, %Mod.TvSpielfilm.vSender)
        set -u10 %Mod.TvSpielfilm.vRead 1
        .msg $chan 15Anfrage für %Mod.TvSpielfilm.vSender wird gestellt...
      }
      else .notice $nick 14Du hast vergessen einen 09Sender14 mit anzugeben (08!tv sender09 um die Senderliste abzurufen14).
    }
    else {
      if ($2) {
        if ($3-) {
          if ($regex($3-, / (\d{2}|\d{1})/)) var %Mod.TvSpielfilm.vTime = $iif($chr(58) isin $4, $gettok($4, 1, 58), $4), %Mod.TvSpielfilm.vSender = $upper($remove($3-, $gettok($3-, -1, 32)))
          else var %Mod.TvSpielfilm.vTime = $gettok($time, 1, 58), %Mod.TvSpielfilm.vSender = $upper($3-)
          var %Mod.TvSpielfilm.vSender1 = $replace(%Mod.TvSpielfilm.vSender, Kabel1, K1, Super RTL, SUPER, Das Vierte, DVIER, Comedy Central, CC, BAYERN, BR, HESSEN, HR, NDR, N3, SÜDWEST, SWR, BRalpha, BRALP, TV Berlin, TVB, ATVplus, ATV, Playboy TV, PBOY, Kinowelt, KINOW, Kabel1 Classics, K1CLA, SAT1 Comedy, SAT1C, Silverline, SILVE, National Geographic, N-GEO, TV Gusto, GUSTO, Spiegel TV, SPTV, BBC Prime, BBC-P, History Channel, HISTO, Playhouse, PLAY, Toon Disney, TOON, Premiere Start, PRS, Premiere Austria, PAUS, Premiere1, PR1, Premiere2, PR2, Premiere3, PR3, Premiere4, PR4, Dosney Channel, DISNE, Premiere Filmclassics, PRFC, Premiere Filmfest, PRFF, Premiere Nostalgie, PRN, Premiere Serie, PRSER)
          %Mod.TvSpielfilm.vSender2 = $replace(%Mod.TvSpielfilm.vSender, Heimatkanal, HEIMA, Animal Planet, APLAN, Beate Uhse TV, BUTV, Classica, CLASS, Discovery Channel, Disco, JETIX, FOXKI, Junior, JUNIO, Planet, PLANE, Premiere Sci-Fi, SCIFI, 13th Street, 13TH, Discovery Geschichte, DISGE, Focus Gesundheit, FOGE, Premiere Sport Portal, PSPO1, Premiere Direkt, DIR1, Blue Movie, BLUM, Blue Movie Extra, BLUME, EinsExtra, EXTRA, EinsFestival, FES, EinsPlus, MUX, Theaterkanal, 2TK, ZDF Doku, ZDOKU, ZDF Info, ZINFO, Eurosport, EURO, Kinderkanal, kika, Neun Live, NLIVE, Terra Nova, TENO, Bibel TV, Bibel, Fashion TV, FATV, Euronews, EURON, N-TV, NTV, Phoenix, PHOEN, Bloomberg TV, BLM, Premiere Krimi, KRIMI, Goldstar TV, GOLD)
          %Mod.TvSpielfilm.vSender = $iif(%Mod.TvSpielfilm.vSender1, $ifmatch, %Mod.TvSpielfilm.vSender2) 
          if ($2 == -g) var %Mod.TvSpielfilm.vDay = $asctime($calc($ctime($date) - 81400), yyyy-mm-dd)
          elseif ($2 == -m) var %Mod.TvSpielfilm.vDay = $asctime($calc($ctime($date) + 86400), yyyy-mm-dd)
          elseif (($2 == -ü) || ($2 == -ue)) var %Mod.TvSpielfilm.vDay =  $asctime($calc($ctime($date) + 199999), yyyy-mm-dd)
          else { .notice $nick 14Du hast eine falsche09 Funkton14 angegeben! Befehl:09 !tv <-m/-g> <sender>  | halt }
          .timerMod.TvSpielfilm-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.TvSpielfilm.sHTTP
          sockopen Mod.TvSpielfilm.sHTTP www.TvSpielfilm.de 80
          sockmark Mod.TvSpielfilm.sHTTP # 4 $+(/tv-programm/sendungen/?page=1&order=time&date=, %Mod.TvSpielfilm.vDay, &tips=0&cat[]=SP&cat[]=SE&cat[]=RE&cat[]=U&cat[]=KIN&cat[]=SPO&time=day, &channel=, %Mod.TvSpielfilm.vSender)
          set -u10 %Mod.TvSpielfilm.vRead 1
          .msg $chan 15Anfrage für %Mod.TvSpielfilm.vSender wird gestellt...
        }
        else .notice $nick 14Du hast vergessen einen09 Sender14 anzugeben! Befehl:09 !tv <-m/-g> <sender> 
      }
    }
    else .notice $nick 14Du hast vergessen ein 09Sender14 mit anzugeben (08!tv sender09 um die Senderliste abzurufen14).
  }
  else {
    if ($timer($+(Mod.TvSpielfilm-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.TvSpielfilm-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.TvSpielfilm-vFlood., #, ., $cid, ., $nick) | .timerMod.TvSpielfilm-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.TvSpielfilm-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.TvSpielfilm-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.TvSpielfilm-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.Spielfilm.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.TvSpielfilm.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $3- HTTP/1.1
  sockwrite -n $sockname Host: www.tvspielfilm.de
  sockwrite -n $sockname User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; de; rv:1.9.0.6) Gecko/2009011913 Firefox/3.0.4
  sockwrite -n $sockname Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
  sockwrite -n $sockname Accept-Language: de-de,de;q=0.8,en-us;q=0.5,en;q=0.3
  sockwrite -n $sockname Accept-Encoding: deflate
  sockwrite -n $sockname Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
  sockwrite -n $sockname Keep-Alive: 300
  sockwrite -n $sockname Connection: keep-alive
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.TvSpielfilm.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.TvSpielfilm.sRead
  while ($sockbr) {
    if ($regex(%Mod.TvSpielfilm.sRead, /.*class="programm-overhead"><span class="c-weiss">0</span><.*/)) {
      .msg $1 04Es tut mir leid,14 aber ich konnte keine Sendungen mit dieser Suchabfrage finden. Tippe 08!tv sender14 um die Verfügbaren Sender zu sehen.
      sockclose Mod.TvSpielfilm.sHTTP | unset %Mod.TvSpielfilm.* | halt
    }
    if ($regex(%Mod.TvSpielfilm.sRead, /<strong>(.*?) - .*</strong>/)) {
      set -u10 %Mod.TvSpielfilm.vStart $regml(1)
    }
    if ($regex(%Mod.TvSpielfilm.sRead, /<span><a href=".*?" target="_self" onclick="saveRef\(\);" title=".*?">(.*?)</a>/)) {
      .timer 1 %Mod.TvSpielfilm.vRead .msg $1 08 $+ %Mod.TvSpielfilm.vStart $+ 09 $regml(1) 
      if (%Mod.TvSpielfilm.vRead == $2) { sockclose Mod.TvSpielfilm.sHTTP | unset %Mod.TvSpielfilm.* | halt }
      inc %Mod.TvSpielfilm.vRead 1
    }
    sockread %Mod.TvSpielfilm.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
