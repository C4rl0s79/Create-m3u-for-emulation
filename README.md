Hey there! I've got two handy Powershell scripts to help you create m3u files for emulators.
I used Powershell because cmd doesn't work with network paths. 
First, run "move multi disc to folders with region.ps1". 
The script will go through all subdirectories from where it was started and search for "(Disc" strings. 
It will then create a directory based on the filename and move the corresponding files to that directory.

Finally, run "create m3u.ps1". This will create an m3u file from files that have "(Disc"
strings in them and are in the correct folders. 



