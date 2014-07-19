#!/usr/bin/env bats

@test "NetworkManager not installed" {
  run which NetworkManager
  [ ${status} -eq 1 ]
}

