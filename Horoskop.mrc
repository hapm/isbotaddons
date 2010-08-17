;*************************************************************************************************
;*
;* Horoskop Addon v1.6 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Zeigt Verschiedene Horoskope für ein Sternzeichen an.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Syntax: !horoskop oder !horo
;*
;* - Tageshorokop: SYNTAX <STERNZEICHEN>
;* - Monatshoroskop: SYNTAX -M <STERNZEICHEN>
;* - Eroskop: SYNTAX -E <STERNZEICHEN>
;* - Singlehoroskop: SYNTAX -S <STERNZEICHEN>
;* - Businesshoroskop: SYNTAX -BU <STERNZEICHEN>
;* - Berufshoroskop: SYNTAX -BE <STERNZEICHEN>
;* - Numeroskop: SYNTAX -N <Geburtsdatum>
;* - China Horoskop: SYNTAX -C <Geburtsdatum> <Geburtsstunde>
;* - Partnerhoroskop: SYNTAX -P <Dein Sternzeichen> <Sternzeichen vom Partner>
;* - Copyright: SYNTAX info
;* - Hilfe: SYNTAX help
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.6
;*   Fixed: Einige Horoskope funktionierten nicht mehr.
;*   Changed: Bei einigen Horoskope wurden timer hinzugefügt, damit die Zeilen nach und nach gepostet werden.
;*
;* v1.5
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.4
;*   Added: Eine Skala für Numeroskop
;*   Added: China Horoskop
;*   Added: Partnerhoroskop
;*   Fixed: Gab probleme beim posten des Numeroskops.
;*
;* v1.3
;*   Added: Numeroskop - !horo -N <Geburtsdatum>
;*
;* v1.2
;*   Update: Auf geänderten HP code angepasst.
;*
;* v1.1
;*   Fixed: Horoskope wurden nicht gepostet.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.mindforge.org
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
on *:UNLOAD:{ .timerMod.Horoskop* off | unset %Mod.Horoskop* }

