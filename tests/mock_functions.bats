#!/usr/bin/env bats

load '../stub'

setup() {
  function rm {
    # shellcheck disable=SC2317  # Don't warn about unreachable commands in this file
    return 10
  }
  function mkdir {
    # shellcheck disable=SC2317  # Don't warn about unreachable commands in this file
    return 20
  }
  function ln {
    # shellcheck disable=SC2317  # Don't warn about unreachable commands in this file
    return 30
  }
  function touch {
    # shellcheck disable=SC2317  # Don't warn about unreachable commands in this file
    return 40
  }
}


@test "Stubbing still works when some util binaries are mock functions" {
  run rm ../README.md
  [ "$status" -eq 10 ]

  run mkdir new-test
  [ "$status" -eq 20 ]
  [ ! -e new-test ]

  run ln dest orig
  [ "$status" -eq 30 ]
  [ ! -e orig ]

  run touch test-file
  [ "$status" -eq 40 ]
  [ ! -e test-file ]

  stub mycommand " : echo OK"
  run mycommand
  [ "$status" -eq 0 ]
  [ "$output" == "OK" ]
  unstub mycommand

  unset rm mkdir ln touch
}
