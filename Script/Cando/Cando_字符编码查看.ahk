Cando_字符编码查看:
	Gui,66:Default
	Gui,Destroy
	;CandySel:="开一二不"  
	; 后、沈、里、 杰 等汉字简繁转换不会成功 後、瀋、裏、傑

	Gosub,Encode
	Gui, add, text,x5 y5,简体汉字:
	Gui,add,Edit,x120 y5 w300 h20 vCcharacter,%CandySel%
	Gui,add,button,x420 y5 w50 h20 default gviewcode,查看

	Gui, add, text,x5 y35 ,系统默认编码(CP0):
	Gui,add,Edit,x120  y35 w300 h20 vcp0,% Trim(cp0)
	Gui,add,button,x480 y35 w60 h20 gclearedit,清空列表

	Gui, add, text,x5 y+10 ,GBK(CP936):
	Gui,add,Edit,x120 y65 w300 h20 vcp936,% Trim(cp936)
	Gui,add,button,x420 y65 w50 h20 vcp936tochinese gTochinese,转中文
	Gui,add,button,x480 y65 w20 h20 vcp936todec gToDec,十
	Gui,add,button,x510 y65 w30 h20 vcp936tohex gToHex,十六

	Gui, add, text,x5 y+10 ,GBK(CP950):
	Gui,add,Edit,x120 y95 w300 h20 vcp950,% Trim(cp950)
	Gui,add,button,x420 y95 w50 h20 vcp950tochinese gTochinese,转中文

	Gui, add, text,x5 y+10 ,UTF-8(CP65001):
	Gui,add,Edit,x120 y125 w300 h20 vcp65001,% Trim(cp65001)
	Gui,add,button,x420 y125 w50 h20 vcp65001tochinese gTochinese,转中文

	Gui, add, text,x5 y+10 ,UTF-16(CP1200):
	Gui,add,Edit,x120 y155 w300 h20 vcp1200,% Trim(cp1200)
	Gui,add,button,x420 y155 w50 h20 vcp1200tochinese gTochinese,转中文

	Gui, add, text,x5 y+10 ,UTF-16(CP1201):
	Gui,add,Edit,x120 y185 w300 h20 vcp1201,% Trim(cp1201)
	Gui,add,button,x420 y185 w50 h20 vcp1201tochinese gTochinese,转中文
	Gui,add,button,x480 y185 w20 h20 vcp1201toDec gToDec,十
	Gui,add,button,x510 y185 w30 h20 vcp1201toHex gToHex,十六

	Gui, add, text,x5 y+10 ,繁体汉字:
	Gui,add,Edit,x120 y215 w300 h20 vtrc,% trc
	Gui,add,button,x420 y215 w50 h20 vtrctochinese gTochinese,转简体

	Gui,show,,中文字符编码查看
	SetFormat, integer, D
Return

viewcode:
	Gui, Submit, NoHide
	if((Ccharacter=CandySel) && ((trc !="") && (cp0 !="")))
		Return
	Else
	{
		CandySel:=Ccharacter
		Gosub,Encode
		GuiControl, , cp0, % Trim(cp0)
		GuiControl, , cp936, % Trim(cp936)
		GuiControl, , cp950, % Trim(cp950)
		GuiControl, , cp65001, % Trim(cp65001)
		GuiControl, , cp1200, % Trim(cp1200)
		GuiControl, , cp1201, % Trim(cp1201)
		GuiControl, , trc, % trc
	}
Return

