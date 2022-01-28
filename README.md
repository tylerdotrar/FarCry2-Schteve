# FarCry2-Schteve
PowerShell based automation for Far Cry 2 modding.

# S.C.H.T.E.V.E.

[Here](https://youtu.be/Z3FQxDj7SIk) is a video showcasing the usage of `FC2.Schteve.ps1` version 2.4.5.

**This video displays:**
- Mass unpacking Far Cry 2 `.dat`/`.fat` files.
- Replacing Far Cry 2 watermark with one of the watermarks from my [Far Cry 2: Modernized](https://www.nexusmods.com/farcry2/mods/308) mod.
- Re-packing `patch_unpack` and moving the output files into the original folder Far Cry 2 directory (`Data_Win32`)
- Launching `FarCry2.exe` from the menu.

Alternative NexusMods [download link](https://www.nexusmods.com/farcry2/mods/316).

# Usage

Supports both PowerShell (desktop) and PowerShell Core.

Relative paths are all irrelevant; the `Tools` directory and `FC2.Schteve.ps1` can be place wherever desired, completely
unrelated.  The only pre-requisite is that you don't modify the names of the directories / files contained within `Tools`
or the folders created by *initializing* the sandbox.

The Sandbox is the base directory where everything happens; that's where files are output, converted, decoded, packed, etc.  Once 
you input your desired Sandbox, remember to **initialize** -- this will create the directories used.

When setting up your three main directories, don't add a slash (`\`) at the end of the input directory.

Menu and directory structure are color coated:
- **Red** = Filepath does not exist / Menu option unavailable due to missing filepath.
- **White** = Filepath exists / Menu option fully available
- **White (with Red Asterisk)** = Base filepath exists, but at least one important derivative filepath does not.

## First-Time Launch (PowerShell Core/Windows Terminal)
![First-Time](https://cdn.discordapp.com/attachments/855920119292362802/931315377500225626/unknown.png)

## Configured & Game Unpacked (PowerShell Core/Windows Terminal)
![Configured](https://cdn.discordapp.com/attachments/855920119292362802/931323131149316126/unknown.png)

## Get-Help (PowerShell Core/Windows Terminal)
![Get-Help](https://cdn.discordapp.com/attachments/855920119292362802/931316369805443132/unknown.png)

## Mass Unpacking
![Unpack](https://cdn.discordapp.com/attachments/620986290317426698/834317841737580554/unknown.png)

## Options
![Options](https://cdn.discordapp.com/attachments/620986290317426698/834312774695256104/unknown.png)

# Disclaimer
Included with this repo are fragments of tools that were not created by me -- some slightly modified, others untouched.
I did not include them to claim credit from the original creators' hard work; they're included for ease of use and forrmatting.

## Tools Included:
- **Gibbed.Dunia** -- unmodified; just stripped down to the files utilized by `FC2.Schteve.ps1`

Binaries used: `Gibbed.Dunia.Pack.exe, Gibbed.Dunia.Unpack.exe, Gibbed.Dunia.ConvertBinary.exe, Gibbed.Dunia.ConvertXml.exe` 
 
 ---> [Original Repository](https://github.com/gibbed/Gibbed.Dunia)

 ---> [Tweaked Variant I Downloaded](https://www.moddb.com/downloads/start/190103)

- **xbt2dds** -- slightly modified to `FC2.xbt2dds.exe`; cleaned up some code, changed terminal output and binary details, added burger icon, recompiled, etc.
Maintains original functionality, minus slight terminal syntax change:

*Syntax:* `FC2.xbt2dds.exe -io C:\Input.xbt C:\OutputFolder`

 ---> [Original Repository](https://github.com/cra0kalo/xbt2dds)

- **FarCry2 XML Decoder** -- changed batch file to internal Schteve functionality; not sure who the original creator is.

 ---> [Download I Used](https://www.moddb.com/downloads/start/195283)
