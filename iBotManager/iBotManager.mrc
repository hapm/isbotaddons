alias iBotManager {
  dialog -ma iBotManager iBotManager.Table
}

dialog iBotManager.Table {
  title "iBot-Manager v0.1"
  size -1 -1 562 338
}

on *:dialog:iBotManager:*:*: {
  if ($devent == init) {
    dcx Mark $dname iBotManager.Cb
    xdialog -b $dname +ty

    ;// Call initilisation alias
    iBotManager.Init
  }
}

alias -l iBotManager.Init {
  ;// Initialising control: (Tab 5)
  xdialog -c $dname 5 tab 6 7 548 295 tabstop notheme hot top

  ;// Initialising control: Instalierte Skripte (Tab Item 6)
  xdid -a $dname 5 0 0 Instalierte Skripte $chr(9) 6 listview 4 22 292 174 grid checkbox report

  ;// Initialising control: Nicht installierte Skripte (Tab Item 7)
  xdid -a $dname 5 0 0 Nicht installierte Skripte $chr(9) 7 listview 4 22 540 269 grid singlesel showsel report

  ;// Initialising control: Automatisch nach Updates suchen (Check 3)
  xdialog -c $dname 3 check 355 311 200 20 tabstop
  xdid -t $dname 3 Automatisch nach Updates suchen

  ;// Initialising control: O.K. (Button 4)
  xdialog -c $dname 4 button 6 311 330 20 tabstop
  xdid -t $dname 4 O.K.

}

;// Callback alias for dcxtest_1273605508
alias iBotManager.Cb {

}

;// quick-access menu item
menu * {
  iBotManager: iBotManager
}
