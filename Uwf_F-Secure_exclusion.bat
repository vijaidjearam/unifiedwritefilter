uwfmgr registry add-exclusion "HKLM\SOFTWARE\F-Secure\"
uwfmgr registry add-exclusion "HKLM\SOFTWARE\F-Secure_Debug"
uwfmgr registry add-exclusion "HKLM\SOFTWARE\WOW6432Node\F-Secure\"
uwfmgr file add-exclusion "C:\Program Files (x86)\F-Secure\"
uwfmgr file add-exclusion "C:\ProgramData\F-Secure\"
uwfmgr file add-exclusion "C:\Windows\System32\config\systemprofile\AppData\Roaming\f-secure\"
Pause
