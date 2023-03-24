; ------------------------------------------------------------------------------
;	B-SUP (ビーサップ)
; ==============================================================================
;	History		author		Description
;	2021/02/19	t.hara		Prototype
; ------------------------------------------------------------------------------

		include		"MSXBIOS.ASM"
		include		"WORKAREA.ASM"

		org			0x4000
; ==============================================================================
;	ROM Header
; ==============================================================================
rom_header_id:
		ds			"AB"
rom_header_init:
		dw			init_code
rom_header_statement:
		dw			call_statement_entry
rom_header_device:
		dw			0
rom_header_text:
		dw			0
rom_header_reserved:
		space		0x0010 - 0x000A, 0

; ==============================================================================
;	Initializer
; ==============================================================================
		scope		init_code
init_code::
		; Is this code on the RAM?
		call		check_ram
		jp			z, this_is_on_the_ram

this_is_on_the_rom:
		call		get_p1_slot			; DEは破壊しない
		push		af					; page1 SLOT# を保存
		call		get_sltwrk			; HL = SLTWRK, DEは破壊しない

		ld			a, [hl]				; INITが複数回呼ばれた場合に2回目以降は何もしない
		inc			hl
		or			a, [hl]
		ret			nz
		dec			hl

		push		hl					; SLTWRK を保存
		ld			hl, [bottom]
		push		hl					; work area address を保存
		ld			de, work_area_size
		add			hl, de
		ld			[bottom], hl
		pop			de					; work area address を復元
		pop			hl					; SLTWRK を復元

		ld			[hl], e				; SLTWORK[0:1] = work area address
		inc			hl
		ld			[hl], d
		inc			hl
		push		de					; work area address を保存
		; H.TIMI を SLTWRK にバックアップする
		call		backup_h_timi		; SLTWORK[2:6] = H.TIMI backup
		push		hl					; SLTWORK + 7 を保存
		call		get_p2_slot
		pop			hl					; SLTWORK + 7 を復元
		ld			[hl], a				; SLOT_WORK[7] = page2 RAM SLOT#

		pop			ix					; work area address を復元
		call		initialize_workarea

		; H.TIMI をフックする
		ld			hl, new_h_timi
		ld			de, h_timi
		ld			bc, 5
		pop			af					; page1 SLOT# を復元
		di
		ldir
		ld			[h_timi + 1], a		; write page1 SLOT# to interslot call in H.TIMI.
		ld			hl, interval_timer_proc_for_rom
		ld			[h_timi + 2], hl
		ei
		ret

this_is_on_the_ram:
		ld			ix, 0x8000 - work_area_size
		call		initialize_workarea

		; H.TIMI をバックアップする
		ld			hl, 0x8000 - work_area_size - h_timi_backup_size
		call		backup_h_timi

		; H.TIMI をフックする

		call		get_p1_slot

		ld			hl, new_h_timi
		ld			de, h_timi
		ld			bc, 5
		di
		ldir
		ld			[h_timi + 1], a		; write page1 SLOT# to interslot call in H.TIMI.
		ld			hl, interval_timer_proc_for_ram
		ld			[h_timi + 2], hl
		ei
		ret
		endscope

; ==============================================================================
;	Initialize workarea
;	input)
;		HL .... workarea top address
;	output)
;		N/A
;	break)
;		AF, BC, DE, HL
; ==============================================================================
		scope		initialize_workarea
initialize_workarea::
		call		get_p1_slot
		ld			[ix + work_p1_slot], a
		call		get_p2_slot
		ld			[ix + work_p2_slot], a
		xor			a, a
		ld			[ix + work_vsync_count + 0], a
		ld			[ix + work_vsync_count + 1], a
		ld			[ix + work_1st_sprite], a
		ld			[ix + work_sprite_drive_on], a

		; Clear sprite information area
		push		ix
		pop			hl
		ld			de, work_sprite_info
		add			hl, de
		ld			[hl], 0
		ld			e, l
		ld			d, h
		inc			de
		ld			bc, size_sprite_info - 1
		ldir
		ret
		endscope

