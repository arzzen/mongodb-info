#!/bin/bash

export GREP="grep"
. tests/assert.sh -v

src="./mongodb-info.sh"

assert_raises "$src" 0
assert_contains "$src -h" "usage:" 1
assert_contains "$src -h" "MongoDB connection string. Example:" 1
assert_contains "$src" "MongoDB Stats" 1

assert_end