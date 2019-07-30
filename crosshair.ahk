#Persistent
#Include Gdip_All.ahk

If !pToken := Gdip_Startup(){
	MsgBox, No Gdiplus 
	ExitApp
}


FileSettings := A_ScriptDir . "\crosshair.ini"
if (!FileExist(FileSettings)){
	file := FileOpen(FileSettings, "w")
	file.Write("[Main]`r`nd=7`r`nR=0`r`nG=200`r`nB=255")
	file.close
}

IniRead, d, %FileSettings%, Main, d
IniRead, r, %FileSettings%, Main, R
IniRead, g, %FileSettings%, Main, G
IniRead, b, %FileSettings%, Main, B


GoSub, drawReticle
ReticleDrawn := 1


Loop
{
	if (WinActive("ahk_class UnrealWindow"))
	{
		if(!ReticleDrawn)
		{
			GoSub, drawReticle
			ReticleDrawn := 1
		}
	}
	else
	{
		Gui, 1:Destroy
		ReticleDrawn := 0
	}
}
Return

~d & UP::
	if d<A_ScreenHeight
	{
		d := d+1
		GoSub, drawReticle
	}
return

~d & Down::
	if d>=4
	{
		d := d-1
		GoSub, drawReticle
	}
return

~r & UP::
	if r<255
	{
		r := r+1
		GoSub, drawReticle
	}
return

~r & Down::
	if r>0
	{
		r := r-1
		GoSub, drawReticle
	}
return

~g & UP::
	if g<255
	{
		g := g+1
		GoSub, drawReticle
	}
return

~g & Down::
	if g>0
	{
		g := g-1
		GoSub, drawReticle
	}
return

~b & UP::
	if b<255
	{
		b := b+1
		GoSub, drawReticle
	}
return

~b & Down::
	if b>0
	{
		b := b-1
		GoSub, drawReticle
	}
return

drawReticle:

	HexR := substr(FHex(r, 2),3)
	HexG:= substr(FHex(g, 2),3)
	HexB := substr(FHex(b, 2),3)
	
	IniWrite, %d%, %FileSettings%, Main, d
	IniWrite, %r%, %FileSettings%, Main, R
	IniWrite, %g%, %FileSettings%, Main, G
	IniWrite, %b%, %FileSettings%, Main, B
	
	
	Color := HexR HexG HexB
	
	Gui, 1:Destroy
	Gui, 1:+LastFound -Caption +AlwaysOnTop +ToolWindow +E0x20
	Gui, 1:Color, EEAA99
	WinSet, TransColor, EEAA99


	Gui, Add, Picture, x0 y0 w%d% h%d% vXhair BackgroundTrans 0xE,

	GuiControlGet, hwnd, hwnd, Xhair

	d2:=d+d/10
	pBitmap := Gdip_CreateBitmap(d2, d2)
	Graphics := Gdip_GraphicsFromImage(pBitmap)

	Gdip_SetSmoothingMode(Graphics, 3)
	Gdip_SetInterpolationMode(Graphics, 7)



	Brush := Gdip_BrushCreateSolid("0xFF" Color)
	Gdip_FillEllipse(Graphics, Brush, 0, 0, d, d)

	;;pPen := Gdip_CreatePen("0xFF" Color2, 2)
	;;Gdip_DrawEllipse(Graphics, pPen, 0, 0, d, d)



	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	Gui, 1:Show, w%d2% h%d2% NA
return



FHex( int, pad=0 ) { ; Function by [VxE]. Formats an integer (decimals are truncated) as hex.

; "Pad" may be the minimum number of digits that should appear on the right of the "0x".

	Static hx := "0123456789ABCDEF"

	If !( 0 <= int |= 0 )

		Return !int ? "0x0" : "-" FHex( -int, pad )

	s := 1 + Floor( Ln( int ) / Ln( 16 ) )

	h := SubStr( "0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18 )

	u := A_IsUnicode = 1

	Loop % s

		NumPut( *( &hx + ( ( int & 15 ) << u ) ), h, pad - A_Index << u, "UChar" ), int >>= 4

	Return h

}