; ==============================================================================
;	Copy the H.TIMI to backup area
;	input)
;		HL ... backup area address
;	output)
;		HL ... HL+5
;	break)
;		BC
; ==============================================================================
		scope		backup_h_timi
backup_h_timi::
		ld			bc, [h_timi + 0]
		ld			[hl], c
		inc			hl
		ld			[hl], b
		inc			hl
		ld			bc, [h_timi + 2]
		ld			[hl], c
		inc			hl
		ld			[hl], b
		inc			hl
		ld			bc, [h_timi + 4]
		ld			[hl], c
		inc			hl
		ret
		endscope

; ==============================================================================
;	CALL statement entry
; ==============================================================================
		scope		call_statement_entry
call_statement_entry::
		push		hl
		ld			de, command_jump_table

search_command_loop:
		ld			hl, procnm
		ld			a, [de]
		or			a, a					; Is this terminator?
		jp			z, no_match
		inc			de
		cp			a, [hl]
		jp			nz, search_next_command
		inc			hl

		ld			a, [de]
		inc			de
		cp			a, [hl]
		jp			nz, search_next_command
		inc			hl

		ld			a, [de]
		inc			de
		cp			a, [hl]
		jp			nz, search_next_command
		inc			hl

		ld			a, [de]
		inc			de
		cp			a, [hl]
		jp			nz, search_next_command
		inc			hl

		ld			a, [hl]
		or			a, a
		jp			nz, search_next_command

		ex			de, hl
		ld			e, [hl]
		inc			hl
		ld			d, [hl]

		pop			hl

		push		de
		ret

exit_call_statement::
		or			a, a					; The command was processed.
		ret

search_next_command:
		ld			a, e
		and			a, 0xF8
		ld			e, a
		ld			hl, 8
		add			hl, de
		ex			de, hl
		jp			search_command_loop

no_match:
		pop			hl
		scf									; This is not supported command.
		ret
		endscope

; ==============================================================================
;	CALL SC15
; ==============================================================================
		scope		call_sc15
call_sc15::
		push		hl
		call		inigrp

		ld			a, 1
		ld			[scrmod], a

		ld			a, 32
		ld			[linl32], a
		ld			[linlen], a

		ld			a, ' '
		ld			hl, 0x1800
		ld			bc, 0x300
		call		bsup_filvrm

		ld			hl, [0x0004]			; get ROM font address
		ld			de, 0x0000
		ld			bc, 0x800 - 8
		call		bsup_ldirvm

		ld			hl, [0x0004]			; get ROM font address
		ld			de, 0x0800
		ld			bc, 0x800 - 8
		call		bsup_ldirvm

		ld			hl, [0x0004]			; get ROM font address
		ld			de, 0x1000
		ld			bc, 0x800 - 8
		call		bsup_ldirvm

		ld			hl, 0x1000 - 8
		ld			bc, 8
		ld			a, 0xFF
		call		bsup_filvrm

		ld			hl, 0x1800 - 8
		ld			bc, 8
		ld			a, 0xFF
		call		bsup_filvrm

		ld			a, [forclr]
		add			a, a
		add			a, a
		add			a, a
		add			a, a
		ld			b, a
		ld			a, [bakclr]
		or			a, b
		ld			hl, 0x2000
		ld			bc, 0x1800
		call		bsup_filvrm
		pop			hl
		jp			exit_call_statement
		endscope

; ==============================================================================
;	Syntax error
; ==============================================================================
		scope		syntax_error
syntax_error::
		ld			e, 2
		ld			ix, calbas_errhand
		jp			calbas
		endscope

; ==============================================================================
;	illegal function call
; ==============================================================================
		scope		illegal_function_call_error
illegal_function_call_error::
		ld			e, 5
		ld			ix, calbas_errhand
		jp			calbas
		endscope

; ==============================================================================
;	type mismatch
; ==============================================================================
		scope		type_mismatch_error
type_mismatch_error::
		ld			e, 13
		ld			ix, calbas_errhand
		jp			calbas
		endscope

; ==============================================================================
;	INTERVAL TIMER PROCEDURE for ROM
; ==============================================================================
		scope		interval_timer_proc_for_rom
