#!/usr/bin/env bats

load '../stub'

function rm {
  return 1
}
function mkdir {
  return 1
}
function ln {
  return 1
}
function touch {
  return 1
}

@test "Stubbing still works when some util binaries are mock functions" {
  run rm ../README.md
  [ "$status" -eq 1 ]

  stub mycommand " : echo OK"
  run mycommand
  [ "$status" -eq 0 ]
  [ "$output" == "OK" ]
  unstub mycommand
}
