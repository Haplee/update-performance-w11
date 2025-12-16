@echo off
setlocal

:: 1. SETUP
echo [SETUP] Preparing to test security warning...
set "OUTPUT_FILE=test_security_warning_output.txt"
if exist "%OUTPUT_FILE%" del "%OUTPUT_FILE%"

:: 2. RUN TEST
echo [TEST] Running WinOptimize.bat and capturing output...

:: Simulate user input:
:: 1. Press a key to continue from the welcome screen
:: 2. Answer "S" to the Chris Titus Tech script prompt
:: 3. Answer "N" to the QuickCPU prompt
(
    echo.
    echo S
    echo N
) | WinOptimize.bat > "%OUTPUT_FILE%" 2>&1

:: 3. VERIFY
echo [VERIFY] Analyzing output for security warning...

:: Check for the security warning text
findstr /c:"[ADVERTENCIA DE SEGURIDAD]" "%OUTPUT_FILE%" > nul
if %errorlevel%==0 (
    echo  - SUCCESS: Security warning was displayed as expected.
) else (
    echo  - FAILURE: Security warning was NOT found in the output.
    echo      Output was:
    type "%OUTPUT_FILE%"
)

:: 4. CLEANUP
echo [CLEANUP] Removing test assets...
if exist "%OUTPUT_FILE%" del "%OUTPUT_FILE%"

echo [DONE] Test finished.
endlocal
