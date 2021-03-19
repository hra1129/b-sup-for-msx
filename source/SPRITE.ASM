; ------------------------------------------------------------------------------
;	B-SUP (ビーサップ) SPRITE命令
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
		call		calbas							; 第1引数取得 0 or 1
		push		hl
		push		af

		call		activate_workarea

		pop			af
		ld			[ix + work_sprite_drive_on], a

		call		restore_p2_slot
		ei

		pop			hl								; BASICコード復帰
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
		call		calbas							; 第1引数取得 0 or 1
		push		hl
		push		af

		call		activate_workarea

		pop			af
		ld			[ix + work_sprite_stop_auto_move], a

		call		restore_p2_slot
		ei

		pop			hl								; BASICコード復帰
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
		call		calbas							; 第1引数取得 <Sprite #> (0～31)

		push		hl								; (1) BASICコード一時保存
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8倍までは桁あふれしない
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info + 12
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASICコード復帰
		push		de								; (1) [8] <Sprite #>に対応する Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (2) [6] 第2引数保存 <X pos>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (3) [4] 第3引数保存 <Y pos>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (4) [2] 第4引数保存 <Pattern #>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (5) [0] 第5引数保存 <Color>

		exx											; HL'=BASICコード

		call		activate_workarea
		ld			hl, 8
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # に対応する Sprite info へのworkareaオフセット
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # に対応する Sprite info のアドレス

		di
		ld			e, 0
		ld			[hl], e							; 移動ベクトルX上位
		dec			hl
		ld			[hl], e							; 移動ベクトルX下位
		dec			hl
		ld			[hl], e							; 移動ベクトルY上位
		dec			hl
		ld			[hl], e							; 移動ベクトルY下位
		dec			hl
		ld			[hl], e							; 移動ベクトル残上位
		dec			hl
		ld			[hl], e							; 移動ベクトル残下位
		dec			hl
		pop			af								; (4) 第5引数復元 <Color>
		ld			[hl], a							; 色
		dec			hl
		pop			af								; (3) 第4引数復元 <Pattern #>
		ld			[hl], a							; パターン#
		dec			hl
		pop			de								; (2) 第3引数復元 <Y pos>
		pop			bc								; (1) 第2引数復元 <X pos>
		xor			a, a							; 属性 0:非表示
		ld			e, a
		sra			d
		rr			e
		ld			c, a
		sra			b
		rr			c
		ld			[hl], b							; X座標 上位
		dec			hl
		ld			[hl], c							; X座標 下位
		dec			hl
		ld			[hl], d							; Y座標 上位
		dec			hl
		ld			[hl], e							; Y座標 下位
		dec			hl
		inc			a								; 属性 1:表示
		ld			[hl], a
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASICコード

		push		hl								; BASICコード保存
		call		restore_p2_slot
		ei

		pop			hl								; BASICコード復帰
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
		call		calbas							; 第1引数取得 <Sprite #> (0～31)

		push		hl								; (1) BASICコード一時保存
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8倍までは桁あふれしない
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info + 12
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASICコード復帰
		push		de								; (1) [6] <Sprite #>に対応する Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (2) [4] 第2引数保存 <Parent Sprite #> (0～31)

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (4) [2] 第3引数保存 <Pattern #>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (5) [0] 第4引数保存 <Color>

		exx											; HL'=BASICコード

		call		activate_workarea
		ld			hl, 6
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # に対応する Sprite info へのworkareaオフセット
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # に対応する Sprite info のアドレス

		di
		ld			e, 0
		ld			[hl], e							; 移動ベクトルX上位
		dec			hl
		ld			[hl], e							; 移動ベクトルX下位
		dec			hl
		ld			[hl], e							; 移動ベクトルY上位
		dec			hl
		ld			[hl], e							; 移動ベクトルY下位
		dec			hl
		ld			[hl], e							; 移動ベクトル残上位
		dec			hl
		ld			[hl], e							; 移動ベクトル残下位
		dec			hl
		pop			af								; (3) 第4引数復元 <Color>
		ld			[hl], a							; 色
		dec			hl
		pop			af								; (2) 第3引数復元 <Pattern #>
		ld			[hl], a							; パターン#
		dec			hl
		pop			de								; (1) 第2引数復元 <Y pos>
		ld			e, 0
		ld			[hl], e							; X座標 上位 (0)
		dec			hl
		ld			[hl], e							; X座標 下位 (0)
		dec			hl
		ld			[hl], e							; Y座標 上位 (0)
		dec			hl
		ld			[hl], d							; Y座標 下位 (リンク先スプライト番号 <Parent Sprite #>)
		dec			hl
		ld			a, 2							; 属性
		ld			[hl], a
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASICコード

		push		hl								; BASICコード保存
		call		restore_p2_slot
		ei

		pop			hl								; BASICコード復帰
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SMOV( <Sprite #>, <vector X>, <vector Y>, <回数> )
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
		call		calbas							; 第1引数取得 <Sprite #> (0～31)

		push		hl								; (1) BASICコード一時保存
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8倍までは桁あふれしない
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info + 12
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASICコード復帰
		push		de								; (1) [6] <Sprite #>に対応する Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de								; (2) [4] 第2引数保存 <Vector X>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de								; (3) [2] 第3引数保存 <Vector Y>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_frmqnt
		call		calbas
		push		de								; (4) [0] 第4引数保存 <回数>

		exx											; HL'=BASICコード

		call		activate_workarea
		ld			hl, 6
		add			hl, sp
		ld			e, [hl]
		inc			hl
		ld			h, [hl]
		ld			l, e							; Sprite # に対応する Sprite info へのworkareaオフセット
		ld			e, ixl
		ld			d, ixh
		add			hl, de							; Sprite # に対応する Sprite info のアドレス

		di
		pop			iy								; (4) [0] 第4引数保存 <回数>
		pop			de								; (3) [2] 第3引数復元 <Vector Y>
		pop			bc								; (2) [4] 第2引数復元 <Vector X>
		ld			[hl], b							; 移動ベクトルX上位
		dec			hl
		ld			[hl], c							; 移動ベクトルX下位
		dec			hl
		ld			[hl], d							; 移動ベクトルY上位
		dec			hl
		ld			[hl], e							; 移動ベクトルY下位
		dec			hl
		ld			e, iyl
		ld			d, iyh
		ld			[hl], d							; 移動ベクトル残上位
		dec			hl
		ld			[hl], e							; 移動ベクトル残下位
		ei

		pop			de								; (0) Sprite info

		exx											; HL=BASICコード

		push		hl								; BASICコード保存
		call		restore_p2_slot
		ei

		pop			hl								; BASICコード復帰
		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL SSEE( <Sprite #>, <結果格納先変数名> )
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
		call		calbas							; 第1引数取得 <Sprite #> (0～31)

		push		hl								; (1) BASICコード一時保存
		and			a, 0x1F
		add			a, a
		add			a, a
		add			a, a							; 8倍までは桁あふれしない
		add			a, a
		ld			h, 0
		rl			h
		ld			l, a							; HL = <Sprite #> * 16
		ld			de, work_sprite_info
		add			hl, de
		ex			de, hl
		pop			hl								; (0) BASICコード復帰
		push		de								; (1) <Sprite #>に対応する Sprite info

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
		push		de								; (2) 第2引数保存 <結果格納先変数名>
		push		hl								; BASICコード保存
		call		activate_workarea
		pop			de								; BASICコード復元
		pop			bc								; 第2引数復元 <結果格納先変数名>
		pop			hl								; <Sprite #>に対応する Sprite info

		push		de								; BASICコード保存
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

		pop			hl								; BASICコード復帰
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
		ret			z								; Sprite Driver OFF なら何もしない

		; Sprite自動移動処理
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

		ld			de, 7
		add			hl, de
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		ld			a, e
		or			a, d
		ld			bc, -8
		jp			z, sprite_auto_move_next_pre

		; 移動ベクトル残 カウンタを減らす
		dec			de
		dec			hl
		ld			[hl], e
		inc			hl
		ld			[hl], d
		inc			hl

		; Y座標移動
		ld			e, [hl]				; 移動ベクトルY 下位
		inc			hl
		ld			d, [hl]				; 移動ベクトルY 上位
		ld			c, -10 + 1			; 上ですでに B=FFh なので、これで BC=-10+1
		add			hl, bc				; HL=Y座標 下位のアドレス
		ld			c, [hl]				; Y座標 下位
		inc			hl
		ld			b, [hl]				; Y座標 上位
		ex			de, hl
		add			hl, bc				; 移動ベクトルを加算
		ex			de, hl
		ld			[hl], d				; Y座標 上位
		dec			hl
		ld			[hl], e				; Y座標 下位
		ld			a, d
		or			a, a
		ld			bc, -1
		jp			m, outside_sprite
		ld			bc, -1 + 11
		add			hl, bc				; HL=移動ベクトルX 下位のアドレス

		; X座標移動
		ld			e, [hl]				; 移動ベクトルX 下位
		inc			hl
		ld			d, [hl]				; 移動ベクトルX 上位
		ld			bc, -12 + 3			; BC=-12+3
		add			hl, bc				; HL=X座標 下位のアドレス
		ld			c, [hl]				; X座標 下位
		inc			hl
		ld			b, [hl]				; X座標 上位
		ex			de, hl
		add			hl, bc				; 移動ベクトルを加算
		ex			de, hl
		ld			[hl], d				; X座標 上位
		dec			hl
		ld			[hl], e				; X座標 下位
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
		; Sprite表示処理
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

		ld			a, [ix + work_1st_sprite]		; Sprite# (0～31)
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

		ld			a, [hl]							; 属性 0:非表示, 1:通常, 2:連結
		inc			hl
		or			a, a							; 非表示なら非表示ルーチンへ
		jp			z, hide_sprite
		dec			a								; 連結なら連結処理ルーチンへ
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
		endscope

; ==============================================================================
;	非表示のスプライト
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
;	通常表示のスプライト
;	input)
;		HL .... Target of Sprite Information + 1
;	output)
;		N/A
;	break)
;		AF, HL
; ==============================================================================
		scope		normal_sprite
normal_sprite::
		; Y座標
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a
		inc			hl

		; X座標
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a
		inc			hl

		; パターン#
		ld			a, [hl]
		out			[0x98], a
		inc			hl

		; 色
		ld			a, [hl]
		out			[0x98], a
		inc			hl
		jp			next_sprite
		endscope

; ==============================================================================
;	連結表示のスプライト
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
		jp			z, skip1					; 連結先が非表示なら、これも非表示

		inc			hl							; 連結先が、また連結であることは考慮しない。

		; Y座標
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		rla
		out			[0x98], a
		inc			hl

		; X座標
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

		; パターン#
		ld			a, [hl]
		out			[0x98], a
		inc			hl

		; 色
		ld			a, [hl]
		out			[0x98], a
		jp			next_sprite

skip1:
		pop			hl
		jp			hide_sprite
		endscope
