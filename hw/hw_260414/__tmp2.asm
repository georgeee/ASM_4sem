section     .text
    global     _fdct 
    global     _idct 

_fdct:
    call _save_registers

    mov eax, [esp + 4]
    mov [args], eax
    mov eax, [esp + 8]
    mov [args + 4], eax
    mov eax, [esp + 12]
    mov [args + 8], eax

    mov dword [block_offset], 0
    mov dword [block_counter], 0
    _fdct_block_loop:
        mov edi, [args]
        mov ebx, [block_offset]
        lea edi, [edi + ebx]

        ;changes: ecx edx ebx eax
        xor edx, edx
        xor ebx, ebx
        _fdct_1d_1_per_col_loop:
            xor ecx, ecx
            xor eax, eax
            _fdct_1d_1_per_row_loop:

                ;start of 1d real implementation
            
                movaps xmm1, [edi + eax]
                movaps xmm2, [edi + eax + 16]
                mulps xmm1, [cosines + ebx]
                mulps xmm2, [cosines + ebx + 16]
            
                addps xmm1, xmm2
                shufps xmm2, xmm1, 0x40
                addps xmm1, xmm2
                shufps xmm2, xmm1, 0xB0
                addps xmm1, xmm2
                shufps xmm1, xmm1, 0x3

                movss xmm0, xmm1
                shufps xmm0, xmm0, 0x39

                ;end of 1d real implementation

                cmp ecx, 3
                jne _fdct_1d_1_per_row_loop_label1
                    movaps [matrix_buffer + ebx], xmm0
                _fdct_1d_1_per_row_loop_label1:

                cmp ecx, 7
                jne _fdct_1d_1_per_row_loop_label2
                    movaps [matrix_buffer + ebx + 16], xmm0
                _fdct_1d_1_per_row_loop_label2:

                inc ecx
                lea eax, [eax + 32]
                cmp ecx, 8
                jb _fdct_1d_1_per_row_loop
            inc edx
            lea ebx, [ebx + 32]
            cmp edx, 8
            jb _fdct_1d_1_per_col_loop

        mov esi, [args + 4]
        mov ebx, [block_offset]
        lea esi, [esi + ebx]

        ;changes: ecx edx ebx eax
        
        xor ecx, ecx
        xor eax, eax
        _fdct_1d_2_per_row_loop:
            xor edx, edx
            xor ebx, ebx
            _fdct_1d_2_per_col_loop:

                ;start of 1d real implementation

                movaps xmm1, [matrix_buffer + ebx]
                movaps xmm2, [matrix_buffer + ebx + 16]
                mulps xmm1, [cosines + eax]
                mulps xmm2, [cosines + eax + 16]
                
                addps xmm1, xmm2
                shufps xmm2, xmm1, 0x40
                addps xmm1, xmm2
                shufps xmm2, xmm1, 0xB0
                addps xmm1, xmm2
                shufps xmm1, xmm1, 0x3

                add esi, eax
                movss [esi + edx*4], xmm1
                sub esi, eax

                ;end of 1d real implementation

                inc edx
                lea ebx, [ebx + 32]
                cmp edx, 8
                jb _fdct_1d_2_per_col_loop
            inc ecx
            lea eax, [eax + 32]
            cmp ecx, 8
            jb _fdct_1d_2_per_row_loop

        xor edx, edx
        mov edi, coefs
        _fdct_coef_loop:
            movaps xmm0, [esi]
            mulps xmm0, [edi]
            movaps [esi], xmm0
            inc edx
            lea esi, [esi + 16]
            lea edi, [edi + 16]
            cmp edx, 16
            jb _fdct_coef_loop
        
        mov edx, [args + 8]
        mov ebx, [block_offset]
        lea ebx, [ebx + 256]
        mov [block_offset], ebx
        mov ebx, [block_counter]
        inc ebx
        mov [block_counter], ebx
        cmp edx, ebx
        ja _fdct_block_loop
    
    call _restore_registers
    ret

