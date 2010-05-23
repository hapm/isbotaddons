;*************************************************************************************************
;*
;* LoveCalc Addon v1.3 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Berechnet die Liebe von zwei Usern.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !lovecalc <NICK1> <NICK2> kann man die Liebe berechnen lassen.
;* Mit !lovecalc info siehst du den Copyright.
;*
;* Hinweis: Es dürfen keine Zeichen oder Zahlen in den Nicks stehen!
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.3
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Removed: Überprüfung ob die User im Chan sind.
;*
;* v1.1
;*   Fixed: LoveCalc wurde ausgeführt obwohl die User nicht im Channel waren.
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
; - Trigger Befehl des LoveCalc Addons.
;*************************************************************************************************
on *:TEXT:!lovecalc*:#:{
  if ($2 == info) { .notice $nick 14LoveCalc Addon v1.3 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if ($2) {
    if ($3) {
      if ($2 != $3) {
        sockclose Mod.LoveCalc.sHTTP
        sockopen Mod.LoveCalc.sHTTP de.cgi.yahoo.com 80
        sockmark Mod.LoveCalc.sHTTP $replace($strip($2), $chr(32), +) $replace($strip($3), $chr(32), +) #
      }
      else .notice $nick 14Du kannst nicht zwei gleiche 09Namen14 angeben.
    }
    else .notice $nick 14Du hast vergessen den 09zweiten Namen14 anzugeben! z.B. 9!lovecalc andy mandy
  }
  else .notice $nick 14Du hast vergessen einen 09Namen14 anzugeben! z.B. 9!lovecalc andy mandy
}

;*************************************************************************************************
; - Öffnet die Seite www.Yahoo.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.LoveCalc.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $+(/de/lovecalc/calc.cgi?p1=, $1, &p2=, $2) HTTP/1.1
  sockwrite -n $sockname Host: de.cgi.yahoo.com
  sockwrite -n $sockname $crlf
}

;*************************************************************************************************
; - Liest die Seite nach Daten aus und Postet sie.
;*************************************************************************************************
on *:SOCKREAD:Mod.LoveCalc.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.LoveCalc.sRead
  while ($sockbr) {
    if ($regex(%Mod.LoveCalc.sRead, /<tr align=center><td colspan=3><font size=5><B>(.*)</B>%</font><br><br></td></tr>/)) set -u10 %Mod.LoveCalc.vProz $regml(1)
    if ($regex(%Mod.LoveCalc.sRead, /<tr><td colspan=3 align=center><b>(.*)/)) {
      if (*Der Liebesrechner kann kein Ergebnis erstellen* iswm $regml(1)) { 
        .msg $3 14Der 09Liebesrechner14 kann kein Ergebnis erstellen, weil in einen der Namen Zeichen oder Zahlen enthalten sind. 
        sockclose Mod.LoveCalc.sHTTP 
        unset %Mod.LoveCalc.*
        halt 
      }
      set -u10 %Mod.LoveCalc.vText $regml(1)
    }
    if ((%Mod.LoveCalc.vText) && ($regex(%Mod.LoveCalc.sRead, /(.*)</b></td></tr>/))) {
      .msg $3 $+(09, $1 14&09 $2 14, $chr(40), , $iif(%Mod.LoveCalc.vProz < 50, 04, 09), %Mod.LoveCalc.vProz, $chr(37), 14, $chr(41), )
      .msg $3 14 $+ $Mod.LoveCalc.aReplace($remove(%Mod.LoveCalc.vText $regml(1), <tr>, </td>, </tr>, <td colspan=3 align=center>))
      sockclose Mod.LoveCalc.sHTTP 
      unset %Mod.LoveCalc.*
      halt
    }
    sockread %Mod.LoveCalc.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCAL ALIASES Start
;*************************************************************************************************
; - Tauscht HTML Zeichen gegen ASCII Zeichen aus:
; - $Mod.LoveCalc.aReplace(Text)
;*************************************************************************************************
alias -l Mod.LoveCalc.aReplace if (($isid) && ($1-)) return $replace($1-, <b>, , </b>, , &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß, &#39;, ')

;*************************************************************************************************
;*                                         LOCAL ALIASES Ende
;*************************************************************************************************
