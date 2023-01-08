#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn	; Enable warnings to assist with detecting common errors.
#SingleInstance Force
#Include <socket>
#MaxHotkeysPerInterval 140	; High value needed for volume/scroll wheels

SendMode Input	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.

/*********************************************

Function for controlling eISCP AVRs like Onkyo

GitHub: https://github.com/knowsshit/ISCP.ahk

Socket.ahk is required: https://github.com/G33kDude/Socket.ahk
Put that file and this file in Documents\AutoHotKey\Lib

Example init line and set of key bindings to put in your own .ahk script follows below:

ISCP_init("192.168.0.20")		; Change to the IP of your AVR!

; Adjust master volume on receiver with Ctrl+Volume,
; and bass with Ctrl+Shift+Volume
^Volume_Up::ISCP("MVLUP")	; Master vol up
^Volume_Down::ISCP("MVLDOWN")	; Master vol down
^+Volume_Up::ISCP("TFRBUP")	; Bass up
^+Volume_Down::ISCP("TFRBDOWN")	; Bass down
^Volume_Mute::ISCP("AMTTG")	; Mute toggle

; Change Inputs with Win+Ctrl+Shift+F1 to F8
#^+F1::ISCP("SLI01")	; CBL/SAT
#^+F2::ISCP("SLI02")	; GAME 1
#^+F3::ISCP("SLI03")	; AUX (Front HDMI)
#^+F4::ISCP("SLI04")	; GAME 2
#^+F5::ISCP("SLI05")	; PC
#^+F6::ISCP("SLI10")	; BD/DVD
#^+F7::ISCP("SLI11")	; STRM BOX
#^+F8::ISCP("SLI23")	; CD

#^+d::ISCP("DIMDIM")	; Display Dimmer
#^+p::ISCP("PWR01")		; Power on receiver
#^+NumpadAdd::ISCP("AVSUP")	; A/V sync+
#^+NumpadSub::ISCP("AVSDOWN")	; A/V sync-

; OSD keys:
#^+m::ISCP("OSDMENU")		; Open on-screen menu
#^+Up::ISCP("OSDUP")		; OSD up
#^+Down::ISCP("OSDDOWN")	; OSD down
#^+Left::ISCP("OSDLEFT")	; OSD left
#^+Right::ISCP("OSDRIGHT")	; OSD right
#^+Enter::ISCP("OSDENTER")	; OSD enter/select
#^+Del::ISCP("OSDEXIT")		; OSD back/exit
#^+q::ISCP("OSDQUICK")		; OSD quick menu

; End of example set. Copy any lines above to your .ahk script.

(Please note that different receivers accepts different set of commands.
 The commands above are from my script for the AVR Onkyo TX-RZ800.)


Special thanks to:

  *  G33kDude for his work on Socket.ahk
  *  /u/anonymous1184 on Reddit for helping me get started.


  Do not change anything below this line unless you know what you are doing.
  Please make any useful modifications available online here:
  https://github.com/knowsshit/ISCP.ahk

*/


ISCP_init(IP)
{
	Global ISCPclient
	Global ISCPserver
	Global ISCPidle
	ISCPclient := new ISCP() 
	ISCPserver := [IP, 60128]			; Connect to AVR on TCP port 60128
	ISCPclient.Connect(ISCPserver)
	ISCPidle := false
	SetTimer ISCP_idletimeout, 180000	; Make idle sockets time out, just in case....
}

ISCP_idletimeout()
{
	global ISCPidle
	global ISCPclient
	ISCPidle := true
	ISCPclient.Disconnect()
	SetTimer ISCP_idletimeout, off
}

ISCP(cmd)
{
	global ISCPserver
	global ISCPclient
	global ISCPidle
	if (ISCPidle)
	{	;	Reconnect if we timed out
		ISCPclient.Connect(ISCPserver)
		ISCPidle := false
	}
	ISCPclient.cmd(cmd)
	SetTimer ISCP_idletimeout, 180000	; Reset idle timer
}

class ISCP extends SocketTCP
{
	Connect(Address)
	{
		try
			Socket.Connect.Call(this, Address)
		catch e
		{
			MsgBox 0x40010, AutoHotKey ISCP error, % "Could not connect to the AVR :(`nPlease check the IP of your AVR in your ISCP_init() command."
			return
		}
	}
	cmd(cmd)
	{
		static Blocking := False
		static Buffer	; Build eISCP packet to send to receiver
		size := VarSetCapacity(buffer, strlen(cmd) + 19, 0)
		StrPut("ISCP", &buffer, 4, "cp0")	; First 4 header bytes = "ISCP"
		NumPut(0, &buffer, 4, "UChar")		; Header size
		NumPut(0, &buffer, 5, "UChar")		; Header size
		NumPut(0, &buffer, 6, "UChar")		; Header size
		NumPut(16, &buffer, 7, "UChar")		; Header size = 16 bytes
		NumPut(0, &buffer, 8, "UChar")		; Data size
		NumPut(0, &buffer, 9, "UChar")		; Data size
		NumPut(0, &buffer, 10, "UChar")		; Data size (First 11 bytes are static)
		NumPut(strlen(cmd) + 3, &buffer, 11, "UChar") ; Data size (length of "!1cmd`n")
		NumPut(1, &buffer, 12, "UChar")		; ISCP version number = 1
		NumPut(0, &buffer, 13, "UChar")		; Reserved
		NumPut(0, &buffer, 14, "UChar")		; Reserved
		NumPut(0, &buffer, 15, "UChar")		; Reserved (Last (16th) byte of ISCP header)
		NumPut(33, &buffer, 16, "UChar")	; "!" (First byte of ISCP data)
		NumPut(49, &buffer, 17, "UChar")	; "1" (Unit number, 1 = receiver)
		Loop % strlen(cmd)			; Send the command data and any parameter data
		{							; First 3 bytes = command, any other bytes = parameter
			NumPut(Asc(substr(cmd, A_Index, 1)), &buffer, 17 + A_Index, "UChar")
		}
		NumPut(10, &buffer, 18 + strlen(cmd), "UChar")	; End byte = newline (last byte)
		try
			this.Send(&buffer, size)
		catch e
		{
			MsgBox 0x40010, AutoHotKey ISCP error, % "Could not send command to the AVR :(`nThe script will attempt to reconnect."
			global ISCPserver
			this.Disconnect()
			this.Connect(ISCPserver)
			return
		}
	}
}
