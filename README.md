# bats-mock

Mocking/stubbing library for BATS (Bash Automated Testing System)

A maintained fork of https://github.com/jasonkarns/bats-mock, which is dormant.

There are great things happening in the `bats` ecosystem! Anyone actively using it should be installing from [bats-core]: https://github.com/bats-core.

## Installation

Recommended installation is via git submodule. Assuming your project's bats
tests are in `test`:

``` sh
git submodule add https://github.com/buildkite-plugins/bats-mock test/helpers/mocks
git commit -am 'added bats-mock module'
```

then in `test/test_helper.bash`:

``` bash
load helpers/mocks/stub
```

## Usage

After loading `bats-mock/stub` you have two new functions defined:

- `stub`: for creating new stubs, along with a plan with expected args and the results to return when called.
- `unstub`: for cleaning up, and also verifying that the plan was fullfilled.

### Stubbing

The `stub` function takes a program name as its first argument, and any remaining arguments goes into the stub plan, one line per arg.

Each plan line represents an expected invocation, with a list of expected arguments followed by a command to execute in case the arguments matched, separated with a colon:

    arg1 arg2 ... : only_run if args matched

The expected args (and the colon) is optional.

So, in order to stub `date`, we could use something like this in a test case (where `format_date` is the function under test, relying on data from the `date` command):

```bash
load helper

# this is the "code under test"
# it would normally be in another file
format_date() {
  date -r 222
}

setup() {
  stub date \
      "-r 222 : echo 'I am stubbed!'" \
      "-r \* : echo 'Wed Dec 31 18:03:42 CST 1969'"
}

teardown() {
  unstub date
}

@test "date format util formats date with expected arguments" {
  result="$(format_date)"
  [ "$result" == 'I am stubbed!' ]

  result="$(format_date)"
  [ "$result" == 'Wed Dec 31 18:03:42 CST 1969' ]
}
```

This verifies that `format_date` indeed called `date` using the args defined in each specified stub, and made proper use of the output of it. Note that `\* will match any **one** argument.

The plan is verified, one by one, as the calls come in, but the final check that there are no remaining un-met plans at the end is left until the stub is removed with `unstub`.

### Unstubbing

Once the test case is done, you should call `unstub <program>` in order to clean up the temporary files, and make a final check that all the plans have been met for the stub.

### Verifying stub input

If you want to verify that your stub was passed the correct data in STDIN, you can redirect its content to a temporary file and check it.

```bash
@test "send_message" {
  stub curl \
    "${_CURL_ARGS} : cat > ${_TMP_DIR}/actual-input ; cat ${_RESOURCES_DIR}/mock-output"

  run send_message
  assert_success
  diff "${_TMP_DIR}/actual-input" "${_RESOURCES_DIR}/expected-input"
  unstub curl
}
```

### Verifying stub arguments

If you want to verify that your stub was called with the correct arguments, you can use (escaped) positional variables in the command. They will be interpreted correctly (`$1`, `$2`, ...).

```bash
@test "send_message" {
  stub curl \
    "-X \* \* : echo \$3 > ${_TMP_DIR}/curl-url; echo \$2 > ${_TMP_DIR}/curl-method"

  run send_message
  
  assert_success
  diff "${_TMP_DIR}/curl-url" "${_RESOURCES_DIR}/expected-url"
  called_method="$(cat ${_TMP_DIR}/curl-method)"
  [ "$called_method" == "POST" ]

  unstub curl
}
```

## Troubleshooting

It can be difficult to figure out why your mock has failed. You can enable debugging setting an environment variable called after the command being stubbed (all in underscore-separeted, uppercase) with the `STUB_DEBUG` suffix. The value of the variable needs to be a device or file descriptor where to redirect the debugging output. Recommended value is `3`, which should make the output compatible with tap's expectation but you can also use `/dev/tty`.

If you have stubbed the `date` command, you can do something like:

```
export DATE_STUB_DEBUG=3
```

## How it works

(You may want to know this, if you get weird results there may be stray files lingering about messing with your state.)

Under the covers, `bats-mock` uses three scripts to manage the stubbed programs/functions.

First, it is the command (or program) itself, which when the stub is created is placed in (or rather, the `binstub` script is sym-linked to) `${BATS_MOCK_BINDIR}/${program}` (which is added to your `PATH` when loading the stub library). Secondly, it creates a stub plan, based on the arguments passed when creating the stub, and finally, during execution, the command invocations are tracked in a stub run file which is checked once the command is `unstub`'ed. The `${program}-stub-[plan|run]` files are both in `${BATS_MOCK_TMPDIR}`.

### Caveat

If you stub functions, make sure to unset them, or the stub script wan't be called, as the function will shadow the binstub script on the `PATH`.

## Credits

Forked from https://github.com/jasonkarns/bats-mock originally with thanks to [@jasonkarns](https://github.com/jasonkarns).

Originally extracted from the [ruby-build][] test suite. Many thanks to its author and contributors: [Sam Stephenson][sstephenson] and [Mislav Marohnić][mislav].

[ruby-build]: https://github.com/sstephenson/ruby-build
[sstephenson]: https://github.com/sstephenson
[mislav]: https://github.com/mislav