;*************************************************************************************************
; - Trigger Befehle vom Horoskop Addon.
;*************************************************************************************************
on $*:TEXT:/^(!horoskop|!horo)/:#:{
  if (!$timer($+(Mod.Horoskop-Flood., #, ., $cid))) {
    if ($2) {
      if ($2 == info) { .notice $nick 14Horoskop Addon v1.6 © by 09www.ircshark.net14 (09IrcShark Team14) | halt }
      elseif ($2 == help) {
        .timerMod.Horoskop-Flood. $+ $+(#, ., $cid) 1 40 halt
        .timer 1 1 .notice $nick 14Mit dem Befehl 09!horo <STERNZEICHEN>14 lässt du dir dein 09Tageshoroskop14 wiedergeben. Für erweiterte Horoskope 09!horo $+(<-M, $chr(124), -S, $chr(124), -E, $chr(124), -BU, $chr(124), -BE, $chr(124), -N>) <STERNZEICHEN/GEBURTSDATUM> [STERNZEICHEN von Partner/Geburtsstunde]
        .timer 1 2 .notice $nick 14(08-M 14=08 Monatshoroskop14,08 -S 14=08 Singlehoroskop14,08 -E 14=08 Eroskop14,08 -BU 14=08 Businesshoroskop14,08 -BE 14=08 Berufshoroskop14,08 -N 14=08 Numeroskop14,08 -C 14=09 China Horoskop14,08 -P 14=09 Partnerhoroskop14)
        .timer 1 3 .notice $nick 14z.B. 09!horo -N 25.07.1990 14gibt Numeroskop wieder und 09!horo -BE löwe14 gibt Berufshoroskop wieder.
      }
      elseif (($+($strip($2), $chr(44)) isin widder, stier, zwilling, krebs, löwe, loewe, jungfrau, waage, skorpion, schütze, schuetze, steinbock, wassermann, fische,) && (!$3)) {
        .timerMod.Horoskop-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Horoskop.sHTTP
        sockopen Mod.Horoskop.sHTTP www.horoscopofree.com 80
        sockmark Mod.Horoskop.sHTTP # $replace($strip($2), widder, 1, stier, 2, zwilling, 3, krebs, 4, löwe, 5, loewe, 5, jungfrau, 6, waage, 7, skorpion, 8, schütze, 9, schuetze, 9, steinbock, 10, wassermann, 11, fische, 12) evening Tageshoroskop
      }
      elseif ($upper($+($strip($2), $chr(44))) isin -M, -E, -S, -BU, -BE,) {
        if (($3) && ($+($strip($3), $chr(44)) isin widder, stier, zwilling, krebs, löwe, loewe, jungfrau, waage, skorpion, schütze, schuetze, steinbock, wassermann, fische,)) {
          if ($upper($strip($2)) == -M) { var %Mod.Horoskop.vHoro = month, %Mod.Horoskop.vFunkt = Monatshoroskop }
          elseif ($upper($strip($2)) == -E) { var %Mod.Horoskop.vHoro = eros, %Mod.Horoskop.vFunkt = Eroskop }
          elseif ($upper($strip($2)) == -S) { var %Mod.Horoskop.vHoro = single, %Mod.Horoskop.vFunkt = Singlehoroskop }
          elseif ($upper($strip($2)) == -BU) { var %Mod.Horoskop.vHoro = astrotrade/business, %Mod.Horoskop.vFunkt = Businesshoroskop }
          elseif ($upper($strip($2)) == -BE) { var %Mod.Horoskop.vHoro = astrotrade/work, %Mod.Horoskop.vFunkt = Berufshoroskop }
          .timerMod.Horoskop-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Horoskop.sHTTP
          sockopen Mod.Horoskop.sHTTP www.horoscopofree.com 80
          sockmark Mod.Horoskop.sHTTP # $replace($strip($3), widder, 1, stier, 2, zwilling, 3, krebs, 4, löwe, 5, loewe, 5, jungfrau, 6, waage, 7, skorpion, 8, schütze, 9, schuetze, 9, steinbock, 10, wassermann, 11, fische, 12) %Mod.Horoskop.vHoro %Mod.Horoskop.vFunkt
        }
        else .notice $nick 14Du hast keinen oder einen falschen 09Sternzeichen14 angegeben! ->08 !horo help
      }
      elseif ($upper($+($strip($2), $chr(44))) isin -C, -P, -N,) {
        if ($upper($strip($2)) == -C) {
          if ($remove($3, $chr(46)) isnum) {
            if ($len($gettok($3, 3, 46)) isnum 1-31) {
              if ($len($gettok($3, 3, 46)) isnum 1-12) {
                if ($len($gettok($3, 3, 46)) == 4) {
                  if ($gettok($3, 3, 46) isnum 1820- $+ $calc($date(yyyy) + 1)) {
                    var %Mod.Horoskop.vGebStd
                    if ($4 isnum 01-03) %Mod.Horoskop.vGebStd = 01
                    elseif ($4 isnum 03-05) %Mod.Horoskop.vGebStd = 03
                    elseif ($4 isnum 05-07) %Mod.Horoskop.vGebStd = 05
                    elseif ($4 isnum 07-09) %Mod.Horoskop.vGebStd = 07
                    elseif ($4 isnum 09-11) %Mod.Horoskop.vGebStd = 09
                    elseif ($4 isnum 11-13) %Mod.Horoskop.vGebStd = 11
                    elseif ($4 isnum 13-15) %Mod.Horoskop.vGebStd = 13
                    elseif ($4 isnum 15-17) %Mod.Horoskop.vGebStd = 15
                    elseif ($4 isnum 17-19) %Mod.Horoskop.vGebStd = 17
                    elseif ($4 isnum 19-21) %Mod.Horoskop.vGebStd = 19
                    elseif ($4 isnum 21-23) %Mod.Horoskop.vGebStd = 21
                    elseif ($4 isnum 23-01) %Mod.Horoskop.vGebStd = 23
                    %Mod.Horoskop.vMark = $+(/chinesisches_horoskop_01-, $gettok($3, 3, 46), -, $gettok($3, 2, 46), -, $gettok($3, 1, 46), -, %Mod.Horoskop.vGebStd, .php)
                    else { .notice $nick 14Du hast vergessen deine09 Geburtsstunde 14(01-23) anzugeben! z.B.09 !horo -c 25.07.1990 14 | halt }
                  }
                  else { .notice $nick 14Dein Geburtsjahr kann nicht kleiner als09 1820 14und nicht größer als09 $calc($date(yyyy) + 1) 14sein! | halt }
                }
                else { .notice $nick 14Dein Geburtsjahr muss aus09 4 14Zahlen bestehen! | halt }
              }
              else { .notice $nick 14Im Monatg gibts nur09 31 14Tage! | halt }
            }
            else { .notice $nick 14Es gibt nur 091214 Monate im Jahr! | halt }
          }
          else { .notice $nick 14Dein Geburtsdatum darf nur aus Zahlen von 090-914 bestehen! | halt }
        }
        elseif ($upper($strip($2)) == -P) {
          if (($3) && ($+($strip($3), $chr(44)) isin widder, stier, zwilling, krebs, löwe, loewe, jungfrau, waage, skorpion, schütze, schuetze, steinbock, wassermann, fische,)) {
            if (($4) && ($+($strip($4), $chr(44)) isin widder, stier, zwilling, krebs, löwe, loewe, jungfrau, waage, skorpion, schütze, schuetze, steinbock, wassermann, fische,)) var %Mod.Horoskop.vMark = $replace($+(/partnerhoroskope-, $strip($3), -, $strip($4), .php), löwe, loewe, schütze, schuetze)
            else { .notice $nick 14Du hast vergessen das09 Sternzeichen 14von deinem Partner anzugeben! z.B.09 !horo -p löwe schütze | halt }
          }
          else { .notice $nick 14Du hast vergessen dein 09Sternzeichen14 anzugeben! z.B.09 !horo -p löwe schütze | halt }
        }
        elseif ($upper($strip($2)) == -N) {
          if ($remove($3, $chr(46)) isnum) {
            if ($len($gettok($3, 3, 46)) isnum 1-31) {
              if ($len($gettok($3, 3, 46)) isnum 1-12) {
                if ($len($gettok($3, 3, 46)) == 4) {
                  if ($gettok($3, 3, 46) isnum 1820- $+ $calc($date(yyyy) + 1)) var %Mod.Horoskop.vMark = $+(/numeroskope_1_, $gettok($3, 3, 46), -, $gettok($3, 2, 46), -, $gettok($3, 1, 46), .php)
                  else { .notice $nick 14Dein Geburtsjahr kann nicht kleiner als09 1820 14und nicht größer als09 $calc($date(yyyy) + 1) 14sein! | halt }
                }
                else { .notice $nick 14Dein Geburtsjahr muss aus09 4 14Zahlen bestehen! | halt }
              }
              else { .notice $nick 14Im Monatg gibts nur09 31 14Tage! | halt }
            }
            else { .notice $nick 14Es gibt nur 091214 Monate im Jahr! | halt }
          }
          else { .notice $nick 14Dein Geburtsdatum darf nur aus Zahlen von 090-914 bestehen! | halt }
        }
        .timerMod.Horoskop-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Horoskop.sHTTPN
        sockopen Mod.Horoskop.sHTTPN www.goastro.de 80
        sockmark Mod.Horoskop.sHTTPN # %Mod.Horoskop.vMark $3-
      }
      else .notice $nick 14Du hast ein falsches 09Sternzeichen14 oder eine falsche 09Funktion14 angegeben! ->08 !horo help
    }
    else .notice $nick 14Du hast keine 09Funktion14 oder ein 09Sternzeichen14 angegeben! ->08 !horo help
  }
  else {
    if ($timer($+(Mod.Horoskop-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Horoskop-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Horoskop-vFlood., #, ., $cid, ., $nick) | .timerMod.Horoskop-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Horoskop-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Horoskop-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Horoskop-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.horoscopofree.com & www.goastro.de
;*************************************************************************************************
on *:SOCKOPEN:Mod.Horoskop.sHTTP*:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $iif($sockname == Mod.Horoskop.sHTTPN, $2, $+(/de/astrology/, $3, /?IdSign=, $2)) HTTP/1.1
  sockwrite -n $sockname HOST: $iif($sockname == Mod.Horoskop.sHTTPN, www.goastro.de, www.horoscopofree.com)
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest Horoskop für Sternzeichen aus und postet es.
;*************************************************************************************************
on *:SOCKREAD:Mod.Horoskop.sHTTP*:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Horoskop.sRead
  while ($sockbr) {
    if ($sockname == Mod.Horoskop.sHTTPN) {
      if ($regex(%Mod.Horoskop.sRead, /.*<div class="text_orange">Chinesisches Sternzeichen: <b>(.*)</b><br />Stundenzeichen: <b>(.*)</b></div><hr size="1"><br />/)) {
        .timer 1 1 .msg $1 14-=( China Horoskop 09-14 Geburtsdatum:09 $3 00•14 Chinesisches Sternzeichen:09 $regml(1) 00•14 Stundenzeichen:09 $regml(2) 14)=- | inc %Mod.Horoskop.vTimer 2
      }
      if ($regex(%Mod.Horoskop.sRead, /.*<div class="text_orange_fett">Ihr Partnerhoroskop für (.*)<br />Ihr Sternzeichen:(.*) / Das Sternzeichen Ihres Partners: (.*)</div>/)) {
        .timer 1 1 .msg $1 14-=( Partner Horoskop 09-14 Für:09 $regml(1) 00•14 Dein Sternzeichen:09 $regml(2) 00•14 Sternzeichen des Partners:09 $regml(3) 14)=- | inc %Mod.Horoskop.vTimer 2
      }
      if ($regex(%Mod.Horoskop.sRead, /<div class="text_orange">Ihr Sternzeichen: <b>(.*)</b></div><hr size="1"><br />/)) {
        .timer 1 1 .msg $1 14-=( Numeroskop 09-14 Geburtsdatum:09 $3 00•14 Geburtszahl:09 %Mod.Horoskop.Gebz 00•14 Sternzeichen:09 $regml(1) 14)=- | inc %Mod.Horoskop.vTimer 2
      }
      if ($regex(%Mod.Horoskop.sRead, /<div class="text_orange">Ihre Geburtszahl ist <b>(.*)</b></div>/)) set -u10 %Mod.Horoskop.Gebz $regml(1)
      if ($regex(%Mod.Horoskop.sRead, /<div class="text_klein_fett_orange">(.*)</div>/)) set -u10 %Mod.Horoskop.vThema $replace($regml(1), &uuml;, ü, &amp;, &)
      if ($regex(%Mod.Horoskop.sRead, /.*<img src="templates/images.*skala/.*/(.*).gif"><br />/)) {
        var %zahl = $regml(1) | set -u10 %Mod.Horoskop.vSkala $+($iif(%zahl > 5, 09, 04), $str($chr(124), %zahl), 14, $str($chr(124), $calc(10 - %zahl)))
      }
      if ((%Mod.Horoskop.vThema) && (%Mod.Horoskop.vThema != Gl&uuml;ckszahlen) && ($regex(%Mod.Horoskop.sRead, /		(.*)/)) && (*<img*> !iswm %Mod.Horoskop.sRead) && (*class="text_klein_fett_orange">* !iswm %Mod.Horoskop.sRead) && (*<a class="* !iswm %Mod.Horoskop.sRead)) {
        if (%Mod.Horoskop.vThema == Glücksstein) {
          .timer 1 %Mod.Horoskop.vTimer .msg $1 14 $+ %Mod.Horoskop.vThema $+ :09 $remove($regml(1), <br />) | sockclose Mod.Horoskop.sHTTP | unset %Mod.Horoskop.* | halt
        }
        elseif (%Mod.Horoskop.vThema != Glückszahlen) {
          .timer 1 %Mod.Horoskop.vTimer .msg $1 14 $+ %Mod.Horoskop.vThema %Mod.Horoskop.vSkala | inc %Mod.Horoskop.vTimer 1
          .timer 1 %Mod.Horoskop.vTimer .msg $1 09 $+ $remove($regml(1), <br />) | inc %Mod.Horoskop.vTimer 1
        }
        if ($str($chr(9), 2) $+ * &nbsp;* iswm %Mod.Horoskop.sRead) {
          .timer 1 %Mod.Horoskop.vTimer .msg $1 14-=( Glückszahlen:09 $remove($v2, &nbsp;, $chr(9))  14)=-
          sockclose Mod.Horoskop.sHTTP | unset %Mod.Horoskop.* | halt
        }
      }
      if (*Ihr * Partnerhoroskop von Gestern* iswm %Mod.Horoskop.sRead) { sockclose Mod.Horoskop.sHTTP | unset %Mod.Horoskop.* | halt }
    }
    else {
      if ($4 != Monatshoroskop) {
        if ($regex(%Mod.Horoskop.sRead, /(.*)</A></div>.*/)) set -u10 %Mod.Horoskop.vSZ $remove($regml(1), <div align="left"><A CLASS=CTit1>)
        if (($regex(%Mod.Horoskop.sRead, /<TD class=CTxt2>(.*)<br>(.*)/)) || ($regex(%Mod.Horoskop.sRead, /<TD class=CTxt1>(.*)<br>(.*)/))) {
          .timer 1 1 .msg $1 14 $+ $4 für09 %Mod.Horoskop.vSZ $+ 14: | .timer 1 2 .msg $1 14 $+ $regml(1)  | .timer 1 3 .msg $1 14 $+ $regml(2) 
          sockclose Mod.Horoskop.sHTTP | unset %Mod.Horoskop.* | halt
        }
      }
      else {
        if ($regex(%Mod.Horoskop.sRead, /<div align="left"><A CLASS=CTit1>(.*)</A></div>/)) set -u10 %Mod.Horoskop.vSZ $regml(1)
        if ($regex(%Mod.Horoskop.sRead, /<a class="CTit5">(.*) </a>(.*)<br><a class="CTit5">(.*) </a>(.*)<br><a class="CTit5">(.*) </a>(.*)/)) {
          .timer 1 1 .msg $1 14 $+ $4 für09 %Mod.Horoskop.vSZ $+ 14:
          .timer 1 2 .msg $1 09 $+ $regml(1) $+ 14 $regml(2)  | .timer 1 3 .msg $1 09 $+ $regml(3) $+ 14 $regml(4)  | .timer 1 4 .msg $1 09 $+ $regml(5) $+ 14 $regml(6) 
          sockclose Mod.Horoskop.sHTTP | unset %Mod.Horoskop.* | halt
        }
      }
    }
    sockread %Mod.Horoskop.sRead
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
