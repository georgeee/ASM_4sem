section .data
    number: resb 16
    reg_copy: resb 16
    orig_input_str: resb 4
section     .text
    global      _print

_print :
    mov [reg_copy], ebx
    mov [reg_copy + 4], ebp
    mov [reg_copy + 8], edi
    mov [reg_copy + 12], esi

    xor esi, esi
    not esi
    
    mov eax, [esp + 12]
    mov [orig_input_str], eax
    call _read_number

    test ebp, 0x1
    jz _label6
    mov edi, number
    call _negate
    _label6:
    
    mov edx, [esp + 4]

    mov eax, [number + 12]
    mov [edx + 12], eax
    mov eax, [number + 8]
    mov [edx + 8], eax
    mov eax, [number + 4]
    mov [edx + 4], eax
    mov eax, [number]
    mov [edx], eax

    mov ebx, [reg_copy]
    mov ebp, [reg_copy + 4]
    mov edi, [reg_copy + 8]
    mov esi, [reg_copy + 12]

    ret

;reads number from orig_input_str into number
;uses all registers
;saves flags in ebp
_read_number :
    mov dword [number], 0
    mov dword [number + 4], 0
    mov dword [number + 8], 0
    mov dword [number + 12], 0

    mov eax, [orig_input_str]
    xor edx, edx

    mov dl, [eax]
    cmp edx, 45
    jnz _label1
    inc eax
    _label1:
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
            jna _label2
            sub edx, 7
            cmp edx, 15
            jna _label2
            sub edx, 32
            _label2:
            shl edx, cl
            add edi, edx
            add ecx, 4
            inc esi
            cmp eax, ebp
            je _label3
            cmp esi, 8
            jb _parse_nums_loop_inner
        _label3:
            mov dword [ebx], edi
            sub ebx, 4
            cmp eax, ebp
            jne _parse_nums_loop

    mov ebp, number
    xor ebp, ebp
    cmp eax, [orig_input_str]
    je _label4
    xor ebp, 0x1
    _label4:

    test edi, 0x80000000
    jz _label5
    xor ebp, 0x1
    mov edi, number
    call _negate
    _label5:
    
    ret


;takes number pointer in edi register
;uses edi, esi, eax
_negate :
    not dword [edi]
    not dword [edi + 4]
    not dword [edi + 8]
    not dword [edi + 12]
    mov esi, num_one
    call _add
    ret

;takes number pointers in edi, esi registers
;uses edi, esi, eax
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
;uses edi, esi, eax, edx
_sub :
    mov edx, edi
    mov edi, esi
    call _negate
    mov esi, edi
    mov edi, edx
    call _add
    ret


section     .rodata
    num_zero: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    num_one: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
