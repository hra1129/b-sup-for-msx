; ------------------------------------------------------------------------------
;	B-SUP (ビーサップ) VRAM 編集用命令
; ==============================================================================
;	History		author		Description
;	2021/02/19	t.hara		Prototype
; ------------------------------------------------------------------------------

; ==============================================================================
;	CALL VFIL( <target address>, <size>, <fill value> )
; ==============================================================================
		scope		call_vfil
call_vfil::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas

		ex			de, hl
		pop			bc
		pop			hl

		push		de
		call		bsup_filvrm
		pop			hl

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	FILVRM
;	input)
;		HL .... Target VRAM address
;		BC .... Size  (0～16383)
;		A ..... Fill data
;	output)
;		N/A
;	break)
;		AF, BC
; ==============================================================================
		scope		bsup_filvrm
bsup_filvrm::
		push		af
		ld			a, l
		di
		out			[0x99], a
		ld			a, h
		or			a, 0x40
		out			[0x99], a
		pop			af

loop:
		out			[0x98], a
		nop
		dec			c
		jr			nz, loop
		dec			b
		jp			p, loop
		ei
		ret
		endscope

; ==============================================================================
;	LDIRVM
;	input)
;		HL .... Source address (CPU RAM)
;		DE .... Destination address (VRAM)
;		BC .... Size (0～16383)
;	output)
;		N/A
;	break)
;		AF, BC, HL
; ==============================================================================
		scope		bsup_ldirvm
bsup_ldirvm::
		ex			de, hl
		ld			a, l
		di
		out			[0x99], a
		ld			a, h
		or			a, 0x40
		out			[0x99], a
		ex			de, hl

loop:
		ld			a, [hl]
		inc			hl
		out			[0x98], a
		dec			c
		jr			nz, loop
		dec			b
		jp			p, loop
		ei
		ret
		endscope

; ==============================================================================
;	SETWRT
;	input)
;		HL .... VRAM address
;	output)
;		N/A
;	break)
;		AF
; ==============================================================================
		scope		bsup_setwrt
bsup_setwrt::
		ld			a, l
		di
		out			[0x99], a
		ld			a, h
		or			a, 0x40
		out			[0x99], a
		ret
		endscope

; ==============================================================================
;	SETRD
;	input)
;		HL .... VRAM address
;	output)
;		N/A
;	break)
;		AF
; ==============================================================================
		scope		bsup_setrd
bsup_setrd::
		ld			a, l
		di
		out			[0x99], a
		ld			a, h
		out			[0x99], a
		ret
		endscope
