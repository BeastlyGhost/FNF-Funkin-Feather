@echo off
color 0a
title Running Game (RELEASE MODE)
cd ../..
echo BUILDING...
haxelib run lime test windows Project.xml -final -D HXCPP_M32
echo.
echo DONE.
pause