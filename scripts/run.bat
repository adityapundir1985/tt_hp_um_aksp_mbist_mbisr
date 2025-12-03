@echo off
cd ..
cd verilog\rtl
iverilog -o ..\..\sim\sim.out *.v ..\..\sim\tb_top.v
if %ERRORLEVEL% neq 0 goto :err
vvp ..\..\sim\sim.out
if %ERRORLEVEL% neq 0 goto :err
gtkwave wave.vcd
goto :eof
:err
echo Build failed
pause
