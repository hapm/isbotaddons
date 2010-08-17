;*************************************************************************************************
;*
;* Formel 1 Addon v1.4 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Postet den Formel 1 WM Stand in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !f1 bekommst du die Formel 1 - Fahrer Ranglise angezeigt.
;* Mit !f1 -t bekommst du die Formel 1 - Team Ranglise angezeigt.
;* Mit !f1 info bekommst du das Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Fixed: Das Zeichen ü wurde nicht richtig angezeigt.
;*   Changed: Teams und Fahrer ohne Punkte haben nun ein - bei den Punkten stehen
;* 
;* v1.3
;*   Fixed: Anzeige-Problem und alter Stand von 2008.
;*
;* v1.2
;*   Fixed: Die F1 Liste wurde nicht mehr gepostet.
;*   Added: Es gibt jetzt eine Team Topliste.
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
on *:UNLOAD:{ .timerMod.F1* off | unset %Mod.F1* }

;*************************************************************************************************
; - Trigger Befehl des Formel 1 Addon.
;*************************************************************************************************
on *:TEXT:!f1*:#:{
  if ($2 == info) { .notice $nick 14Formel 1 Addon v1.4 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.F1-Flood., #, ., $cid))) {
    .timerMod.F1-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.F1.sHTTP
    sockopen Mod.F1.sHTTP www.sport1.de 80
    sockmark Mod.F1.sHTTP # $iif($2 == -t, _r1_/) $iif($2 == -t, 11, 22) | set -u10 %Mod.F1.Read 1
  }
  else {
    if ($timer($+(Mod.F1-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.F1-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.F1-vFlood., #, ., $cid, ., $nick) | .timerMod.F1-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.F1-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.F1-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.F1-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.sport1.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.F1.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET /dynamic/datencenter/sport/rangliste/formel-1- $+ $asctime($ctime, yyyy) $+ / $+ $2 HTTP/1.1
  sockwrite -n $sockname Host: www.sport1.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Formel 1 WM Stand Liste aus und postet sie.
;*************************************************************************************************
on *:SOCKREAD:Mod.F1.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.F1.sRead
  while ($sockbr) {
    if ($regex(%Mod.F1.sRead, /.*<a class="wfb_link" href="/dynamic/datencenter/sport/.*/formel-1/.*">/)) set -u10 %Mod.F1.vReady 1
    if ((%Mod.F1.vReady) && ($regex(%Mod.F1.sRead, /([^\t]*[^\t ])? *[\t ]*</a>.*/))) set -u10 %Mod.F1.vFahrer $replace($remove($regml(1), $chr(9)), Ã¤, ä, Ã¶, ö, Ã©, é, Ã¼, ü)
    if ((%Mod.F1.vReady) && ($regex(%Mod.F1.sRead, /<td align="center" class="wfb_tab_zelle wfb_tab_zelle_font">(.*)</td>/))) {
      if (%Mod.F1.Read == 1) .msg $1 14-=( Formel 1 $asctime($ctime, yyyy) -09 $iif($3, Team, Fahrer) Rangliste 14)=-
      if (%Mod.F1.vFahrer != $null) {
        .timer 1 %Mod.F1.Read .msg $1 14 $+ %Mod.F1.Read $+ .09 %Mod.F1.vFahrer 00•14 Punkte:09 $iif($regml(1) == $null, -, $regml(1)) 
        if (%Mod.F1.Read == $3) { sockclose Mod.F1.sHTTP | unset %Mod.F1.* | halt }
        inc %Mod.F1.Read
      }
      unset %Mod.F1.vReady
    }
    sockread %Mod.F1.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
