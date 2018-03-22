@echo off
REM Tool to clean up user profiles for staff who no longer work at Cairn.
REM Cleanly removed profiles off of all Servers in one go.
REM v2.2 © TPJ 20180322
cls

@echo TS Profile Remover

REM Variables
REM 	Ask for Username to work with	
		set /p Profile = "What is the username to remove? "
REM 	Enter user below and REM the line above to hardcode a user
REM 	set Profile=
REM 	Return User SID from provided Username
		for /f "skip=2 tokens=2 delims=," %%A in ('"wmic useraccount where name="%Profile%" get sid /format:csv"') do (set usersid=%%A)
REM 	Turn Safety (No deletions) on by entering REM after the = below
		o=
REM 	Initialise Counter
		set n=1

REM Body
		echo.
		if "%o%"=="REM" (set safetymessage=Saftey Mode Enabled) else (set safetymessage=off)
		Goto Counter

REM Subroutines

:Counter
	If %n% lss 6 (Goto ProcessServer) else (Goto Completed)

:ProcessServer
	REM Sequential Name of Servers
	set servername=CAIRN-TS%n%
	IF Exist \\%servername%\c$\Users\%Profile% (Goto RegBackup) else (echo No profile for %Profile% on %servername%)
	
:RegBackup
	echo %safetymessage%
	echo Backing up HKEY_USERS
	Reg Export \\%servername%\HKEY_USERS C:\HKU_Backup_TS%n%.txt
	Goto CheckTS


:CheckTS
	echo %safetymessage%
	echo Checking \\%servername%\c$\Users\%Profile%
	echo Removing Registry Settings
	set key=\\%servername%\HKEY_USERS\%usersid%
%o%	reg delete %key% /f
	echo %safetymessage%
	echo Removing Profile
%o%	rmdir \\%servername%\c$\Users\%Profile% /s /q
	echo Checked \\%servername%\c$\Users\%Profile%
	echo Cleaned Profile from %servername%
	set /A n=n+1
	Goto Counter

:Completed
	echo.
	echo.
	echo Profile successfully removed from all servers
	echo %safetymessage%
