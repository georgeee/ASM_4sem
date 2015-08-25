section .data
    mydata: db "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
section     .text
    global     seq 

seq:
    mov eax, [esp + 12]
    xor edx, edx
    fld1
    fld1
    faddp st1, st0
    fld1
    fldz
    fld qword [esp + 4]
    fld st0
    fmul st0
    fxch st1
    _loop:
        fld st0
        fdiv st0, st4
        fxch st5
        fadd st4, st0
        fxch st5
        fadd st3, st0
        faddp st0, st0 ;simple pop
        fmul st0, st1
        fld st0
        fdiv st0, st4
        fxch st5
        fadd st4, st0
        fxch st5
        fsub st3, st0
        faddp st0, st0 ;simple pop
        fmul st0, st1
        inc edx
        cmp eax, edx
        ja _loop
    fxch st0, st2
    ffree st1
    ffree st2
    ffree st3
    ffree st4
    ret
        
    
