include		windows.inc 
include		kernel32.inc 
include		user32.inc 
include     gdi32.inc  
include 	shell32.inc
include		winmm.inc
include		masm32.inc
include		msvcrt.inc
include		comctl32.inc
include		oleaut32.inc
include		ole32.inc
include		advapi32.inc
include		comdlg32.inc
include		msimg32.inc
include     /masm32/macros/macros.asm

includelib	kernel32.lib
includelib	user32.lib 
includelib 	gdi32.lib
includelib 	shell32.lib
includelib	winmm.lib
includelib 	masm32.lib
includelib	msvcrt.lib
includelib	comctl32.lib
includelib  oleaut32.lib
includelib  ole32.lib
includelib	advapi32.lib
includelib	comdlg32.lib
includelib 	msimg32.lib

include btnt.inc

include V2M_V15.inc
includelib V2M_V15.lib

externdef c theTune:byte 

DlgProc			PROTO	:DWORD,:DWORD,:DWORD,:DWORD

.const
IDD_MAIN	equ	1000
IDD_ABOUT	equ	2000
IDB_EXIT	equ	1001
IDB_ABOUT	equ	1002
IDC_NAME	equ	1003
IDC_SERIAL	equ	1004

.data
WindowTitle	db	"-=: PRF oWNZ dA wORLD ! :=-",0
r3kt			RECT	<>
TxtFont		LOGFONT <0FFFFFFF5h,0,0,0,2BCh,0,0,0,1,0,0,0,0,'verdana'>
;<12,8,0,0,FW_DONTCARE,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,0,'terminal'>
DELAY_VALUE			equ		6
Transparency		dd		?
TRANSPARENT_VALUE	equ 254
usrsize		dd  100h
Userbuff	db	100h dup(0)

.data?
hInstance	dd	?
hFont			dd	?
hName			dd	?
hSerial			dd	?
hIMG			dd  ?
WndRect		RECT	<>
XndRect		RECT	<>
NameRect	RECT	<>
SerialRect	RECT	<>
hBrush		dd	?
nHeight		dd	?
nWidth		dd	?
xWnd		dd  ?