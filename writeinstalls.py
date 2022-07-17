import os
import subprocess


folderpath = subprocess.check_output("dirval=$(find ~/.wp_engine_autoscope/ -type f -name 'autoscope.sh' -print -quit 2>/dev/null | rev | cut -d'/' -f2- | rev); echo ${dirval//' '/'\ '}", shell=True).decode()

filepath = "/autoscopeinstalls.sh"

abspath = folderpath.rstrip('\n')+filepath

# abspath = "/Users/$USER/.wp_engine_autoscope/autoscopeinstalls.sh"

print("Preparing to write Install List...\n")

installs = input("Paste Installs here: ")

installsfile = open(abspath, "w")
installsfile.write("#!/bin/bash=" + "\n" + "inst=" + "\"" + installs + "\"")
installsfile.close()