_idct:
    call _save_registers

    mov ebp, 2

    mov eax, [esp + 4]
    mov [args], eax
    mov eax, [esp + 8]
    mov [args + 4], eax
    mov eax, [esp + 12]
    mov [args + 8], eax

    call dct_impl
    
    call _restore_registers
    ret

dct_impl:
    mov dword [block_offset], 0
    mov dword [block_counter], 0
    dct_impl_block_loop:
        mov edi, [args]
        mov ebx, [block_offset]
        lea edi, [edi + ebx]
        mov esi, matrix_buffer
        ;changes: ecx edx ebx eax
        call fdct_impl_1d

        mov edi, matrix_buffer
        mov esi, [args + 4]
        mov ebx, [block_offset]
        lea esi, [esi + ebx]
        or ebp, 1
        ;changes: ecx edx ebx eax
        call fdct_impl_1d

        test ebp, 2
        jnz dct_impl_label1
        xor edx, edx
        mov edi, coefs
        dct_impl_coef_loop:
            movaps xmm0, [esi]
            mulps xmm0, [edi]
            movaps [esi], xmm0
            inc edx
            lea esi, [esi + 16]
            lea edi, [edi + 16]
            cmp edx, 16
            jb dct_impl_coef_loop
        dct_impl_label1:
        
        mov edx, [args + 8]
        mov ebx, [block_offset]
        lea ebx, [ebx + 256]
        mov [block_offset], ebx
        mov ebx, [block_counter]
        inc ebx
        mov [block_counter], ebx
        cmp edx, ebx
        ja dct_impl_block_loop
    ret

_restore_registers:
    mov ebx, [reg_copy]
    mov ebp, [reg_copy + 4]
    mov edi, [reg_copy + 8]
    mov esi, [reg_copy + 12]
    ret

_save_registers:
    mov [reg_copy], ebx
    mov [reg_copy + 4], ebp
    mov [reg_copy + 8], edi
    mov [reg_copy + 12], esi
    ret

