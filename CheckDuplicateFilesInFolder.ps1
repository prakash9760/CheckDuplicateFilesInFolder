<#
.SYNOPSIS
For Searching duplicate files in a directory

.PARAMETER Path
1. FolderToSearchIn # Default=.
.EXAMPLE
.\CheckDuplicateFilesInFolder.ps1 -FolderToSearchIn "<folderPath>"

WIP: converting the csv correctly
#>
Param([Parameter][string]$FolderToSearchIn)
if(-Not $FolderToSearchIn)
{
    $FolderToSearchIn = $PSScriptRoot
}
$ListOfFilesCsv = Join-Path $PSScriptRoot "ListOfFiles.csv"
$DuplicateList = Join-Path $PSScriptRoot "fileList.txt"
$DuplicateListCsv = Join-Path $PSScriptRoot "DuplicateListCsv.csv"

function Get-ListOfFiles($FolderToSearchIn,$ListOfFilesCsv)
{
    Write-Host "`n"
    Get-ChildItem -Path $FolderToSearchIn -Recurse |`
    foreach{
    $Item = $_
    $Type = $_.Extension
    $Path = $_.FullName
    $Folder = $_.PSIsContainer
    $Age = $_.CreationTime

    $Path | Select-Object `
        @{n="Name";e={$Item}},`
        @{n="Created";e={$Age}},`
        @{n="filePath";e={$Path}},`
        @{n="Extension";e={if($Folder){"Folder"}else{$Type}}}`
    }| Export-Csv $ListOfFilesCsv -NoTypeInformation 

}

function Get-DuplicateListCsv($ListOfFilesCsv,$DuplicateListCsv)
{
    Write-Host "`n"
    $Temp = Import-Csv $ListOfFilesCsv | Select-Object -Property Name,filePath,Created,Extension
    $Temp1 = Import-Csv $ListOfFilesCsv | Select-Object -Property Name,filePath,Created,Extension
    if( Test-Path $DuplicateListCsv)
    {
        Remove-Item $DuplicateListCsv -Force
    }
    

    #$newcsv = {} | Select "DUPLICATECOUNT,NAME,FILEPATH,EXTENSION,CREATED" | Export-Csv $DuplicateListCsv -Append
    #$newcsv={}|Select "DUPLICATECOUNT","NAME","FILEPATH","EXTENSION","CREATED"| Export-Csv $DuplicateListCsv

    foreach($value in $Temp)
    {
        $Dupecount=0
        $msg = "`n*****************Checking for file: $value.name"
        "`n" | Out-File $DuplicateListCsv -Append        

        $dupeCount, $value.name, $value.filepath, $value.Extension, $value.Created | Out-File $DuplicateListCsv -Append        
        #"**********************Details: " | Out-File $DuplicateListCsv -Append
        foreach($value1 in $Temp1)
        {
            If($value.name -eq $value1.name)
            {
                #Write-Host "Duplicate File: $value" -ForegroundColor Yellow
                $DupeCount+=1
                if($Dupecount -gt 1)
                {
                    $Dupecount, $Value1.name, $value1.filepath, $value1.Extension, $value1.Created | Out-File $DuplicateListCsv -Append                    
                }
            }
        }
        if($Dupecount -eq 1)
        {
            
            $Dupecount, $Value.name, $value.filepath, $value.Extension, $value.Created | Out-File $DuplicateListCsv -Append
            
        }
        If($Dupecount -gt 1)
        {
            Write-Host "Duplicate file found: $value.name with count: $Dupecount" -ForegroundColor Cyan
            $Value.name, $value.filepath, $Dupecount | Out-File $DuplicateListCsv -Append
        }
        else
        {
            Write-Host "`n Only one occurance found for $value" -ForegroundColor yellow
        }
    }
}

function Get-DuplicateList([string]$ListOfFilesCsv,[string]$FolderToSearchIn,[String]$DuplicateList)
{
    Write-Host "`n"
    $Temp1 = Import-Csv $ListOfFilesCsv | Where-Object {$_.DupeCount -gt 1} | Select-Object -Property Filename
    
    $Content = "a"
    if(Test-Path $DuplicateList)
    {
        Remove-Item $DuplicateList -Force -Verbose
    }

    Foreach($value in $Temp1)
    {

        Write-Host $value.Filename -ForegroundColor Green
        $Temp2 = $Temp | Where-Object {$_.filename -eq $value.Filename} | Select-Object -Property Folder
    
        $Content = "`n" + $Content + $value
        $FolderPath = $Temp2.Folder.Replace($FolderToSearchIn,"")
        $Content = "`n" + $Content + $FolderPath
        Write-Host $Content
    }

    $Content | Out-File $DuplicateList


    #$Temp = Get-Content C:\Users\prmishra\Desktop\Path2.txt

    #$Temp = $Temp.Replace("E:\Projects\7.8.0.0_Package_platform_build_full\","")
    #$Temp | Out-File "E:\MyPowerShellScripts\CheckDuplicateFilesInFolder\Folders.txt"
}

function DupeCount
{

$Temp = Import-Csv "C:\Users\prmishra\Desktop\DuplicateDlls.csv" | Where-Object {$_.DupeCount -gt 0} | Select-Object -Property GroupID,Filename,Folder,Size,DupeCount

Write-Host "Exporting csv"

$Temp | Export-Csv "E:\MyPowerShellScripts\CheckDuplicateFilesInFolder\Details.csv"

#$Temp |  Out-File "E:\MyPowerShellScripts\CheckDuplicateFilesInFolder\Details.csv"
}

Get-ListOfFiles -ListOfFilesCsv $ListOfFilesCsv -FolderToSearchIn $FolderToSearchIn
Get-DuplicateListCsv -ListOfFilesCsv $ListOfFilesCsv -DuplicateListCsv $DuplicateListCsv

#Get-DuplicateList -DuplicateList $DuplicateList