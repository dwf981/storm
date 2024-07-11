@echo off
::setlocal EnableDelayedExpansion
set PATH=C:\tools\Anaconda3\condabin;%PATH%
REM Batch script to activate Anaconda environment, set PYTHONPATH, and run unit tests

cd /d "%~dp0.."

REM --- Configuration ---
set CONDA_ENV_NAME=storm  
set PROJECT_ROOT=C:\src\dwf981@gh\storm

REM --- Activate Conda Environment ---
call conda activate %CONDA_ENV_NAME%

REM --- Set PYTHONPATH ---
set PYTHONPATH=%PYTHONPATH%;%PROJECT_ROOT%\src

REM --- Run Unit Tests ---
python -m unittest discover tests

REM --- Optional: Deactivate Environment ---
REM call conda deactivate
pause
