#!/bin/bash
sed -n -e 's/[[:space:]]*\(.*\)/\1/p' | grep "."
