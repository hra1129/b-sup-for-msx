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
;	CALL BCPY( <SX>, <SY>, <Width>, <Height>, <DX>, <DY> )
; ==============================================================================
		scope		call_bcpy
call_bcpy::
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, '('
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第1引数保存 <SX>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第2引数保存 <SY>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第3引数保存 <Width>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第4引数保存 <Height>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; 第5引数保存 <DX>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas							; 第6引数保存 <DY>

		exx											; BASICコードアドレスを裏レジスタに保存

		pop			bc
		ld			c, a							; B = <DX>, C = <DY>

		pop			af								; A = <Height>
		pop			de
		ld			e, a							; D = <Width>, E = <Height>

		pop			af								; A = <SY>
		pop			hl
		ld			l, a							; H = <SX>, L = <SY>

		ld			iy, -32							; スタック上に 32byte のワーク領域を確保
		add			iy, sp
		ld			sp, iy

		; パラメータを調整 (水平)
		ld			a, b							; A = <DX>
		cp			a, 32
		jp			nc, end_of_bcpy					; 転送先が画面外の場合は何もしない

		add			a, d							; A = <DX> + <Width>
		cp			a, 32
		jp			c, skip_adjust_width1

		ld			a, 32
		sub			a, b
		ld			d, a							; 右にはみ出さない幅に調整  D = 32 - <DX>
skip_adjust_width1:

		ld			a, h							; A = <SX>
		cp			a, 32
		jp			nc, end_of_bcpy					; 転送元が画面外の場合は何もしない

		add			a, d							; A = <SX> + <Width>
		cp			a, 32
		jp			c, skip_adjust_width2

		ld			a, 32
		sub			a, h
		ld			d, a							; 右にはみ出さない幅に調整  D = 32 - <SX>
skip_adjust_width2:

		; パラメータを調整 (垂直)
		ld			a, c							; A = <DY>
		cp			a, 24
		jp			nc, end_of_bcpy					; 転送先が画面外の場合は何もしない

		add			a, e							; A = <DY> + <Height>
		cp			a, 24
		jp			c, skip_adjust_height1

		ld			a, 24
		sub			a, c
		ld			e, a							; 右にはみ出さない幅に調整  E = 24 - <DY>
skip_adjust_height1:

		ld			a, l							; A = <SY>
		cp			a, 24
		jp			nc, end_of_bcpy					; 転送元が画面外の場合は何もしない

		add			a, d							; A = <SY> + <Height>
		cp			a, 24
		jp			c, skip_adjust_height2

		ld			a, 24
		sub			a, l
		ld			e, a							; 右にはみ出さない幅に調整  E = 24 - <SY>
skip_adjust_height2:

		; 上にコピーか、下にコピーかで処理を分ける
		ld			a, l
		cp			a, c							; if SY < DY goto copy_to_bottom
		push		af

		; アドレスに変換
		; HL = L * 32 + H + 0x1800
		; L ∈ [0,23] → L * 32 ∈ [0,736]
		; 5 < log2(23) < 6 → 左5bitシフト(32倍)すると 2bitはみ出す
		xor			a, a
		srl			l
		rra
		srl			l
		rra
		srl			l
		rra
		add			a, h
		ld			h, l
		ld			l, a
		ld			a, 0x18
		add			a, h
		ld			h, a

		; DE = C * 32 + B + 0x1800; B = <Width>; C = <Height>
		xor			a, a
		srl			c
		rra
		srl			c
		rra
		srl			c
		rra
		add			a, b
		ld			b, c
		ld			c, a
		ld			a, 0x18
		add			a, b
		ld			b, d
		ld			d, a
		ld			a, e
		ld			e, c
		ld			c, a

		pop			af
		jp			c, copy_to_bottom

copy_to_top:
		; 転送元アドレス HL を VDP にセット
		call		bsup_setrd						; ※diのまま戻る
		push		hl

		push		iy
		pop			hl

		; VRAMを１ライン分読み出す
		push		bc
x_loop1r:
		in			a, [0x98]
		ld			[hl], a
		inc			hl
		djnz		x_loop1r
		pop			bc

		; 転送先アドレス DE を VDP にセット
		ex			de, hl
		call		bsup_setwrt						; ※diのまま戻る
		ex			de, hl

		push		iy
		pop			hl

		; VRAMを１ライン分書き出す
		push		bc
x_loop1w:
		ld			a, [hl]
		out			[0x98], a
		inc			hl
		djnz		x_loop1w
		ei

		pop			bc
		pop			hl
		push		bc

		; 次のラインへ遷移
		ld			bc, 32
		add			hl, bc
		ex			de, hl
		add			hl, bc
		ex			de, hl
		pop			bc					; ★ここで期待の値が得られていない

		dec			c
		jp			nz, copy_to_top
		jp			end_of_bcpy

copy_to_bottom:
		push		bc
		; 下端までのオフセット
		ld			b, c				; HL = C * 32; BC = HL
		ld			c, l
		ld			l, b
		ld			b, h
		ld			h, 0
		add			hl, hl
		add			hl, hl
		add			hl, hl
		add			hl, hl
		add			hl, hl
		push		hl
		add			hl, bc				; 転送元アドレスを下端に移動
		ex			de, hl
		pop			bc
		add			hl, bc				; 転送先アドレスを下端に移動
		ex			de, hl
		pop			bc

copy_to_bottom_y_loop:
		; 転送元アドレス HL を VDP にセット
		call		bsup_setrd						; ※diのまま戻る
		push		hl

		push		iy
		pop			hl

		; VRAMを１ライン分読み出す
		push		bc
x_loop2r:
		in			a, [0x98]
		ld			[hl], a
		inc			hl
		djnz		x_loop2r
		pop			bc

		; 転送先アドレス DE を VDP にセット
		ex			de, hl
		call		bsup_setwrt						; ※diのまま戻る
		ex			de, hl

		push		iy
		pop			hl

		; VRAMを１ライン分書き出す
		push		bc
x_loop2w:
		ld			a, [hl]
		out			[0x98], a
		inc			hl
		djnz		x_loop2w
		ei

		pop			bc
		pop			hl
		push		bc

		; 次のラインへ遷移
		ld			bc, -32
		add			hl, bc
		ex			de, hl
		add			hl, bc
		ex			de, hl
		pop			bc

		dec			c
		jp			nz, copy_to_bottom_y_loop

end_of_bcpy:
		ld			hl, 32					; スタック上に確保したワーク領域を開放
		add			hl, sp
		ld			sp, hl

		exx
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