interval_timer_proc_for_rom::

		; SLTWRK から workarea のアドレスを取得して IX に格納する
		call		get_p1_slot
		call		get_sltwrk
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		inc			hl

		push		hl				; 前の H.TIMI のアドレス

		; IX = work area address
		ld			ixl, e
		ld			ixh, d

		ld			de, 5
		add			hl, de
		ld			d, [hl]

		; 現在の page2 SLOT# を保存する
		call		get_p2_slot
		push		af

		; page2 SLOT# を RAM の SLOT# に変更する
		ld			a, d
		call		set_p2_slot

		pop			af
		ld			[ix + work_current_p2_slot], a

		call		interval_timer_proc

		; page2 SLOT# を元に戻す
		ld			a, [ix + work_current_p2_slot]
		call		set_p2_slot

		; 前の H.TIMI hook へジャンプ
		pop			hl
		jp			hl
		endscope

; ==============================================================================
;	INTERVAL TIMER PROCEDURE for RAM
; ==============================================================================
		scope		interval_timer_proc_for_ram
interval_timer_proc_for_ram::
		; workarea のアドレスを IX に格納する
		ld			ix, 0x8000 - work_area_size
		call		interval_timer_proc

		; 前の H.TIMI hook へジャンプ
		ld			hl, 0x8000 - work_area_size - h_timi_backup_size
		jp			hl
		endscope

; ==============================================================================
;	INTERVAL TIMER PROCEDURE
;	input)
;		IX .... work area address
;	output)
;		IX .... work area address (inputの値そのまま)
;	break)
;		AF, BC, DE, HL
; ==============================================================================
		scope		interval_timer_proc
interval_timer_proc::
		call		vsync_counter
		call		sprite_driver
		ret
		endscope

; ==============================================================================
;	H.TIMI
; ==============================================================================
		scope		new_h_timi
new_h_timi::
		rst			0x30
		db			0
		dw			interval_timer_proc_for_ram
		ret
		endscope

; ==============================================================================
;	SUB ROUTINES
; ==============================================================================
		include		"SLTWRK.ASM"
		include		"VRAM.ASM"
		include		"NAMETBL.ASM"
		include		"PCG.ASM"
		include		"SPRITE.ASM"
		include		"VSYNC.ASM"

; ==============================================================================
;	Jump Table (ATTENSION!!: s_cmmand must be sorted)
; ==============================================================================
command_jump_table_item		macro	s_command, address
		ds			s_command			; Must be set 4 characters.
		dw			address
		dw			0					; Reserved
		endm

command_jump_table_itemb	macro	s_command0, s_command1, s_command2, s_command3, address
		db			s_command0			; Must be set 4 characters.
		db			s_command1			; Must be set 4 characters.
		db			s_command2			; Must be set 4 characters.
		db			s_command3			; Must be set 4 characters.
		dw			address
		dw			0					; Reserved
		endm

		align		8
command_jump_table::
		command_jump_table_item		"SPUT", call_sput
		command_jump_table_item		"SLNK", call_slnk
		command_jump_table_item		"SMOV", call_smov
		command_jump_table_item		"SEPT", call_sept
		command_jump_table_item		"SSEE", call_ssee
		command_jump_table_item		"BPUT", call_bput
		command_jump_table_item		"BCPY", call_bcpy
		command_jump_table_item		"BFIL", call_bfil
		command_jump_table_item		"VFIL", call_vfil
		command_jump_table_item		"PCG0", call_pcg0
		command_jump_table_item		"PCG1", call_pcg1
		command_jump_table_item		"PCG2", call_pcg2
		command_jump_table_item		"PCG3", call_pcg3
		command_jump_table_item		"COL0", call_col0
		command_jump_table_item		"COL1", call_col1
		command_jump_table_item		"COL2", call_col2
		command_jump_table_item		"COL3", call_col3
		command_jump_table_item		"BCLS", call_bcls
		command_jump_table_item		"VCST", call_vcst
		command_jump_table_item		"VCWT", call_vcwt
		command_jump_table_item		"BFNT", call_bfnt
		command_jump_table_item		"SSTP", call_sstp
		command_jump_table_item		"SDRV", call_sdrv
		command_jump_table_item		"SC15", call_sc15
		db			0					; Terminator

		align		16384
