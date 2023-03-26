#This Tcl command below sets an empty list for Tcl variable assert_output_stop_level 
#The effect of this is that the simulation will not stop upon assertions failures
#which would be the default behaviour, 
#i.e it allows us to continue to the end of simulation even if assertion fail.
set assert_output_stop_level {};
# Turn "X" propogation on
xprop -on
#This will cause the simulation to run until completion
run;

