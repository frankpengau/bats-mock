#!/usr/bin/env bats

load '../stub'

function setup() {
    export AWS_CREDENTIALS='
    {
        "Credentials": {
            "SecretAccessKey": "9drTJvcXLB89EXAMPLELB8923FB892xMFI",
            "SessionToken": "AQoXdzELDDY//////////wEaoAK1wvxJY12r2IrDFT2IvAzTCn3zHoZ7YNtpiQLF0MqZye/qwjzP2iEXAMPLEbw/m3hsj8VBTkPORGvr9jM5sgP+w9IZWZnU+LWhmg+a5fDi2oTGUYcdg9uexQ4mtCHIHfi4citgqZTgco40Yqr4lIlo4V2b2Dyauk0eYFNebHtYlFVgAUj+7Indz3LU0aTWk1WKIjHmmMCIoTkyYp/k7kUG7moeEYKSitwQIi6Gjn+nyzM+PtoA3685ixzv0R7i5rjQi0YE0lf1oeie3bDiNHncmzosRM6SFiPzSvp6h/32xQuZsjcypmwsPSDtTPYcs0+YN/8BRi2/IcrxSpnWEXAMPLEXSDFTAQAM6Dl9zR0tXoybnlrZIwMLlMi1Kcgo5OytwU=",
            "Expiration": "2016-03-15T00:05:07Z",
            "AccessKeyId": "ASIAJEXAMPLEXEG2JICEA"
        }    
    }'

    stub jq \
        "-r .Credentials.AccessKeyId : echo ASIAJEXAMPLEXEG2JICEA" \
        "-r .Credentials.SecretAccessKey : echo 9drTJvcXLB89EXAMPLELB8923FB892xMFI" \
        "-r .Credentials.SessionToken : echo AQoXdzELDDY//////////wEaoAK1wvxJY12r2IrDFT2IvAzTCn3zHoZ7YNtpiQLF0MqZye/qwjzP2iEXAMPLEbw/m3hsj8VBTkPORGvr9jM5sgP+w9IZWZnU+LWhmg+a5fDi2oTGUYcdg9uexQ4mtCHIHfi4citgqZTgco40Yqr4lIlo4V2b2Dyauk0eYFNebHtYlFVgAUj+7Indz3LU0aTWk1WKIjHmmMCIoTkyYp/k7kUG7moeEYKSitwQIi6Gjn+nyzM+PtoA3685ixzv0R7i5rjQi0YE0lf1oeie3bDiNHncmzosRM6SFiPzSvp6h/32xQuZsjcypmwsPSDtTPYcs0+YN/8BRi2/IcrxSpnWEXAMPLEXSDFTAQAM6Dl9zR0tXoybnlrZIwMLlMi1Kcgo5OytwU=" \
        "--arg search_string_uppercase \"BATS TEST\" '.Accounts[] | select(.Name|ascii_upcase == \$search_string_uppercase).Id' : echo jqparsedid123456789012" \
        "-r '.' : echo 123456789012"

    stub aws \
        "sts assume-role --role-arn arn:aws:iam::123456789012:role/bats-test-role --role-session-name bats-test : echo ${AWS_CREDENTIALS}"
}

function teardown() {
    # Just clean up
    unstub --allow-missing jq
    unstub --allow-missing aws
}

# Uncomment to enable stub debug output:
export JQ_STUB_DEBUG=/dev/tty
export AWS_STUB_DEBUG=/dev/tty

@test "Stub jq - test 1" {
    run bash -c "jq -r '.'"
    [ "$status" -eq 0 ]
    echo "$output"
    [[ "$output" == *"123456789012"* ]]
}

@test "Stub jq - test 2" {
    run bash -c "jq -r .Credentials.AccessKeyId"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ASIAJEXAMPLEXEG2JICEA"* ]]
}

@test "Stub jq - test 3" {
    run bash -c "jq -r .Credentials.SecretAccessKey"
    [ "$status" -eq 0 ]
    [[ "$output" == *"9drTJvcXLB89EXAMPLELB8923FB892xMFI"* ]]
}

@test "Stub jq - test 4" {
    run bash -c "jq -r .Credentials.SessionToken"
    [ "$status" -eq 0 ]
    [[ "$output" == *"AQoXdzELDDY//////////wEaoAK1wvxJY12r2IrDFT2IvAzTCn3zHoZ7YNtpiQLF0MqZye/qwjzP2iEXAMPLEbw/m3hsj8VBTkPORGvr9jM5sgP+w9IZWZnU+LWhmg+a5fDi2oTGUYcdg9uexQ4mtCHIHfi4citgqZTgco40Yqr4lIlo4V2b2Dyauk0eYFNebHtYlFVgAUj+7Indz3LU0aTWk1WKIjHmmMCIoTkyYp/k7kUG7moeEYKSitwQIi6Gjn+nyzM+PtoA3685ixzv0R7i5rjQi0YE0lf1oeie3bDiNHncmzosRM6SFiPzSvp6h/32xQuZsjcypmwsPSDtTPYcs0+YN/8BRi2/IcrxSpnWEXAMPLEXSDFTAQAM6Dl9zR0tXoybnlrZIwMLlMi1Kcgo5OytwU="* ]]
}

@test "Stub jq - test 5" {
    search_string_uppercase="BATS TEST"
    run bash -c "jq --arg search_string_uppercase \"${search_string_uppercase}\" '.Accounts[] | select(.Name|ascii_upcase == $search_string_uppercase).Id'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"jqparsedid123456789012"* ]]
}

@test "Stub aws" {
    run bash -c "aws sts assume-role --role-arn arn:aws:iam::123456789012:role/bats-test-role --role-session-name bats-test"

    [ "$status" -eq 0 ]
    echo "$output"
    [[ "$output" == *"2016-03-15T00:05:07Z"* ]]
}