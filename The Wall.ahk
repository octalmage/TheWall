CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

SetWinDelay, 50
setbatchlines, -1
Gui,color,2B2D2A
Gui, -caption -toolwindow
Gui, +lastfound
Gui, font,s48 cA7BE89,  Lucida Console
Gui, add, text,x10 y-60 , The Wall
VarSetCapacity(sFile, 260)
DllCall("SystemParametersInfo", "Uint", 115, "Uint", 260, "str", sFile, "Uint", 0)
SetTimer, outtro, -500
OnExit, cleanup
;ui,add,picture,x0 y0 w%a_screenwidth% h%a_screenheight%, %sFile%
Gui, show, w%a_Screenwidth% x0  h8000 y0,party
HWND_Gui1:= WinExist()
winwait, party
send !{Esc}

DetectHiddenWindows, on

pic_y=0


WinHide, ahk_id %HWND_Gui1%
WinSet, ExStyle, ^0x80, ahk_id %HWND_Gui1%
WinShow,  ahk_id %HWND_Gui1%
;AlwaysAtBottom(HWND_Gui1)

OnMessage(0x201, "WM_LBUTTONDOWN")
Return


#o::



	
		GuiControl, movedraw, Static1 , y-60
		gosub outtro
return


WM_LBUTTONDOWN(wParam, lParam)
	{
		global winlist

		X := lParam & 0xFFFF
		Y := lParam >> 16

		If A_GuiControl
			Control := "`n(in Control " . A_GuiControl . ")"
		;ToolTip You left-clicked in Gui window #%A_Gui% at client coordinates %X%x%Y%.%Control%


		;ControlGet, thisctrl, HWND , , AutoHotkeyGUI1, Program Manager
		;ControlGetPos , , Gui_Y,  , , ,ahk_id %thisctrl%
		WinGetPos , thisx, Gui_Y, , , party
		;tooltip, %gui_y%
		start_y=%Gui_y%
		MouseGetPos, XPOS,YPOS
		Loop
		{
			If !GetKeyState("LButton","P")
			{
				Break
				msgbox break2
				}
			MouseGetPos, XPOS2, YPOS2
			Gui_Y += (YPOS2-YPOS)
			pic_y-= (YPOS2-YPOS)
			change:=YPOS2-YPOS

			If not Gui_Y>0
			{
				WinMove, party, , , %Gui_Y%
				;WinMove, ahk_id %thisctrl%,, , %Gui_Y%

			}
			Else
			{
				;mousemove, , %YPOS%, 0
				Gui_Y=0
			}
			WinGetPos , thisx, thisy, , , party
			;ControlGetPos , thisx, thisy,  , , ,ahk_id %thisctrl%
			pic_y:=abs(thisy)
			;GuiControl, move, Static1 , y%pic_y%
			YPOS := YPOS2
		}

		If change<1
			dir=down
		Else
			dir=up

		force:=abs(change)

		Loop
		{
			If GetKeyState("LButton")
			{
	
							sendinput, {lbutton up} {lbutton down}
							Exit
			}

				
				
			WinGetPos , thisx, thisy, , , party
			;ControlGetPos , thisx, thisy,  , , ,ahk_id %thisctrl%
			If dir=up
			{
				thisy:=thisy+force
				pic_y:=pic_y-force
			}
			Else
			{
				thisy:=thisy-force
				pic_y:=pic_y+force
			}
			If not thisy>0
			{
				WinMove,party,, , %thisy%
				;WinMove, ahk_id %thisctrl%,, , %thisy%

			}
			Else
			{
				thisy=0
			}
			WinGetPos , thisx, thisy, , , party
			;ControlGetPos , thisx, thisy,  , , ,ahk_id %thisctrl%
			pic_y:=abs(thisy)
			;GuiControl, move, Static1 , y%pic_y%
			force:=force/2


			If force<5
				Break
		sleep 50
		}
		WinGetPos , thisx, thisy, , , party
		;ControlGetPos , thisx, thisy,  , , ,ahk_id %thisctrl%
		pic_y:=abs(thisy)


		WinGet, ctrllist, ControlList, party
		Loop, Parse, ctrllist, `n
		{



			ControlGet, HWND_Gui2, Hwnd  , , %A_LoopField%, party
			ControlGetText, this_title ,  %A_LoopField%, party



			If not this_title
				Continue

			id:= Decimal_to_Hex( DllCall( "GetWindow", "uint", HWND_Gui2) ) ;

			WinGetTitle, Title, ahk_id %id%
		
			;if not title=party
			;continue


			ControlGetPos , cX, cY, xw, , %A_LoopField%, party

			PostMessage, 0xF, 0,,, ahk_id %HWND_Gui2%
			WinMove, ahk_id %thisctrl%,, %cX%, %cY%
		}
		PostMessage, 0xF, 0,,, party


		;GuiControl, movedraw, Static1 , y%pic_y%
		;GuiControl, move, Static1 , y%pic_y%
	}





Return


outtro:
critical
	ControlGetPos , tx, ty,, , Static1, party

	Loop 40
	{
		ty+=(40-A_index)/10
		GuiControl, move, Static1 , y%ty%
		Sleep 20
	}
	Sleep 2000


	Loop 10
	{
		ty+=(10-A_index)
		GuiControl, move, Static1 , y%ty%
		Sleep 30
	}

	Loop 40
	{
		ty-=A_index/2
		GuiControl, move, Static1 , y%ty%
		Sleep 20
	}
	
	
		
Return

Decimal_to_Hex(var)
	{
		SetFormat, integer, hex
		var += 0
		SetFormat, integer, d
		Return var
	}

#r::
	Reload
Return

!1::


	Gosub removeallwindows


Return

cleanup:



	Gosub removeallwindows

	ExitApp


removeallwindows:
	WinGet, ctrllist, ControlList, party
	Loop, Parse, ctrllist, `n
	{



		ControlGet, HWND_Gui2, Hwnd  , , %A_LoopField%, party
		If not HWND_Gui2
			Continue

		ControlGetPos , cx, cy, , , %A_LoopField%, party
		
		DllCall( "SetParent", "uint", HWND_Gui2, "uint", "" )
			winmove, ahk_id %HWND_Gui2%,, %cx%,%cy%
	}


Return

GetParentWindow(hwnd)
	{
		Return,DllCall("GetWindow","uint",hwnd,"uint",GW_OWNER:=4)
	}


GetParentTitle( baseHwnd, levels ) {

		hwnd1:=dllCall( "GetParent", UInt, baseHwnd )

		Loop % levels {
			cnt:=( a_index+1 )
			hwnd%cnt%:=dllCall( "GetParent", UInt, hwnd%a_index% )
			hwndAddress:=hwnd%a_index%
		}

		WinGetTitle, winT, % "ahk_id " hwndAddress
		Return % ( ( winT ) && ( cnt<>2 ) ? winT : "No parent title found`n"
		. ( cnt-=1 ) ( ( cnt<2 ) ? " level up!" : " levels up!" ) )

	}


f10::
	HWND_Gui2 := WinExist("A")
	WinGetTitle, title,ahk_id %HWND_Gui2%

	WinGetPos , , newy, , , ahk_id %HWND_Gui2%
	WinGetPos , thisx, thisy, , , party
	winlist=%winlist%|%title%
	DllCall( "SetParent", "uint", HWND_Gui2, "uint", HWND_Gui1)
	Gui_y:=abs(thisy)+newy
	ControlGet, thisctrl, HWND , , %title%, party

	WinMove, ahk_id %thisctrl%,, , %Gui_y%

Return


f9::
	HWND_Gui2 := WinExist("A")

	DllCall( "SetParent", "uint", HWND_Gui2, "uint", "" )
Return

f2::
	force=100

	Loop
	{

		WinGetPos , thisx, thisy, , , party
		thisy:=thisy-force
		WinMove,party,, , %thisy%
		If not GetKeyState("WheelUp")
			force:=force/2
		Else
			force=100

		Sleep 10
	}


Return

AlwaysAtBottom(Child_ID)
	{
		WinGet, Desktop_ID, ID, ahk_class Progman
		Return DllCall("SetParent", "uint", Child_ID, "uint", Desktop_ID)
	}

!WheelUp::


	WinGetPos , thisx, thisy, , , party
	thisy:=thisy-100
	WinMove,party,, , %thisy%
Return


!WheelDown::

	WinGetPos , thisx, thisy, , , party
	thisy:=thisy+100
	WinMove,party,, , %thisy%

Return