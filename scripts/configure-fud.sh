#!/bin/bash

set -euf -o pipefail

# Update the submodules
git submodule update --init --recursive

# Build the tools
cd calyx && cargo build && cd ..
cd filament && cargo build && cd ..

# Configure fud
fud c stages.futil.exec "$(pwd)/calyx/target/debug/futil"
fud c stages.filament.exec "$(pwd)/filament/target/debug/filament"
fud c stages.cocotb.exec "$(pwd)/filament/target/debug/filament"
fud check