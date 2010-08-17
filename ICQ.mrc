;*************************************************************************************************
;*
;* ICQ Addon v1.4 © by www.IrcShark.net (IrcShark Team)
;*
;*************************************************************************************************
;*                                         Beschreibung   
;*************************************************************************************************
;*
;* Liest Informationen von dem ICQ User aus und postet sie in den Channel.
;*
;*************************************************************************************************
;*                                         Befehle
;*************************************************************************************************
;* 
;* Mit !icq bekommst du deine ICQ Informationen angezeigt, du musst aber in der Datenbank stehen!
;* Mit !icq <Nr/Nick> bekommst du Informationen von der <Nr> oder dem <Nick>. Der <Nick> muss in Datenbank stehen!
;* Mit !icq add <Nr> wird die ICQ Nummer in die Datenbank eingetragen.
;* Mit !icq del <Nr/Nick> wird die <Nr> oder der <Nick> aus der Datenbank entfernt.
;* Mit !icq list siehst du wer in der Datenbank eingetragen ist.
;* Mit !icq info siehst du Copyright.
;*
;*************************************************************************************************
;*                                         Changes
;*************************************************************************************************
;*
;* v1.4
;*   Fixed: Fehlende Angaben werden nun als Unbekannt angezeigt
;*
;* v1.3
;*   Changed: Code gesäubert und verbessert.
;*
;* v1.2
;*   Fixed: Wenn !icq 1234 abgefragt wurde, kam keine Fehlermeldung.
;*   Fixed: Wenn leerzeichen im Pfad, dann gabs probleme mit der Datei.
;*
;* v1.1
;*   Changed: Op überprüfung, nun werden auch die Status * und ! geprüft.
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
; - Lädt die Dateien beim laden des Addons.
;*************************************************************************************************
on *:LOAD:{
  if ($isfile($Mod.ICQ.aFile)) {
    if ($hget(Mod.ICQ.hData)) hfree Mod.ICQ.hData
    hmake Mod.ICQ.hData 10000
    hload Mod.ICQ.hData $Mod.ICQ.aFile
  }
}

;*************************************************************************************************
; - Entfernt die Dateien beim entladen.
;*************************************************************************************************
on *:UNLOAD:{
  if ($isfile($Mod.ICQ.aFile)) {
    noop $input(Soll die Datei ICQ.hsh gelöscht werden?, yv, Datei Löschen?)
    if ($! == $yes) .remove -b $Mod.ICQ.aFile
  }
  if ($hget(Mod.ICQ.hData)) hfree $ifmatch
}

;*************************************************************************************************
; - Lädt die Hash Tables beim Starten.
;*************************************************************************************************
on *:START:{
  if ($exists($Mod.ICQ.aFile)) {
    if ($hget(Mod.ICQ.hData)) hfree $ifmatch
    hmake Mod.ICQ.hData 10000
    hload Mod.ICQ.hData $Mod.ICQ.aFile
  }
}

