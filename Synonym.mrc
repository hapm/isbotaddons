;*************************************************************************************************
;*
;* Synonym Addon v1.2 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Sucht in der Woxikon-Synonym-Datenbank nach Wörten mit gleicher Bedeutung (oft auch Synonyme genannt).
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !syn <Suchbegriff> bekommst du Wörter mit gleicher Bedeutung angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Fixed: Es wurden keine Ergebnisse mehr gepostet.
;*
;* v1.1
;*   Fixed: Es wurden keine Ergebnisse mehr gepostet.
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
on *:UNLOAD:{ .timerMod.Synonym* off | unset %Mod.Synonym* }

;*************************************************************************************************
; - Trigger Befehle vom Synonym Addon.
;*************************************************************************************************
on *:TEXT:!syn*:#:{
  if (!$timer($+(Mod.Synonym-Flood., #, ., $cid))) {
    if (!$2) { .msg # 14Du hast vergessen ein 09Suchbegriff14 anzugeben! | halt }
    .timerMod.Synonym-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Synonym.sHTTP
    sockopen Mod.Synonym.sHTTP synonyme.woxikon.de 80
    sockmark Mod.Synonym.sHTTP # $strip($2)
    set -u20 %Mod.Synonym.vRead 1
  }
  else {
    if ($timer($+(Mod.Synonym-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Synonym-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuch's in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Synonym-vFlood., #, ., $cid, ., $nick) | .timerMod.Synonym-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Synonym-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Synonym-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Synonym-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet synonyme.woxikon.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Synonym.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $+(/synonyme/, $2, .php) HTTP/1.1
  sockwrite -n $sockname Host: synonyme.woxikon.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Synonyme aus.
;*************************************************************************************************
on *:SOCKREAD:Mod.Synonym.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Synonym.sRead
  while ($sockbr) {
    ;echo -a T %Mod.Synonym.sRead
    if (*Keine Synonyme f* iswm %Mod.Synonym.sRead) {
      .msg $1 14Es wurden keine Treffer für09 $upper($left($2, 1)) $+ $right($2, $calc($len($2) - 1)) 14erzielt! | sockclose Mod.Synonym.sHTTP | unset %Mod.Synonym* | halt
    }
    if ((!%Mod.Synonym.vSyn) && ($regex(%Mod.Synonym.sRead , /<div style="padding: 5px 10px; color: #0000ff; border: 1px solid #DDDDDD; border-right: none; border-left: none; border-bottom: none; background: +#FBF4CA;"><h2 class="inline">([^<]*)</h2></div>/))) {
      set -u10 %Mod.Synonym.vSyn $regml(1)
    }
    if ((%Mod.Synonym.vSyn) && ($regex(%Mod.Synonym.sRead , /					([^<]*)				</h4>/))) {
      if (%Mod.Synonym.vRead == 1) .msg $1 14Synonyme für09 $upper($left($2, 1)) $+ $right($2, -1) $+ 14:
      .timer 1 %Mod.Synonym.vRead .msg $1 14 $+ %Mod.Synonym.vRead $+ .09 %Mod.Synonym.vSyn 14(09 $+ $remove($regml(1), $chr(9)) $+ 14)
      if (%Mod.Synonym.vRead == 3) { sockclose Mod.Synonym.sHTTP | unset %Mod.Synonym* | halt }
      inc %Mod.Synonym.vRead | unset %Mod.Synonym.vSyn
    }
    sockread %Mod.Synonym.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
