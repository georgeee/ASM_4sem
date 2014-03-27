section     .text
    global      _print

_print :
    mov [reg_copy], ebx
    mov [reg_copy + 4], ebp
    mov [reg_copy + 8], edi
    mov [reg_copy + 12], esi
    
    mov eax, [esp + 12]
    mov [orig_input_str], eax
    call _read_number

    mov edi, [esp + 8]
    call _read_format
    
    mov edi, number
    call _print_raw10

    mov edi, [esp + 4]
    call _print_formated


    mov ebx, [reg_copy]
    mov ebp, [reg_copy + 4]
    mov edi, [reg_copy + 8]
    mov esi, [reg_copy + 12]

    ret

;assumes, that edx contains length ow raw10 string, edi - output buffer
_print_formated:
    mov ebp, [format]
    mov esi, sub_res

    test ebp, 0x1
    jz _pf_label1
    mov byte [edi], 45
    inc edi
    jmp _pf_label3
    
    _pf_label1:
    test ebp, 0x2
    jz _pf_label2
    mov byte [edi], 43
    inc edi
    jmp _pf_label3
    
    _pf_label2:
    test ebp, 0x10
    jz _pf_label3
    mov byte [edi], 32
    inc edi
    
    _pf_label3:
    test ebp, 0x20
    jz _pf_print_raw_10_label
    test ebp, 0x4
    jnz _pf_print_raw_10_label
    call _print_indent
    
    _pf_print_raw_10_label:
    xor ecx, ecx
    _loop4:
        mov ch, [esi]
        mov [edi], ch
        inc edi
        inc esi
        inc cl
        cmp dl, cl
        ja _loop4
    
    test ebp, 0x20
    jz _pf_label5
    test ebp, 0x4
    jz _pf_label5
    test ebp, 0x8
    jz _pf_label4
    xor ebp, 0x8
    _pf_label4:
    call _print_indent
    
    _pf_label5:
    mov byte [edi], 0
    
    ret

; takes result string string length (signed) from edx, format from ebp, edi - output buffer
_print_indent:
    mov eax, [width]
    test ebp, 0x1
    jnz _pi_label1
    test ebp, 0x2
    jnz _pi_label1
    test ebp, 0x10
    jnz _pi_label1
    jmp _pi_label2
    _pi_label1:
    sub eax, 1
    _pi_label2:
    sub eax, edx
    jna _print_indent_exit
    mov bl, 32
    test ebp, 0x8
    jz _pi_label3
    mov bl, 48
    _pi_label3:
    _loop5:
        mov [edi], bl
        dec eax
        inc edi
        test eax, eax
        ja _loop5
    _print_indent_exit:
    ret

; assumes that sign bit if the least in ebp, edi - address of format string
_read_format:
    _loop1:
        mov ah, [edi]
        inc edi

        cmp ah, 45
        jnz _loop1_case1_end
        or ebp, 0x4
        jmp _loop1
        _loop1_case1_end:
        
        cmp ah, 43
        jnz _loop1_case2_end
        or ebp, 0x2
        jmp _loop1
        _loop1_case2_end:
        
        cmp ah, 48
        jnz _loop1_case3_end
        or ebp, 0x8
        jmp _loop1
        _loop1_case3_end:
        
        cmp ah, 32 
        jnz _loop1_case4_end
        or ebp, 0x10
        jmp _loop1
        _loop1_case4_end:
        
        dec edi
    
    xor edx, edx
    xor eax, eax
    _width_loop:
        mov al, [edi]
        inc edi
        test al, al
        jz _width_loop_exit
        sub al, 48
        shl edx, 1
        lea edx, [edx+edx*4]
        add edx, eax
        jmp _width_loop
        _width_loop_exit:
    test edx, edx
    jz _rf_label1
    or ebp, 0x20
    mov [width], edx
    _rf_label1:
    mov [format], ebp

    ret

_print_raw10:
    mov edi, [number]
    mov [number_copy], edi
    mov edi, [number + 4]
    mov [number_copy + 4], edi
    mov edi, [number + 8]
    mov [number_copy + 8], edi
    mov edi, [number + 12]
    mov [number_copy + 12], edi
    mov edi, number_copy
    xor edx, edx
    mov ebx, 39
    bin_search_loop:
        mov ecx, ebx
        add ecx, edx
        shr ecx, 1
        mov esi, 38
        sub esi, ecx
        shl esi, 4
        add esi, pow10
        call _add
        js _pr_label1
        mov edx, ecx
        neg ecx
        add ecx, ebx
        jmp _pr_label2
        _pr_label1:
        mov ebx, ecx
        sub ecx, edx
        call _sub
        _pr_label2:
        cmp ecx, 1
        ja bin_search_loop

    mov edi, number
    ;edx - length of result number - 1
    mov ebx, sub_res
    mov esi, 38
    sub esi, edx
    shl esi, 4
    add esi, pow10
    xor cl, cl
    _loop2:
        xor ch, ch
        _loop3:
            inc ch
            call _add
            jns _loop3
        call _sub
        add ch, 47
        mov [ebx], ch
        inc ebx
        add esi, 16
        inc cl
        cmp dl, cl
        jnb _loop2
    inc edx
    ret
    

