@echo off
setlocal

echo [INFO] Starting performance test for event log clearing...

:: --- Function to get current time in centiseconds ---
:get_time_cs
for /f "tokens=1-4 delims=:." %%a in ("%time%") do (
    set /a "time_cs=%%a*360000 + (1%%b-100)*6000 + (1%%c-100)*100 + (1%%d-100)"
)
exit /b

:: --- Measure Original Sequential Execution ---
echo [RUN] Measuring original sequential command...
call :get_time_cs
set "start_time_seq=%time_cs%"

for /f "tokens=*" %%a in ('wevtutil el') do (
    wevtutil cl "%%a" >nul 2>nul
)

call :get_time_cs
set "end_time_seq=%time_cs%"
set /a "elapsed_cs_seq=(end_time_seq - start_time_seq)"
echo [RESULT] Original (Sequential) Execution Time: %elapsed_cs_seq% centiseconds
echo.

:: --- Measure New Parallel Execution ---
echo [RUN] Measuring new parallel command...
call :get_time_cs
set "start_time_par=%time_cs%"

for /f "tokens=*" %%a in ('wevtutil el') do (
    start "" /b wevtutil cl "%%a" >nul 2>nul
)

:wait_for_wevtutil
timeout /t 1 /nobreak >nul
tasklist /fi "IMAGENAME eq wevtutil.exe" 2>nul | find "wevtutil.exe" >nul
if %errorlevel%==0 goto wait_for_wevtutil

call :get_time_cs
set "end_time_par=%time_cs%"
set /a "elapsed_cs_par=(end_time_par - start_time_par)"
echo [RESULT] New (Parallel) Execution Time: %elapsed_cs_par% centiseconds
echo.

:: --- Verification ---
echo [VERIFY] Comparing execution times...
if %elapsed_cs_par% LSS %elapsed_cs_seq% (
    echo  - SUCCESS: Parallel execution is faster than sequential execution.
) else (
    echo  - FAILURE: Parallel execution is NOT faster than sequential execution.
)

echo [DONE] Performance test finished.
endlocal
