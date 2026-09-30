@echo off
echo ========================================================
echo COMPILING AG_UI (REACT) NATIVELY...
echo ========================================================
cd "resources\[core]\ag_ui\web"
call npm install
call npm run build
cd ..\..\..\..
echo.
echo ========================================================
echo STARTING SECTEUR 212 - FIVEM FXSERVER
echo ========================================================
"C:\Users\doxies\Desktop\fivem\server\FXServer.exe" +exec server.cfg
