@echo off
if exist out rd /s /q out
mkdir out
:input
cls
set input=:
set /p input= ����Ҫ�����lua�ļ��У�
set "input=%input:"=%"
if "%input%"==":" goto input
if not exist "%input%" goto input
for %%i in ("%input%") do if /i "%%~di"==%%i goto input
pushd %cd%
cd /d "%input%">nul 2>nul || exit
set cur_dir=%cd%
popd
set /a num = 0
for /f "delims=" %%i in ('dir /b /a-d /s "%input%"') do (set /a num += 1 & luajit -b %%~fsi out/%%~nxi & echo %%~nxi)
echo ����ű�������%num%
ATTRIB out/*.* +R
pause
