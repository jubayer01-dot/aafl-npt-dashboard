@echo off
cd /d "%~dp0"
echo Starting AAFL Live MCP Dashboard...
echo Folder: %CD%
echo Checking Node...
node -v
if errorlevel 1 (
  echo Node.js not found. Install from https://nodejs.org
  pause
  exit /b
)
if not exist "node_modules" (
  echo Installing dependencies...
  call npm install
)
echo.
echo Starting server on http://localhost:3001
echo Keep this window open. Open browser to http://localhost:3001
echo Press Ctrl+C to stop.
node server.js
pause
