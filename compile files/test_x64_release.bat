@echo off
color 0a
title Running Game (RELEASE MODE)
cd ..
echo BUILDING...
haxelib run lime test windows -release
echo.
echo DONE.
pause