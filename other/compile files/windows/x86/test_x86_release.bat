@echo off
color 0a
title Running Game (RELEASE MODE)
cd ../../../..
echo BUILDING...
haxelib run lime test Project.xml windows -release -D HXCPP_M32
echo.
echo DONE.
pause