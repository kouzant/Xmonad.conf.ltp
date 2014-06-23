#!/usr/bin/env python

import shutil
import os

if __name__=="__main__":
    #Home Directory
    home=os.getenv("HOME")
    #Repository name
    repo=home+"/Xmonad.conf.ltp/"
    #Directories to copy
    #SOURCE:TARGET
    dirs={home+"/.xmonad/":".xmonad/",
            home+"/scripts/xmobar/":"scripts/xmobar/"}
    #Files to copy    
    files=(home+"/.Xdefaults",
            home+"/.xmobarrc",
            home+"/.xsession",
            home+"/scripts/battery")

    #First copy the directories
    for dir,name in dirs.items():
        repoDir=repo+name
        #shutli.copytree() needs the target directory
        #not to exist
        if os.path.exists(repoDir):
            shutil.rmtree(repoDir)
        shutil.copytree(dir,repoDir)

    #Copy the files
    for file in files:
        shutil.copy2(file,repo)
