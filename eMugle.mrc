;*************************************************************************************************
;*
;* eMugle Addon v1.2 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht bei eMugle.com nach dem Suchbegriff und postet die Links in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !emugle <Suchbegriff> kannst du eine Suche bei eMugle starten.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Fixed: Es wurde nix in den Chan gepostet, aber eine timer Fehler Meldung im Status.
:*
;* v1.1
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*   Fixed: Keine Meldung, wenn Suche erfolglos war.
;*   Fixed: Einige Informationen wurden falsch gepostet.
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
on *:UNLOAD:{ .timerMod.eMugle* off | unset %Mod.eMugle* }

;*************************************************************************************************
; - Trigger Befehl des eMugle Addon.
;*************************************************************************************************
on *:TEXT:!emugle*:#:{
  if (!$timer($+(Mod.eMugle-Flood., #, ., $cid))) {
    if ($2-) {
      .timerMod.eMugle-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.eMugle.sHTTP
      sockopen Mod.eMugle.sHTTP www.emugle.com 80
      sockmark Mod.eMugle.sHTTP # 3 $strip($2-)
      set %Mod.eMugle.Read 1
    }
    else .notice $nick 14Du hast keinen09 Suchbegriff 14angegeben!
  }
  else {
    if ($timer($+(Mod.eMugle-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.eMugle-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.eMugle-vFlood., #, ., $cid, ., $nick) | .timerMod.eMugle-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.eMugle-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.eMugle-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.eMugle-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.eMugle.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.eMugle.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $+(/search.php?q=, $replace($3-, $chr(32), +), &t=All+categories&Submit=Search&f=1) HTTP/1.1
  sockwrite -n $sockname Host: www.emugle.com
  sockwrite -n $sockname $crlf
  .msg $1 14Die Suche nach09 $3- 14wurde gestartet ...
}

;*************************************************************************************************
; - Liest die Treffer aus und postet sie in den Channel.
;*************************************************************************************************
on *:SOCKREAD:Mod.eMugle.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.eMugle.sRead
  while ($sockbr) {
    if ((*>Document Moved<* iswm %Mod.eMugle.sRead) || (*>No results found.<* iswm %Mod.eMugle.sRead)) { .msg $1 14Es wurden keine Ergebnisse für09 $3- 14gefunden! | sockclose Mod.eMugle.sHTTP | unset %Mod.eMugle.* | halt }
    if ($regex(%Mod.eMugle.sRead, /.*<b>Size:</b> (.*) <b>Aproximate sources:</b> (.*) (.*) so.*/)) { set -u10 %Mod.eMugle.vSize 14Size:09 $regml(1) 00- | set -u10 %Mod.eMugle.vDL1 14Quellen:09 $remove($regml(2), $chr(40), <font) | set -u10 %Mod.eMugle.vDL2 $remove($regml(3), $chr(40), color='FF0000'>) }
    if ($regex(%Mod.eMugle.sRead, /<b>Type:</b> (.*) <.*/)) set -u10 %Mod.eMugle.vType 14Typ:09 $gettok($regml(1), 1, 60) 00-14
    if ($regex(%Mod.eMugle.sRead, /.*<b>Length:</b> (.*) <.*/)) set -u10 %Mod.eMugle.vLength 14Länge:09 $gettok($regml(1), 1, 60) 00-14
    if ($regex(%Mod.eMugle.sRead, /.*<b>Bitrate:</b> (.*) <.*/)) set -u10 %Mod.eMugle.vBitrate 14Bitrate:09 $gettok($regml(1), 1, 60) 00-14
    if ($regex(%Mod.eMugle.sRead, /.*<b>Codec:</b> (.*) <.*/)) set -u10 %Mod.eMugle.vCodec 14Codec:09 $gettok($regml(1), 1, 60) 00-14
    if ($regex(%Mod.eMugle.sRead, /<font color=#008000 size="1">ed2k:(.*)</font></font>/)) {
      .timer 1 %Mod.eMugle.Read .msg $1 %Mod.eMugle.vSize %Mod.eMugle.vDL1 14(09 $+ %Mod.eMugle.vDL2 $+ 14)00 - %Mod.eMugle.vType %Mod.eMugle.vLength %Mod.eMugle.vBitrate %Mod.eMugle.vCodec Link:09 ed2k: $+ $remove($regml(1), <b>, </b>) 
      if (%Mod.eMugle.Read == $2) { sockclose Mod.eMugle.sHTTP | unset %Mod.eMugle.* | halt }
      inc %Mod.eMugle.Read
    }
    sockread %Mod.eMugle.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
