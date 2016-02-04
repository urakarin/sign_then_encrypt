#!/bin/bash

passphrase=`pwgen 4 1`
echo $passphrase
echo $passphrase > pass.key
