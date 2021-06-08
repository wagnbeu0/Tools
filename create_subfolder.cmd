@echo off
set Mainfolder=20
set subfolder=30
set count_files=100
set template_file=bild.jpg
set root_folder=U:\Nextcloud\intranet.ben-wagner.de\TEMP

REM Create Mainfolder
FOR /L %%i IN (1,1,%MAINFOLDER%) DO (
  cd /d %root_folder%
  mkdir Mainfolder_%%i
  cd Mainfolder_%%i

REM Create Subfolder in Current Mainfolder
	FOR /L %%k IN (1,1,%subfolder%) DO (
	mkdir Subfolder_%%k
	cd /d Subfolder_%%k
	
		REM Create Files in Current Subfolder
		FOR /L %%l IN (1,1,%count_files%) DO (
		copy /Y %root_folder%\%template_file% .\%%l_%template_file% >NUL
		)
	echo Creating Files in Mainfolder_%%i\Subfolder_%%k done		
	cd /d %root_folder%\Mainfolder_%%i	
	)  
cd /d %ROOT_folder%
)

