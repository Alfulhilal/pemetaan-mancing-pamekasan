@echo off
echo =========================================================================
echo MENJALANKAN BACKEND API SISTEM PEMETAAN MANCING PESISIR PAMEKASAN
echo =========================================================================
cd /d "%~dp0backend"
call venv\Scripts\activate.bat
echo Server aktif di: http://127.0.0.1:8000
echo Dokumentasi Swagger UI: http://127.0.0.1:8000/api/v1/docs
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