Encode:
	If(CandySel="")
		Return
	SetFormat, integer, H
	cp0:=Encode(CandySel, "cp0")
	cp936:=Encode(CandySel, "cp936")
	cp950:=Encode(CandySel, "cp950")
	cp65001:=Encode(CandySel, "cp65001")
	cp1200:=Encode(CandySel, "cp1200")

	If A_IsUnicode
		LE:=CandySel
	Else
		Ansi2Unicode(LE,CandySel,936)
	LCMAP_BYTEREV := 0x800
	cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,LE, UInt,-1, Str,0, UInt,0)
	VarSetCapacity(BE, cch * 2)
	DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,LE, UInt,cch, Str,BE, UInt,cch)

	cp1201:=Encode(BE, "cp1201")

	if(strlen(cp1200) !=strlen(cp1201))
	{
		toHex(BE,o)
		cp1201:=SubStr(o,1,cch * 4 - 4)
	}

	VarSetCapacity(trc1, 2*cch:=VarSetCapacity(LE)//2), LCMAP_TRADITIONAL_CHINESE := 0x4000000
	DllCall( "LCMapStringW", UInt,0x400, UInt,LCMAP_TRADITIONAL_CHINESE, Str,LE, UInt,cch, Str,trc1, UInt,cch )

	If A_IsUnicode
		trc :=trc1
	else
		Unicode2Ansi(trc1, trc,936)
Return

Tochinese:
	Gui, Submit, NoHide
	WButton:=StrReplace(A_GuiControl , "tochinese", "")
	code:=%WButton%
	If(code="")
		Return
	Gosub,clearedit
	GuiControl, , %WButton%, % %WButton%
	If(WButton = "trc")
	{
		If !A_IsUnicode
			Ansi2Unicode(tmp1, trc, 936)
		Else
			tmp1:=trc

		VarSetCapacity(tmp2, 2*cch:=VarSetCapacity(tmp1)//2), LCMAP_SIMPLIFIED_CHINESE:=0x02000000 
		DllCall( "LCMapStringW", UInt,0x400, UInt,LCMAP_SIMPLIFIED_CHINESE, Str,tmp1, UInt,cch, Str,tmp2, UInt,cch )

		If !A_IsUnicode
			Unicode2Ansi(tmp2, spc, 936)
		Else
			spc := tmp2
		GuiControl, , Ccharacter, % spc
	}
	Else
	{
		code:=codeclear(code)
		MCode(varchinese, code)
		If(WButton ="cp1201")
		{
			LCMAP_BYTEREV := 0x800
			cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,varchinese, UInt,-1, Str,0, UInt,0)
			VarSetCapacity(LE, cch * 2)
			DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,varchinese, UInt,cch, Str,LE, UInt,cch)
			If !A_IsUnicode
				Unicode2Ansi(LE, spc, 936)
			Else
				spc:=LE
			GuiControl, , Ccharacter, % spc
		}
		Else
			GuiControl, , Ccharacter, % StrGet(&varchinese,WButton)
	}
Return

ToDec:
	Gui, Submit, NoHide
	WButton:=StrReplace(A_GuiControl , "todec", "")
	code:=%WButton%
	GuiControl, , %WButton%
 If(code="")
		Return
	code := StrReplace(code, "\u", " ")
	Loop, Parse, code, %A_Space%
	{
  tmphex:="0x" A_LoopField
  c2dec .=" " hex2dec(tmphex)
}
GuiControl, , %WButton%, % Trim(c2dec)
c2dec=
Return

ToHex:
	Gui, Submit, NoHide
	WButton:=StrReplace(A_GuiControl , "tohex", "")
	code:=%WButton%
 If(code="")
		Return
	If code contains a,b,c,d,e,f
		Return
	GuiControl, , %WButton%

	code := StrReplace(code, "&#", "")
	code := StrReplace(code, ";", " ")
	Loop, Parse, code, %A_Space%
	c2hex .=" " dec2hex(A_LoopField)
	c2hex:=StrReplace(c2hex, "0x", "")

	GuiControl, , %WButton%, % Trim(c2hex)
	c2hex=
Return

clearedit:
	GuiControl, , Ccharacter
	GuiControl, , cp0
	GuiControl, , cp936
	GuiControl, , cp950
	GuiControl, , cp65001
	GuiControl, , cp1200
	GuiControl, , cp1201
	GuiControl, , trc
Return

codeClear(code)
{
	code := StrReplace(code, " ", "")
	code := StrReplace(code, "\u", "")
	code := StrReplace(code, "&#x", "")
	code := StrReplace(code, "%", "")
	code := StrReplace(code, ";", "")
Return code	
}

