uwfmgr registry add-exclusion "HKLM\SOFTWARE\WOW6432Node\KasperskyLab\protected\KES\environment\ProductHotfix"
uwfmgr registry add-exclusion "HKCU\Software\Classes\WOW6432Node\CLSID\{7e5fe3d9-985f-4908-91f9-ee19f9fd1514}\InprocHandler"
uwfmgr registry add-exclusion "HKCR\WOW6432Node\CLSID\{7e5fe3d9-985f-4908-91f9-ee19f9fd1514}"
uwfmgr registry add-exclusion "HKCU\Software\Classes\WOW6432Node\CLSID\{603D3800-BD81-11D0-A3A5-00C04FD706EC}"
uwfmgr registry add-exclusion "HKCR\WOW6432Node\CLSID\{603D3800-BD81-11D0-A3A5-00C04FD706EC}"
uwfmgr registry add-exclusion "HKCU\Software\KasperskyLab\protected\KES"
uwfmgr registry add-exclusion "HKLM\SYSTEM\CurrentControlSet\Services\klflt\Parameters\ClientData"
uwfmgr file add-exclusion "C:\Program Files (x86)\Kaspersky Lab\
uwfmgr file add-exclusion "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Endpoint Security for Windows\x64\wmi64.exe"
uwfmgr file add-exclusion "C:\ProgramData\Kaspersky Lab\KES"
pause
