; ------------------------------------------------------------------------------
;	B-SUP (ビーサップ) VSYNC命令
; ==============================================================================
;	History		author		Description
;	2021/04/02	t.hara		Prototype
; ------------------------------------------------------------------------------

; ==============================================================================
;	V-Sync counter
; ==============================================================================
		scope		vsync_counter
vsync_counter::
		ld			e, [ix + work_vsync_count + 0]
		ld			d, [ix + work_vsync_count + 1]

		ld			a, e
		or			a, d
		ret			z

		dec			de
		ld			[ix + work_vsync_count + 0], e
		ld			[ix + work_vsync_count + 1], d
		ret
		endscope

; ==============================================================================
;	<count> を取得する
; ==============================================================================
		scope		get_count
get_count::
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
		cp			a, ')'
		jp			nz, syntax_error
		inc			hl

		pop			de
		ret
		endscope

; ==============================================================================
;	CALL VCST( <count> )
; ==============================================================================
		scope		call_vcst
call_vcst::
		call		get_count

		push		hl
		push		de
		call		activate_workarea

		ld			hl, work_vsync_count
		ld			e, ixl
		ld			d, ixh
		add			hl, de

		pop			de
		di
		ld			[hl], e
		inc			hl
		ld			[hl], d
		ei

		pop			hl
		jp			exit_call_statement
		endscope

; ==============================================================================
;	CALL VCWT( <count> )
; ==============================================================================
		scope		call_vcwt
call_vcwt::
		call		get_count

		push		hl
		push		de
		call		activate_workarea

		ld			hl, work_vsync_count
		ld			e, ixl
		ld			d, ixh
		add			hl, de

		pop			bc

wait_loop:
		; V-Sync counter を読み出す
		di
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		ei
		dec			hl
		ex			de, hl

		or			a, a
		sbc			hl, bc
		ex			de, hl

		jp			z, skip
		jp			nc, wait_loop
skip:
		pop			hl
		jp			exit_call_statement
		endscope
