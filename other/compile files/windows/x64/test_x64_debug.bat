@echo off
color 0a
title Running Game (DEBUG MODE)
cd ../../../..
echo BUILDING...
haxelib run lime test Project.xml windows -debug
echo. 
echo DONE
pause