;args: edi = float* in
;args: esi = float* out
;args: ebp = mode (first bit - first/second phase, second bit - direct/inverse dct
;changes: ecx edx ebx eax
fdct_impl_1d:
    xor ecx, ecx
    xor eax, eax
    fdct_impl_1d_per_row_loop:
        xor edx, edx
        xor ebx, ebx
        fdct_impl_1d_per_col_loop:

            ;start of 1d real implementation

            test ebp, 1
            jz fdct_impl_1d_label1
                movaps xmm1, [edi + ebx]
                movaps xmm2, [edi + ebx + 16]
                test ebp, 2
                jz fdct_impl_1d_label5
                    mulps xmm1, [cosines2 + eax]
                    mulps xmm2, [cosines2 + eax + 16]
                jmp fdct_impl_1d_label6
                fdct_impl_1d_label5:
                    mulps xmm1, [cosines + eax]
                    mulps xmm2, [cosines + eax + 16]
                fdct_impl_1d_label6:
            jmp fdct_impl_1d_label2
            fdct_impl_1d_label1:
                movaps xmm1, [edi + eax]
                movaps xmm2, [edi + eax + 16]
                test ebp, 2
                jz fdct_impl_1d_label7
                    mulps xmm1, [cosines2 + ebx]
                    mulps xmm2, [cosines2 + ebx + 16]
                jmp fdct_impl_1d_label8
                fdct_impl_1d_label7:
                    mulps xmm1, [cosines + ebx]
                    mulps xmm2, [cosines + ebx + 16]
                fdct_impl_1d_label8:
            fdct_impl_1d_label2:
            
            addps xmm1, xmm2
            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2
            shufps xmm2, xmm1, 0xB0
            addps xmm1, xmm2
            shufps xmm1, xmm1, 0xB

            test ebp, 1
            jz fdct_impl_1d_label3
                add esi, eax
                movss [esi + edx*4], xmm1
                sub esi, eax
            jmp fdct_impl_1d_label4
            fdct_impl_1d_label3:
                add esi, ebx
                movss [esi + ecx*4], xmm1
                sub esi, ebx
            fdct_impl_1d_label4:

            ;end of 1d real implementation

            inc edx
            lea ebx, [ebx + 32]
            cmp edx, 8
            jb fdct_impl_1d_per_col_loop
        inc ecx
        lea eax, [eax + 32]
        cmp ecx, 8
        jb fdct_impl_1d_per_row_loop
    ret

    
section .rodata
    align 16
    cosines dd 0x3F800000, 0x3F800000, 0x3F800000, 0x3F800000, 0x3F800000, 0x3F800000, 0x3F800000, 0x3F800000, 0x3F7B14BE, 0x3F54DB31, 0x3F0E39D9, 0x3E47C5BC, 0xBE47C5C2, 0xBF0E39DC, 0xBF54DB32, 0xBF7B14BF, 0x3F6C835F, 0x3EC3EF15, 0xBEC3EF18, 0xBF6C835F, 0xBF6C835F, 0xBEC3EF0B, 0x3EC3EF1B, 0x3F6C835F, 0x3F54DB31, 0xBE47C5C2, 0xBF7B14BF, 0xBF0E39D6, 0x3F0E39D7, 0x3F7B14BE, 0x3E47C5D0, 0xBF54DB34, 0x3F3504F3, 0xBF3504F3, 0xBF3504F1, 0x3F3504F7, 0x3F3504F3, 0xBF3504FB, 0xBF3504EF, 0x3F3504F4, 0x3F0E39D9, 0xBF7B14BF, 0x3E47C5C8, 0x3F54DB2D, 0xBF54DB34, 0xBE47C5BB, 0x3F7B14BC, 0xBF0E39E4, 0x3EC3EF15, 0xBF6C835F, 0x3F6C835F, 0xBEC3EF25, 0xBEC3EF23, 0x3F6C835B, 0xBF6C835C, 0x3EC3EF25, 0x3E47C5BC, 0xBF0E39D6, 0x3F54DB2D, 0xBF7B14BD, 0x3F7B14C1, 0xBF54DB3A, 0x3F0E39E9, 0xBE47C614
    align 16
    coefs dd 0x3C800000, 0x3CB504F3, 0x3CB504F3, 0x3CB504F3, 0x3CB504F3, 0x3CB504F3, 0x3CB504F3, 0x3CB504F3, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3CB504F3, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000, 0x3D000000
    align 16
    cosines2 dd 0x3F800000, 0x3FB18A85, 0x3FA73D75, 0x3F968317, 0x3F7FFFFF, 0x3F49234D, 0x3F0A8BD4, 0x3E8D42AB, 0x3F800000, 0x3F968317, 0x3F0A8BD4, 0xBE8D42AF, 0xBF7FFFFF, 0xBFB18A86, 0xBFA73D75, 0xBF492348, 0x3F800000, 0x3F49234D, 0xBF0A8BD6, 0xBFB18A86, 0xBF7FFFFD, 0x3E8D42B3, 0x3FA73D75, 0x3F968314, 0x3F800000, 0x3E8D42AB, 0xBFA73D75, 0xBF492348, 0x3F800003, 0x3F968314, 0xBF0A8BDF, 0xBFB18A84, 0x3F800000, 0xBE8D42AF, 0xBFA73D75, 0x3F49234A, 0x3F7FFFFF, 0xBF968319, 0xBF0A8BDD, 0x3FB18A87, 0x3F800000, 0xBF492351, 0xBF0A8BCC, 0x3FB18A85, 0xBF800005, 0xBE8D42AA, 0x3FA73D72, 0xBF96831D, 0x3F800000, 0xBF968318, 0x3F0A8BD8, 0x3E8D42B9, 0xBF7FFFFA, 0x3FB18A84, 0xBFA73D73, 0x3F492363, 0x3F800000, 0xBFB18A86, 0x3FA73D75, 0xBF968319, 0x3F800000, 0xBF49235C, 0x3F0A8BDF, 0xBE8D42E9



section .data
    reg_copy: resb 16
    align 16
    matrix_buffer: resd 64
    block_offset: resd 1
    block_counter: resd 1
    args: resd 3
    

