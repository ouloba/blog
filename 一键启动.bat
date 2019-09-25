@echo off
echo Starting lobby...
cd F:\work_sangong\server_svn\server\bin_lobby
start gameserver.exe

ping -n 3 127.0.0.1>nul

echo honghei...
cd F:\work_sangong\server_svn\server\bin_honghei
start gameserver.exe
cd F:\work_sangong\server_svn\server\bin_honghei_bot
start gameserver.exe

ping -n 3 127.0.0.1>nul

echo long hu...
cd F:\work_sangong\server_svn\server\bin_longhu
start gameserver.exe
cd F:\work_sangong\server_svn\server\bin_longhu_bot
start gameserver.exe

ping -n 3 127.0.0.1>nul

echo san gong...
cd F:\work_sangong\server_svn\server\bin_san_gong
start gameserver.exe
cd F:\work_sangong\server_svn\server\bin_sg_bot
start gameserver.exe

ping -n 3 127.0.0.1>nul

echo niuniu...
cd F:\work_sangong\server_svn\server\bin_niuniu\room1
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu\room2
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu\room3
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu\room4
start gameserver.exe

ping -n 3 127.0.0.1>nul

echo niuniu bot...
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot1
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot2
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot3
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot4
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot5
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot6
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot7
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot8
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot9
start gameserver.exe
ping -n 1 127.0.0.1>nul
cd F:\work_sangong\server_svn\server\bin_niuniu_bot\bot10
start gameserver.exe

exit