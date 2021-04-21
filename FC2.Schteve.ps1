function Schteve {
#.SYNOPSIS
# PowerShell based automation for Far Cry 2 modding.
# ARBITRARY VERSION NUMBER:  2.0.1
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# I couldn't think of a catchy name for this tool, so now we're stuck with SCHTEVE.  This 
# script is meant to automate some of the tedious aspects of modding Ubisoft's Far Cry® 2. 
# Using a handful of different open source mod tools (e.g., Gibbed.Dunia, xbt2dds, etc.), 
# this tool automates many of the most common modding tasks:
#
#     [start]    Launches 'FarCry2.exe' for quicker testing.
#
#     [unpack]   Unpacks Far Cry 2's 'patch.dat', 'common.dat', 'worlds.dat', 'dlc1.dat',
#                and 'dlc_jungle.dat' files and moves them into your specified sandbox 
#                directory.
#
#     [pack]     Re-packs the '\patch_unpack' folder in your sandbox directory and moves 
#                the output back into Far Cry 2's '\Data_Win32' directory.
#      
#     [convert]  Converts '.xbt' texture files to and from '.dds'/'.schteve' files for
#                easier texture editing.
#
#     [decode]   Decodes the '.xml' files usually found in the folders of converted
#                'entitylibrarypatchoverride.fcb' files.
#
# Notes:
# - When inputing directories, don't add a slash at the end.
# - Supports both PowerShell desktop and PowerShell Core.
#
#.LINK
# https://github.com/tylerdotrar/FarCry2-Schteve
# https://nexusmods.com/farcry2/mods/308


    ### Base Directories ###
    $script:FarCry2Folder  = "C:\Program Files (x86)\Steam\steamapps\common\Far Cry 2"
    $script:SandboxFolder  = "C:\Example\Sandbox"
    $script:ToolsFolder    = "C:\Example\Tools"


    ### Derivative Paths ###

    # Derivs 1
    $script:FarCry2exe     = "$script:FarCry2Folder\bin\FarCry2.exe"
    $script:FarCry2Win32   = "$script:FarCry2Folder\Data_Win32"

    # Derivs 2
    $script:UnpackOutput   = "$script:SandboxFolder\[] Raw Files"
    $script:XbtTextures    = "$script:SandboxFolder\[] Texture Conversion\XBT"
    $script:DdsTextures    = "$script:SandboxFolder\[] Texture Conversion\DDS"
    $script:XmlDecoding    = "$script:SandboxFolder\[] XML Decoding"
    $script:PatchUnpack    = "$script:SandboxFolder\patch_unpack"

    # Derivs 3
    $script:PackExe        = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.Pack.exe"
    $script:UnpackExe      = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.Unpack.exe"
    $script:XmlExe         = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.ConvertXml.exe"
    $script:BinaryExe      = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.ConvertBinary.exe"
    $script:ConverterExe   = "$script:ToolsFolder\Texture Converter\FC2.xbt2dds.exe"
    $script:DecoderExe     = "$script:ToolsFolder\XML Decoder System Files\Wob.FC2Dunia.exe"


    # Boolean Arrays Used for Directory Validation
    $script:InvalidDerivs1 = @($FALSE, $FALSE, $FALSE)
    $script:InvalidDerivs2 = @($FALSE, $FALSE, $FALSE, $FALSE, $FALSE)
    $script:InvalidDerivs3 = @($FALSE, $FALSE, $FALSE, $FALSE, $FALSE, $FALSE)


    # Header, Directory Listings, and Path Validation
    function Banner ([switch]$FunctionCheck) {
        
        function Verify-BaseFolders   ([string]$BaseItem) {

            if (Test-Path -LiteralPath $BaseItem) { return $FALSE }
            else { return $TRUE }
        }
        function Verify-Derivatives   ([array]$DerivArray,[array]$BooleanArray) {

            for ($Index = 0; $Index -lt $DerivArray.Count; $Index++) {
                
                $DerivativeItem = ($DerivArray[$Index])

                if (Test-Path -LiteralPath $DerivativeItem) { $BooleanArray[$Index] = $FALSE }
                else { $BooleanArray[$Index] = $TRUE }
            }

            return $BooleanArray
        }
        function Display-Derivatives  ([string]$BaseItem,[array]$DerivArray) {

            for ($Index = 0; $Index -lt $DerivArray.Count; $Index++) {
                
                $DerivativeItem = ($DerivArray[$Index])
                $RelativePath = $DerivativeItem.Replace($BaseItem,'.')

                Write-Host "`t`t     - " -NoNewline -ForegroundColor Yellow

                if (Test-Path -LiteralPath $DerivativeItem) { Write-Host $RelativePath }
                else { Write-Host $RelativePath -ForegroundColor Red }
            }
            Write-Host ""
        }


        Write-Host " ─────────────────────────────────────────── 
    ──╔═══╗╔═══╗╔╗ ╔╦════╦═══╦╗  ╔╦═══╗──    
   ───║╔═╗║║╔═╗║║║ ║║╔╗╔╗║╔══╣╚╗╔╝║╔══╝───   
  ────║╚══╗║║ ╚╝║╚═╝╠╝║║╚╣╚══╬╗║║╔╣╚══╗────  
  ────╚══╗║║║ ╔╗║╔═╗║ ║║ ║╔══╝║╚╝║║╔══╝────  
   ───║╚═╝╠╣╚═╝╠╣║ ║╠╗║║╔╣╚══╦╬╗╔╬╣╚══╦╗──   
    ──╚═══╩╩═══╩╩╝ ╚╩╝╚╝╚╩═══╩╝╚╝╚╩═══╩╝─    " -ForegroundColor Yellow

        Write-Host " ───────────────────────────────────────────" -ForegroundColor Yellow
        Write-Host "  SC" -NoNewline -ForegroundColor Red
        Write-Host "ripted " -NoNewline
        Write-Host "H" -NoNewline -ForegroundColor Red
        Write-Host "elper " -NoNewline
        Write-Host "T" -NoNewline -ForegroundColor Red
        Write-Host "ool for (FC2) D" -NoNewLine
        Write-Host "EVE" -NoNewline -ForegroundColor Red
        Write-Host "lopers  "
        Write-Host " ───────────────────────────────────────────" -ForegroundColor Yellow


        # Verify Existence of Base Folders
        $InvalidDirectory1   = Verify-BaseFolders -BaseItem $script:FarCry2Folder
        $InvalidDirectory2   = Verify-BaseFolders -BaseItem $script:SandboxFolder
        $InvalidDirectory3   = Verify-BaseFolders -BaseItem $script:ToolsFolder

        $DerivativeArray1 = @($script:FarCry2exe, $script:FarCry2Win32)
        $DerivativeArray2 = @($script:UnpackOutput, $script:XbtTextures, $script:DdsTextures, $script:XmlDecoding, $script:PatchUnpack)
        $DerivativeArray3 = @($script:PackExe, $script:UnpackExe, $script:BinaryExe, $script:XmlExe, $script:DecoderExe, $script:ConverterExe)

        # Verify Existence of Derivative Folders / Files
        $script:InvalidDerivs1 = Verify-Derivatives -DerivArray $DerivativeArray1 -BooleanArray $script:InvalidDerivs1
        $script:InvalidDerivs2 = Verify-Derivatives -DerivArray $DerivativeArray2 -BooleanArray $script:InvalidDerivs2
        $script:InvalidDerivs3 = Verify-Derivatives -DerivArray $DerivativeArray3 -BooleanArray $script:InvalidDerivs3


        # Metric Shit Ton of Arrays for Less Repetition (Messages, Base Folders, Derivative Folders, Base Booleans, Derivative Booleans)
        $BaseMessages     = @('   Far Cry 2     ','   Sandbox       ','   Tools         ')
        $BaseDirectories  = @($script:FarCry2Folder, $script:SandboxFolder, $script:ToolsFolder)
        $BaseBoolArray    = @($InvalidDirectory1, $InvalidDirectory2, $InvalidDirectory3)

        $DerivativeArrArr = @( @($DerivativeArray1), @($DerivativeArray2), @($DerivativeArray3) )
        $DerivBoolArrArr  = @( @($script:InvalidDerivs1), @($script:InvalidDerivs2), @($script:InvalidDerivs3) )


        # Output Directory Listing
        Write-Host "`n`n Directory Info:" -ForegroundColor Yellow
         
        for ($Index=0; $Index -lt $BaseMessages.Count; $Index++) {

            Write-Host $BaseMessages[$Index] -NoNewLine ; Write-Host "  | " -NoNewline -ForegroundColor Yellow

            if ($BaseBoolArray[$Index]) { Write-Host $BaseDirectories[$Index] -ForegroundColor Red }
            elseif ($DerivBoolArrArr[$Index] -contains $TRUE) { Write-Host $BaseDirectories[$Index] -NoNewline ; Write-Host "*" -ForegroundColor Red }
            else { $BaseDirectories[$Index] }

            if ($FunctionCheck) { Display-Derivatives -BaseItem $BaseDirectories[$Index] -DerivArray $DerivativeArrArr[$Index] }
        }
    }

    # Script Options
    function Start-GameInstance {
    
        # Directoy Validation
        if ($script:InvalidDerivs1[0]) {
            Write-Host "`n   Missing 'FarCry2.exe' executable! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }


        # Visual Formatting
        Clear-Host
        Banner
        Write-host "`n`n [" -NoNewline ; Write-Host "start" -NoNewline -ForegroundColor Red ; Write-Host "]"


        # Launch Game
        Write-Host "`n   [LAUNCHING]" -ForegroundColor Green
        . $script:FarCry2exe
        Start-Sleep -Seconds 3
    }
    function Unpack-GameFiles {
   
        # Directoy Validation
        if ($script:InvalidDerivs1[1]) {
            Write-Host "`n   Missing '\Data_Win32' directory! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
        elseif ($script:InvalidDerivs2[0]) {
            Write-Host "`n   Sandbox not initialized! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
        elseif ($script:InvalidDerivs3[1]) {
            Write-Host "`n   Missing 'Gibbed.Dunia.Unpack.exe' executable! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
         

        # Visual Formatting
        Clear-Host
        Banner
        Write-host "`n`n [" -NoNewline ; Write-Host "unpack" -NoNewline -ForegroundColor Red ; Write-Host "]"
        

        # Find all '.dat' Files to Unpack
        Get-ChildItem -LiteralPath $script:FarCry2Win32 -Recurse -Name "*.dat" | % { $DatFiles += @($_) }


        try {

            # Unpack Game Files
            Write-Host "`n   [UNPACKING...]" -ForegroundColor Yellow

            foreach ($DatFile in $DatFiles) {

                $BaseName = ($DatFile).Split('\')[-1]

                . $script:UnpackExe "$script:FarCry2Win32\$DatFile"
                Write-Host "   - " -NoNewline -ForegroundColor Yellow ; $BaseName.ToUpper()
            }
            Start-Sleep -Seconds 2


            # Move Game Files to Unpacked Directory
            Write-Host "`n   [MOVING...]" -ForegroundColor Yellow

            foreach ($DatFile in $DatFiles) {
                
                $UnpackName = (($DatFile).Split('\')[-1]).Replace('.dat','_unpack')
                $InputName  = "$script:FarCry2Win32\" + $DatFile.Replace('.dat','_unpack')
                $OutputName = "$script:UnpackOutput\$UnpackName"

                # if ( !(Test-Path -LiteralPath $script:UnpackOutput ) ) { New-Item -ItemType Directory $script:UnpackOutput }

                if ($UnpackName -eq 'PATCH_UNPACK') { Move-Item -LiteralPath $InputName "$script:SandboxFolder\$UnpackName" -Force -ErrorAction Stop }
                else { Move-Item -LiteralPath $InputName $OutputName -Force -ErrorAction Stop }
                Write-Host "   - " -NoNewline -ForegroundColor Yellow ; $UnpackName.ToUpper()
            }
            Start-Sleep -Seconds 2


            Write-Host "`n   [DONE]" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }

        # Error Correction if Files Didn't Output Correctly
        catch {

            Write-Host "`n   File(s) not found! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    function Pack-GameFiles {
    
        # Directoy Validation
        if ($script:InvalidDerivs1[1]) {
            Write-Host "`n   Missing '\Data_Win32' directory! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
        elseif ($script:InvalidDerivs2[4]) {
            Write-Host "`n   Missing '\patch_unpack' directory! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
        elseif ($script:InvalidDerivs3[0]) {
            Write-Host "`n   Missing 'Gibbed.Dunia.Pack.exe' executable! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }


        # Visual Formatting
        Clear-Host
        Banner
        Write-host "`n`n [" -NoNewline ; Write-Host "pack" -NoNewline -ForegroundColor Red ; Write-Host "]"


        try {
    
            # Packed Input / Output
            $PatchDatIn = $script:PatchUnpack + ".dat"
            $PatchFatIn = $script:PatchUnpack + ".fat"
            $PatchDatOut = "$script:FarCry2Win32\patch.dat"
            $PatchFatOut = "$script:FarCry2Win32\patch.fat"


            # Error Correction
            if ( !(Test-Path -LiteralPath $script:PatchUnpack) ) {
                Write-Host "`n 'patch_unpack' not found! Aborting." -ForegroundColor Red
                Start-Sleep -Seconds 2
                break
            }


            # Pack Game Files
            Write-Host "`n   [PACKING...]" -ForegroundColor Yellow
            . $script:PackExe $script:PatchUnpack

            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; 'PATCH_UNPACK'
            Start-Sleep -Seconds 2


            # Move Game Files to FC2's '.\Data_Win32' directory
            Write-Host "`n   [MOVING...]" -ForegroundColor Yellow

            Move-Item -LiteralPath "$PatchDatIn" "$PatchDatOut" -Force -ErrorAction Stop
            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; 'PATCH.DAT'

            Move-Item -LiteralPath "$PatchFatIn" "$PatchFatOut" -Force -ErrorAction Stop
            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; 'PATCH.FAT'
            Start-Sleep -Seconds 2


            Write-Host "`n   [DONE]" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }

        # Error Correction if Files Didn't Output Correctly
        catch {

            Write-Host "`n   File(s) not found! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    function Texture-Conversion {

        # Internal Conversion Functions    
        function XBT-to-DDS {
            
            # Create Array of .xbt Files
            Get-ChildItem -LiteralPath $script:XbtTextures -Name "*.xbt" | % { $XbtFiles += @($_) }

            if ($XbtFiles.Count -eq 0) {
                Write-Host "`n   No '.xbt' files found! Aborting." -ForegroundColor Red
                Start-Sleep -Seconds 2
                break 
            }
            elseif ($script:InvalidDerivs3[5]) {
                Write-Host "`n   No 'FC2.xbt2dds.exe' executable! Aborting." -ForegroundColor Red
                Start-Sleep -Seconds 2
                break 
            }


            # Visual Formatting
            Clear-Host
            Banner
            Write-host "`n`n [" -NoNewline ; Write-Host "convert" -NoNewline -ForegroundColor Red ; Write-Host "]"
            Write-host "`n [" -NoNewline ; Write-Host "one" -NoNewline -ForegroundColor Red ; Write-Host "]"


            Write-Host "`n   [CONVERTING TO DDS...]" -ForegroundColor Yellow

            foreach ($XbtFile in $XbtFiles) { 
                
                $SchteveFile = $XbtFile.Replace('.xbt','.schteve')
                $DdsFile     = $XbtFile.Replace('.xbt','.dds')

                $XbtFilePath = "$script:XbtTextures\$XbtFile"
                $SchteveOutput = "$script:DdsTextures\" + $SchteveFile

                # Output .xbt Header to .schteve File
                if ($PSEdition -eq 'Core') { $FileBytes   = (Get-Content -LiteralPath $XbtFilePath -AsByteStream -First 50) -Join ' ' }
                else { $FileBytes   = (Get-Content -LiteralPath $XbtFilePath -Encoding Byte -First 50) -Join ' ' }

                $XbtHeader   = ($FileBytes -Split ' 68 68 83')[0] -Split ' '

                [System.IO.File]::WriteAllBytes($SchteveOutput,$XbtHeader)
                

                # Convert .xbt Files to .dds Files
                . $script:ConverterExe -io $XbtFilePath $script:DdsTextures | Out-Null

                Write-Host "   - " -NoNewline -ForegroundColor Yellow ; $DdsFile.ToUpper()
                Write-Host "   - " -NoNewline -ForegroundColor Yellow ; $SchteveFile.ToUpper()
            }
            Start-Sleep -Seconds 2

            Write-host "`n   [DONE]" -ForegroundColor Green
            Start-Sleep -Seconds 3

        }
        function DDS-to-XBT {
            
            # Create Arrays of .xbt and .schteve Files
            Get-ChildItem -LiteralPath $script:DdsTextures -Name "*.dds" | % { $DdsFiles += @($_) }

            if ($DdsFiles.Count -eq 0) {
                Write-Host "`n   No '.dds' files found! Aborting." -ForegroundColor Red
                Start-Sleep -Seconds 2
                break 
            }


            # Visual Formatting
            Clear-Host
            Banner
            Write-host "`n`n [" -NoNewline ; Write-Host "convert" -NoNewline -ForegroundColor Red ; Write-Host "]"
            Write-host "`n [" -NoNewline ; Write-Host "one" -NoNewline -ForegroundColor Red ; Write-Host "]"

        
            Write-Host "`n   [CONVERTING TO XBT...]" -ForegroundColor Yellow

            for ($Index = 0; $Index -lt $DdsFiles.Count; $Index++) {
            
                $DdsFile         = $DdsFiles[$Index]

                $XbtFile         = $DdsFile.Replace('.dds','.xbt')
                $XbtOutput       = "$script:XbtTextures\" + $XbtFile

                $DdsFilePath     = "$script:DdsTextures\" + $DdsFile
                $SchteveFilePath = $DdsFilePath.Replace('.dds','.schteve')


                # Concatenate Header Bytes with .dds File Bytes; Output .xbt File
                try {
                
                    $FileHead    = [System.IO.File]::ReadAllBytes($SchteveFilePath)
                    $FileBase    = [System.IO.File]::ReadAllBytes($DdsFilePath)

                    $FileContent = $FileHead + $FileBase

                    # Output Recreated .xbt File
                    [System.IO.File]::WriteAllBytes($XbtOutput,$FileContent)

                    Write-Host "   - " -NoNewline -ForegroundColor Yellow ; $XbtFile.ToUpper()
                }
                catch {
                    Write-Host "   - " -NoNewline -ForegroundColor Yellow ; Write-Host $XbtFile.ToUpper() -ForegroundColor Red
                }
            }
            Start-Sleep -Seconds 2

            Write-host "`n   [DONE]" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }


        # Directory Validation
        if ($script:InvalidDerivs2[1] -or $script:InvalidDerivs2[2]) {
            Write-Host "`n   Sandbox not initialized! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break 
        }


        $MiniMenu = $TRUE
        while ($MiniMenu) {
        
            Clear-Host
            Banner
            Write-host "`n`n [" -NoNewline ; Write-Host "convert" -NoNewline -ForegroundColor Red ; Write-Host "]"

            Write-Host "`n`n Select Conversion:" -ForegroundColor Yellow
            Write-host "   [" -NoNewline ; Write-Host "one" -NoNewline -ForegroundColor Red ; Write-Host "]         XBT-to-DDS"
            Write-host "   [" -NoNewline ; Write-Host "two" -NoNewline -ForegroundColor Red ; Write-Host "]         DDS-to-XBT"
            Write-host "   [" -NoNewline ; Write-Host "back" -NoNewline -ForegroundColor Red ; Write-Host "]        Back to Main Menu"

            Write-Host "`n`n Selection:`n   |" -NoNewline -ForegroundColor Yellow; $ConversionInput = Read-Host
        
            switch ( $ConversionInput.ToUpper() ) {
           
                "ONE"   { XBT-to-DDS }
                "TWO"   { DDS-to-XBT }
                "BACK"  { $MiniMenu = $FALSE }
                default { Write-Host "`n   Invalid input." -ForegroundColor Red ; Start-Sleep -Seconds 2 }
            } 
        }
    }
    function XML-Decoding {
        
        # Directoy Validation
        if ($script:InvalidDerivs2[3]) {
            Write-Host "`n   Sandbox not initialized! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
        elseif ($script:InvalidDerivs3[4]) {
            Write-Host "`n   Missing 'Wob.FC2Dunia.exe' executable! Aborting." -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
        

        # Visual Formatting
        Clear-Host
        Banner
        Write-host "`n`n [" -NoNewline ; Write-Host "decode" -NoNewline -ForegroundColor Red ; Write-Host "]"

        
        # Visual Formatting for Consistency
        Get-ChildItem -LiteralPath $script:XmlDecoding -Name "*.xml" | % { $XmlFiles += @($_) }
        Write-Host "`n   [DECODING...]" -ForegroundColor Yellow


        # Only Line doing Actual Decoding
        . $script:DecoderExe -n -t $script:XmlDecoding | Out-Null


        # Comparing LastWriteTime to Completion time for Success Estimate
        $CompletionTime = (Get-Date).AddSeconds(-30)

        foreach ($XmlFile in $XmlFiles) {
            
            $LastWrite = (Get-Item -LiteralPath "$script:XmlDecoding\$XmlFile").LastWriteTime

            if ($CompletionTime -lt $LastWrite) { Write-Host "   - " -NoNewline -ForegroundColor Yellow ; $XmlFile.ToUpper() }
            else { Write-Host "   - " -NoNewline -ForegroundColor Yellow ; Write-Host $XmlFile.ToUpper() -ForegroundColor Red }
        }
        Start-Sleep -Seconds 2

        Write-host "`n   [DONE]" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
    function Folder-Options {
        
        # Internal Options Functions
        function Modify-Folders {

            # Visual Formatting
            Clear-Host
            Banner -FunctionCheck
            Write-host "`n [" -NoNewline ; Write-Host "options" -NoNewline -ForegroundColor Red ; Write-Host "]"
            Write-host "`n [" -NoNewline ; Write-Host "modify" -NoNewline -ForegroundColor Red ; Write-Host "]"


            # Start User Input
            Write-Host "`n (Press ENTER to keep current value)"

            Write-Host "`n Input new 'Far Cry 2' directory:`n   |" -NoNewline -ForegroundColor Yellow ; $UserInput1 = Read-Host
            Write-Host "`n Input new 'Sandbox' directory:`n   |" -NoNewline -ForegroundColor Yellow ;   $UserInput2 = Read-Host
            Write-Host "`n Input new 'Tools' directory:`n   |" -NoNewline -ForegroundColor Yellow ;     $UserInput3 = Read-Host


            if ($UserInput1 -eq "") { $UserInput1 = $script:FarCry2Folder }
            if ($UserInput2 -eq "") { $UserInput2 = $script:SandboxFolder }
            if ($UserInput3 -eq "") { $UserInput3 = $script:ToolsFolder }
    

            # Modify Directory Values and Replace Script (Set-Content used for Proper .ps1 Encoding)
            $FinalContent = (Get-Content -Literalpath "$PSScriptRoot\FC2.Schteve.ps1").Replace("$script:FarCry2Folder","$UserInput1").Replace("$script:SandboxFolder","$UserInput2").Replace("$script:ToolsFolder","$UserInput3")
            Set-Content -Encoding UTF8 -LiteralPath "$PSScriptRoot\FC2.Schteve.ps1" -Value $FinalContent


            # Replace Directory Variables so Reloading isn't Required
            $script:FarCry2Folder = $UserInput1
            $script:SandboxFolder = $UserInput2
            $script:ToolsFolder   = $UserInput3

            # Recreate Derivative Variables
            $script:FarCry2exe    = "$script:FarCry2Folder\bin\FarCry2.exe"
            $script:FarCry2Win32  = "$script:FarCry2Folder\Data_Win32"

            $script:UnpackOutput  = "$script:SandboxFolder\[] Raw Files"
            $script:XbtTextures   = "$script:SandboxFolder\[] Texture Conversion\XBT"
            $script:DdsTextures   = "$script:SandboxFolder\[] Texture Conversion\DDS"
            $script:XmlDecoding   = "$script:SandboxFolder\[] XML Decoding"
            $script:PatchUnpack   = "$script:SandboxFolder\patch_unpack"

            $script:PackExe       = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.Pack.exe"
            $script:UnpackExe     = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.Unpack.exe"
            $script:XmlExe        = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.ConvertXml.exe"
            $script:BinaryExe     = "$script:ToolsFolder\Gibbed.Dunia\Gibbed.Dunia.ConvertBinary.exe"
            $script:ConverterExe  = "$script:ToolsFolder\Texture Converter\FC2.xbt2dds.exe"
            $script:DecoderExe    = "$script:ToolsFolder\XML Decoder System Files\Wob.FC2Dunia.exe"

            Write-Host "`n   [DONE]" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }
        function Create-Folders {
            
            # Directory Validation
            if ( !($script:InvalidDerivs2[0]) -and !($script:InvalidDerivs2[1]) -and !($script:InvalidDerivs2[2]) -and !($script:InvalidDerivs2[0]) ) { 
                Write-Host "`n   All sandbox directories found! Aborting." -ForegroundColor Red
                Start-Sleep -Seconds 2
                break
            }


            # Visual Formatting
            Clear-Host
            Banner -FunctionCheck
            Write-host "`n [" -NoNewline ; Write-Host "options" -NoNewline -ForegroundColor Red ; Write-Host "]"
            Write-host "`n [" -NoNewline ; Write-Host "init" -NoNewline -ForegroundColor Red ; Write-Host "]"


            # Creating Sandbox Directories
            Write-Host "`n   [CREATING FOLDERS...]" -ForegroundColor Yellow

            if ($script:InvalidDerivs2[0]) { New-Item -ItemType Directory $script:UnpackOutput -Force | Out-Null }
            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; ($script:UnpackOutput.Replace("$script:SandboxFolder\","")).ToUpper()

            if ($script:InvalidDerivs2[1]) { New-Item -ItemType Directory $script:XbtTextures -Force | Out-Null }
            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; ($script:XbtTextures.Replace("$script:SandboxFolder\","")).ToUpper()

            if ($script:InvalidDerivs2[2]) { New-Item -ItemType Directory $script:DdsTextures -Force | Out-Null }
            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; ($script:DdsTextures.Replace("$script:SandboxFolder\","")).ToUpper()

            if ($script:InvalidDerivs2[3]) { New-Item -ItemType Directory $script:XmlDecoding -Force | Out-Null }
            Write-Host "   - " -NoNewline -ForegroundColor Yellow ; ($script:XmlDecoding.Replace("$script:SandboxFolder\","")).ToUpper()
            Start-Sleep -Seconds 2

            Write-Host "`n   [DONE]" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }


        $MiniMenu = $TRUE
        while ($MiniMenu) {
        
            Clear-Host
            Banner -FunctionCheck
            Write-host "`n [" -NoNewline ; Write-Host "options" -NoNewline -ForegroundColor Red ; Write-Host "]"

            Write-Host "`n`n Select Option:" -ForegroundColor Yellow
            Write-host "   [" -NoNewline ; Write-Host "modify" -NoNewline -ForegroundColor Red ; Write-Host "]      Modify Main Directories"
            Write-host "   [" -NoNewline ; Write-Host "init" -NoNewline -ForegroundColor Red ; Write-Host "]        Initialize Sandbox"
            Write-host "   [" -NoNewline ; Write-Host "back" -NoNewline -ForegroundColor Red ; Write-Host "]        Back to Main Menu"

            Write-Host "`n`n Selection:`n   |" -NoNewline -ForegroundColor Yellow; $ConversionInput = Read-Host
        
            switch ( $ConversionInput.ToUpper() ) {
                
                "MODIFY" { Modify-Folders }
                "INIT"   { Create-Folders }
                "BACK"   { $MiniMenu = $FALSE }
                default  { Write-Host "`n   Invalid input." -ForegroundColor Red ; Start-Sleep -Seconds 2 }
            } 
        }
    }
    function Display-Help {

        Clear-Host
        Get-Help Schteve

        Write-Host "`n`n Press any key to return to the main menu." -ForegroundColor Yellow
        $NULL = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    # Main Menu System
    while ($TRUE) {

        Clear-Host
        Banner

        ### Visually Formatted Menu Options ###
        Write-Host "`n`n Function List:" -ForegroundColor Yellow

        # START
        Write-host "   [" -NoNewline ; Write-Host "start" -NoNewline -ForegroundColor Red ; Write-Host "]       " -NoNewline
        if ($script:InvalidDerivs1[0]) {  Write-Host "Launch 'FarCry2.exe'" -ForegroundColor Red }
        else { Write-Host "Launch 'FarCry2.exe'" }

        # UNPACK
        Write-host "   [" -NoNewline ; Write-Host "unpack" -NoNewline -ForegroundColor Red ; Write-Host "]      " -NoNewline
        if ($script:InvalidDerivs1[1] -or $script:InvalidDerivs2[0] -or $script:InvalidDerivs3[1]) { Write-Host "Unpack ALL Far Cry 2 '.dat'/'.fat' Files" -ForegroundColor Red }
        else { Write-Host "Unpack ALL Far Cry 2 '.dat'/'.fat' Files" }

        # PACK
        Write-host "   [" -NoNewline ; Write-Host "pack" -NoNewline -ForegroundColor Red ; Write-Host "]        " -NoNewline
        if ($script:InvalidDerivs1[1] -or $script:InvalidDerivs2[4] -or $script:InvalidDerivs3[0]) { Write-Host "Pack 'patch_unpack' and Move Files" -ForegroundColor Red }
        else { Write-Host "Pack 'patch_unpack' and Move Files" }

        # CONVERT
        Write-host "   [" -NoNewline ; Write-Host "convert" -NoNewline -ForegroundColor Red ; Write-Host "]     " -NoNewline
        if ($script:InvalidDerivs2[1] -or $script:InvalidDerivs2[2] -or $script:InvalidDerivs3[5]) { Write-Host "Convert '.xbt'/'.dds' Texture Files" -ForegroundColor Red }
        else { Write-Host "Convert '.xbt'/'.dds' Texture Files" }

        # DECODE
        Write-host "   [" -NoNewline ; Write-Host "decode" -NoNewline -ForegroundColor Red ; Write-Host "]      " -NoNewline
        if ($script:InvalidDerivs2[3] -or $script:InvalidDerivs3[4]) { Write-Host "Decode '.xml' Files" -ForegroundColor Red }
        else { Write-Host "Decode '.xml' Files" }


        Write-host "   [" -NoNewline ; Write-Host "options" -NoNewline -ForegroundColor Red ; Write-Host "]     View or Edit Directory Info"
        Write-host "   [" -NoNewline ; Write-Host "help" -NoNewline -ForegroundColor Red ; Write-Host "]        Display More Info"
        Write-host "   [" -NoNewline ; Write-Host "exit" -NoNewline -ForegroundColor Red ; Write-Host "]        Exit Tool"

        
        # User Input
        Write-Host "`n`n Selection:`n   |" -NoNewline -ForegroundColor Yellow ; $MenuInput = Read-host

        switch ( $MenuInput.ToUpper() ) {

            "START"   { Start-GameInstance }
            "UNPACK"  { Unpack-GameFiles }
            "PACK"    { Pack-GameFiles }
            "CONVERT" { Texture-Conversion }
            "DECODE"  { XML-Decoding }
            "OPTIONS" { Folder-Options }
            "HELP"    { Display-Help }
            "EXIT"    { Clear-Host ; exit }
            default   { Write-Host "`n   Invalid input." -ForegroundColor Red ; Start-Sleep -Seconds 2 }
        }
    }
}

# Window Modification
$Host.UI.RawUI.WindowTitle = “SCHTEVE ── FarCry2 Modding Utility (v2.0.1)"
$Host.UI.RawUI.BackgroundColor = "Black"

# Start Script
Schteve