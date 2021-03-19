; ------------------------------------------------------------------------------
;	B-SUP (ビーサップ) PCG命令
; ==============================================================================
;	History		author		Description
;	2021/02/19	t.hara		Prototype
; ------------------------------------------------------------------------------

; ==============================================================================
		scope		call_pcg_param_sub
call_pcg_param_sub::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第1引数保存

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmevl
		call		calbas

		push		hl								; BASICコードアドレス
		ld			ix, calbas_frestr
		call		calbas
		ex			de, hl
		pop			hl								; BASICコードアドレス
		pop			af								; 第1引数復元
		pop			bc								; 戻り番地取り出し
		push		hl								; BASICコードアドレス
		ld			hl, -8
		add			hl, sp
		ld			sp, hl
		push		bc								; 戻り番地を積む

		ld			b, a
		ld			de, [dac + 2]
		ld			a, [de]
		cp			a, 16
		jp			nz, illegal_function_call_error


		push		hl								; スタック上の 8byte ワークアドレス

		inc			de
		ld			a, [de]
		ld			l, a
		inc			de
		ld			a, [de]
		ld			h, a							; HL = 文字列データの先頭アドレス

		pop			de								; スタック上の 8byte ワークアドレス
		push		de								; スタック上の 8byte ワークアドレス

		call		get_one_byte
		call		get_one_byte
		call		get_one_byte
		call		get_one_byte
		call		get_one_byte
		call		get_one_byte
		call		get_one_byte
		call		get_one_byte

		ld			l, b
		ld			h, 0
		add			hl, hl
		add			hl, hl
		add			hl, hl

		pop			de								; スタック上の 8byte ワークアドレス
		ret
		endscope

; ==============================================================================
		scope		get_one_byte
get_one_byte::
		ld			a, [hl]
		inc			hl
		bit			6, a
		jp			z, skip1
		add			a, 9
skip1:
		and			a, 0x0F
		add			a, a
		add			a, a
		add			a, a
		add			a, a

		ld			c, a

		ld			a, [hl]
		inc			hl
		bit			6, a
		jp			z, skip2
		add			a, 9
skip2:
		and			a, 0x0F
		or			a, c

		ld			[de], a
		inc			de
		ret
		endscope

; ==============================================================================
;	CALL PCG0( <character number>, <pattern> )
; ==============================================================================
		scope		call_pcg0
call_pcg0::
		call		call_pcg_param_sub

		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
exit_call_pcg::
		ld			hl, 8
		add			hl, sp
		ld			sp, hl

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
;	CALL PCG1( <character number>, <pattern> )
; ==============================================================================
		scope		call_pcg1
call_pcg1::
		call		call_pcg_param_sub

		ld			bc, 0x800
		add			hl, bc

		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL PCG2( <character number>, <pattern> )
; ==============================================================================
		scope		call_pcg2
call_pcg2::
		call		call_pcg_param_sub

		ld			bc, 0x1000
		add			hl, bc

		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL PCG3( <character number>, <pattern> )
; ==============================================================================
		scope		call_pcg3
call_pcg3::
		call		call_pcg_param_sub

		push		hl
		push		de
		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		pop			de
		pop			hl

		ld			bc, 0x800
		add			hl, bc
		push		hl
		push		de
		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		pop			de
		pop			hl

		ld			bc, 0x800
		add			hl, bc
		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL COL0( <character number>, <pattern> )
; ==============================================================================
		scope		call_col0
call_col0::
		call		call_pcg_param_sub

		ld			bc, 0x2000
		add			hl, bc

		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL COL1( <character number>, <pattern> )
; ==============================================================================
		scope		call_col1
call_col1::
		call		call_pcg_param_sub

		ld			bc, 0x2800
		add			hl, bc

		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL COL2( <character number>, <pattern> )
; ==============================================================================
		scope		call_col2
call_col2::
		call		call_pcg_param_sub

		ld			bc, 0x3000
		add			hl, bc

		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL COL3( <character number>, <pattern> )
; ==============================================================================
		scope		call_col3
call_col3::
		call		call_pcg_param_sub

		ld			bc, 0x2000
		add			hl, bc
		push		hl
		push		de
		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		pop			de
		pop			hl

		ld			bc, 0x800
		add			hl, bc
		push		hl
		push		de
		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		pop			de
		pop			hl

		ld			bc, 0x800
		add			hl, bc
		ex			de, hl
		ld			bc, 8
		call		bsup_ldirvm
		jp			exit_call_pcg
		endscope

; ==============================================================================
;	CALL BFNT
; ==============================================================================
		scope		call_bfnt
call_bfnt::
		push		hl

		ld			hl, 0
		di
		call		setwrt
		call		set_font
		call		set_font
		call		set_font
		ei
		pop			hl
		jp			exit_call_statement

set_font:
		ld			hl, [0x0004]
		ld			bc, 0x800
loop1:
		ld			a, [hl]
		inc			hl
		ld			d, a
		srl			a
		or			a, d
		out			[0x98], a
		dec			bc
		ld			a, c
		or			a, b
		jp			nz, loop1
		ret
		endscope
