import os
import subprocess


folderpath = subprocess.check_output("find . -type f -name 'autoscope.sh' -print -quit 2>/dev/null | rev | cut -d'/' -f2- | rev", shell=True).decode()

filepath = "/autoscopeinstalls.sh"

abspath = folderpath.rstrip('\n')+filepath

print("Preparing to write Install List to " + abspath + "\n")

installs = input("Paste Installs here: ")

installsfile = open(abspath, "w")
installsfile.write("#!/bin/bash=" + "\n" + "inst=" + "\"" + installs + "\"")
installsfile.close()