;reads number from orig_input_str into number
;uses all registers
;saves format in ebp
_read_number :
    mov dword [number], 0
    mov dword [number + 4], 0
    mov dword [number + 8], 0
    mov dword [number + 12], 0

    mov eax, [orig_input_str]
    xor edx, edx

    mov dl, [eax]
    cmp edx, 45
    jnz _rn_label1
    inc eax
    _rn_label1:
    mov ebp, eax

    _len_loop:
        inc eax
        mov dl, [eax]
        or dl, dl
        jnz _len_loop
    
    lea ebx, [number + 12]
    _parse_nums_loop:
        xor esi, esi
        xor edi, edi
        xor ecx, ecx
        _parse_nums_loop_inner:
            dec eax
            xor edx, edx
            mov dl, [eax]
            sub edx, 48
            cmp edx, 9
            jna _rn_label2
            sub edx, 7
            cmp edx, 15
            jna _rn_label2
            sub edx, 32
            _rn_label2:
            shl edx, cl
            add edi, edx
            add ecx, 4
            inc esi
            cmp eax, ebp
            je _rn_label3
            cmp esi, 8
            jb _parse_nums_loop_inner
        _rn_label3:
            mov dword [ebx], edi
            sub ebx, 4
            cmp eax, ebp
            jne _parse_nums_loop

    xor ebp, ebp
    cmp eax, [orig_input_str]
    je _rn_label4
    xor ebp, 0x1
    _rn_label4:

    test edi, 0x80000000
    jz _rn_label5
    xor ebp, 0x1
    mov edi, number
    call _negate
    _rn_label5:
    
    ret


;takes number pointer in edi register
;changes eax
_negate :
    not dword [edi]
    not dword [edi + 4]
    not dword [edi + 8]
    not dword [edi + 12]
    mov esi, num_one
    call _add
    ret

;takes number pointers in edi, esi registers
;changes eax
_add :
    mov eax, [edi + 12]
    add eax, [esi + 12]
    mov [edi + 12], eax
    mov eax, [edi + 8]
    adc eax, [esi + 8]
    mov [edi + 8], eax
    mov eax, [edi + 4]
    adc eax, [esi + 4]
    mov [edi + 4], eax
    mov eax, [edi]
    adc eax, [esi]
    mov [edi], eax
    ret

;takes number pointers in edi, esi registers
;changes eax, ebp
_sub :
    mov [sub_esi], esi
    mov eax, [esi]
    not eax
    mov [sub_number], eax
    mov eax, [esi + 4]
    not eax
    mov [sub_number + 4], eax
    mov eax, [esi + 8]
    not eax
    mov [sub_number + 8], eax
    mov eax, [esi + 12]
    not eax
    mov [sub_number + 12], eax
    mov ebp, edi
    mov edi, sub_number
    mov esi, num_one
    call _add
    mov edi, ebp
    mov esi, sub_number
    call _add
    mov esi, [sub_esi]
    ret


section .data
    number: resb 16
    reg_copy: resb 16
    sub_number: resb 16
    sub_esi: resb 4
    orig_input_str: resb 4
    format: resb 4
    width: resb 4
    number_copy: resb 4
    sub_res: resb 40

