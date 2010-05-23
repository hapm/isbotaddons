;*************************************************************************************************
;*
;* Wetter Addon v1.2 © by www.IrcShark.de (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Gibt Wetterdaten für die angegebene PLZ wieder.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !wetter <PLZ> bekommst du die aktuellen Wetterdaten angezeigt.
;* Mit !wetter -m <PLZ> bekommst du die Wetterdaten für den nächsten Tag angezeigt.
;* Mit !wetter info bekommst du den Copyright angeziegt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.2
;*   Added: Flood-Protection.
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.1
;*   Added: Flag -m um Wetterdaten für den nächsten Tag anzuzeigen.
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
on *:UNLOAD:{ .timerMod.Wetter* off | unset %Mod.Wetter* }

;*************************************************************************************************
; - Trigger Befehl des Wetter Addons.
;*************************************************************************************************
on *:TEXT:!wetter*:#:{
  if ($2 == info) { .notice $nick 14Wetter Addon v1.2 © by 09www.IrcShark.de14 (09IrcShark Team14) | halt }
  if (!$timer($+(Mod.Wetter-Flood., #, ., $cid))) {
    if ($2) {
      if ($left($2, 1) != $chr(45)) {
        if ($2 isnum) {
          if ($len($2) == 5) {
            .timerMod.Wetter-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Wetter.sHTTP
            sockopen Mod.Wetter.sHTTP de.weather.com 80
            sockmark Mod.Wetter.sHTTP # $+(/weather/local/, $2, ?x=0&y=0) $2
          }
          else .notice $nick 14Eine09 PLZ 14besteht aus 09514 Zahlen!
        }
        else .notice $nick 14Die 09PLZ14 darf nur aus 09Zahlen14 bestehen!
      }
      else {
        if ($2 == -m) {
          if ($3 isnum) {
            if ($len($3) == 5) {
              .timerMod.Wetter-Flood. $+ $+(#, ., $cid) 1 40 halt | sockclose Mod.Wetter.sHTTP
              sockopen Mod.Wetter.sHTTP de.weather.com 80
              sockmark Mod.Wetter.sHTTP # /weather/hourbyhour/ $+ $3 $3
            }
            else .notice $nick 14Eine09 PLZ 14besteht aus 09514 Zahlen!
          }
          else .notice $nick 14Die 09PLZ14 darf nur aus 09Zahlen14 bestehen!
        }
        else .notice $nick 14Du hast eine falsche Eingabe gemacht!08 Befehl: !wetter -m <PLZ>
      }
    }
    else .notice $nick 14Du hast vergessen deine 09PLZ14 mit anzugeben.
  }
  else {
    if ($timer($+(Mod.Wetter-Flood., #, ., $cid, ., $nick, .3))) halt
    var %secs = $timer($+(Mod.Wetter-Flood., #, ., $cid)).secs | .notice $nick 14Flood-Protection: Versuchs in09 $duration(%secs) 14nochmal!
    inc $+($chr(37), Mod.Wetter-vFlood., #, ., $cid, ., $nick) | .timerMod.Wetter-Flood. $+ $+(#, ., $cid, ., $nick, *) off
    .timerMod.Wetter-Flood. $+ $+(#, ., $cid, ., $nick, ., $eval($+(%, Mod.Wetter-vFlood., #, ., $cid, ., $nick), 2)) 1 %secs unset %Mod.Wetter-vFlood.*
  }
}

;*************************************************************************************************
; - Öffnet die Seite www.de.weather.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.Wetter.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $2 HTTP/1.1
  sockwrite -n $sockname Host: de.weather.com
  sockwrite -n $sockname $crlf
  .msg $1 14Wetterdaten für09 $3 14werden gelesen, bitte habe ein Moment Geduld.
}

;*************************************************************************************************
; - Liest die Daten aus und postet sie.
;*************************************************************************************************
on *:SOCKREAD:Mod.Wetter.sHTTP:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.Wetter.sRead
  while ($sockbr) {
    if (Location: http://de.weather.com/common/home/localweather.html isin %Mod.Wetter.sRead) {
      .msg $1 14Es ist ein Fehler aufgetreten, bitte versuchs ein anderes mal.
      sockclose Mod.Wetter.sHTTP | unset %Mod.Wetter.* | halt
    }
    if (/weather/local/*?x=0&y=0 iswm $2) {
      if ($regex(%Mod.Wetter.sRead, /<TITLE>.* - .* - (.*)</TITLE>/)) set -u10 %Mod.Wetter.vOrt $regml(1)
      if ($regex(%Mod.Wetter.sRead, /<TD COLSPAN="2" CLASS="obsTempText" VALIGN="TOP">&nbsp;(.*)&deg;C</TD>/)) set -u10 %Mod.Wetter.vTemp $regml(1) $+ °C
      if ($regex(%Mod.Wetter.sRead, /<TD colspan="3" align="center" CLASS="obsText">(.*)<BR>/)) set -u10 %Mod.Wetter.vDesc $regml(1)
      if ($regex(%Mod.Wetter.sRead, /Gef&uuml;hlte Temp.&nbsp;(.*)&deg;C</TD>/)) set -u10 %Mod.Wetter.vGefTemp $regml(1) $+ °C
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="currentObsText">(.*) km/h</TD>/)) set -u10 %Mod.Wetter.vWind $regml(1) km/h
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="currentObsText">(.*)&deg;C</TD>/)) set -u10 %Mod.Wetter.vTaup $regml(1) $+ °C
      if (*<TD CLASS="currentObsText">* $+(%, </TD>) iswm %Mod.Wetter.sRead) set -u10 %Mod.Wetter.vLuft $remove(%Mod.Wetter.sRead, <TD CLASS="currentObsText">, </TD>)
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="currentObsText">(.*) km</TD></TD>/)) set -u10 %Mod.Wetter.vSicht $regml(1) km
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="currentObsText">(.*) hPa</TD>/)) set -u10 %Mod.Wetter.vLuftd $regml(1) hPa
      if ($regex(%Mod.Wetter.sRead, /<FONT CLASS="obsTempText">(.*)</FONT><BR>(.*)</TD>/)) {
        var %Mod.Wetter.vUVz = $regml(1), %Mod.Wetter.vUVt = $regml(2)
        .timer 1 2 .msg $1 14-=( Wetter für09 %Mod.Wetter.vOrt 14)=-=( Wetterlage:09 %Mod.Wetter.vDesc 00•14 Sicht:09 %Mod.Wetter.vSicht 00•14 Gemessene Temp.:09 %Mod.Wetter.vTemp 00•14 Gefühlte Temp.:09 %Mod.Wetter.vGefTemp 00•14 Taupunkt:09 %Mod.Wetter.vTaup 00•14 Luftfeuchtigkeit:09 %Mod.Wetter.vLuft 00•14 Luftdruck:09 %Mod.Wetter.vLuftd 00•14 UV-Index:09 %Mod.Wetter.vUVz 14(09 $+ %Mod.Wetter.vUVt $+ 14) 00•14 Wind:09 %Mod.Wetter.vWind 14)=-
        sockclose Mod.Wetter.sHTTP | unset %Mod.Wetter.* | halt
      }
    }
    else {
      if ($regex(%Mod.Wetter.sRead, /<TITLE>de.weather.com - Rund um die Uhr - (.*)</TITLE>/)) set -u10 %Mod.Wetter.vOrt $regml(1)
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="dataText" ALIGN="CENTER">(.*)&nbsp;</TD>/)) {
        if (!%Mod.Wetter.vDate) set -u10 %Mod.Wetter.vDate $regml(1)
      }
      if ($regex(%Mod.Wetter.sRead, /WIDTH="25" HEIGHT="25" ALT=".*"><br>(.*)&nbsp;</TD>/)) {
        if (!%Mod.Wetter.vDesc) set -u10 %Mod.Wetter.vDesc $regml(1)
      }
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="dataText" ALIGN="CENTER">(.*)&deg;C&nbsp;</TD>/)) {
        if (!%Mod.Wetter.vTemp) set -u10 %Mod.Wetter.vTemp $regml(1) $+ °C
      }
      if (<TD CLASS="dataTextBold" ALIGN="RIGHT">Gef&uuml;hlte Temperatur</TD> isin %Mod.Wetter.sRead) set -u10 %Mod.Wetter.vGefTempC 1
      if (($regex(%Mod.Wetter.sRead, /<TD CLASS="dataText" ALIGN="CENTER">(.*)&nbsp;</TD>/)) && (%Mod.Wetter.vGefTempC)) {
        if (!%Mod.Wetter.vGefTemp) set -u10 %Mod.Wetter.vGefTemp $remove($regml(1), &deg;C) $+ °C
      }
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="dataText" ALIGN="CENTER">(.*)&deg;C&nbsp;</TD>/)) {
        if (!%Mod.Wetter.vTaup) set -u10 %Mod.Wetter.vTaup $regml(1) $+ °C
      }
      if ($regex(%Mod.Wetter.sRead, /(.*)%&nbsp;</TD>/)) {
        if (!%Mod.Wetter.vLuft) set -u10 %Mod.Wetter.vLuft $regml(1) $+ %
      }
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="dataText" ALIGN="CENTER">(.*)&nbsp;km/h&nbsp;</TD>/)) {
        if (!%Mod.Wetter.vWind) set -u10 %Mod.Wetter.vWind $regml(1) km/h
      }
      if ($regex(%Mod.Wetter.sRead, /<TD CLASS="dataText" ALIGN="CENTER" VALIGN="BOTTOM">(.*)%&nbsp;</TD>/)) {
        .timer 1 2 .msg $1 14-=( Wetter für den09 %Mod.Wetter.vDate 14-09 %Mod.Wetter.vOrt 14)=-=( Wetterlage:09 %Mod.Wetter.vDesc 00•14 Gemessene Temp.:09 %Mod.Wetter.vTemp 00•14 Gefühlte Temp.:09 %Mod.Wetter.vGefTemp 00•14 Taupunkt:09 %Mod.Wetter.vTaup 00•14 Luftfeuchtigkeit:09 %Mod.Wetter.vLuft 00•14 Wind:09 %Mod.Wetter.vWind 00•14 Niederschlag:09 $+($regml(1), %) 14)=-
        sockclose Mod.Wetter.sHTTP | unset %Mod.Wetter.* | halt
      }
    }
    sockread %Mod.Wetter.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
