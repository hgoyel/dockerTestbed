@echo off
setlocal enabledelayedexpansion

echo starting the detection container
docker run -d --name detection --privileged -p 3000:3000 detection
echo starting the attacker container
docker run -d --name attacker --privileged ubuntu_attacker_continous


REM List of elements and files
set "ied=ied1 ied2 ied3 ied4 ied5 ied6 ied7 ied8 ied9 ied10 ied11 ied12 ied13 ied14 ied15 ied16 ied17 ied18"
set "dir=/root/dataset/GOOSE-synthesised-dataset/IEC61850GOOSE_Divided/Normal/"
set "pcap=16.pcapng 17.pcapng 18.pcapng 19.pcapng 20.pcapng 21.pcapng 22.pcapng 23.pcapng 24.pcapng 25.pcapng 26.pcapng 27.pcapng 28.pcapng 29.pcapng 30.pcapng 31.pcapng 32.pcapng 33.pcapng"

REM Split lists into arrays
set i=0
for %%a in (%ied%) do (
    set "array_ied[!i!]=%%a"
    set /A i+=1
)

set i=0
for %%b in (%pcap%) do (
    set "array_pcap[!i!]=%%b"
    set /A i+=1
)

REM Determine the length of the arrays
set /A length=!i!-1

REM Run IED containiers
for /L %%i in (0,1,%length%) do (
    echo starting container !array_ied[%%i]!
    docker run -d --name !array_ied[%%i]! --privileged ubuntu_ied
)


echo starting the replay of packets

REM Execute replay commands
for /L %%i in (0,1,%length%) do (
    echo IED name !array_ied[%%i]!
    echo file name !array_pcap[%%i]!
    REM Add your code here for starting containers or any other processing
    start cmd /k docker exec !array_ied[%%i]! sudo tcpreplay -i eth0 -vK /root/dataset/GOOSE-synthesised-dataset/IEC61850GOOSE_Divided/Normal/!array_pcap[%%i]!
)

timeout /nobreak /t 10 >nul
