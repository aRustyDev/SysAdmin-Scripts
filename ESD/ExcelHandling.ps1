C:
[System.Console]::Clear()
Echo "Format:: C:\Users\Administrator\my_test.xls"
#$excelFile = Read-Host -Prompt 'File Location:'

$excelFile = "C:\Users\adam.c.smith.ctr\Desktop\Book1.xlsx"
$excel = New-Object -ComObject Excel.Application
#So Excel wont open with this
$excel.Visible = $false

Echo "`nOpening Excel"
$workBook = $excel.Workbooks.Open($excelFile)
$temp = $WorkBook.sheets | Select-Object -Property Name
Echo "`nPlease enter the name of the Sheet from the following options"
foreach ($sheet in $temp){
                write-host "`t $($sheet.name)"
}

$SheetName = Read-Host -Prompt 'Sheet Name:'
$workSheet = $WorkBook.sheets.item($SheetName)

Echo "`nSetting Columns"
$column = Read-Host -Prompt 'Column Char:'

Echo "`nClearing Previous Array Objects"
$excelArray = @()
$OutArray = @()

Echo "`nBuilding Array"
$excelArray += $worksheet.columns($column).value2

Echo "`nLooping"
[System.Console]::Clear()
foreach ($alias in $excelArray){

       if ($alias -eq $null){
              Continue
       }else{
              $UserInfo = "" | Select EU_alias,ExchSrvr,MailBox

              foreach ($userEntry in $UserInfo){
                      $ExchStr = (get-aduser -identity $alias -Properties msExchHomeServerName).msExchHomeServerName
                      $HomeMDB = (get-aduser -identity $alias -Properties homeMDB).homeMDB

                      $UserInfo.EU_alias = $alias
                      $UserInfo.ExchSrvr = $ExchStr.split('=')[5]
                      $UserInfo.MailBox = $HomeMDB.split('=,')[1]
                      $OutArray += $UserInfo
              }
       }
}

$OutArray

$excel.Workbooks.Close()
