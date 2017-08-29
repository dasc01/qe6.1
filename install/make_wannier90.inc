#=======================================
# WANNIER90 	
#=======================================

TOPDIR = /scratch/users/dasc/Projects/Builds/OCEAN-HOME/qe-6.1

F90=mpif90
FCOPTS=$(FFLAGS) -nomodule 
LDOPTS=-static-intel 

LIBS =    -lmkl_intel_lp64  -lmkl_sequential -lmkl_core 
