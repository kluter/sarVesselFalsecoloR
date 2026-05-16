@echo off

SET mypath=%~dp0

set /p UserInputPath=Enter ImageChip-Input directory (full path):
set /p UserOutputPath=Enter ImageChip-Output directory (full path):
set /p Threshold=Enter Threshold (e.g. 0.1 - 1.0):

@echo "%UserInputPath%","%UseroutputPath%","%Threshold%">cache.txt

echo Processing. . . . . . .

"C:\Program Files\R\R-3.5.3\bin\R.exe" CMD BATCH --vanilla --slave "%mypath:~0,-1%\sar_vessel_adaptive.R"

del cache.txt

echo Finished.

pause
