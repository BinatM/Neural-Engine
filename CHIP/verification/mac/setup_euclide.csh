#!/bin/csh


set RED='\033[1;31m'
set NC='\033[0m'



set euclide_workspace_base = "~/euclide_workspace_vlsi"
set euclide_launches_path = "$euclide_workspace_base/.metadata/.plugins/org.eclipse.debug.core/.launches"

mkdir $euclide_launches_path
if ($? != 0) then
  echo "${RED}Error${NC} Directory creation failed. The base path above probably doesn't exist - please check that you have followed step 5 in the exercise guide"
   exit 1
endif

cp ./*launch $euclide_launches_path
if ($? != 0) then
   echo "${RED}Error${NC} Copy operation failed. Please check that you have followed step 5 in the exercise guide"
   exit 1
endif

echo "Success : copied launch configurations into euclide workspace"
