@echo off
color 0a
title Running Game (RELEASE MODE)
cd ../../..
echo BUILDING...
haxelib run lime test Project.xml windows -final
echo.
echo DONE.
pause
