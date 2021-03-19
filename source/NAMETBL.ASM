; ------------------------------------------------------------------------------
;	B-SUP (ビーサップ) Name table 編集用命令
; ==============================================================================
;	History		author		Description
;	2021/02/19	t.hara		Prototype
; ------------------------------------------------------------------------------

; ==============================================================================
;	CALL BFIL( <左上X座標>, <左上Y座標>, <幅>, <高さ>, <値> )
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
		push		af								; 第1引数保存

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第2引数保存

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第3引数保存

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第4引数保存

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas

		pop			bc
		ld			c, a							; B = 第4引数(Height), C = 第5引数(Chr)

		pop			af
		ld			e, a

		pop			af
		ld			d, a							; D = 第2引数(Ypos), E = 第3引数(Width)

		pop			af								; A = 第1引数(Xpos)
		push		hl								; BASICコード
		ld			l, a							; L = 第1引数(Xpos)

		or			a, a
		jp			z, end_of_bfil					; 幅が無い場合は何もしない
		cp			a, 33
		jp			nc, end_of_bfil					; 右にはみ出してる場合は何もしない

		add			a, e
		cp			a, 33
		jp			c, skip_adjust_w				; 画面内に収まっている場合は、幅調整をスキップ

		ld			a, 32
		sub			a, h
		ld			e, a
skip_adjust_w:

		ld			a, d
		or			a, a
		jp			z, end_of_bfil					; 高さが無い場合は何もしない
		cp			a, 25
		jp			nc, end_of_bfil					; 下にはみ出してる場合は何もしない

		add			a, b
		cp			a, 25
		jp			c, skip_adjust_h				; 画面内に収まっている場合は、高さ調整をスキップ

		ld			a, 24
		sub			a, d
		ld			b, a
skip_adjust_h:
		; アドレスに変換する
		ld			a, d							; A = Ypos (0～31)
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