MCode(ByRef code, hex) 
{ ; allocate memory and write Machine Code there
	VarSetCapacity(code, 0) 
	VarSetCapacity(code,StrLen(hex)//2+2)
	Loop % StrLen(hex)//2 + 2
		NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "Char")
}

; 老版autohotkey使用的 "StrGet" 留做备份
; get data starting from pointer up to 0 char
ExtractData(pointer)
{
	Loop
	{ 
		errorLevel := ( pointer+(A_Index-1) )
		Asc := *( errorLevel ) 
		IfEqual, Asc, 0, Break ; Break if NULL Character 
		String := String . Chr(Asc)
	} 
Return String 
}

; Encode简化版留做备用
; 可参考链接：https://zhuanlan.zhihu.com/p/19712731
Encode2(Str, Encoding, Separator := " ")
{
	StrCap := StrPut(Str, Encoding)
	VarSetCapacity(ObjStr, StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))
	StrPut(Str, &ObjStr, Encoding)
	Loop, % StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
		ObjCodes .= Separator . NumGet(ObjStr, A_Index - 1, "UChar")
Return, ObjCodes
}

Encode(Str, Encoding, Separator := " ")
{
	If (Encoding="cp1201")
	{
		tmpe:=1
		encoding:=A_IsUnicode ? "cp1200" : "cp0"
	}
	StrCap := StrPut(Str, Encoding)
	StrCap:=StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
	VarSetCapacity(ObjStr, StrCap)
	StrPut(Str, &ObjStr, Encoding)
	Loop, % StrCap - ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
	; StrPut 返回的长度中包含末尾的字符串截止符 00 ,因此必须减 1。
	{
		If(encoding="cp950")
			ObjCodes .= SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
		Else If(encoding="utf-16"||encoding="cp1200"||tmpe=1)
		{
			if((h:=NumGet(ObjStr, A_Index - 1, "UChar"))=0x0)
				HH:="00"
			else if (h<0x10) and (h!=0x0)
				HH:="0" SubStr(h, 3)
			else
				HH:=SubStr(h, 3)

			If(Mod(A_Index , 2) = 0x1  )
				ObjCodes .= Separator . HH
			Else
				ObjCodes .= HH
		}
		Else
		{
			HH:=SubStr(h:=NumGet(ObjStr, A_Index - 1, "UChar"), 3)
			If(h<0x7F)
			{
				ObjCodes .=Separator . HH
				tmpswitch=1
			}
			else
			{
				if(tmpswitch=1) or (tmpswitch="")or (tmpswitch=0)
				{
					ObjCodes .= Separator . HH
					tmpweizhi:=A_Index 
					tmpswitch=2
				}
				else
				{
					ObjCodes .= HH
					If(encoding="utf-8"||encoding="cp65001")
					{
						if(A_Index=tmpweizhi+2)
							tmpswitch=0
					}
					else
						tmpswitch=0
				}
			}
		}
	}
Return, ObjCodes
}

toHex( ByRef V, ByRef H, dataSz:=0 )
{ ; http://goo.gl/b2Az0W (by SKAN)
	P := ( &V-1 ), VarSetCapacity( H,(dataSz*2) ), Hex := "123456789ABCDEF0"
	Loop, % dataSz ? dataSz : VarSetCapacity( V )
		H  .=  SubStr(Hex, (*++P >> 4), 1) . SubStr(Hex, (*P & 15), 1)
}

hex2dec(h)
{
	oldfrmt := A_FormatInteger
	SetFormat, integer, dec
	d :=h+0
	SetFormat, IntegerFast, %oldfrmt% 
return d
} 

dec2hex(d)
{
	oldfrmt := A_FormatInteger
	SetFormat, integer, H
	h :=d+0
	SetFormat, IntegerFast, %oldfrmt%
return h
}

; 独立运行(调测时)需加上
#Include *i %A_ScriptDir%\..\..\Lib\string.ahk