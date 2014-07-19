#!/usr/bin/env bats

@test "Root password not unset" {
  passwd -S root | grep -v "root NP"
}

