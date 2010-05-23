;*************************************************************************************************
;*
;* Calc Addon v1.1 © by www.eVolutionX-Project.de (eVolutionX-Project Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Hiermit kannst du deine Rechnungen ausrechnen lassen, runden kannst du auch.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !calc <Rechnung> wird <Rechnung> ausgerechnet.
;* Mit !calc -r<NR> <Rechnung> kannst du bei <NR> angeben auf wieviel Stellen hinter Komma gerundet werden soll.
;* Mit !calc info bekommst du den Copyright angezeigt.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Changed: Code gesäubert und verbessert.
;*
;*************************************************************************************************
;*                                        IRC Kontakt
;*************************************************************************************************
;*
;* Server: irc.SpeedSpace-IRC.eu
;* Port: 6667
;* Channel: #eVolutionX
;*
;* Befehl: /server -m irc.SpeedSpace-IRC.eu -j #eVolutionX
;*
;*************************************************************************************************
;*                                         ON EVENTS Start
;*************************************************************************************************
; - Trigger Befehl des Calc Addon.
;*************************************************************************************************
on *:TEXT:!calc*:#:{
  if ($2-) {
    if ($2 == info) { .notice $nick 14Calc Addon v1.1 © by 09www.eVolutionX-Project.de14 (09eVolutionX-Project Team14) | halt }
    if ($+(*, $chr(44), *) !iswm $strip($2-)) {
      if (($chr(43) isin $strip($2-)) || ($chr(45) isin $strip($2-)) || ($chr(42) isin $strip($2-)) || ($chr(47) isin $strip($2-))) {
        if (-r* !iswm $2-) .msg # 09 $+ $2- 14=09 $calc($2-) 
        else .msg # 09 $+ $3- 14=09 $round($calc($3-), $remove($2, -r)) 
      }
      else .notice $nick 14Du hast nicht angegeben wie ich's 09rechnen14 soll! 08(09 * 14=09 Multiplizieren 00•09 / 14=09 Dividieren 00•09 + 14=09 Addieren 00•09 - 14=09 Subtrahieren 08)
    }
    else .notice $nick 14Statt dem 09Komma14 musst du einen 09Punkt14 nehmen!
  }
  else .notice $nick 14Du hast vergessen deine 09Rechnung14 anzugeben!
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
