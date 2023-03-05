set outdir ./out
set partname "xczu3eg-sbva484-1-e"
set IP "./IP"
file mkdir $IP

# Create a new project and read IP
create_project -force -part $partname FutilBuild $outdir
read_ip [glob "$IP/*/*.xci"]
add_files -quiet [glob -nocomplain ./*.sv]
add_files -fileset constrs_1 [glob ./*.xdc]
set_property top main [current_fileset]

# Switch the project to "out-of-context" mode, which frees us from the need to
# hook up every input & output wire to a physical device pin.
set_property \
    -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-mode out_of_context -flatten_hierarchy "rebuilt"} \
    -objects [get_runs synth_1]

# Run synthesis. This is enough to generate the utilization report mentioned
# above but does not include timing information.
launch_runs synth_1
wait_on_run synth_1

# Run implementation to do place & route. This also produces the timing
# report mentioned above. Removing this step makes things go quite a bit
# faster if you just need the resource report!
launch_runs impl_1 -to_step route_design
wait_on_run impl_1
