# ISCP.ahk
AutoHotKey function for controlling Onkyo AVR over network using the ISCP protocol

Requires Socket.ahk: https://github.com/G33kDude/Socket.ahk
Put both files in Documents\AutoHotKey\Lib and use ```#Include <ISCP>``` in your AHK file for easy access.

Special thanks to:
* G33kDude for his work on Socket.ahk
* /u/anonymous1184 on Reddit for helping me get started.

I have never touched AHK before this weekend! :)

Remember to change the IP address in the beginning of the script to get started!

Features to come/personal wishlist (feel free to contact me if you want to help out!)
* Option to show OSD on PC screen with new volume level or feedback from functions
* A GUI Remote control with buttons for easy control of functions and a
display to show volume, current input and other functions of the AVR.

Example key bindings:

```
; Adjust master volume on receiver with Ctrl+Volume,
; and bass with Ctrl+Shift+Volume
^Volume_Up::ISCP("MVLUP")       ; Master vol up
^Volume_Down::ISCP("MVLDOWN")   ; Master vol down
^+Volume_Up::ISCP("TFRBUP")     ; Bass up
^+Volume_Down::ISCP("TFRBDOWN") ; Bass down
^Volume_Mute::ISCP("AMTTG")     ; Mute toggle

; Win+Ctrl+Shift for other hotkeys to avoid conflicts/accidents

; Change receiver inputs and other functions
#^+1::ISCP("SLI01")  ; CBL/SAT
#^+2::ISCP("SLI02")  ; GAME 1
#^+3::ISCP("SLI03")  ; AUX (Front HDMI)
#^+4::ISCP("SLI04")  ; GAME 2
#^+5::ISCP("SLI05")  ; PC
#^+d::ISCP("DIMDIM") ; Display Dimmer
#^+o::ISCP("MOTUP")  ; Music Optimizer/Sound Retriever
#^+p::ISCP("PWR01")  ; Power on
#^+NumpadAdd::ISCP("AVSUP")	; A/V sync+
#^+NumpadSub::ISCP("AVSDOWN") ; A/V sync-

; OSD keys:
#^+m::ISCP("OSDMENU")
#^+Up::ISCP("OSDUP")
#^+Down::ISCP("OSDDOWN")
#^+Left::ISCP("OSDRIGHT")
#^+Right::ISCP("OSDLEFT")
#^+Enter::ISCP("OSDENTER")
#^+ESC::ISCP("OSDEXIT")
#^+q::ISCP("OSDQUICK")

; Find more commands by searching online!
; https://github.com/mkulesh/onpc/tree/master/doc got some extensive lists

```
