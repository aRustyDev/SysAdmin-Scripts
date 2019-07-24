###############################################################################
#Script for choosing a User to add in AD, from a New_Hire_Table.csv
###############################################################################
###############################################################################
# Transform the Excel Sheet into a CSV, then Import the CSV
###############################################################################
$excelApp = New-Object -ComObject Excel.Application
$excelApp.DisplayAlerts = $false
$excelFile = "C:\Users\asmith\Desktop\New_Hire_Table.xlsx"

$workbook = $excelApp.Workbooks.Open($excelFile)
$csvFile = $excelFile -replace "\.xlsx$", ".csv"
$workbook.SaveAs($csvFile, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSV)
$workbook.Close()

$csvObj = import-csv $csvFile
###############################################################################
# Create a Dynamic Menu of the Listed Users, Color Coded for Who is or Isnt in AD Already
###############################################################################
$newHireList = @()
clear-host
Write-host "****************************************************"
Write-host "****************************************************"
write-host "`t::IN AD::" -F Green
write-host "`t::NOT in AD::`n" -F Cyan

Foreach ($newHire in $csvObj){
    $ct        += 1
    $newHireList += $newHire
    $fullName = $newHire.FirstName + " " + $newHire.LastName

    if(!$newHire.FirstName){
      break
    }
    $ADid = ($newHire.FirstName).substring(0,1) + $newHire.LastName
    if((get-aduser $ADid)){
      write-host "$ct)`t"$fullName -F Green
    }else{
      write-host "$ct)`t"$fullName -F Cyan
    }
}
$targetNewhire = read-host "`n`tNew Hire"
write-host "Target New Hire: " ($newHireList[$targetNewhire - 1]).FirstName
$targetNewhire = $newHireList[$targetNewhire - 1]

###############################################################################
# Return Values: $targetNewhire
###############################################################################
