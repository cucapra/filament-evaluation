#!/bin/bash

set -euf -o pipefail

# Update the submodules
git submodule update --init --recursive

# Install fud
## Check if flit is installed
if ! command -v flit &> /dev/null
then
    >&2 echo "Flit is not installed. Installing..."
    python -m pip install flit
fi
## Check if fud is installed
if ! command -v fud &> /dev/null
then
    >&2 echo "Fud is not installed. Installing..."
    cd calyx/fud && flit install -s && cd ../..
fi
## Check if jq is installed
if ! command -v jq &> /dev/null
then
    >&2 echo "jq is not installed. Please install it before continuing..."
    exit 1
fi
## Check if iverilog is installed
if ! command -v iverilog &> /dev/null
then
    >&2 echo "iverilog is not installed. Please install it before continuing..."
    exit 1
fi

# Install cocotb and dependencies
python -m pip install cocotb pytest

# Build the tools
cd calyx && cargo build && cd ..
cd filament && cargo build && cd ..

# Configure fud
fud c stages.futil.exec "$(pwd)/calyx/target/debug/futil"
fud c stages.filament.exec "$(pwd)/filament/target/debug/filament"
fud c stages.cocotb.exec "$(pwd)/filament/target/debug/filament"
fud check