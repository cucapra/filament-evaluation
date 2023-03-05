#!/bin/bash

set -euf -o pipefail

FILES=(
    table-2/filament/harness.fil
    table-2/filament-reticle/harness.fil
    table-2/chisel-conv-16/conv2d_real_16.sv
)
outputs=table-2/outputs

# Check if outputs directory exists and error if it does
if [ -d outputs ]; then
    echo "Error: $outputs already exists. Please remove it before running this script."
    exit 1
else
    mkdir "$outputs"
fi

for f in "${FILES[@]}"; do
    # Get the device.xdc and synth.tcl files in the folder of the file we're checking
    dir=$(dirname "$f")
    xdc="$dir/device.xdc"
    tcl="$dir/synth.tcl"

    # The output JSON is named after the folder
    out="$outputs/$(basename "$dir").json"

    # Get the extension of the file
    ext="${f##*.}"
    # If the extesion if .sv, then the starting state is "synth-verilog", if it is .fil then filament, and error otherwise
    if [ "$ext" = "sv" ]; then
        start="synth-verilog"
    elif [ "$ext" = "fil" ]; then
        start="filament"
    else
        echo "Unknown file extension: $ext"
        exit 1
    fi

    echo "Resources for $f using $xdc and $tcl: $out"
    # Run the fud command. We don't need to explicitly handle the difference between
    # the input .sv and .fil files because fud will do that for us.
    fud e "$f" --from "$start" --to resource-estimate -s synth-files.constraints "$xdc" -s synth-files.tcl "$tcl" > "$out"
done