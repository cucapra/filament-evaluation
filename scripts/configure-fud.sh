#!/bin/bash

set -euf -o pipefail

fud c global "$(pwd)/calyx"
fud c stages.futil.exec "$(pwd)/calyx/target/debug/futil"
fud c stages.filament.exec "$(pwd)/filament/target/debug/filament"
fud check