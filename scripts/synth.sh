#!/bin/bash

set -euf -o pipefail

Yellow='\033[0;33m'       # Yellow
NC='\033[0m'       # Text Reset
Green='\033[0;32m'
Red='\033[0;31m'

WARN="${Yellow}WARNING${NC}"
INFO="${Green}INFO${NC}"
ERR="${Red}ERROR${NC}"

# Programs to synthesize
FILES=(
    table-2/filament/harness.fil
    table-2/filament-reticle/harness.fil
    table-2/chisel-conv-16/conv2d_real_16.sv
)
outputs=table-2/outputs
mkdir -p $outputs

CSV=table-2.csv
echo "LUTs,DSPs,Registers,Frequency" > $CSV

for f in "${FILES[@]}"; do
    dir=$(dirname "$f")
    # The output JSON is named after the folder
    out="$outputs/$(basename "$dir").json"

    # If the output file already exists, skip it
    if [ -f "$out" ]; then
        >&2 echo -e "${WARN}: Skipping synthesis for $f because $out already exists"
    else
        # Get the device.xdc and synth.tcl files in the folder of the file we're checking
        xdc="$dir/device.xdc"
        tcl="$dir/synth.tcl"

        # Get the extension of the file
        ext="${f##*.}"
        # If the extesion if .sv, then the starting state is "synth-verilog", if it is .fil then filament, and error otherwise
        if [ "$ext" = "sv" ]; then
            start="synth-verilog"
        elif [ "$ext" = "fil" ]; then
            start="filament"
        else
            >&2 echo -e "${ERR}: Unknown file extension: $ext"
            exit 1
        fi

        # Run the fud command. We don't need to explicitly handle the difference between
        # the input .sv and .fil files because fud will do that for us.
        >&2 echo -e "${INFO}: Resources for $f using $xdc and $tcl: $out"
        fud e -vv "$f" --from "$start" --to resource-estimate -s synth-verilog.constraints "$xdc" -s synth-verilog.tcl "$tcl" -o "$out"

        # if the previous command failed, remove the out file and exit with an error
        if [ $? -ne 0 ]; then
            rm "$out"
            >&2 echo -e "${ERR}: Failed to get resources for $f"
            exit 1
        fi
    fi

    # Use jq to extract
    cat $out | jq -r "[.lut, .dsp, .registers, .frequency] | @csv" >> $CSV
done

echo "======================"
cat $CSV