; --------------------------------------------------------------------
;	SLTWRK routine
; ====================================================================
;	History			Author		Description
;	Feb/27th/2021	t.hara		1st release
; --------------------------------------------------------------------

; --------------------------------------------------------------------
;	Get page1 slot
;	input)
;		N/A
;	output)
;		A ... SLOT# (ENASLT format)
;	break)
;		AF, BC, HL
; --------------------------------------------------------------------
		scope		get_p1_slot
get_p1_slot::
		in			a, [0xA8]
		ld			c, a
		and			a, 0x0C			; A=0000BB00
		rrca
		rrca
		ld			b, a			; B=000000BB
		add			a, 0xC1
		ld			l, a
		ld			h, 0xFC
		ld			a, [hl]
		and			a, 0x80
		ld			a, b
		ret			z				; If it was a base slot, exit here.

		rrca
		rrca
		ld			l, a			; L=BB000000
		ld			a, c
		and			a, 0x3F
		or			a, l
		di
		out			[0xA8], a		; Page3 changes to page1 slot.
		ld			a, [0xFFFF]
		ld			l, a
		ld			a, c
		out			[0xA8], a		; Restore base slot register.
		ei

		ld			a, l
		cpl							; A=xxxxEExx
		and			a, 0x0C			; A=0000EE00
		or			a, b			; A=0000EEBB
		or			a, 0x80			; A=1000EEBB
		ret
		endscope

; --------------------------------------------------------------------
;	Get page2 slot
;	input)
;		N/A
;	output)
;		A ... SLOT# (ENASLT format)
;	break)
;		AF, BC, HL
; --------------------------------------------------------------------
		scope		get_p2_slot
get_p2_slot::
		in			a, [0xA8]
		ld			c, a
		and			a, 0x30			; A=00BB0000
		rrca
		rrca
		rrca
		rrca
		ld			b, a			; A=000000BB
		add			a, 0xC1
		ld			l, a
		ld			h, 0xFC
		ld			a, [hl]
		or			a, a
		ld			a, b
		ret			p				; If it was a base slot, exit here.

		rrca
		rrca
		ld			l, a			; L=BB000000
		ld			a, c
		and			a, 0x3F
		or			a, l
		di
		out			[0xA8], a		; Page3 changes to page2 slot.
		ld			a, [0xFFFF]
		ld			l, a
		ld			a, c
		out			[0xA8], a		; Restore base slot register.
		ei

		ld			a, l
		cpl							; A=xxEExxxx
		rrca
		rrca
		and			a, 0x0C			; A=0000EE00
		or			a, b			; A=0000EEBB
		or			a, 0x80			; A=1000EEBB
		ret
		endscope

; --------------------------------------------------------------------
;	Set page2 slot
;	input)
;		A ... SLOT# (ENASLT format)
;	output)
;		N/A
;	break)
;		AF, BC, D
;	comment)
;		DI
; --------------------------------------------------------------------
		scope		set_p2_slot
set_p2_slot::
		or			a, a
		jp			m, extended_slot
		; 基本スロットの場合
		and			a, 0x03			; A=000000BB
		rrca
		rrca
		rrca
		rrca
		ld			c, a			; A=00BB0000
		in			a, [0xA8]
		and			a, 0xCF
		or			a, c
		di
		out			[0xA8], a
		ret

		; 拡張スロットの場合
extended_slot:
		ld			b, a			; B=1000EEBB
		rrca
		rrca
		and			a, 0xC0
		ld			c, a			; C=BB000000
		rrca
		rrca
		or			a, c
		ld			c, a			; C=BBBB0000
		in			a, [0xA8]
		ld			d, a			; D=現在の基本スロット状態
		and			a, 0x0F
		or			a, c			; A=BBBBbbbb

		di
		out			[0xA8], a
		and			a, 0x3F
		ld			c, a
		ld			a, d
		and			a, 0xC0
		or			a, c
		ld			c, a			; C=bbBBbbbb

		ld			a, b
		rlca
		rlca
		and			a, 0x30
		ld			b, a

		ld			a, [0xFFFF]
		cpl
		and			a, 0xCF
		or			a, b
		ld			[0xFFFF], a

		ld			a, c
		out			[0xA8], a
		ret
		endscope

; --------------------------------------------------------------------
;	Get SLTWRK
;	input)
;		A ... SLOT# (ENASLT format)
;	output)
;		HL .. SLTWRK address
;	break)
;		AF
; --------------------------------------------------------------------
		scope		get_sltwrk
get_sltwrk::
		and			a, 0x0F			; A=0000EEBB : E=ExtSlot, B=BaseSlot
		ld			l, a
		and			a, 0x03			; A=000000BB
		add			a, a
		add			a, a
		add			a, a
		add			a, a			; A=00BB0000
		or			a, l			; A=00BBEEBB
		and			a, 0x3C			; A=00BBEE00
		add			a, a			; A=0BBEE000
		add			a, 0x09
		ld			l, a
		ld			h, 0xFD
		ret
		endscope

; --------------------------------------------------------------------
;	Check RAM
;	input)
;		N/A
;	output)
;		Zf .... 0: ROM, 1: RAM
;	break)
;		AF
; --------------------------------------------------------------------
		scope		check_ram
check_ram::
		push		hl
		ld			hl, 0x4000
		ld			a, [hl]
		cpl
		ld			[hl], a
		cp			a, [hl]
		cpl
		ld			[hl], a
		pop			hl
		ret
		endscope

; --------------------------------------------------------------------
;	Activate workarea
;	input)
;		N/A
;	output)
;		IX ... ワークエリアのアドレス
;	break)
;		AF, BC, DE, HL
;	comment)
;		Page2 をワークエリアの SLOT に変更する
; --------------------------------------------------------------------
		scope		activate_workarea
activate_workarea::
		call		check_ram
		ld			ix, 0x8000 - work_area_size
		ret			z								; RAMの場合、Page2を切り替える必要は無い。このまま抜ける。

		; ROMの場合
		call		get_p1_slot
		call		get_sltwrk
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		ld			ixl, e
		ld			ixh, d							; IX = workarea address

		push		hl
		call		get_p2_slot
		pop			hl

		ld			de, 6
		add			hl, de

		ld			e, a

		ld			a, [hl]
		call		set_p2_slot						; Page2 を RAM に切り替える。Eレジスタは非破壊
		ld			[ix + work_save_p2_slot], e
		ret
		endscope

; --------------------------------------------------------------------
;	Restore page2 slot
;	input)
;		IX ... ワークエリアのアドレス
;	output)
;		N/A
;	break)
;		AF, BC, DE, HL
;	comment)
;		Page2 を元に戻す
; --------------------------------------------------------------------
		scope		restore_p2_slot
restore_p2_slot::
		call		check_ram
		ret			z

		ld			a, [ix + work_save_p2_slot]
		jp			set_p2_slot
		endscope
