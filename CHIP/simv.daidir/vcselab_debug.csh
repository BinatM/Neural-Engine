#!/bin/csh -f

cd /project/tsmc28mmwave/users/jp1/ws/neural-engine/Neural-Engine/CHIP

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/tools/synopsys/vcs/T-2022.06-SP1-1/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

