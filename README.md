# ISCP.ahk
AutoHotKey function for controlling AVRs like Onkyo over the network using the eISCP protocol

GitHub: https://github.com/knowsshit/ISCP.ahk

Changelog:
 * v1.2 - Lots of quality of life improvements
 * * Persistent TCP connection
 * * Rapid commands like holding down a button or using a volume wheel/scrollwheel for adjusting volume are now super smooth!
 * * Implemented ISCPinit("ip.to.AV.receiver") command so you don't need to edit ISCP.ahk
 * * Automatic connection retry on Send failure
 * * Added timeout (default 3 minutes) to automatically disconnect and reconnect as needed. Will prevent failures of a stale connection.
 * * Rewritten the way the network packet is buildt.
 * * Tried to implement reading responses from the AVR, but Socket.ahk kept throwing warnings and no data was read. Anyone else care to give it a try?
 * * Using #Include should not be needed anymore

 * v1.0 - Initial release

Socket.ahk is required: https://github.com/G33kDude/Socket.ahk
Put that and this file in Documents\AutoHotKey\Lib

Special thanks to:

  *  G33kDude for his work on Socket.ahk
  *  /u/anonymous1184 on Reddit for helping me get started.

Example init line and set of key bindings to put in your .ahk script follows below:

```
ISCP_init("192.168.0.20")		; Change to the IP of your AVR!

; Adjust master volume on receiver with Ctrl+Volume,
; and bass with Ctrl+Shift+Volume
^Volume_Up::ISCP("MVLUP")		; Master vol up
^Volume_Down::ISCP("MVLDOWN")	; Master vol down
^+Volume_Up::ISCP("TFRBUP")		; Bass up
^+Volume_Down::ISCP("TFRBDOWN")	; Bass down
^Volume_Mute::ISCP("AMTTG")		; Mute toggle

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
#^+NumpadSub::ISCP("AVSDOWN") ; A/V sync-

; OSD keys:
#^+m::ISCP("OSDMENU")		; Open on-screen menu
#^+Up::ISCP("OSDUP")		; OSD up
#^+Down::ISCP("OSDDOWN")	; OSD down
#^+Left::ISCP("OSDLEFT")	; OSD left
#^+Right::ISCP("OSDRIGHT")	; OSD right
#^+Enter::ISCP("OSDENTER")	; OSD enter/select
#^+Del::ISCP("OSDEXIT")		; OSD back/exit
#^+q::ISCP("OSDQUICK")		; OSD quick menu

; Retrieving info is not implemented here yet (Socket.ahk fails to receive data from the AVR)
; but you can connect to tcp port 60128 of your AVR and see the info there using putty/netcat/telnet
#^+a::ISCP("IFAQSTN") ; Get info about the audio signal
#^+v::ISCP("IFVQSTN") ; Get info about the video signal

; Find more commands by searching online!
; https://github.com/mkulesh/onpc/tree/master/doc got some extensive lists

; End of example set. Copy any lines above to your .ahk script.

; Please note that different receivers accepts different set of commands.
; The commands above are from my script for the AVR Onkyo TX-RZ800.

```
