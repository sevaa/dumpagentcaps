del *.vsix
if not x%1 == x/b powershell .\util\BumpTaskVersion.ps1 -Folder src\DumpAgentCaps & powershell .\util\BumpExtVersion.ps1 -File src\ext.json
call %APPDATA%\npm\tfx extension create --manifest-globs ext.json --root src
