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

		ld			a, d							; 負だったら 0 に置換
		or			a, a
		jp			p, skip
		ld			de, 0
skip:
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
		push		de								; (1) [8] <Sprite #>に対応する Sprite info

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (2) [6] 第2引数保存 <Endpoint X>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		push		af								; (3) [4] 第3引数保存 <Endpoint Y>

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
		push		af								; (4) [2] 第4引数保存 <speed>

		dec			hl
		ld			ix, calbas_chrgtr
		call		calbas
		cp			a, ','
		jp			nz, syntax_error
		inc			hl

		ld			ix, calbas_getbyt
		call		calbas
		and			a, 1
		push		af								; (5) [0] 第5引数保存 <mode>

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
		ex			de, hl
		ld			iyl, e
		ld			iyh, d

		di
		xor			a, a
		ld			[iy + 11], a

		pop			af								; (5) [0] 第5引数保存 <mode>
		ld			[iy + 7], a
		ld			a, 0x80
		ld			[iy + 8], a

		pop			af								; (4) [2] 第4引数保存 <speed>
		ld			[iy + 13], a

		pop			af								; (3) [4] 第3引数復元 <Endpoint Y>
		ld			[iy + 14], a

		ld			e, [iy + 1]						; -- 始点Y座標 下位
		rlc			e
		ld			d, [iy + 2]						; -- 始点Y座標 上位
		rl			d
		sub			a, d							; 終点Y - 始点Y
		ld			d, a
		jp			nc, skip_bigger_than_ep_y
		neg
		ld			d, a
		ld			a, [iy + 11]
		or			a, 0x80
		ld			[iy + 11], a
skip_bigger_than_ep_y:

		pop			af								; (2) [6] 第2引数復元 <Endpoint X>
		ld			[iy + 15], a

		ld			e, [iy + 3]						; -- 始点X座標 下位
		rlc			e
		ld			b, [iy + 4]						; -- 始点X座標 上位
		rl			b
		sub			a, b							; 終点X - 始点X
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

		; 移動ベクトル残 を確認
		ld			de, 7
		add			hl, de
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		ld			a, d
		or			a, a					; 0x80 か?
		jp			m, sprite_bresenham_move
		or			a, e
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

sprite_bresenham_move:
		inc			hl
		ld			b, [hl]							; 長辺
		inc			hl
		ld			c, [hl]							; 短辺
		inc			hl
		ld			d, [hl]							; フラグ
		inc			hl
		ld			a, [hl]							; カウンタ

		add			a, c
		cp			a, b
		ld			c, 1
		jr			c, skip_add
		inc			c
		sub			a, b
skip_add:
		ld			[hl], a							; カウンタ更新
		ld			a, d

		inc			hl
		ld			b, [hl]							; 速度

		dec			c
		jp			z, skip_vector
		ld			c, b
skip_vector:

		inc			hl
		ld			e, [hl]							; 終点Y
		inc			hl
		ld			d, [hl]							; 終点X
		push		de

		bit			0, a							; Zf: 1=長辺はX, 0=長辺はY
		jp			z, long_side_is_x

long_side_is_y:
		ld			d, b
		ld			b, c
		ld			c, d

long_side_is_x:
		ld			de, -12
		add			hl, de							; HL = X座標下位のアドレス

		ld			d, a							; フラグ保存

		bit			6, a
		jp			nz, x_endpoint_is_left1

x_endpoint_is_right1:
		ld			a, [hl]							; a = X座標下位
		add			a, b							; a = X座標下位 + 速度
		ld			[hl], a							; X座標下位 更新

		inc			hl
		ld			a, [hl]							; ※フラグレジスタ保存
		adc			a, 0							; a = X座標上位 + キャリー
		ld			[hl], a							; X座標上位 更新
		jp			y_move1

x_endpoint_is_left1:
		ld			a, [hl]							; a = X座標下位
		sub			a, b							; a = X座標下位 + 速度
		ld			[hl], a							; X座標下位 更新

		inc			hl
		ld			a, [hl]							; ※フラグレジスタ保存
		sbc			a, 0							; a = X座標上位 + キャリー
		ld			[hl], a							; X座標上位 更新

y_move1:
		dec			hl
		dec			hl
		dec			hl

		bit			7, d
		jp			nz, y_endpoint_is_up1

y_endpoint_is_down1:
		ld			a, [hl]							; a = Y座標下位
		add			a, c							; a = Y座標下位 + 速度
		ld			[hl], a							; Y座標下位 更新

		inc			hl
		ld			a, [hl]							; ※フラグレジスタ保存
		adc			a, 0							; a = Y座標上位 + キャリー
		ld			[hl], a							; Y座標上位 更新
		jp			sprite_bresenham_move_end_check

y_endpoint_is_up1:
		ld			a, [hl]							; a = Y座標下位
		sub			a, c							; a = Y座標下位 + 速度
		ld			[hl], a							; Y座標下位 更新

		inc			hl
		ld			a, [hl]							; ※フラグレジスタ保存
		sbc			a, 0							; a = Y座標上位 + キャリー
		ld			[hl], a							; Y座標上位 更新

sprite_bresenham_move_end_check:
		ld			bc, -2
		cp			a, 212 / 2						; Y座標が 212以上になったか？
		jp			nc, sprite_went_offscreen

		inc			hl
		inc			hl
		ld			c, -4
		ld			a, [hl]							; X座標上位
		or			a, a
		jp			m, sprite_went_offscreen

		inc			hl
		inc			hl
		inc			hl								; HL=モードのアドレス (+7)
		ld			a, [hl]
		or			a, a
		jp			nz, sprite_auto_move_next_pre

		ld			bc, -6
		add			hl, bc							; HL=Y座標下位のアドレス
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		adc			a, a							; A=Y座標
		ld			bc, 12
		add			hl, bc
		cp			a, [hl]							; 終点Y と比較
		ld			bc, -14
		jp			nz, sprite_auto_move_next_pre

		inc			hl
		ld			a, [hl]							; B=終点X
		ld			bc, -12
		add			hl, bc
		ld			b, a
		ld			a, [hl]
		inc			hl
		add			a, a
		ld			a, [hl]
		adc			a, a							; A=X座標
		cp			a, b
		ld			bc, -4
		jp			nz, sprite_auto_move_next_pre

		inc			hl
		inc			hl
		inc			hl								; HL=モードのアドレス
		ld			[hl], 0
		inc			hl
		ld			[hl], 0
		ld			bc, -8
		jp			sprite_auto_move_next_pre

sprite_went_offscreen:
		add			hl, bc							; HL=属性のアドレス
		xor			a, a
		ld			[hl], a
		jp			sprite_auto_move_next
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
