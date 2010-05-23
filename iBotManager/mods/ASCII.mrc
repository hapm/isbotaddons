;*************************************************************************************************
;*
;* ASCII Addon v1.1 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Gibt ASCII Informationen über ein Zeichen.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !ascii <Zahl(33-255)> bekommst du Infos über die Zahl.
;* Mit !ascii <Zeichen> bekommst du ASCII Infos über das Zeichen.
;* Mit !ascii <Wort> bekommst du den ASCII Code vom <Wort> angezeigt.
;* Mit !ascii info siehst du die Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.1
;*   Changed: Code gesäubert und verbessert.
;*   Added: Wort in ASCII Code umwandeln.
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
; - Trigger für ASCII Addon.
;*************************************************************************************************
on *:TEXT:!ascii*:#:{
  if ($2 == info) { .notice $nick 14ASCII Addon v1.1 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if ($2 isnum) {
    if ($2 isnum 32-255) {
      if (($2 == 32) || ($2 == 160)) { .msg # 14-=(ASCII Info für09 $ $+ chr( $+ $2 $+ )14)=-=( Zeichen:09 SPACE 00•14 Hex:09 $base($2, 10, 16, 2) 00•14 Tastenkombi:09 ALT+ $+ $base($2, 10, 10, 4) 14)=- | halt }
      .msg # 14-=(ASCII Info für09 $ $+ chr( $+ $2 $+ )14)=-=( Zeichen:09 $chr($2) 00•14 Hex:09 $base($2, 10, 16, 2) 00•14 Tastenkombi:09 ALT+ $+ $base($2, 10, 10, 4) 14)=-
    }
    else .notice $nick 14Du kannst dir nur die Zeichen09 33 - 25514 anzeigen lassen!
  }
  elseif ($2) {
    if ($len($2) > 1) {
      var %a = $v1, %b = 1, %c = $2
      while (%b <= %a) {
        var %chr = %chr $+($chr(36), chr, $chr(40), $asc($mid(%c, %b, 1)), $chr(41), $iif(%a != %b, $+(14, $chr(44), 09)))
        inc %b
      }
      .msg # 14-=(ASCII Info für09 $2 $+ 14)=-=(14 $+($chr(36), +, $chr(40), 09, %chr, 14, $chr(41)) 14)=-
    }
    else {
      var %a = 33
      while (%a <= 255) {
        if ($2 == $chr(%a)) {
          var %ascii = 1 | .msg # 14-=(ASCII Info für09 $2 $+ 14)=-=( Zeichen:09 $ $+ chr( $+ $asc($2) $+ ) 00•14 Hex:09 $base($asc($2), 10, 16, 2) 00•14 Tastenkombi:09 ALT+ $+ $base($asc($2), 10, 10, 4) 14)=- | halt
        }
        inc %a 1
      }
      if (!%ascii) .notice $nick 14Du kannst dir nur die Zeichen09 33 - 25514 anzeigen lassen!
    }
  }
  else .notice $nick 14Du hast vergessen ein09 Zeichen 14oder eine09 Zahl 14anzugeben!08 Syntax: !ascii <Zeichen/Zahl(33-255)>
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************
