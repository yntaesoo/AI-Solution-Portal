Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

portalDir = fso.GetParentFolderName(WScript.ScriptFullName)

batchFiles = Array( _
  "_start_arfab_service.bat", _
  "_start_dsu_service.bat", _
  "_start_equipment_service.bat", _
  "_start_ocr_service.bat", _
  "_start_chatbot_service.bat", _
  "_start_mentor_service.bat", _
  "_start_startup_club_service.bat", _
  "_start_md_backend.bat", _
  "_start_md_frontend.bat", _
  "_start_md2html_backend.bat", _
  "_start_md2html_frontend.bat", _
  "_start_portal_service.bat", _
  "gateway\start_gateway.bat" _
)

' Construct Korean path names using ChrW to avoid any file encoding/syntax issues in WScript
pathChangUpGwanRyeon = ChrW(52285) & ChrW(50629) & ChrW(44288) & ChrW(46888)
pathMentorMatching = ChrW(52285) & ChrW(50629) & ChrW(46428) & ChrW(53664) & ChrW(47588) & ChrW(52845) & ChrW(49884) & ChrW(49828) & ChrW(53596)
pathStartupClub = ChrW(50976) & ChrW(54617) & ChrW(49373) & ChrW(52285) & ChrW(50629) & ChrW(46041) & ChrW(50500) & ChrW(47532)

For Each file In batchFiles
  logName = Replace(file, "\", "_") & ".log"
  
  If file = "_start_mentor_service.bat" Then
    cmd = "cmd.exe /c cd /d ""H:\Create with Codex\" & pathChangUpGwanRyeon & "\" & pathMentorMatching & """ && call ""C:\Program Files\nodejs\npm.cmd"" run dev"
  ElseIf file = "_start_startup_club_service.bat" Then
    cmd = "cmd.exe /c cd /d ""H:\Create with Codex\" & pathChangUpGwanRyeon & "\" & pathStartupClub & "\startup-club-manager"" && call ""C:\Program Files\nodejs\npm.cmd"" run start -- -p 3004"
  Else
    cmd = "cmd.exe /c cd /d """ & portalDir & """ && call """ & file & """"
  End If
  
  cmd = cmd & " > """ & portalDir & "\" & logName & """ 2>&1"
  WshShell.Run cmd, 0, false
Next
