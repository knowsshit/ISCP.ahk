#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
#Include <socket>
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*

Function for controlling ISCP AVRs like Onkyo

GitHub: https://github.com/knowsshit/ISCP.ahk

Socket.ahk is required: https://github.com/G33kDude/Socket.ahk
Put both files in Documents\AutoHotKey\Lib and
use #Include <ISCP> in your AHK file for easy access!

Special thanks to:

    G33kDude for his work on Socket.ahk
    /u/anonymous1184 on Reddit for helping me get started.
	I have never touched AHK before this weekend! :)

Example key bindings:

; Adjust master volume on receiver with Ctrl+Volume,
; and bass with Ctrl+Shift+Volume
^Volume_Up::ISCP("MVLUP")       ; Master vol up
^Volume_Down::ISCP("MVLDOWN")   ; Master vol down
^+Volume_Up::ISCP("TFRBUP")     ; Bass up
^+Volume_Down::ISCP("TFRBDOWN") ; Bass down
^Volume_Mute::ISCP("AMTTG")     ; Mute toggle

Remember to change the IP address below to get started!

*/

ISCP(cmd){
  Server := ["10.0.0.71", 60128]	; *** Change to IP address of your AVR! ***
  Client := new ISCP() 
  return Client.Connect(Server, cmd)
}

class ISCP extends SocketTCP
{
	static Blcoking := False
	static Buffer
	
	Connect(Address, cmd)
	{
		try
			Socket.Connect.Call(this, Address)
		catch e
			tooltip % "ISCP: Error connecting to AVR :(`n" e.What " failed at line" e.Line
		size := VarSetCapacity(buffer, 16, 0)
		StrPut("ISCP", &buffer, 4, "cp0")		; Packet header = ISCP
		NumPut(0, &buffer, 4, "UChar")
		NumPut(0, &buffer, 5, "UChar")
		NumPut(0, &buffer, 6, "UChar")
		NumPut(0x10, &buffer, 7, "UChar")
		NumPut(0, &buffer, 8, "UChar")
		NumPut(0, &buffer, 9, "UChar")
		NumPut(0, &buffer, 10, "UChar")			; First 11 bytes are static
		NumPut(strlen(cmd) + 3, &buffer, 11, "UChar") ; Size char (value of length of !1cmd`n)
		NumPut(1, &buffer, 12, "UChar")
		NumPut(0, &buffer, 13, "UChar")
		NumPut(0, &buffer, 14, "UChar")
		NumPut(0, &buffer, 15, "UChar")
		this.Send(&buffer, size)	; Send first 16 bytes
		size := VarSetCapacity(buffer, strlen(cmd) + 3, 0)
		StrPut("!1" cmd "`n", &buffer, strlen(cmd) + 3, "cp0")	
		this.Send(&buffer, size)	; Send !1 + command + newline
		this.Disconnect()
	}
}
