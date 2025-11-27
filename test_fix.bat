@echo off
setlocal

:: 1. SETUP
echo [SETUP] Creating test directory and a locked file...
if not exist "test_temp" mkdir "test_temp"
if not exist "test_temp\sub_dir" mkdir "test_temp\sub_dir"
echo locked > "test_temp\locked_file.txt"

echo [SETUP] Locking the file...
start "FileLocker" cmd /c "more < "test_temp\locked_file.txt""
timeout /t 2 /nobreak > nul

:: 2. RUN TESTS
echo [TEST] Running original and fixed commands...

:: Original command from WinOptimize.bat
(
    del /f /s /q "test_temp\*.*"
    for /d %%p in ("test_temp\*") do rmdir "%%p" /s /q
) > test_original_output.txt 2>&1

:: Fixed command
(
    del /f /s /q "test_temp\*.*" >nul 2>&1
    for /d %%p in ("test_temp\*") do rmdir "%%p" /s /q >nul 2>&1
) > test_fixed_output.txt 2>&1

:: 3. VERIFY
echo [VERIFY] Analyzing results...

:: Check original output - should contain an error
findstr /c:"being used by another process" "test_original_output.txt" > nul
if %errorlevel%==0 (
    echo  - SUCCESS: Original command failed with expected error.
) else (
    echo  - FAILURE: Original command did not produce the expected error.
    echo      Output was:
    type "test_original_output.txt"
)

:: Check fixed output - should be empty
findstr /r /c:"." "test_fixed_output.txt" > nul
if %errorlevel%==0 (
    echo  - FAILURE: Fixed command produced unexpected output.
    echo      Output was:
    type "test_fixed_output.txt"
) else (
    echo  - SUCCESS: Fixed command produced no output, as expected.
)

:: 4. CLEANUP
echo [CLEANUP] Removing test assets...
taskkill /f /fi "WINDOWTITLE eq FileLocker" > nul
timeout /t 1 /nobreak > nul
if exist "test_temp" rmdir "test_temp" /s /q
if exist "test_original_output.txt" del "test_original_output.txt"
if exist "test_fixed_output.txt" del "test_fixed_output.txt"

echo [DONE] Test finished.
endlocal
