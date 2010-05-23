[ScriptHeader]
autor=Andreas Schweizer (Andy)
webseite=www.schweizerandreas.de
version=0.1

;****
;* Set the FloodProtection
;**
;* - $Core.FloodProtection.setProtection($script, <network>, <channel>, <time>, <cmd>)
;* - $script = Path and name of the script that start this alias
;* - <network> = Network of the channel
;* - <channel> = Channel where the FloodProtection should be enabled
;* - <time> = How long the FloodProtection, in secounds, should life
;* - <cmd> = Which command should started if the FloorProtection is stoped
;**
;* Return:
;* - Successful: true
;* - Failed: false
;****
alias Core.FloodProtection.setProtection {
  var %script = $1, %network = $2, %channel = $3, %time = $4, %cmd = $5

  if (!%script) {
    $Core.Error.add($script, No script is given! - Stoped setProtection.)
    return false
  }
  elseif (!%network) {
    $Core.Error.add($script, No network is given! - Stoped setProtection.)
    return false
  }
  elseif (!%channel) {
    $Core.Error.add($script, No channel is given! - Stoped setProtection.)
    return false
  }
  elseif (!%time) {
    $Core.Error.add($script, No time is given! - Stoped setProtection.)
    return false
  }
  else {
    if ($timer(Core.FloodProtection. $+ $+(%script, ., %network, ., %channel))) {
      $Core.Error.add($script, The protection for %channel on %network is allready setted - Stoped setProtection.)
      return false
    }

    .timerCore.FloodProtection. $+ $+(%script, ., %network, ., %channel) 1 %time $iif(!%cmd, halt, %cmd)
    return true
  }
}

;****
:* Returns how long the FloodProtection is set
;**
;* - $Core.FloodProtection.getTime($script, <network>, <channel>)
;* - $script = Path and name of the script that start this alias
;* - <network> = Network of the channel
;* - <channel> = Channel where the FloodProtection should be enabled
;**
;* Return:
;* - Successful: Time in sec.
;* - Failed: flase
;****
alias Core.FloodProtection.getTime {
  var %script = $1, %network = $2, %channel = $3

  if (!%script) {
    $Core.Error.add($script, No script is given! - Stoped getTime.)
    return false
  }
  elseif (!%network) {
    $Core.Error.add($script, No network is given! - Stoped getTime.)
    return false
  }
  elseif (!%channel) {
    $Core.Error.add($script, No channel is given! - Stoped getTime.)
    return false
  }
  else {
    if (!$timer(Core.FloodProtection. $+ $+(%script, ., %network, ., %channel))) {
      $Core.Error.add($script, No protection for %channel on %network is setted - Stoped getTime.)
      return false
    }

    return $timer(Core.FloodProtection. $+ $+(%script, ., %network, ., %channel)).secs
  }
}
