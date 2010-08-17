alias drawcycle {
  var %flags, %win, %color, %size, %center.x, %center.y, %start = 0, %end = 360, %current, %radius, %range, %rate, %fac., %fac.y
  if ($left($1, 1) == -) {
    %flags = $right($1, -1)
    tokenize 32 $2-
  }
  %win = $1
  %color = $2
  %size = $3
  %radius = $4
  %center.x = $5
  %center.y = $6
  %fac.x = 1
  %fac.y = 0.5
  %rate = $calc(90 / (%radius * 3.15))
  tokenize 32 $7-
  if (o isin %flags) {
    %start = $calc($1 % 360)
    %end = $calc($2 % 360)
    tokenize 32 $3-
  }
  if (%start >= %end) inc %end 360
  %range = %start $+ - $+ %end
  %current = 0
  var %x, %y
  var %drawdot = drawdot -n $+ $iif(r isin %flags, r, $null) %win %color $int($sqrt($calc(%size ^ 2 / 2.5)))
  var %drawline = drawline -n $+ $iif(r isin %flags, r, $null) %win %color %size
  var %drawfill = drawfill -n $+ $iif(r isin %flags, r, $null) %win %color %color
  var %last.x, %last.y, %coords
  while (%current <= 90) {
    %x = $calc($sin($calc(%current + 0.4)).deg * %radius * %fac.x)
    %y = $calc($cos($calc(%current + 0.4)).deg * %radius * %fac.y)
    %coords = $null
    if ((%current >= %start) && (%current <= %end)) %coords = $calc(%x + %center.x) $calc(%y * -1 + %center.y)
    inc %current 90
    if ((%current >= %start) && (%current <= %end)) %coords = %coords $calc(%x + %center.x) $calc(%y + %center.y)
    inc %current 90
    if ((%current >= %start) && (%current <= %end)) %coords = %coords $calc(%x * -1 + %center.x) $calc(%y + %center.y)
    inc %current 90
    if ((%current >= %start) && (%current <= %end)) %coords = %coords $calc(%x * -1 + %center.x) $calc(%y * -1 + %center.y)
    inc %current 90
    dec %current 360
    if (%coords) %drawdot %coords
    inc %current %rate
  }
  if ((c isin %flags) && ($calc(%end - %start) < 360)) {
    ;dec %start $calc(%size / (%radius * 15) * 360)
    ;inc %start 360
    ;%start = $calc(%start % 360)
    %x = $calc($sin(%start).deg * %radius * %fac.x)
    %y = $calc($cos(%start).deg * %radius * %fac.y)
    if (%start <= 90) %coords = $calc(%x + %center.x) $calc(%y * -1 + %center.y)
    elseif (%start <= 180) %coords = $calc(%x + %center.x) $calc(%y + %center.y)
    elseif (%start <= 270) %coords = $calc(%x * -1 + %center.x) $calc(%y + %center.y)
    else %coords = $calc(%x * -1 + %center.x) $calc(%y * -1 + %center.y)
    %drawline %center.x %center.y %coords
    %x = $calc($sin(%end).deg * %radius * %fac.x)
    %y = $calc($cos(%end).deg * %radius * %fac.y)
    if (%end <= 90) %coords = $calc(%x + %center.x) $calc(%y * -1 + %center.y)
    elseif (%end <= 180) %coords = $calc(%x + %center.x) $calc(%y + %center.y)
    elseif (%end <= 270) %coords = $calc(%x * -1 + %center.x) $calc(%y + %center.y)
    else %coords = $calc(%x * -1 + %center.x) $calc(%y * -1 + %center.y)
    %drawline %center.x %center.y %coords
  }
  if (f isin %flags) {
    var %fill.deg = $calc(%end / 2 + %start / 2)
    dec %radius $calc(%size * 2)
    %x = $calc($sin(%fill.deg).deg * %radius * %fac.x)
    %y = $calc($cos(%fill.deg).deg * %radius * %fac.y)
    if (%start <= 90) %coords = $calc(%x + %center.x) $calc(%y * -1 + %center.y)
    elseif (%start <= 180) %coords = $calc(%x + %center.x) $calc(%y + %center.y)
    elseif (%start <= 270) %coords = $calc(%x * -1 + %center.x) $calc(%y + %center.y)
    else %coords = $calc(%x * -1 + %center.x) $calc(%y * -1 + %center.y)
    %drawfill %coords
    %drawline %center.x %center.y %coords
  }
  if (n !isin %flags) drawdot %win
}

alias test {
  window -adfhk0p @picwintest -1 -1 1000 1000
  window -a @picwintest
  drawcycle -cro @picwintest $rgb(255, 0, 0) 1 240 500 500 10 45
}