;*************************************************************************************************
; - Trigger Befehl des ICQ Addon.
;*************************************************************************************************
on *:TEXT:!icq*:#:{
  if ($2 == info) { .notice $nick 14ICQ Addon v1.4 © by 09www.IrcShark.net14 (09IrcShark Team14) | halt }
  if ($2) {
    if ($2 isnum) {
      sockclose Mod.ICQ.sHTTP*
      sockopen Mod.ICQ.sHTTP1 status.icq.com 80
      sockmark Mod.ICQ.sHTTP1 # $2
    }
    elseif ($2 == add) {
      if ($3) {
        if ($3 isnum) {
          if (!$hfind(Mod.ICQ.hData, $nick)) {
            if (!$hfind(Mod.ICQ.hData, $3).data) {
              sockclose Mod.ICQ.sHTTP*
              sockopen Mod.ICQ.sHTTP www.icq.com 80
              sockmark Mod.ICQ.sHTTP # $3 $nick 1
              .notice $nick 14Deine ICQ Nummer09 $3 14wird auf Gültigkeit überprüft, habe ein Moment Geduld!
            }
            else .notice $nick 14Die ICQ Nummer09 $3 14steht schon in meiner Datenbank!
          }
          else .notice $nick 14Du stehst schon in meiner09 ICQ14 Datenbank!
        }
        else .notice $nick 14Die 09ICQ Nummer14 kann nur aus Zahlen bestehen!
      }
      else .notice $nick 14Du hast vergessen deine09 ICQ Nummer14 anzugeben!
    }
    elseif ($2 == del) {
      if ($left($nick(#, $nick).pnick, 1) isin ~*&!@%) {
        if ($3) {
          if ($3 isnum) {
            if ($hfind(Mod.ICQ.hData, $3).data) {
              hdel Mod.ICQ.hData $hfind(Mod.ICQ.hData, $3).data | hsave Mod.ICQ.hData $Mod.ICQ.aFile
              .notice $nick 14Die ICQ Nummer09 $3 14wurde erfolgreich aus meiner Datenbank entfernt!
            }
            else .notice $nick 14Die ICQ Nummer09 $3 14steht nicht in meiner Datenbank!
          }
          else {
            if ($hfind(Mod.ICQ.hData, $3)) {
              hdel Mod.ICQ.hData $3 | hsave Mod.ICQ.hData $Mod.ICQ.aFile
              .notice $nick 14Der User09 $3 14wurde erfolgreich aus meiner Datenbank entfernt!
            }
            else .notice $nick 14Der User09 $3 14steht nicht in meiner Datenbank!
          }
        }
        else .notice $nick 14Du hast vergessen einen09 Nick 14oder eine09 ICQ Nummer 14anzugeben!
      }
      else .notice $nick 14Du hast dafür keine09 Rechte14! Frag einen09 Operator 14um Hilfe!
    }
    elseif ($2 == list) {
      if ($hget(Mod.ICQ.hData)) {
        if ($hget(Mod.ICQ.hData, 0).item) {
          var %a = $hget(Mod.ICQ.hData, 0).item, %b = %a
          while (%a) { var %Mod.ICQ.vList = %Mod.ICQ.vList 09 $+ $hget(Mod.ICQ.hData, %a).item 14(08 $+ $hget(Mod.ICQ.hData, %a).data $+ 14) | dec %a }
          .notice $nick 14Es $iif(%b == 1, steht09 %b 14Eintrag, stehen09 %b 14Einträge) in der Datenbank: %Mod.ICQ.vList
        }
        else .notice $nick 14Es stehen keine09 Einträge 14in meiner Datenbank!
      }
      else .notice $nick 14Die 09Datenbank 14kann nicht gelesen werden!
    }
    else {
      if ($hfind(Mod.ICQ.hData, $2)) {
        sockclose Mod.ICQ.sHTTP*
        sockopen Mod.ICQ.sHTTP1 status.icq.com 80
        sockmark Mod.ICQ.sHTTP1 # $hget(Mod.ICQ.hData, $2)
      }
      else .notice $nick 14Der User09 $2 14stehst nicht in meiner Datenbank!
    }
  }
  else {
    if ($hfind(Mod.ICQ.hData, $nick)) {
      sockclose Mod.ICQ.sHTTP*
      sockopen Mod.ICQ.sHTTP1 status.icq.com 80
      sockmark Mod.ICQ.sHTTP1 # $hget(Mod.ICQ.hData, $nick)
    }
    else .notice $nick 14Du stehst09 nicht 14in meiner Datenbank!
  }
}

;*************************************************************************************************
; - Öffnet die Seiten www.ICQ.com und http://Status.ICQ.com
;*************************************************************************************************
on *:SOCKOPEN:Mod.ICQ.sHTTP*:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockwrite -n $sockname GET $iif($sockname == Mod.ICQ.sHTTP1, $+(/online.gif?icq=, $2, &amp&img=5), /people/ $+ $2) HTTP/1.1
  sockwrite -n $sockname Host: $iif($sockname == Mod.ICQ.sHTTP1, status.icq.com, www.icq.com)
  sockwrite -n $sockname $crlf
  if ($sockname == Mod.ICQ.sHTTP1) {
    set -u20 %Mod.ICQ.vStatus 05Unbekannt
    set -u10 %Mod.ICQ.vName 05Unbekannt
    set -u10 %Mod.ICQ.vNick 05Unbekannt
    set -u10 %Mod.ICQ.vGesch 05Unbekannt
    set -u10 %Mod.ICQ.vAlter 05Unbekannt
  }
}

