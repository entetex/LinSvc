#!/bin/bash
SaltMinionHostname="$(cat config.cfg | grep SaltMinionHostname)"
SaltMinionHostname=${SaltMinionHostname#SaltMinionHostname=}

salt $SaltMinionHostname cmd.run 'pwd'