section     .rodata
    num_zero: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    num_one: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
    ; pow10 lower
   pow10: db 0x57, 0xB3, 0xC4, 0xB4, 0x85, 0x3B, 0x79, 0xA5, 0xC0, 0xDD, 0x75, 0xF6, 0x00, 0x00, 0x00, 0x00, 0xEF, 0x11, 0x7A, 0xF8, 0x26, 0xB9, 0x25, 0x2A, 0x60, 0xC9, 0x0B, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x31, 0x68, 0x3F, 0xFF, 0xEA, 0xF8, 0x36, 0x84, 0xF0, 0x60, 0xB4, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x9E, 0xBD, 0xEC, 0xFF, 0x7D, 0xB2, 0x38, 0x8D, 0x18, 0x70, 0x78, 0xD4, 0x00, 0x00, 0x00, 0x00, 0xF6, 0x12, 0xFE, 0xFF, 0x3F, 0x78, 0x52, 0x41, 0x9C, 0x71, 0x72, 0xC8, 0x00, 0x00, 0x00, 0x00, 0xB2, 0xCE, 0xFF, 0xFF, 0x6C, 0x72, 0xBB, 0x39, 0xF6, 0xA4, 0x3E, 0xC7, 0x00, 0x00, 0x00, 0x00, 0x11, 0xFB, 0xFF, 0xFF, 0xA4, 0xBE, 0x92, 0xD2, 0x7F, 0x10, 0x53, 0x7A, 0x00, 0x00, 0x00, 0x00, 0x81, 0xFF, 0xFF, 0xFF, 0xDD, 0xDF, 0x41, 0xC8, 0xD9, 0xB4, 0x6E, 0x3F, 0x00, 0x00, 0x00, 0x80, 0xF3, 0xFF, 0xFF, 0xFF, 0x2F, 0x63, 0xD3, 0x60, 0x15, 0x12, 0x8B, 0xB9, 0x00, 0x00, 0x00, 0xC0, 0xFE, 0xFF, 0xFF, 0xFF, 0x51, 0xF0, 0xE1, 0xBC, 0x35, 0xE8, 0x8D, 0x92, 0x00, 0x00, 0x00, 0x60, 0xFF, 0xFF, 0xFF, 0xFF, 0xA1, 0x31, 0xB0, 0xDF, 0x9E, 0xFD, 0xDA, 0xC1, 0x00, 0x00, 0x00, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xC3, 0xD1, 0xC4, 0xFC, 0xC3, 0x7F, 0x2F, 0x60, 0x00, 0x00, 0x00, 0x18, 0xFF, 0xFF, 0xFF, 0xFF, 0x2D, 0x48, 0xAD, 0xFF, 0x2D, 0xF3, 0x37, 0x23, 0x00, 0x00, 0x00, 0x1C, 0xFF, 0xFF, 0xFF, 0xFF, 0x6A, 0xBA, 0xF7, 0xFF, 0xB7, 0xFE, 0xEB, 0xE9, 0x00, 0x00, 0x00, 0xB6, 0xFF, 0xFF, 0xFF, 0xFF, 0x3D, 0x2C, 0xFF, 0xFF, 0x12, 0x33, 0x31, 0xE4, 0x00, 0x00, 0x00, 0x5F, 0xFF, 0xFF, 0xFF, 0xFF, 0xD2, 0xEA, 0xFF, 0xFF, 0xB5, 0x1E, 0x38, 0xFD, 0x00, 0x00, 0x80, 0x09, 0xFF, 0xFF, 0xFF, 0xFF, 0xE1, 0xFD, 0xFF, 0xFF, 0x45, 0x36, 0x1F, 0xE6, 0x00, 0x00, 0xC0, 0x4D, 0xFF, 0xFF, 0xFF, 0xFF, 0xC9, 0xFF, 0xFF, 0xFF, 0x3A, 0x52, 0x36, 0xCA, 0x00, 0x00, 0x60, 0x21, 0xFF, 0xFF, 0xFF, 0xFF, 0xFA, 0xFF, 0xFF, 0xFF, 0xD2, 0xA1, 0x38, 0x94, 0x00, 0x00, 0xF0, 0x9C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFB, 0xDC, 0x38, 0x75, 0x00, 0x00, 0x18, 0x76, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x4C, 0x49, 0x1F, 0xF2, 0x00, 0x00, 0x9C, 0x58, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x87, 0xBA, 0x9C, 0xFE, 0x00, 0x00, 0x76, 0xA2, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0D, 0x79, 0xDC, 0xFF, 0x00, 0x00, 0x3F, 0x90, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x81, 0x72, 0xFC, 0xFF, 0x00, 0x80, 0x39, 0x5B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0C, 0xA5, 0xFF, 0xFF, 0x00, 0xC0, 0x85, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xE7, 0xF6, 0xFF, 0xFF, 0x00, 0x60, 0x8D, 0xB1, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x17, 0xFF, 0xFF, 0xFF, 0x00, 0xF0, 0x5A, 0x2B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xE8, 0xFF, 0xFF, 0xFF, 0x00, 0x18, 0x89, 0xB7, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFD, 0xFF, 0xFF, 0xFF, 0x00, 0x1C, 0xF4, 0xAB, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x36, 0x65, 0xC4, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x1F, 0x0A, 0xFA, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x80, 0x69, 0x67, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xC0, 0xBD, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x60, 0x79, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xF0, 0xD8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x18, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x9C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xF6, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF