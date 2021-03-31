; ------------------------------------------------------------------------------
;	B-SUP (�r�[�T�b�v) Name table �ҏW�p����
; ==============================================================================
;	History		author		Description
;	2021/02/19	t.hara		Prototype
; ------------------------------------------------------------------------------

; ==============================================================================
;	CALL BFIL( <����X���W>, <����Y���W>, <��>, <����>, <�l> )
; ==============================================================================
		scope		call_bfil
call_bfil::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; ��1�����ۑ�

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; ��2�����ۑ�

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; ��3�����ۑ�

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; ��4�����ۑ�

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas

		pop			bc
		ld			c, a							; B = ��4����(Height), C = ��5����(Chr)

		pop			af
		ld			e, a

		pop			af
		ld			d, a							; D = ��2����(Ypos), E = ��3����(Width)

		pop			af								; A = ��1����(Xpos)
		push		hl								; BASIC�R�[�h
		ld			l, a							; L = ��1����(Xpos)

		or			a, a
		jp			z, end_of_bfil					; ���������ꍇ�͉������Ȃ�
		cp			a, 33
		jp			nc, end_of_bfil					; �E�ɂ͂ݏo���Ă�ꍇ�͉������Ȃ�

		add			a, e
		cp			a, 33
		jp			c, skip_adjust_w				; ��ʓ��Ɏ��܂��Ă���ꍇ�́A���������X�L�b�v

		ld			a, 32
		sub			a, h
		ld			e, a
skip_adjust_w:

		ld			a, d
		or			a, a
		jp			z, end_of_bfil					; �����������ꍇ�͉������Ȃ�
		cp			a, 25
		jp			nc, end_of_bfil					; ���ɂ͂ݏo���Ă�ꍇ�͉������Ȃ�

		add			a, b
		cp			a, 25
		jp			c, skip_adjust_h				; ��ʓ��Ɏ��܂��Ă���ꍇ�́A�����������X�L�b�v

		ld			a, 24
		sub			a, d
		ld			b, a
skip_adjust_h:
		; �A�h���X�ɕϊ�����
		ld			a, d							; A = Ypos (0�`31)
		ld			h, 0x18 >> 2
		add			a, a
		add			a, a
		add			a, a
		add			a, a
		rl			h
		add			a, a
		rl			h
		add			a, l
		ld			l, a							; HL = 0x1800 + Ypos * 32
		jp			nc, loop_y
		inc			h

loop_y:
		push		hl
		di
		call		setwrt
		ld			a, c
		ld			h, e
loop_x:
		out			[0x98], a
		nop
		dec			h
		jr			nz, loop_x
		pop			hl
		push		de
		ld			de, 32
		add			hl, de
		pop			de
		djnz		loop_y

end_of_bfil:
		ei
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
;	CALL BCLS
; ==============================================================================
		scope		call_bcls
call_bcls::
		push		hl
		call		activate_workarea
		ld			a, [ix + work_sprite_drive_on]
		push		af
		xor			a, a
		ld			[ix + work_sprite_drive_on], a

		call		cls

		pop			af
		ld			[ix + work_sprite_drive_on], a
		call		restore_p2_slot
		pop			hl
		ret
		endscope