section     .text
    global     _fdct 
    global     _idct 

_fdct:
    call _save_registers

    mov edi, [esp + 4]
    mov esi, [esp + 8]
    mov ebp, [esp + 12]

    xor ebx, ebx
    _fdct_block_loop:
        xor ecx, ecx
        xor eax, eax
        _fdct_1d_1_per_col_loop:
            ;start of 1d real implementation
            movaps xmm6, [cosines + eax]
            movaps xmm7, [cosines + eax + 16]
        
            movaps xmm1, [edi + 0]
            movaps xmm2, [edi + 0 + 16]
            movaps xmm3, [edi + 32]
            movaps xmm4, [edi + 32 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [edi + 64]
            movaps xmm2, [edi + 64 + 16]
            movaps xmm3, [edi + 96]
            movaps xmm4, [edi + 96 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
                
            movaps [matrix_buffer + eax], xmm0
        
            movaps xmm1, [edi + 128]
            movaps xmm2, [edi + 128 + 16]
            movaps xmm3, [edi + 160]
            movaps xmm4, [edi + 160 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [edi + 192]
            movaps xmm2, [edi + 192 + 16]
            movaps xmm3, [edi + 224]
            movaps xmm4, [edi + 224 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
        
            movaps [matrix_buffer + eax + 16], xmm0

            ;end of 1d real implementation

            inc ecx
            lea eax, [eax + 32]
            cmp ecx, 8
            jb _fdct_1d_1_per_col_loop

        xor ecx, ecx
        xor eax, eax
        _fdct_1d_2_per_row_loop:
            movaps xmm6, [cosines + eax]
            movaps xmm7, [cosines + eax + 16]

            movaps xmm1, [matrix_buffer + 0]
            movaps xmm2, [matrix_buffer + 0 + 16]
            movaps xmm3, [matrix_buffer + 32]
            movaps xmm4, [matrix_buffer + 32 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [matrix_buffer + 64]
            movaps xmm2, [matrix_buffer + 64 + 16]
            movaps xmm3, [matrix_buffer + 96]
            movaps xmm4, [matrix_buffer + 96 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
                
            mulps xmm0, [coefs + eax]
            movaps [esi + eax], xmm0
        
            movaps xmm1, [matrix_buffer + 128]
            movaps xmm2, [matrix_buffer + 128 + 16]
            movaps xmm3, [matrix_buffer + 160]
            movaps xmm4, [matrix_buffer + 160 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [matrix_buffer + 192]
            movaps xmm2, [matrix_buffer + 192 + 16]
            movaps xmm3, [matrix_buffer + 224]
            movaps xmm4, [matrix_buffer + 224 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
        
            mulps xmm0, [coefs + eax + 16]
            movaps [esi + eax + 16], xmm0

            ;end of 1d real implementation
            
            inc ecx
            lea eax, [eax + 32]
            cmp ecx, 8
            jb _fdct_1d_2_per_row_loop
        
        lea edi, [edi + 256]
        lea esi, [esi + 256]
        inc ebx
        cmp ebp, ebx
        ja _fdct_block_loop
    
    call _restore_registers
    ret

_idct:
    call _save_registers

    mov edi, [esp + 4]
    mov esi, [esp + 8]
    mov ebp, [esp + 12]

    xor ebx, ebx
    _idct_block_loop:
        xor ecx, ecx
        xor eax, eax
        _idct_1d_1_per_col_loop:
            ;start of 1d real implementation
            movaps xmm6, [cosines2 + eax]
            movaps xmm7, [cosines2 + eax + 16]
        
            movaps xmm1, [edi + 0]
            movaps xmm2, [edi + 0 + 16]
            movaps xmm3, [edi + 32]
            movaps xmm4, [edi + 32 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [edi + 64]
            movaps xmm2, [edi + 64 + 16]
            movaps xmm3, [edi + 96]
            movaps xmm4, [edi + 96 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
                
            movaps [matrix_buffer + eax], xmm0
        
            movaps xmm1, [edi + 128]
            movaps xmm2, [edi + 128 + 16]
            movaps xmm3, [edi + 160]
            movaps xmm4, [edi + 160 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [edi + 192]
            movaps xmm2, [edi + 192 + 16]
            movaps xmm3, [edi + 224]
            movaps xmm4, [edi + 224 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
        
            movaps [matrix_buffer + eax + 16], xmm0

            ;end of 1d real implementation

            inc ecx
            lea eax, [eax + 32]
            cmp ecx, 8
            jb _idct_1d_1_per_col_loop

        xor ecx, ecx
        xor eax, eax
        _idct_1d_2_per_row_loop:
            movaps xmm6, [cosines2 + eax]
            movaps xmm7, [cosines2 + eax + 16]

            movaps xmm1, [matrix_buffer + 0]
            movaps xmm2, [matrix_buffer + 0 + 16]
            movaps xmm3, [matrix_buffer + 32]
            movaps xmm4, [matrix_buffer + 32 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [matrix_buffer + 64]
            movaps xmm2, [matrix_buffer + 64 + 16]
            movaps xmm3, [matrix_buffer + 96]
            movaps xmm4, [matrix_buffer + 96 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
                
            movaps [esi + eax], xmm0
        
            movaps xmm1, [matrix_buffer + 128]
            movaps xmm2, [matrix_buffer + 128 + 16]
            movaps xmm3, [matrix_buffer + 160]
            movaps xmm4, [matrix_buffer + 160 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            movaps xmm0, xmm1
            shufps xmm1, xmm0, 0x40
            addps xmm0, xmm1

            movaps xmm1, [matrix_buffer + 192]
            movaps xmm2, [matrix_buffer + 192 + 16]
            movaps xmm3, [matrix_buffer + 224]
            movaps xmm4, [matrix_buffer + 224 + 16]
            mulps xmm1, xmm6
            mulps xmm2, xmm7
            mulps xmm3, xmm6
            mulps xmm4, xmm7
            addps xmm1, xmm2
            addps xmm3, xmm4
            movaps xmm2, xmm1
            movaps xmm4, xmm3
            unpcklps xmm2, xmm3
            unpckhps xmm1, xmm4
            addps xmm1, xmm2

            shufps xmm2, xmm1, 0x40
            addps xmm1, xmm2

            shufps xmm0, xmm1, 0xEE
        
            movaps [esi + eax + 16], xmm0

            ;end of 1d real implementation
            
            inc ecx
            lea eax, [eax + 32]
            cmp ecx, 8
            jb _idct_1d_2_per_row_loop
        
        lea edi, [edi + 256]
        lea esi, [esi + 256]
        inc ebx
        cmp ebp, ebx
        ja _idct_block_loop
    
    call _restore_registers
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
    

