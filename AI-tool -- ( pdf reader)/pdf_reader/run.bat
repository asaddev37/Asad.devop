@echo off
call .venv\Scripts\activate
python pdf_reader.py %*
pause
