
include biglib.inc
includelib biglib.lib

include base64.asm

GenKey		PROTO	:DWORD
CheckName	PROTO	:DWORD,:DWORD,:DWORD

.data
; this time it's RSA-370 now, since it's the latest (but also an old) version of Download Express. :P
ExpN 		db "2AE23A62A605CAB8A6A8E063112DECF900B91B531BEBEC66B57A8A3C78BDA57BE2D3E14B6BFFBBF8C46188FD02D57",0
ExpD 		db "20E3260B896F5FAC848376B202F6C9899CB858F03FB58A89A3E5DA679C6D8C8091E2AD95D16F6EC1C6EA218DB2F61",0
AppLabel	db "DE14",0
OneByte		db 01h,0
LicType		db "10000",0
StartKey	db "dqma",0
EndKey		db "amqd",0
NoName		db "insert ur name.",0
TooLong		db "name too long.",0
Blacklisted db "CANNOT GENERATE SERiAL :: NAME BLACKLiSTED",0
FinalBuffer db 256 dup(0)
NameBuffer	db 256 dup(0)
BlklistBuffer db 64 dup(0)

; a bunch of blacklisted names detected in dep.exe through IDA Pro:

blk1		db "LAM CHI WAI SAMUEL",0
blk2		db "doreen shepherd",0
blk3		db "Bruce L. Karr",0
blk4		db "kolar jerry",0
blk5		db "Craig Alston",0
blk6		db "Lisa Toth",0
blk7		db "Gregg Markus",0
blk8		db "Roy Newman-Smith",0
blk9		db "Colin Hillis",0
blk10		db "RENAULT SERVICE",0
blk11		db "Ruscio Steven",0
blk12		db "Peter Bird",0
blk13		db "hamed mohamed",0
blk14		db "jonathan marquez",0
blk15		db "Alessandro Piras",0
blk16		db "Susan G Miller",0
blk17		db "srab",0
blk18		db "M@nster Art's",0
blk19		db "Richard Rosen",0
blk20		db "tony khalife",0
blk21		db "michael axlin",0
blk22		db "eoin carey",0
blk23		db "houette xavier",0
blk24		db "Lee Frakes",0
blk25		db "Charles McArthur",0
blk26		db "Ursala Knudsen-Latta",0
blk27		db "J,C.P.M Taalman",0
blk28		db "Vo Quang Le",0
blk29		db "freeserials.com",0
blk30		db "1024byte",0

.data?
_N			dd ?
_D			dd ?
_C		    dd ?
_M  		dd ?
RSAEnk		db 256 dup(?)
Base64Bfr	db 256 dup(?)

.code
GenKey proc hWin:DWORD

	; get the whole name string.
	invoke GetDlgItemText,hWin,IDC_NAME,addr NameBuffer, sizeof NameBuffer
	or eax,eax
	jz no_name
	cmp eax,30
	jg name_too_long
	
	; initialize name check for the blacklisted names..
	; (if any of the names above entered above = shows the "Blacklisted" message instead of generating)
	invoke lstrcpy,offset BlklistBuffer,offset NameBuffer
	invoke CheckName,offset BlklistBuffer,offset blk1,980
	test eax,eax
	jz name_blacklisted
	
	; initialize the string for RSA-370 decryption
	mov byte ptr [RSAEnk],7
	invoke lstrcat,offset RSAEnk,offset AppLabel	; DE14
	invoke lstrcat,offset RSAEnk,offset OneByte		; 01h
	invoke lstrcat,offset RSAEnk,offset NameBuffer	; ur name
	invoke lstrcat,offset RSAEnk,offset OneByte		; 01h
	invoke lstrcat,offset RSAEnk,offset LicType		; 10000 (Unlimited site license)
	
	; initialize biglib for modulus and the private key exponent, and for the plaintext and chipertext.
	invoke _BigCreate,0
	mov _N,eax
	invoke _BigCreate,0
	mov _D,eax
	invoke _BigCreate,0
	mov _C,eax
	invoke _BigCreate,0
	mov _M,eax
	
	; set exponents with _BigIn and calculate the length of the RSAEnk variable
	invoke _BigIn,offset ExpN,16,_N
	invoke _BigIn,offset ExpD,16,_D
	invoke lstrlen,offset RSAEnk
	
	; set the bytes for the padded plaintext
	invoke _BigInBytes,offset RSAEnk,eax,256,_M
	
	; _C = _M^_D mod _N
	invoke _BigPowMod,_M,_D,_N,_C
	
	;set RSA-370 bytes for the RSA buffer
	invoke _BigOutBytes,_C,256,offset RSAEnk
	
	; encode them with base64
	push offset Base64Bfr
	push eax
	push offset RSAEnk
	call Base64Enk
	
	; "dqma" + final string made of RSA-370 & Base64 + "amqd"
	invoke lstrcat,offset FinalBuffer,offset StartKey
	invoke lstrcat,offset FinalBuffer,offset Base64Bfr
	invoke lstrcat,offset FinalBuffer,offset EndKey
	
	; final result in the textbox :p
	invoke SetDlgItemText,hWin,IDC_SERIAL,offset FinalBuffer
	
	; clear RSA buffers.
	call Clean
	ret
	
no_name:
	invoke SetDlgItemText,hWin,IDC_SERIAL,addr NoName
	ret
	
name_too_long:
	invoke SetDlgItemText,hWin,IDC_SERIAL,addr TooLong
	ret
	
name_blacklisted:
	invoke SetDlgItemText,hWin,IDC_SERIAL,addr Blacklisted
	ret	
	
GenKey endp

Clean proc

	invoke RtlZeroMemory,offset FinalBuffer,sizeof FinalBuffer
	invoke RtlZeroMemory,offset RSAEnk,sizeof RSAEnk
	invoke RtlZeroMemory,offset Base64Bfr,sizeof Base64Bfr
	invoke RtlZeroMemory,offset NameBuffer,sizeof NameBuffer
	invoke _BigDestroy,_N
	invoke _BigDestroy,_D
	invoke _BigDestroy,_C
	invoke _BigDestroy,_M
	ret
	
Clean endp

; had a brief look over PHPMaker.v5.0.0.0.Incl.Keymaker-CORE through IDA to see how
; this name-checking procedure is coded and i've recoded it now.

CheckName proc str_1:LPCSTR,str_2:LPCSTR,bfrSize:DWORD

	push esi
	push edi
	push ebx
	mov edi, [str_1]
	mov esi, [str_2]
	mov ebx, [bfrSize]
	add ebx, esi

name_verif: 			
	invoke lstrcmp,edi,esi
	test eax, eax
	jz final
	invoke lstrlen,esi
	inc eax
	add esi, eax
	cmp esi, ebx
	jl name_verif

final:
	pop ebx
	pop edi
	pop esi
	ret
	
CheckName endp