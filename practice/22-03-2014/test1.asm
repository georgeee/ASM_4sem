section .data
    mydata: db "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
section     .text
    global      fac
    global      fac_d

fac:
    mov eax, [esp+4]
    push edi
    push esi
    mov edi, eax
    mov eax, 1
    mov esi, 1
    fac_loop:
        inc esi
        mul esi
        cmp edi, esi
        ja fac_loop
    pop esi
    pop edi
    ret

fac_d:
    mov eax, [esp + 4]
    mov edx, 1
    fld1
    fld1
    fac_d_loop:
        fld1
        faddp st2, st0
        fmul st0, st1
        inc edx
        cmp eax, edx
        ja fac_d_loop
    ffree st1
    ;fstp qword [mydata]
    ;mov edx, [mydata]
    ;mov eax, [mydata + 4]
    ret
        
    