;*************************************************************************************************
; - Liest die Daten aus und postet sie in den Chan.
;*************************************************************************************************
on *:SOCKREAD:Mod.ICQ.sHTTP*:{
  tokenize 32 $sock($sockname).mark
  if ($sockerr > 0) { .msg $1 14Es ist ein Fehler aufgetreten:09 $sock($sockname).wsmsg | halt }
  sockread %Mod.ICQ.sRead
  while ($sockbr) {
    if (*<p>The requested URL /online.gif was not found on this server.</p>* iswm %Mod.ICQ.sRead) { .msg $1 14Die ICQ Nummer09 $2 14ist ungültig! | sockclose Mod.ICQ.sHTTP* | unset %Mod.ICQ.* | halt }
    if (*/online1.gif* iswm %Mod.ICQ.sRead) {
      sockclose Mod.ICQ.sHTTP1
      set -u20 %Mod.ICQ.vStatus 09Online
      sockopen Mod.ICQ.sHTTP www.icq.com 80
      sockmark Mod.ICQ.sHTTP $1 $2 | halt
    }
    elseif (*/online0.gif* iswm %Mod.ICQ.sRead) {
      sockclose Mod.ICQ.sHTTP1
      set -u20 %Mod.ICQ.vStatus 04Offline
      sockopen Mod.ICQ.sHTTP www.icq.com 80
      sockmark Mod.ICQ.sHTTP $1 $2 | halt
    }
    elseif (*/online2.gif* iswm %Mod.ICQ.sRead) {
      sockclose Mod.ICQ.sHTTP1
      set -u20 %Mod.ICQ.vStatus 05Unbekannt
      sockopen Mod.ICQ.sHTTP www.icq.com 80
      sockmark Mod.ICQ.sHTTP $1 $2 | halt
    }
    if (<title>ICQ.com - Oops !!</title> isin %Mod.ICQ.sRead) { .msg $1 14Es ist ein 09Fehler 14aufgetreten, versuchs später noch einmal! | sockclose Mod.ICQ.sHTTP* | unset %Mod.ICQ.* | halt }
    if (Location: /people/error.php isin %Mod.ICQ.sRead) {
      if ($4 == 1) .notice $3 14Die ICQ Nummer09 $2 14ist ungültig!
      else .msg $1 14Es ist ein Fehler aufgetreten, frag einen 09Operator14 um Hilfe.
      sockclose Mod.ICQ.sHTTP* | unset %Mod.ICQ.* | halt
    }
    if (($4 == 1) && (ICQ-Benutzer von überall auf der Welt isin %Mod.ICQ.sRead)) .notice $3 14Die ICQ Nummer09 $2 14ist ungültig!
    if (($4 == 1) && ($regex(%Mod.ICQ.sRead, /.*<title>.* - ICQ.com</title>.*/))) {
      hadd -m Mod.ICQ.hData $3 $2 | hsave Mod.ICQ.hData $Mod.ICQ.aFile
      .notice $3 14Deine ICQ Nummer09 $2 14wurde erfolgreich in die Datenbank aufgenommen! | sockclose Mod.ICQ.sHTTP* | unset %Mod.ICQ.* | halt
    }
    if ($regex(%Mod.ICQ.sRead, /.*<div class="h5-2-new">(.*)</div>/)) set -u10 %Mod.ICQ.vNick $replace($regml(1), &lt;, <, &gt;, >, &uuml;, ü, &auml;, ä, &ouml;, ö, &quot;, ", &szlig;, ß, &amp;, &, &ocirc;, ô, &raquo;, », &laquo;, «, &reg;, ®, &deg;, °, &oacute;, ó, &ograve;, ò, &iquest;, ¿, &curren;, €, &nbsp;, $chr(32), Ã¤, ä, Ã¶, ö, Ã¼, ü, ÃŸ, ß)
    if ($regex(%Mod.ICQ.sRead, /					<div class="uinf-2-2-2-1">(.*)</div>/)) set -u10 %Mod.ICQ.vName $regml(1)
    if ($regex(%Mod.ICQ.sRead, /.*M&auml;nnlich/)) set -u10 %Mod.ICQ.vGesch Männlich
    if ($regex(%Mod.ICQ.sRead, /.*Weiblich.*/)) set -u10 %Mod.ICQ.vGesch Weiblich
    if ($regex(%Mod.ICQ.sRead, /(.*) Jahre alt/)) set -u10 %Mod.ICQ.vAlter $remove($regml(1), $chr(9))
    if (</html> isin %Mod.ICQ.sRead) {
      .msg $1 14-=(09 $+ %Mod.ICQ.vNick 14-09 $2 $+ 14)=-=( Status: %Mod.ICQ.vStatus 00•14 Name:09 $iif(%Mod.ICQ.vName, $v1, -) 00•14 Geschlecht:09 $iif(%Mod.ICQ.vGesch, $v1, -) 00•14 Alter:09 $iif(%Mod.ICQ.vAlter, $v1, -) 14)=-
      sockclose Mod.ICQ.sHTTP* | unset %Mod.ICQ.* | halt
    }
    sockread %Mod.ICQ.sRead
  }
}

;*************************************************************************************************
;*                                         ON EVENTS Ende
;*************************************************************************************************

;*************************************************************************************************
;*                                         LOCALE ALIASES Start
;*************************************************************************************************
; - Gibt den Pfad zur Datei wieder:
; - $Mod.ICQ.aFile
;*************************************************************************************************
alias Mod.ICQ.aFile {
  if (!$isdir(System)) mkdir System
  return $+(", $mircdirSystem\ICQ.hsh, ")
}

;*************************************************************************************************
;*                                         LOCALE ALIASES Ende
;*************************************************************************************************
