@echo off
color 0a
title Running Game (DEBUG MODE)
cd ../..
echo BUILDING...
haxelib run lime test Project.xml windows -debug -D HXCPP_M32
echo. 
echo DONE
pause