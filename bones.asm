.686
.model	flat, stdcall
option	casemap :none

USE_BMP = 1

include	resID.inc
include BoxProc.asm
include algo.asm
include aboutbox.asm

AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
ENDM

.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	invoke	InitCommonControls
	invoke LoadBitmap,hInstance,400
	mov hIMG,eax
	invoke CreatePatternBrush,eax
	mov hBrush,eax
	AllowSingleInstance addr WindowTitle
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset DlgProc, 0
	invoke	ExitProcess, eax

DlgProc proc hDlg:HWND,uMessg:UINT,wParams:WPARAM,lParam:LPARAM
LOCAL X:DWORD
LOCAL Y:DWORD
LOCAL ps:PAINTSTRUCT

	.if [uMessg] == WM_INITDIALOG
 
 		push hDlg
 		pop xWnd
		mov eax, 448
		mov nHeight, eax
		mov eax, 222
		mov nWidth, eax                
		invoke GetSystemMetrics,0                
		sub eax, nHeight
		shr eax, 1
		mov [X], eax
		invoke GetSystemMetrics,1               
		sub eax, nWidth
		shr eax, 1
		mov [Y], eax
		invoke SetWindowPos,xWnd,0,X,Y,nHeight,nWidth,40h
            	
		invoke	LoadIcon,hInstance,200
		invoke	SendMessage, xWnd, WM_SETICON, 1, eax
		invoke  SetWindowText,xWnd,addr WindowTitle
		
		invoke  V2M_V15_Init,FUNC(GetForegroundWindow),offset theTune,1000,44100,1 ; v2m initialization with current window
		invoke  V2M_V15_Play,0
		
		invoke  SkrBoxInit,xWnd
		invoke  GetUserName,offset Userbuff,offset usrsize
		invoke  SetDlgItemText,xWnd,IDC_NAME,offset Userbuff
		invoke 	SendDlgItemMessage, xWnd, IDC_NAME, EM_SETLIMITTEXT, 31, 0
		invoke CreateFontIndirect,addr TxtFont
		mov hFont,eax
		invoke GetDlgItem,xWnd,IDC_NAME
		mov hName,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,xWnd,IDC_SERIAL
		mov hSerial,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		
		invoke ImageButton,xWnd,23,182,600,602,601,IDB_ABOUT
		mov hAbout,eax
		invoke ImageButton,xWnd,230,182,700,702,701,IDB_EXIT
		mov hExit,eax
		
		invoke GenKey,xWnd
	.elseif [uMessg] == WM_LBUTTONDOWN

		invoke SendMessage, xWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0

	.elseif [uMessg] == WM_CTLCOLORDLG

		return hBrush

	.elseif [uMessg] == WM_PAINT
                
		invoke BeginPaint,xWnd,addr ps
		mov edi,eax
		lea ebx,r3kt
		assume ebx:ptr RECT
                
		invoke GetClientRect,xWnd,ebx
		invoke CreateSolidBrush,00FF7800h
		invoke FrameRect,edi,ebx,eax
		invoke EndPaint,xWnd,addr ps                   
     
    .elseif [uMessg] == WM_CTLCOLOREDIT
    
		invoke SetBkMode,wParams,TRANSPARENT
		invoke SetTextColor,wParams,White
		invoke GetWindowRect,xWnd,addr WndRect
		invoke GetDlgItem,xWnd,IDC_NAME
		invoke GetWindowRect,eax,addr NameRect
		mov edi,WndRect.left
		mov esi,NameRect.left
		sub edi,esi
		mov ebx,WndRect.top
		mov edx,NameRect.top
		sub ebx,edx
		invoke SetBrushOrgEx,wParams,edi,ebx,0
		mov eax,hBrush
		ret        
	
	.elseif [uMessg] == WM_CTLCOLORSTATIC
	
		invoke SetBkMode,wParams,TRANSPARENT
		invoke SetTextColor,wParams,White
		invoke GetWindowRect,xWnd,addr XndRect
		invoke GetDlgItem,xWnd,IDC_SERIAL
		invoke GetWindowRect,eax,addr SerialRect
		mov edi,XndRect.left
		mov esi,SerialRect.left
		sub edi,esi
		mov ebx,XndRect.top
		mov edx,SerialRect.top
		sub ebx,edx
		invoke SetBrushOrgEx,wParams,edi,ebx,0
		mov eax,hBrush
		ret
	.elseif [uMessg] == WM_COMMAND
        
		mov eax,wParams
		mov edx,eax
		shr edx,16
		and eax,0ffffh
		.if edx == EN_CHANGE
			.if eax == IDC_NAME
				invoke GenKey,xWnd
			.endif
		.endif
		.if eax == IDB_ABOUT
	    	invoke SuspendThread,BoxThread
	    	invoke ShowWindow,xWnd,0
	    	invoke DialogBoxParam,0,IDD_ABOUT,0,offset AboutProc,0
		.elseif eax == IDB_EXIT
			invoke SendMessage,xWnd,WM_CLOSE,0,0
		.endif 
             
	.elseif [uMessg] == WM_CLOSE
		invoke V2M_V15_Stop,0
		invoke V2M_V15_Close
		call CleanEf
		invoke EndDialog,xWnd,0     
	.endif
         xor eax,eax
         ret
DlgProc endp

end start