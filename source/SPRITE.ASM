; ------------------------------------------------------------------------------
;	B-SUP (�r�[�T�b�v) SPRITE����
; ==============================================================================
;	History		author		Description
;	2021/03/07	t.hara		Prototype
; ------------------------------------------------------------------------------

; ==============================================================================
;	CALL SDRV( <0/1> )
; ==============================================================================
		scope		call_sdrv
call_sdrv::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 0 or 1
		push		hl
		push		af

		call		activate_workarea

		pop			af
		ld			[ix + work_sprite_drive_on], a

		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SSTP( <0/1> )
; ==============================================================================
		scope		call_sstp
call_sstp::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 0 or 1
		push		hl
		push		af

		call		activate_workarea

		pop			af
		ld			[ix + work_sprite_stop_auto_move], a

		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SPUT( <Sprite #>, <X pos>, <Y pos>, <Pattern #>, <Color> )
; ==============================================================================
		scope		call_sput
call_sput::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 <Sprite #> (0�`31)

		push		hl								; (1) BASIC�R�[�h�ꎞ�ۑ�
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8�{�܂ł͌����ӂꂵ�Ȃ�
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info + 12
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASIC�R�[�h���A
		push		de								; (1) [8] <Sprite #>�ɑΉ����� Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (2) [6] ��2�����ۑ� <X pos>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (3) [4] ��3�����ۑ� <Y pos>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (4) [2] ��4�����ۑ� <Pattern #>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (5) [0] ��5�����ۑ� <Color>

		exx											; HL'=BASIC�R�[�h

		call		activate_workarea
		ld			hl, 8
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # �ɑΉ����� Sprite info �ւ�workarea�I�t�Z�b�g
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # �ɑΉ����� Sprite info �̃A�h���X

		di
		ld			e, 0
		ld			[hl], e							; �ړ��x�N�g��X���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��X����
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��Y���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��Y����
		dec			hl
		ld			[hl], e							; �ړ��x�N�g���c���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g���c����
		dec			hl
		pop			af								; (4) ��5�������� <Color>
		ld			[hl], a							; �F
		dec			hl
		pop			af								; (3) ��4�������� <Pattern #>
		ld			[hl], a							; �p�^�[��#
		dec			hl
		pop			de								; (2) ��3�������� <Y pos>
		pop			bc								; (1) ��2�������� <X pos>
		xor			a, a							; ���� 0:��\��
		ld			e, a
		sra			d
		rr			e
		ld			c, a
		sra			b
		rr			c
		ld			[hl], b							; X���W ���
		dec			hl
		ld			[hl], c							; X���W ����
		dec			hl
		ld			[hl], d							; Y���W ���
		dec			hl
		ld			[hl], e							; Y���W ����
		dec			hl
		inc			a								; ���� 1:�\��
		ld			[hl], a
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASIC�R�[�h

		push		hl								; BASIC�R�[�h�ۑ�
		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SLNK( <Sprite #>, <Link Target Sprite #>, <Pattern #>, <Color> )
; ==============================================================================
		scope		call_slnk
call_slnk::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 <Sprite #> (0�`31)

		push		hl								; (1) BASIC�R�[�h�ꎞ�ۑ�
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8�{�܂ł͌����ӂꂵ�Ȃ�
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info + 12
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASIC�R�[�h���A
		push		de								; (1) [6] <Sprite #>�ɑΉ����� Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (2) [4] ��2�����ۑ� <Parent Sprite #> (0�`31)

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (4) [2] ��3�����ۑ� <Pattern #>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (5) [0] ��4�����ۑ� <Color>

		exx											; HL'=BASIC�R�[�h

		call		activate_workarea
		ld			hl, 6
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # �ɑΉ����� Sprite info �ւ�workarea�I�t�Z�b�g
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # �ɑΉ����� Sprite info �̃A�h���X

		di
		ld			e, 0
		ld			[hl], e							; �ړ��x�N�g��X���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��X����
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��Y���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��Y����
		dec			hl
		ld			[hl], e							; �ړ��x�N�g���c���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g���c����
		dec			hl
		pop			af								; (3) ��4�������� <Color>
		ld			[hl], a							; �F
		dec			hl
		pop			af								; (2) ��3�������� <Pattern #>
		ld			[hl], a							; �p�^�[��#
		dec			hl
		pop			de								; (1) ��2�������� <Y pos>
		ld			e, 0
		ld			[hl], e							; X���W ��� (0)
		dec			hl
		ld			[hl], e							; X���W ���� (0)
		dec			hl
		ld			[hl], e							; Y���W ��� (0)
		dec			hl
		ld			[hl], d							; Y���W ���� (�����N��X�v���C�g�ԍ� <Parent Sprite #>)
		dec			hl
		ld			a, 2							; ����
		ld			[hl], a
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASIC�R�[�h

		push		hl								; BASIC�R�[�h�ۑ�
		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SMOV( <Sprite #>, <vector X>, <vector Y>, <��> )
; ==============================================================================
		scope		call_smov
call_smov::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 <Sprite #> (0�`31)

		push		hl								; (1) BASIC�R�[�h�ꎞ�ۑ�
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8�{�܂ł͌����ӂꂵ�Ȃ�
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info + 12
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASIC�R�[�h���A
		push		de								; (1) [6] <Sprite #>�ɑΉ����� Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de								; (2) [4] ��2�����ۑ� <Vector X>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de								; (3) [2] ��3�����ۑ� <Vector Y>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas

		ld			a, d							; ���������� 0 �ɒu��
		or			a, a
		jp			p, skip
		ld			de, 0
skip:
		push		de								; (4) [0] ��4�����ۑ� <��>

		exx											; HL'=BASIC�R�[�h

		call		activate_workarea
		ld			hl, 6
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # �ɑΉ����� Sprite info �ւ�workarea�I�t�Z�b�g
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # �ɑΉ����� Sprite info �̃A�h���X

		di
		pop			iy								; (4) [0] ��4�����ۑ� <��>
		pop			de								; (3) [2] ��3�������� <Vector Y>
		pop			bc								; (2) [4] ��2�������� <Vector X>
		ld			[hl], b							; �ړ��x�N�g��X���
		dec			hl
		ld			[hl], c							; �ړ��x�N�g��X����
		dec			hl
		ld			[hl], d							; �ړ��x�N�g��Y���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g��Y����
		dec			hl
		ld			e, iyl
		ld			d, iyh
		ld			[hl], d							; �ړ��x�N�g���c���
		dec			hl
		ld			[hl], e							; �ړ��x�N�g���c����
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASIC�R�[�h

		push		hl								; BASIC�R�[�h�ۑ�
		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SEPT( <Sprite #>, <endpoint X>, <endpoint Y>, <speed>, <mode> )
; ==============================================================================
		scope		call_sept
call_sept::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 <Sprite #> (0�`31)

		push		hl								; (1) BASIC�R�[�h�ꎞ�ۑ�
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8�{�܂ł͌����ӂꂵ�Ȃ�
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASIC�R�[�h���A
		push		de								; (1) [8] <Sprite #>�ɑΉ����� Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (2) [6] ��2�����ۑ� <Endpoint X>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (3) [4] ��3�����ۑ� <Endpoint Y>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		dec			a
		and			a, 127
		inc			a								; 0-->128, 1-->1, 2-->2, ... , 127-->127, 128-->128, 129-->1, ... 255-->127
		push		af								; (4) [2] ��4�����ۑ� <speed>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		and			a, 1
		push		af								; (5) [0] ��5�����ۑ� <mode>

		exx											; HL'=BASIC�R�[�h

		call		activate_workarea
		ld			hl, 8
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # �ɑΉ����� Sprite info �ւ�workarea�I�t�Z�b�g
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # �ɑΉ����� Sprite info �̃A�h���X
		ex			de, hl
		ld			iyl, e
		ld			iyh, d

		di
		xor			a, a
		ld			[iy + 11], a

		pop			af								; (5) [0] ��5�����ۑ� <mode>
		ld			[iy + 7], a
		ld			a, 0x80
		ld			[iy + 8], a

		pop			af								; (4) [2] ��4�����ۑ� <speed>
		ld			[iy + 13], a

		pop			af								; (3) [4] ��3�������� <Endpoint Y>
		ld			[iy + 14], a

		ld			e, [iy + 1]						; -- �n�_Y���W ����
		rlc			e
		ld			d, [iy + 2]						; -- �n�_Y���W ���
		rl			d
		sub			a, d							; �I�_Y - �n�_Y
		ld			d, a
		jp			nc, skip_bigger_than_ep_y
		neg
		ld			d, a
		ld			a, [iy + 11]
		or			a, 0x80
		ld			[iy + 11], a
skip_bigger_than_ep_y:

		pop			af								; (2) [6] ��2�������� <Endpoint X>
		ld			[iy + 15], a

		ld			e, [iy + 3]						; -- �n�_X���W ����
		rlc			e
		ld			b, [iy + 4]						; -- �n�_X���W ���
		rl			b
		sub			a, b							; �I�_X - �n�_X
		ld			b, a
		jp			nc, skip_bigger_than_ep_x
		neg
		ld			b, a
		ld			a, [iy + 11]
		or			a, 0x40
		ld			[iy + 11], a
skip_bigger_than_ep_x:

		ld			a, b
		cp			a, d
		jp			nc, skip_long_boundary_is_x
		ld			a, d
		ld			d, b
		ld			b, a
		ld			a, [iy + 11]
		or			a, 0x01
		ld			[iy + 11], a
skip_long_boundary_is_x:
		ld			[iy + 9], b
		ld			[iy + 10], d

		xor			a, a
		ld			[iy + 12], a
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASIC�R�[�h

		push		hl								; BASIC�R�[�h�ۑ�
		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SSEE( <Sprite #>, <���ʊi�[��ϐ���> )
; ==============================================================================
		scope		call_ssee
call_ssee::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; ��1�����擾 <Sprite #> (0�`31)

		push		hl								; (1) BASIC�R�[�h�ꎞ�ۑ�
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8�{�܂ł͌����ӂꂵ�Ȃ�
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASIC�R�[�h���A
		push		de								; (1) <Sprite #>�ɑΉ����� Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		xor			a, a
		ld			[subflg], a
		ld			ix, calbas_ptrget
		call		calbas
		dec			de
		dec			de
		dec			de
		ld			a, [de]
		cp			a, 2
		jp			nz, type_mismatch_error
		inc			de
		inc			de
		inc			de
		push		de								; (2) ��2�����ۑ� <���ʊi�[��ϐ���>
		push		hl								; BASIC�R�[�h�ۑ�
		call		activate_workarea
		pop			de								; BASIC�R�[�h����
		pop			bc								; ��2�������� <���ʊi�[��ϐ���>
		pop			hl								; <Sprite #>�ɑΉ����� Sprite info

		push		de								; BASIC�R�[�h�ۑ�
		ld			e, ixl
		ld			d, ixh
		add			hl, de
		ld			a, [hl]

		ld			[bc], a
		inc			bc
		xor			a, a
		ld			[bc], a

		call		restore_p2_slot
		ei

		pop			hl								; BASIC�R�[�h���A
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	Sprite Driver on H.TIMI
;	input)
;		ix .... workarea address
;	output)
;		N/A
;	break)
;		all
; ==============================================================================
		scope		sprite_driver
sprite_driver::
		ld			a, [ix + work_sprite_drive_on]
		or			a, a
		ret			z								; Sprite Driver OFF �Ȃ牽�����Ȃ�

		; Sprite�����ړ�����
		ld			a, [ix + work_sprite_stop_auto_move]
		or			a, a
		jp			nz, skip_auto_move

		ld			b, 32
		push		ix
		pop			hl
		ld			de, work_sprite_info
		add			hl, de
sprite_auto_move:
		push		bc
		ld			a, [hl]
		dec			a
		jp			nz, sprite_auto_move_next

		; �ړ��x�N�g���c ���m�F
		ld			de, 7
		add			hl, de
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		ld			a, d
		or			a, a					; 0x80 ��?
		jp			m, sprite_bresenham_move
		or			a, e
		ld			bc, -8
		jp			z, sprite_auto_move_next_pre

		; �ړ��x�N�g���c �J�E���^�����炷
		dec			de
		dec			hl
		ld			[hl], e
		inc			hl
		ld			[hl], d
		inc			hl

		; Y���W�ړ�
		ld			e, [hl]				; �ړ��x�N�g��Y ����
		inc			hl
		ld			d, [hl]				; �ړ��x�N�g��Y ���
		ld			c, -10 + 1			; ��ł��ł� B=FFh �Ȃ̂ŁA����� BC=-10+1
		add			hl, bc				; HL=Y���W ���ʂ̃A�h���X
		ld			c, [hl]				; Y���W ����
		inc			hl
		ld			b, [hl]				; Y���W ���
		ex			de, hl
		add			hl, bc				; �ړ��x�N�g�������Z
		ex			de, hl
		ld			[hl], d				; Y���W ���
		dec			hl
		ld			[hl], e				; Y���W ����
		ld			a, d
		or			a, a
		ld			bc, -1
		jp			m, outside_sprite
		ld			bc, -1 + 11
		add			hl, bc				; HL=�ړ��x�N�g��X ���ʂ̃A�h���X

		; X���W�ړ�
		ld			e, [hl]				; �ړ��x�N�g��X ����
		inc			hl
		ld			d, [hl]				; �ړ��x�N�g��X ���
		ld			bc, -12 + 3			; BC=-12+3
		add			hl, bc				; HL=X���W ���ʂ̃A�h���X
		ld			c, [hl]				; X���W ����
		inc			hl
		ld			b, [hl]				; X���W ���
		ex			de, hl
		add			hl, bc				; �ړ��x�N�g�������Z
		ex			de, hl
		ld			[hl], d				; X���W ���
		dec			hl
		ld			[hl], e				; X���W ����
		ld			a, d
		or			a, a
		ld			bc, -3
		jp			p, sprite_auto_move_next_pre

outside_sprite:
		add			hl, bc
		xor			a, a
		ld			[hl], a
		jp			sprite_auto_move_next

sprite_auto_move_next_pre:
		add			hl, bc
sprite_auto_move_next:
		ld			de, 16
		add			hl, de
		pop			bc
		djnz		sprite_auto_move

skip_auto_move:
		; Sprite�\������
		ld			hl, 0x1B00 | 0x4000				; Sprite Attribute Table
		ld			a, l
		out			[0x99], a
		ld			a, h
		out			[0x99], a

		ld			e, ixl
		ld			d, ixh
		ld			hl, work_sprite_info
		add			hl, de
		ex			de, hl

		ld			a, [ix + work_1st_sprite]		; Sprite# (0�`31)
		add			a, 19
		and			a, 31
		ld			[ix + work_1st_sprite], a

		add			a, a
		add			a, a
		add			a, a
		add			a, a
		ld			l, a
		ld			h, 0
		rl			h

		ld			b, 32
loop1:
		push		hl
		push		bc
		add			hl, de

		ld			a, [hl]							; ���� 0:��\��, 1:�ʏ�, 2:�A��
		inc			hl
		or			a, a							; ��\���Ȃ��\�����[�`����
		jp			z, hide_sprite
		dec			a								; �A���Ȃ�A���������[�`����
		jp			nz, join_sprite
		jp			normal_sprite
next_sprite::
		pop			bc
		pop			hl

		ld			a, l
		add			a, 11 * 16
		ld			l, a
		ld			a, h
		adc			a, 0
		and			a, 1
		ld			h, a
		djnz		loop1
		ret

sprite_bresenham_move:
		inc			hl
		ld			b, [hl]							; ����
		inc			hl
		ld			c, [hl]							; �Z��
		inc			hl
		ld			d, [hl]							; �t���O
		inc			hl
		ld			a, [hl]							; �J�E���^

		add			a, c
		cp			a, b
		ld			c, 1
		jr			c, skip_add
		inc			c
		sub			a, b
skip_add:
		ld			[hl], a							; �J�E���^�X�V
		ld			a, d

		inc			hl
		ld			b, [hl]							; ���x

		dec			c
		jp			z, skip_vector
		ld			c, b
skip_vector:

		inc			hl
		ld			e, [hl]							; �I�_Y
		inc			hl
		ld			d, [hl]							; �I�_X
		push		de

		bit			0, a							; Zf: 1=���ӂ�X, 0=���ӂ�Y
		jp			z, long_side_is_x

long_side_is_y:
		ld			d, b
		ld			b, c
		ld			c, d

long_side_is_x:
		ld			de, -12
		add			hl, de							; HL = X���W���ʂ̃A�h���X

		ld			d, a							; �t���O�ۑ�

		bit			6, a
		jp			nz, x_endpoint_is_left1

x_endpoint_is_right1:
		ld			a, [hl]							; a = X���W����
		add			a, b							; a = X���W���� + ���x
		ld			[hl], a							; X���W���� �X�V

		inc			hl
		ld			a, [hl]							; ���t���O���W�X�^�ۑ�
		adc			a, 0							; a = X���W��� + �L�����[
		ld			[hl], a							; X���W��� �X�V
		jp			y_move1

x_endpoint_is_left1:
		ld			a, [hl]							; a = X���W����
		sub			a, b							; a = X���W���� + ���x
		ld			[hl], a							; X���W���� �X�V

		inc			hl
		ld			a, [hl]							; ���t���O���W�X�^�ۑ�
		sbc			a, 0							; a = X���W��� + �L�����[
		ld			[hl], a							; X���W��� �X�V

y_move1:
		dec			hl
		dec			hl
		dec			hl

		bit			7, d
		jp			nz, y_endpoint_is_up1

y_endpoint_is_down1:
		ld			a, [hl]							; a = Y���W����
		add			a, c							; a = Y���W���� + ���x
		ld			[hl], a							; Y���W���� �X�V

		inc			hl
		ld			a, [hl]							; ���t���O���W�X�^�ۑ�
		adc			a, 0							; a = Y���W��� + �L�����[
		ld			[hl], a							; Y���W��� �X�V
		jp			sprite_bresenham_move_end_check

y_endpoint_is_up1:
		ld			a, [hl]							; a = Y���W����
		sub			a, c							; a = Y���W���� + ���x
		ld			[hl], a							; Y���W���� �X�V

		inc			hl
		ld			a, [hl]							; ���t���O���W�X�^�ۑ�
		sbc			a, 0							; a = Y���W��� + �L�����[
		ld			[hl], a							; Y���W��� �X�V

sprite_bresenham_move_end_check:
		ld			bc, -2
		cp			a, 212 / 2						; Y���W�� 212�ȏ�ɂȂ������H
		jp			nc, sprite_went_offscreen

		inc			hl
		inc			hl
		ld			c, -4
		ld			a, [hl]							; X���W���
		or			a, a
		jp			m, sprite_went_offscreen

		inc			hl
		inc			hl
		inc			hl								; HL=���[�h�̃A�h���X (+7)
		ld			a, [hl]
		or			a, a
		jp			nz, sprite_auto_move_next_pre

		ld			bc, -6
		add			hl, bc							; HL=Y���W���ʂ̃A�h���X
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		adc			a, a							; A=Y���W
		ld			bc, 12
		add			hl, bc
		cp			a, [hl]							; �I�_Y �Ɣ�r
		ld			bc, -14
		jp			nz, sprite_auto_move_next_pre

		inc			hl
		ld			a, [hl]							; B=�I�_X
		ld			bc, -12
		add			hl, bc
		ld			b, a
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		adc			a, a							; A=X���W
		cp			a, b
		ld			bc, -4
		jp			nz, sprite_auto_move_next_pre

		inc			hl
		inc			hl
		inc			hl								; HL=���[�h�̃A�h���X
		ld			[hl], 0
		inc			hl
		ld			[hl], 0
		ld			bc, -8
		jp			sprite_auto_move_next_pre

sprite_went_offscreen:
		add			hl, bc							; HL=�����̃A�h���X
		xor			a, a
		ld			[hl], a
		jp			sprite_auto_move_next
		endscope

; ==============================================================================
;	��\���̃X�v���C�g
;	input)
;		HL .... Target of Sprite Information + 1
;	output)
;		N/A
;	break)
;		AF, C
; ==============================================================================
		scope		hide_sprite
hide_sprite::
		ld			c, 4
		ld			a, 212
loop:
		out			[0x98], a
		nop
		dec			c
		jr			nz, loop
		jp			next_sprite
		endscope

; ==============================================================================
;	�ʏ�\���̃X�v���C�g
;	input)
;		HL .... Target of Sprite Information + 1
;	output)
;		N/A
;	break)
;		AF, HL
; ==============================================================================
		scope		normal_sprite
normal_sprite::
		; Y���W
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a
		inc			hl

		; X���W
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a
		inc			hl

		; �p�^�[��#
		ld			a, [hl]
		out			[0x98], a
		inc			hl

		; �F
		ld			a, [hl]
		out			[0x98], a
		inc			hl
		jp			next_sprite
		endscope

; ==============================================================================
;	�A���\���̃X�v���C�g
;	input)
;		HL .... Target of Sprite Information + 1
;	output)
;		N/A
;	break)
;		AF, HL
; ==============================================================================
		scope		join_sprite
join_sprite::
		ld			a, [hl]
		push		hl

		add			a, a
		add			a, a
		add			a, a
		add			a, a
		ld			l, a
		ld			h, 0
		rl			h
		add			hl, de

		ld			a, [hl]
		or			a, a
		jp			z, skip1					; �A���悪��\���Ȃ�A�������\��

		inc			hl							; �A���悪�A�܂��A���ł��邱�Ƃ͍l�����Ȃ��B

		; Y���W
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a
		inc			hl

		; X���W
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a

		pop			hl
		inc			hl
		inc			hl
		inc			hl
		inc			hl

		; �p�^�[��#
		ld			a, [hl]
		out			[0x98], a
		inc			hl

		; �F
		ld			a, [hl]
		out			[0x98], a
		jp			next_sprite

skip1:
		pop			hl
		jp			hide_sprite
		endscope