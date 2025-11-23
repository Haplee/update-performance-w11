@echo off
echo ===================================================
echo             Test Script for WinOptimize Fix
echo ===================================================
echo.

:: --- Test Setup ---
echo [SETUP] Creating test directories and files...
mkdir "%TEMP%\\winoptimize_test_dir"
echo "test file" > "%TEMP%\\winoptimize_test_dir\\test.txt"
mkdir "C:\\Windows\\Prefetch\\winoptimize_test_dir"
echo "test file" > "C:\\Windows\\Prefetch\\winoptimize_test_dir\\test.txt"
echo [SETUP] Test directories and files created.
echo.

:: --- Run WinOptimize Script ---
echo [TEST] Running WinOptimize.bat...
call WinOptimize.bat
echo [TEST] WinOptimize.bat execution finished.
echo.

:: --- Verification ---
echo [VERIFY] Verifying that the test directories were deleted...
if not exist "%TEMP%\\winoptimize_test_dir" (
    echo [PASS] The test directory in %%TEMP%% was successfully deleted.
) else (
    echo [FAIL] The test directory in %%TEMP%% was NOT deleted.
)

if not exist "C:\\Windows\\Prefetch\\winoptimize_test_dir" (
    echo [PASS] The test directory in C:\Windows\Prefetch was successfully deleted.
) else (
    echo [FAIL] The test directory in C:\Windows\Prefetch was NOT deleted.
)
echo.

echo ===================================================
echo                      Test Complete
echo ===================================================
pause
