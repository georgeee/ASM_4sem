
;args: eax = left-top corner of square
read_44_block_2:
    movaps xmm4, [eax]
    movaps xmm5, [eax + 32]
    movaps xmm6, [eax + 64]
    movaps xmm7, [eax + 96]
    ret

;args: eax = left-top corner of square
read_44_block_1:
    movaps xmm0, [eax]
    movaps xmm1, [eax + 32]
    movaps xmm2, [eax + 64]
    movaps xmm3, [eax + 96]
    ret

;args: eax = left-top corner of square
;it possibly changes regs: edx
transpose_44_inplace:
    call read_44_block_1
    call write_transpose_44_block_1
    ret
    
;args: eax = left-top corner of square 1, ecx = left-top corner of square 2
;it possibly changes regs: edx
transpose_swap_44:
    call read_44_block_1
    xchg eax, ecx
    call read_44_block_2
    call write_transpose_44_block_2
    xchg eax, ecx
    call write_transpose_44_block_1
    ret

;args: eax = left-top corner of 8x8 matrix
;it possibly changes regs: eax, ecx, edx
transpose_88:
    call transpose_44_inplace
    lea ecx, [eax + 128]
    lea eax, [eax + 16]
    call transpose_swap_44
    lea eax, [eax + 128]
    call transpose_44_inplace
    ret

;it possibly changes regs: edx
write_transpose_44_block_2:
    xor edx, edx
    _write_transpose_44_block_2_loop1:
        movss [eax + edx*4], xmm4
        movss [eax + edx*4 + 32], xmm5
        movss [eax + edx*4 + 64], xmm6
        movss [eax + edx*4 + 96], xmm7
        shufps xmm4, xmm4, 0x39
        shufps xmm5, xmm5, 0x39
        shufps xmm6, xmm6, 0x39
        shufps xmm7, xmm7, 0x39
        inc edx
        cmp edx, 4
        jb _write_transpose_44_block_2_loop1
    ret

;it possibly changes regs: edx
write_transpose_44_block_1:
    xor edx, edx
    _write_transpose_44_block_1_loop1:
        movss [eax + edx*4], xmm0
        movss [eax + edx*4 + 32], xmm1
        movss [eax + edx*4 + 64], xmm2
        movss [eax + edx*4 + 96], xmm3
        shufps xmm0, xmm0, 0x39
        shufps xmm1, xmm1, 0x39
        shufps xmm2, xmm2, 0x39
        shufps xmm3, xmm3, 0x39
        inc edx
        cmp edx, 4
        jb _write_transpose_44_block_1_loop1
    ret
