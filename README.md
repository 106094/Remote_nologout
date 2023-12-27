For system A Remote system B
1. execute \client\client_setup.bat and reboot on system B
2. execute \remote\remote.bat on system A
3. input the IP address of system B then hit enter. input the login/password in the mstsc window.
4. exit mstsc to end the connection

Limitations
1. in remoted site, only one cotroller is acceptable in the same time.
2. both systems in the same local net area
3. both are windows systems
4. support English/Japaness environment



例如A要遙控B
1. 於遠端系統(B)執行\client\client_setup.bat並重開機 (支援login無設定密碼)
2. 於control系統(A)執行\remote\remote.bat
3. 出現cmd視窗，輸入IP，出現mstsc畫面後輸入username/password，開始remote，client端不會被登出
4. 關閉視窗即可斷開連線，client端不會被登出。
制限：
1.remote端(A)一次只能接受一個remote連線
2.AB系統必須同網域
3.AB都是Windows系統
4.目前支援英文、日文系統。中文系統還沒試過。PS.中文系統若不行請回報。
