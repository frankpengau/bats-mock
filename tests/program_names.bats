#!/usr/bin/env bats

load '../stub'

# As the executable names are used to create variable names, we need to check
# what happens when characters are valid in one but not the other

@test "Stub a command with spaces in its name" {
  stub 'my command' "echo run with \${@}"

  run 'my command' llamas on fire

  [ "$status" -eq 0 ]
  [[ "$output" == "run with llamas on fire" ]]

  unstub 'my command'
}

@test "Stub a command a period in its name" {
  stub CMD.EXE "echo run with \${@}"

  run CMD.EXE llamas on fire

  [ "$status" -eq 0 ]
  [[ "$output" == "run with llamas on fire" ]]

  unstub CMD.EXE
}

@test "Stub a command with only non-latin characters" {
  stub á€äßø "echo run with \${@}"

  run á€äßø llamas on fire

  [ "$status" -eq 0 ]
  [[ "$output" == "run with llamas on fire" ]]

  unstub á€äßø
}

@test "Stub a command that does not start with a letter" {
  stub 0-day "echo run with \${@}"

  run 0-day llamas on fire

  [ "$status" -eq 0 ]
  [[ "$output" == "run with llamas on fire" ]]

  unstub 0-day
}

