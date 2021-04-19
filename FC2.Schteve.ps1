function Schteve {
#.SYNOPSIS
# PowerShell based automation for Far Cry 2 modding.
# ARBITRARY VERSION NUMBER:  1.0.0
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# I couldn't think of a catchy name for this tool, so now we're stuck with SCHTEVE.  This script is meant to automate
# some of the tedious aspects of modding Ubisoft's Far Cry® 2.  Currently there's not a ton of functionality, but
# using the fantastic Gibbed.Dunia modding tools it automates some of the most common things:
#
#     [start]   Launches 'FarCry2.exe' for quicker testing.
#
#     [unpack]  Unpacks Far Cry 2's 'patch.dat', 'common.dat', 'worlds.dat', 'dlc1.dat', and 'dlc_jungle.dat' files 
#              and moves them into your specified sandbox directory ('Unpacked Output').
#
#     [pack]    Re-packs the 'patch_unpack' folder in your sandbox directory and moves the output back into 
#              Far Cry 2's '.\Data_Win32\' directory.
#
# When inputing directories, don't add a slash at the end.  Currently directory validation is pretty artificial; it
# only verifies if the input path exists, not if the contents are correct.  
#
# Expect more options to be added in the future.
#
#.LINK
# https://github.com/tylerdotrar/FarCry2-Schteve
# https://nexusmods.com/FarCry2/mods/308

    # Main Directories Used
    $script:FarCry2Folder = "X:\[i] FC2 Modding\[] Sandbox\[i] Game Instance"
    $script:UnpackedFolder = "X:\Example\Sandbox"
    $script:ToolsFolder = "X:\Example\Tools\Gibbed.Dunia Mod Tools"

    # Booleans Used for Directory Validation
    $script:InvalidDirectory1 = $FALSE
    $script:InvalidDirectory2 = $FALSE
    $script:InvalidDirectory3 = $FALSE

    # Header and Directory Listing
    function Banner {

        $script:InvalidDirectory1 = $FALSE
        $script:InvalidDirectory2 = $FALSE
        $script:InvalidDirectory3 = $FALSE

        Write-Host " ─────────────────────────────────────────── 
    ──╔═══╗╔═══╗╔╗─╔╦════╦═══╦╗──╔╦═══╗──    
   ───║╔═╗║║╔═╗║║║─║║╔╗╔╗║╔══╣╚╗╔╝║╔══╝───   
  ────║╚══╗║║─╚╝║╚═╝╠╝║║╚╣╚══╬╗║║╔╣╚══╗────  
  ────╚══╗║║║─╔╗║╔═╗║─║║─║╔══╝║╚╝║║╔══╝────  
   ───║╚═╝╠╣╚═╝╠╣║─║╠╗║║╔╣╚══╦╬╗╔╬╣╚══╦╗──   
    ──╚═══╩╩═══╩╩╝─╚╩╝╚╝╚╩═══╩╝╚╝╚╩═══╩╝─    " -ForegroundColor Yellow

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

        Write-Host "`n`n Directory Info:" -ForegroundColor Yellow

        Write-Host "   Far Cry 2     " -NoNewLine ; Write-Host "   | " -NoNewline -ForegroundColor Yellow
        if (Test-Path -LiteralPath $script:FarCry2Folder) { "$script:FarCry2Folder" }
        else { $script:InvalidDirectory1 = $TRUE ; Write-Host "$script:FarCry2Folder" -ForegroundColor Red }

        Write-Host "   Unpacked Output" -NoNewLine ; Write-Host "  | " -NoNewline -ForegroundColor Yellow
        if (Test-Path -LiteralPath $script:UnpackedFolder) { "$script:UnpackedFolder" }
        else { $script:InvalidDirectory2 = $TRUE ; Write-Host "$script:UnpackedFolder" -ForegroundColor Red }

        Write-Host "   Gibbed.Tools  " -NoNewLine ; Write-Host "   | " -NoNewline -ForegroundColor Yellow
        if (Test-Path -LiteralPath $script:ToolsFolder) { "$script:ToolsFolder`n"}
        else { $script:InvalidDirectory3 = $TRUE ; Write-Host "$script:ToolsFolder" -ForegroundColor Red }
    }

    # Script Options
    function Start-GameInstance {
    
        # Directoy Validation
        if ($script:InvalidDirectory1) {
            Write-Host "`n   Invalid directory path(s)!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }

        Write-Host "`n   [LAUNCHING]" -ForegroundColor Green
        . "$script:FarCry2Folder\bin\FarCry2.exe"
        Start-Sleep -Seconds 3
    }
    function Unpack-GameFiles {
   
        # Directoy Validation
        if ($script:InvalidDirectory1 -or $script:InvalidDirectory2 -or $script:InvalidDirectory3) {
            Write-Host "`n   Invalid directory path(s)!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }
    
        # Files to Unpack
        $PatchDat     = "$script:FarCry2Folder\Data_Win32\patch.dat"
        $CommonDat    = "$script:FarCry2Folder\Data_Win32\common.dat"
        $WorldsDat    = "$script:FarCry2Folder\Data_Win32\worlds\worlds.dat"
        $DLC1Dat      = "$script:FarCry2Folder\Data_Win32\downloadcontent\dlc1\dlc1.dat"
        $DLCJungleDat = "$script:FarCry2Folder\Data_Win32\downloadcontent\dlc_jungle\dlc_jungle.dat"

        # Unpacked Directory Input / Output
        $PatchDirIN      = $PatchDat.Replace(".dat","_unpack")
        $CommonDirIN     = $CommonDat.Replace(".dat","_unpack")
        $WorldsDirIN     = $WorldsDat.Replace(".dat","_unpack")
        $DLC1DirIN       = $DLC1Dat.Replace(".dat","_unpack")
        $DLCJungleDirIN  = $DLCJungleDat.Replace(".dat","_unpack")
        $PatchDirOUT     = "$script:UnpackedFolder\patch_unpack"
        $CommonDirOUT    = "$script:UnpackedFolder\common_unpack"
        $WorldsDirOUT    = "$script:UnpackedFolder\worlds_unpack"
        $DLC1DirOUT      = "$script:UnpackedFolder\dlc1_unpack"
        $DLCJungleDirOUT = "$script:UnpackedFolder\dlc_jungle_unpack"


        # Unpack Game Files
        Write-Host "`n   [UNPACKING 'PATCH'...]" -ForegroundColor Yellow
        . "$script:ToolsFolder\Gibbed.Dunia.Unpack.exe" $PatchDat
        Write-Host "   [UNPACKING 'COMMON'...]" -ForegroundColor Yellow
        . "$script:ToolsFolder\Gibbed.Dunia.Unpack.exe" $CommonDat
        Write-Host "   [UNPACKING 'WORLDS'...]" -ForegroundColor Yellow
        . "$script:ToolsFolder\Gibbed.Dunia.Unpack.exe" $WorldsDat
        Write-Host "   [UNPACKING 'DLC1'...]" -ForegroundColor Yellow
        . "$script:ToolsFolder\Gibbed.Dunia.Unpack.exe" $DLC1Dat
        Write-Host "   [UNPACKING 'DLC_JUNGLE'...]" -ForegroundColor Yellow
        . "$script:ToolsFolder\Gibbed.Dunia.Unpack.exe" $DLCJungleDat
        Start-Sleep -Seconds 2


        # Move Game Files to Unpacked Directory
        try {
            Write-Host "`n   [MOVING 'PATCH_UNPACK'...]" -ForegroundColor Yellow
            Move-Item -LiteralPath "$PatchDirIN" "$PatchDirOUT" -Force -ErrorAction Stop
            Write-Host "   [MOVING 'COMMON_UNPACK'...]" -ForegroundColor Yellow
            Move-Item -LiteralPath "$CommonDirIN" "$CommonDirOUT" -Force -ErrorAction Stop
            Write-Host "   [MOVING 'WORLDS_UNPACK'...]" -ForegroundColor Yellow
            Move-Item -LiteralPath "$WorldsDirIN" "$WorldsDirOUT" -Force -ErrorAction Stop
            Write-Host "   [MOVING 'DLC1_UNPACK'...]" -ForegroundColor Yellow
            Move-Item -LiteralPath "$DLC1DirIN" "$DLC1DirOUT" -Force -ErrorAction Stop
            Write-Host "   [MOVING 'DLC_JUNGLE_UNPACK'...]" -ForegroundColor Yellow
            Move-Item -LiteralPath "$DLCJungleDirIN" "$DLCJungleDirOUT" -Force -ErrorAction Stop
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
        if ($script:InvalidDirectory1 -or $script:InvalidDirectory2 -or $script:InvalidDirectory3) {
            Write-Host "`n   Invalid directory path(s)!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            break
        }

        # Unpacked Directory
        $PatchDirectory = "$script:UnpackedFolder\patch_unpack"
    
        # Packed Input / Output
        $PatchDatIn = "$PatchDirectory" + ".dat"
        $PatchFatIn = "$PatchDirectory" + ".fat"
        $PatchDatOut = "$script:FarCry2Folder\Data_Win32\patch.dat"
        $PatchFatOut = "$script:FarCry2Folder\Data_Win32\patch.fat"


        # Pack Game Files
        Write-Host "`n   [PACKING 'PATCH_UNPACK'...]" -ForegroundColor Yellow
        . "$script:ToolsFolder\Gibbed.Dunia.Pack.exe" $PatchDirectory
        Start-Sleep -Seconds 2


        # Move Game Files to FC2's '.\Data_Win32' directory
        try {
            Write-Host "`n   [MOVING TO '.\DATA_WIN32\'...]" -ForegroundColor Yellow
            Move-Item -LiteralPath "$PatchDatIn" "$PatchDatOut" -Force -ErrorAction Stop
            Move-Item -LiteralPath "$PatchFatIn" "$PatchFatOut" -Force -ErrorAction Stop
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
    function Modify-Directories {
    
        Clear-Host
        Banner

        Write-Host "`n`n Changes:" -ForegroundColor Yellow
        Write-Host " (Press ENTER to keep current value)"

        Write-Host "`n Input new 'Far Cry 2' directory:`n   " -NoNewline -ForegroundColor Yellow ; $UserInput1 = Read-Host
        Write-Host "`n Input new 'Unpacked Files' directory:`n   " -NoNewline -ForegroundColor Yellow ; $UserInput2 = Read-Host
        Write-Host "`n Input new 'Gibbed.Tools' directory:`n   " -NoNewline -ForegroundColor Yellow ; $UserInput3 = Read-Host

        if ($UserInput1 -eq "") { $UserInput1 = $script:FarCry2Folder }
        if ($UserInput2 -eq "") { $UserInput2 = $script:UnpackedFolder }
        if ($UserInput3 -eq "") { $UserInput3 = $script:ToolsFolder }
    
        # Modify Directory Values and Replace Script
        $FinalContent = (Get-Content -Literalpath "$PSScriptRoot\FC2.Schteve.ps1").Replace("$script:FarCry2Folder","$UserInput1").Replace("$script:UnpackedFolder","$UserInput2").Replace("$script:ToolsFolder","$UserInput3")
        Set-Content -Encoding UTF8 -LiteralPath "$PSScriptRoot\FC2.Schteve.ps1" -Value $FinalContent

        # Replace Directory Variables so Reloading isn't Required
        $script:FarCry2Folder = $UserInput1
        $script:UnpackedFolder = $UserInput2
        $script:ToolsFolder = $UserInput3

        Write-Host "`n   [DONE]" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
    function Display-Help {
        Clear-Host
        Get-Help Schteve
        Write-Host "`n Press any key to return to the main menu." -ForegroundColor Yellow
        $NULL = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    # Main Menu System
    while ($TRUE) {

        Clear-Host
        Banner

        Write-Host "`n`n Select Option:" -ForegroundColor Yellow

        # Visually Formatted Menu Options
        Write-host "   [" -NoNewline ; Write-Host "start" -NoNewline -ForegroundColor Red ; Write-Host "]       " -NoNewline
        if ($script:InvalidDirectory1) {  Write-Host "Launch 'FarCry2.exe'" -ForegroundColor Red }
        else { Write-Host "Launch 'FarCry2.exe'"}
         
        Write-host "   [" -NoNewline ; Write-Host "unpack" -NoNewline -ForegroundColor Red ; Write-Host "]      " -NoNewline
        if ($script:InvalidDirectory1 -or $script:InvalidDirectory2 -or $script:InvalidDirectory3) { Write-Host "Unpack ALL Far Cry 2 '.dat'/'.fat' Files" -ForegroundColor Red }
        else { Write-Host "Unpack ALL Far Cry 2 '.dat'/'.fat' Files"}

        Write-host "   [" -NoNewline ; Write-Host "pack" -NoNewline -ForegroundColor Red ; Write-Host "]        " -NoNewline
        if ($script:InvalidDirectory1 -or $script:InvalidDirectory2 -or $script:InvalidDirectory3) { Write-Host "Pack 'patch_unpack' and Move Files" -ForegroundColor Red }
        else { Write-Host "Pack 'patch_unpack' and Move Files"} 

        Write-host "   [" -NoNewline ; Write-Host "modify" -NoNewline -ForegroundColor Red ; Write-Host "]      Modify Directory Paths"
        Write-host "   [" -NoNewline ; Write-Host "help" -NoNewline -ForegroundColor Red ; Write-Host "]        Display More Info"
        Write-host "   [" -NoNewline ; Write-Host "exit" -NoNewline -ForegroundColor Red ; Write-Host "]        Exit Tool"
        
        # User Input
        Write-Host "`n`n Selection: " -NoNewline -ForegroundColor Yellow ; $MenuInput = Read-host

        switch ( $MenuInput.ToUpper() ) {

            "START"   { Start-GameInstance }
            "UNPACK"  { Unpack-GameFiles }
            "PACK"    { Pack-GameFiles }
            "MODIFY"  { Modify-Directories }
            "HELP"    { Display-Help }
            "EXIT"    { Clear-Host ; exit }
            default   { Write-Host "`n   Invalid input." -ForegroundColor Red ; Start-Sleep -Seconds 2 }
        }
    }

}

# Window Modification
$Host.UI.RawUI.WindowTitle = “SCHTEVE ── FarCry2 Modding Utility (v1.0.0)"
$Host.UI.RawUI.BackgroundColor = "Black"

# Start Script
Schteve
