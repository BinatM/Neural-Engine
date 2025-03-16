#!/bin/csh

set RED='\033[1;31m'
set NC='\033[0m'

if ($#argv != 1) then
  echo "Please use this script as follows: ./create_project.csh <single digit number>"
  exit 1
endif



set dirname = "mac_run_dir";

if (! -f Makefile) then
   echo "You need to copy the Makefile into this directory"
   exit 1
endif

# Make a new directory inside X with a name from the command line
mkdir -p $dirname;
if ($? != 0) then
    echo "${RED}Error${NC} Directory creation failed"
    exit 1
endif

cp ./Makefile $dirname/
if ($? != 0) then
    echo "${RED}Error${NC} Copy operation failed. Are you in ws directory? make sure you are in ws directory where Makefile is accessible"
    exit 1
endif

echo "Success : created the following directory: $dirname, and copied the necessary Makefile into it!"
