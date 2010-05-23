;*************************************************************************************************
;*
;* Ort Addon v1.2 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Das Addon liest Infos über ein Ort aus.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !ort <PLZ/Ortsname> bekommst du Informationen über den Ort angezeigt.
;* Mit !ort info bekommste die copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Changed: UTF8 Umlaute werden nunrichtig angezeigt, der erste Buchstabe des Städtenamens wird
;*            automatisch groß geschrieben.
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
;* Befehl: /server -m irc.mindforge.org -j #IrcShark
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Entfernt die Timer beim entladen
;*************************************************************************************************
on *:UNLOAD:{ .timerMod.Ort* off | unset %Mod.Ort* }

;*************************************************************************************************
; - Trigger Befehl des Ort Addon.
;*************************************************************************************************
on *:TEXT:!ort*:#:{
  if ($2 == info) { .notice $nick 14Ort Addon v1.2 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Ort-Flood., #, ., $cid))) {
    if ($2) {
      if (($2 isnum) && (!$timer(Mod.Ort.tNr. $+ #))) {
        if ($len($2) == 5) {
          sockclose Mod.Ort.sHTTP
          sockopen Mod.Ort.sHTTP www.plz-postleitzahl.de 80
          sockmark Mod.Ort.sHTTP # $+(/site.plz/search.html?c=plz&q=, $2, &x=0&y=0) $2
          .timerMod.Ort-Flood. $+ $+(#, ., $cid) 1 40 halt
        }
        else .notice $nick 14Die 09PLZ14 muss aus 09514 Zahlen bestehen!
      }
      elseif (($2 !isnum) && (!$timer(Mod.Ort.tNr. $+ #))) {
        if ($len($2-) > 2) {
          var %ort = $replace($2-, Ã¤, ä, Ã¶, ö, Ã¼, ü)
          %ort = $upper($left(%ort, 1)) $+ $mid(%ort, 2)
          sockclose Mod.Ort.sHTTP
          sockopen Mod.Ort.sHTTP www.plz-postleitzahl.de 80
          sockmark Mod.Ort.sHTTP # $+(/site.plz/search.html?c=ort&q=, $replace(%ort, ä, $+($chr(37), C3, $chr(37), A4), ö, $+($chr(37), C3, $chr(37), B6), ü, $+($chr(37), C3, $chr(37), BC), ß, $+($chr(37), C3, $chr(37), 9F), $chr(35), +), &x=0&y=0r) %ort
          set -u10 %Mod.Ort.vNick $nick | .timerMod.Ort-Flood. $+ $+(#, ., $cid) 1 40 halt
        }
        else .notice $nick 14Ein 09Ort14 kann nicht aus weniger als 09zwei14 Buchstaben bestehen!
      }
      elseif (($2 isnum) && ($timer(Mod.Ort.tNr. $+ #))) {
        if ($nick == $gettok($timer(Mod.Ort.tNr. $+ #).com, -1, 32)) {
          if ($2 isnum) {
            if ($2 isnum 1- $+ $hget(Mod.Ort.hData, 0).item) {
              .timerMod.Ort.tNr. $+ # off | sockclose Mod.Ort.sHTTP
              .msg # 14Die Daten für09 $replace($hget(Mod.Ort.hData, $2).item, +, $chr(32), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &) 14werden geladen, bitte hab etwas Geduld.
              .timer 1 2 sockopen Mod.Ort.sHTTP www.plz-postleitzahl.de 80 | .timer 1 2 sockmark Mod.Ort.sHTTP # $hget(Mod.Ort.hData, $2).data 0 | hfree Mod.Ort.hData
            }
            else .notice $nick 14Such ne 09Zahl14 von 09114 bis09 $hget(Mod.Ort.hData, 0).item 14aus!
          }
          else .notice $nick 14Die 14Eingabe14 ist ungültig! Prüfe ob du wirklich nur ne 09Zahl14 angegeben hast!
        }
        else .msg # 14Sorry, aber09 $gettok($timer($timer(Mod.Ort.tNr. $+ #)).com, -1, 32) 14muss noch seine Bestätigung tätigen.
      }
      else .notice $nick 14Du hast vergessen eine09 PLZ 14oder einen09 Ort 14anzugeben!
    }
    else .notice $nick 14Du hast vergessen eine09 PLZ 14oder einen09 Ort 14anzugeben!
  }
  else {
    if ($timer($+(Mod.Ort-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Ort-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Ort-vFlood., #, ., $cid, ., $nick) | .timerMod.Ort-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Ort-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Ort-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Ort-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.plz-postleitzahl.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Ort.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $2 HTTP/1.1
  sockwrite -n $sockname Host: www.plz-postleitzahl.de
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Seite nach Daten aus und Postet sie.
;*************************************************************************************************
on *:SOCKREAD:Mod.Ort.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Ort.sRead
  while ($sockbr) {
    if ($regex(%Mod.Ort.sRead , /.*Es wurde leider kein Ort gefunden.*/)) {
      .msg $1 14Es ergab leider keine Treffer für09 $3  | sockclose Mod.Ort.sHTTP | unset %Mod.Ort.* | halt
    }
    if ($3 isnum) {
      if ($3 != 0) {
        if ($regex(%Mod.Ort.sRead , /<td valign="top"><a href="(.*)" title=".*">.*</a></td>/)) { .msg $1 14Die Daten für09 $3 14werden geladen, bitte hab etwas Geduld. | sockclose Mod.Ort.sHTTP | .timer 1 2 sockopen Mod.Ort.sHTTP www.plz-postleitzahl.de 80 | .timer 1 2 sockmark Mod.Ort.sHTTP $1 $regml(1) 0 | halt }
      }
      else {
        if ($regex(%Mod.Ort.sRead , /<h1 xmlns:lng="http://xmlns.webmaking.ms/lng/">(.*) .*PLZ: (.*)</h1>/)) .msg $1 14 $+ $replace($regml(1), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &) (08 $+ $remove($regml(2), $chr(41)) $+ 14) 00-09 www.plz-postleitzahl.de $+ $2 
        if ((!%Mod.Ort.vBuLa) && (<td><b>Bundesland:</b></td> isin %Mod.Ort.sRead)) set %Mod.Ort.vBuLa $true
        if ((%Mod.Ort.vBuLa == $true) && (*<b>*</b>* !iswm %Mod.Ort.sRead) && ($regex(%Mod.Ort.sRead, /<td><a href=".*">(.*)</a></td>/))) set -u10 %Mod.Ort.vBuLa $replace($regml(1), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &)
        if ((!%Mod.Ort.vTyp) && (<td><b>Typ:</b></td> isin %Mod.Ort.sRead)) set -u10 %Mod.Ort.vTyp $true
        if ((%Mod.Ort.vTyp == $true) && (*<b>*</b>* !iswm %Mod.Ort.sRead) && ($regex(%Mod.Ort.sRead, /<td>(.*)</td>/))) set -u10 %Mod.Ort.vTyp $replace($regml(1), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &)
        if ((!%Mod.Ort.vGeo) && (<td><b>Geografische Position:</b></td> isin %Mod.Ort.sRead)) set -u10 %Mod.Ort.vGeo $true
        if ((%Mod.Ort.vGeo == $true) && (*<b>*</b>* !iswm %Mod.Ort.sRead) && ($regex(%Mod.Ort.sRead, /<td>(.*)</td>/))) set -u10 %Mod.Ort.vGeo $remove($regml(1), $chr(32))
        if ((!%Mod.Ort.vReg) && (<td><b>Regierungsbezirk:</b></td> isin %Mod.Ort.sRead)) set -u10 %Mod.Ort.vReg $true
        if ((%Mod.Ort.vReg == $true) && (*<b>*</b>* !iswm %Mod.Ort.sRead) && ($regex(%Mod.Ort.sRead, /<td><a href=".*">(.*)</a></td>/))) set -u10 %Mod.Ort.vReg $replace($regml(1), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &)
        if ((!%Mod.Ort.vLan) && (<td><b>Landkreis:</b></td> isin %Mod.Ort.sRead)) set -u10 %Mod.Ort.vLan $true
        if ((%Mod.Ort.vLan == $true) && (*<b>*</b>* !iswm %Mod.Ort.sRead) && ($regex(%Mod.Ort.sRead, /<td><a href=".*">(.*)</a></td>/))) set -u10 %Mod.Ort.vLan $replace($regml(1), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &)
        if ((!%Mod.Ort.vKfz) && (<td><b>Autokennzeichen:</b></td> isin %Mod.Ort.sRead)) set -u10 %Mod.Ort.vKfz $true
        if ((%Mod.Ort.vKfz == $true) && (*<b>*</b>* !iswm %Mod.Ort.sRead) && ($regex(%Mod.Ort.sRead, /<a href=".*">(.*)</a>/))) set -u10 %Mod.Ort.vKfz $upper($Mod.Ort.aReplace($regml(1)))
        if (<td valign="top"><b>weitere Postleitzahlen:</b></td> isin %Mod.Ort.sRead) {
          .msg $1 14Bundesland:09 %Mod.Ort.vBuLa 00-14 Typ:09 %Mod.Ort.vTyp 00-14 Geografische Position:09 $replace(%Mod.Ort.vGeo, $chr(47), $chr(32) $+ $chr(47) $+ $chr(32)) 00-14 $iif(%Mod.Ort.vReg, Regierungsbezirk:09 $ifmatch 00-14) $iif(%Mod.Ort.vLan, Landkreis:09 $ifmatch 00-14) Autokennzeichen:09 %Mod.Ort.vKfz 
          if (!$timer($+(Mod.Ort-Flood., $1, ., $cid))) .timerMod.Ort-Flood. $+ $+($1, ., $cid) 1 40 halt 
          sockclose Mod.Ort.sHTTP | unset %Mod.Ort.* | halt
        }
      }
    }
    else {
      if ($3- != 0) {
        if ($regex(%Mod.Ort.sRead, /<td valign="top"><a href="(.*)" title="(.*)">.*</a></td>/)) { inc %Mod.Ort.vCount 1 | hadd -m Mod.Ort.hData $replace($regml(2), $chr(32), +) $regml(1) }
        if (<td valign="top" style="padding-left: 15px;"></td> isin %Mod.Ort.sRead) {
          if (%Mod.Ort.vCount > 1) {
            .timerMod.Ort-Flood. $+ $+($1, ., $cid) off | unset $+($chr(37), Mod.Ort-vFlood.*, $1, *)
            .msg $1 14Es wurden09 %Mod.Ort.vCount 14Treffer erzielt. Such dir eins der Folgenden 09Orten14 aus und tipp dann 08!ort <Nr>14 Du hast dafür09 3014 Sek. Zeit:
            var %a = 1, %b = $hget(Mod.Ort.hData, 0).item, %x = 1
            while (%a <= %b) {
              var %Mod.Ort.vList = %Mod.Ort.vList $+(14, %a, .09) $replace($hget(Mod.Ort.hData, %a).item, +, $chr(32), &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &)
              if (%a == %b) { .timer 1 %x .msg $1 %Mod.Ort.vList | inc %x }
              inc %a
            }
            .timerMod.Ort.tNr. $+ $1 1 30 Mod.Ort.aTimer $1 %Mod.Ort.vNick | sockclose Mod.Ort.sHTTP | unset %Mod.Ort.* | halt
          }
          else {
            .msg $1 14Die Daten für09 $3- 14werden geladen, bitte hab etwas Geduld. | sockclose Mod.Ort.sHTTP
            .timer 1 2 sockopen Mod.Ort.sHTTP www.plz-postleitzahl.de 80 | .timer 1 2 sockmark Mod.Ort.sHTTP $1 $hget(Mod.Ort.hData, 1).data 0 | hfree Mod.Ort.hData | halt
          }
        }
      }
    }
    sockread %Mod.Ort.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         Local ALIASES Start
;*************************************************************************************************
; - Löscht die Hash Table und schreibt eine Bestätigung in den Chan:
; - /Mod.Ort.aTimer $chan $nick
;*************************************************************************************************
alias -l Mod.Ort.aTimer { .msg $1 09 $+ $2 14hat keine Eingabe gemacht! Die 09Datenbank14 wurde jetzt geleert. | hfree Mod.Ort.hData | .timerMod.Ort-Flood. $+ $+($1, ., $cid) 1 40 halt }

;*************************************************************************************************
; - Tauscht HTML Zeichen gegen ASCII Zeichen aus:
; - $Mod.Ort.aReplace(Text)
;*************************************************************************************************
alias -l Mod.Ort.aReplace if (($isid) && ($1-)) return $replace($1-, &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &szlig;, ß, &amp;, &, &nbsp;, $chr(32), &#39;, ')

;*************************************************************************************************
;*                                         ALIASES Ende
;*************************************************************************************************
