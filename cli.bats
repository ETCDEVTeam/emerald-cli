#!/usr/bin/env bats

: ${EMERALD_CLI:=$HOME/.cargo/bin/emerald} # FIXME emerald or emerald-cli?


# Setup and teardown are called surrounding EACH @test.
setup() {
	export EMERALD_BASE_PATH=`mktemp -d`
}

teardown() {
	rm -rf $EMERALD_BASE_PATH
    unset EMERALD_BASE_PATH
}

@test "[meta] succeeds: set env var and tmp dir EMERALD_BASE_PATH" {
    run echo "$EMERALD_BASE_PATH"
    [ "$status" -eq 0 ]
	[ -d $EMERALD_BASE_PATH ]
    [ "$output" != "" ]
}

@test "succeeds: --version" {
	run $EMERALD_CLI --version
	[ "$status" -eq 0 ]
	[[ "$output" == *"v"* ]]
}

@test "succeeds: --help" {
    run $EMERALD_CLI --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Emerald"* ]]
    [[ "$output" == *"Usage"* ]]
    [[ "$output" == *"Options"* ]]
}

@test "succeeds: new --chain=testnet [empty options]" {
    run $EMERALD_CLI new \
        --chain=testnet \
        <<< $'foo\n'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created new account"* ]]
}

@test "succeeds: new --chain=mainnet --security=high --name='Test account' --description='Some description'" {
    run $EMERALD_CLI new \
        --chain=mainnet \
        --security-level=high \
        --name="Test account" \
        --description="Some description" \
        <<< $'foo\n'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created new account"* ]]
}

@test "succeeds: list" {
    run $EMERALD_CLI new \
        --chain=testnet \
        <<< $'foo\n'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created new account"* ]]

    # FIXME I'm ugly.
    local address=$(echo "$output" | perl -lane 'print $F[-1]' | tr -d '\n')
    local removeme='!passphrase:'
    local replacewith=''
    address="${address//$removeme/$replacewith}"
    [[ "$address" != "" ]]
    [[ "$address" == *"0x"* ]]

    run $EMERALD_CLI list \
        --chain=testnet
    echo "$output" # prints in case fails
    echo "$address"

    [ "$status" -eq 0 ]
    [[ "$output" == *"Total: 1"* ]]
    [[ "$output" == *"Account: $address, name: , description:"* ]]
}

@test "succeeds: update" {
    run $EMERALD_CLI new \
        --chain=testnet \
        <<< $'foo\n'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created new account"* ]]

    # FIXME I'm ugly.
    local address=$(echo "$output" | perl -lane 'print $F[-1]' | tr -d '\n')
    local removeme='!passphrase:'
    local replacewith=''
    address="${address//$removeme/$replacewith}"
    [[ "$address" != "" ]]
    [[ "$address" == *"0x"* ]]

    run $EMERALD_CLI update \
        --chain=testnet \
        "$address" \
        --name="NewName" \
        --description="NewDescription"

	echo "$address" # debug
    [ "$status" -eq 0 ]

    run $EMERALD_CLI list \
        --chain=testnet

    [ "$status" -eq 0 ]
    [[ "$output" == *"NewName"* ]]
    [[ "$output" == *"NewDescription"* ]]
}

@test "succeeds: strip" {
    run $EMERALD_CLI new \
        --chain=testnet \
        <<< $'foo\n'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created new account"* ]]

    # FIXME I'm ugly.
    local address=$(echo "$output" | perl -lane 'print $F[-1]' | tr -d '\n')
    local removeme='!passphrase:'
    local replacewith=''
    address="${address//$removeme/$replacewith}"
    [[ "$address" != "" ]]
    [[ "$address" == *"0x"* ]]

    run $EMERALD_CLI strip \
        --chain=testnet \
        "$address" \
        <<< $'foo\n'

    [ "$status" -eq 0 ]
    [[ "$output" == *"Private key: 0x"* ]]
}

@test "succeeds: hide && unhide" {
    run $EMERALD_CLI new \
        --chain=testnet \
        <<< $'foo\n'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created new account"* ]]

    # FIXME I'm ugly.
    local address=$(echo "$output" | perl -lane 'print $F[-1]' | tr -d '\n')
    local removeme='!passphrase:'
    local replacewith=''
    address="${address//$removeme/$replacewith}"
    [[ "$address" != "" ]]
    [[ "$address" == *"0x"* ]]

    # Hide account.
    run $EMERALD_CLI hide \
        --chain=testnet \
        "$address"

	echo "$address" # debug
    [ "$status" -eq 0 ]

    # Ensure is hidden; doesn't show up in list.
    run $EMERALD_CLI list \
        --chain=testnet

    [ "$status" -eq 0 ]
    [[ "$output" != *"$address"* ]]

    # Unhide account.
    run $EMERALD_CLI unhide \
        --chain=testnet \
        "$address"

    # Esnure is not hidden; shows up in list.
    run $EMERALD_CLI list \
        --chain=testnet

    [ "$status" -eq 0 ]
    [[ "$output" == *"$address"* ]]
}
