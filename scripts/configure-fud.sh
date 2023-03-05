#!/bin/bash

set -euf -o pipefail

cd calyx && cargo build && cd ..
cd filament && cargo build && cd ..

fud c stages.futil.exec "$(pwd)/calyx/target/debug/futil"
fud c stages.filament.exec "$(pwd)/filament/target/debug/filament"
fud c stages.cocotb.exec "$(pwd)/filament/target/debug/filament"
fud check