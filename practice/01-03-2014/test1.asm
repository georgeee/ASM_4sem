extern printf

section .data
    str1: db "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    str2: db "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

section     .text
    global      print10 ;must be declared for linker (ld)
    global      fac

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
    
print10:
    mov eax, [esp+4]
    mov esi, 1999999Ah ;1/10 * 2^32
    mov ebx, str1
    main_loop:
        mov ecx, eax
        imul esi
        ; ecx=<src_num> edx=<src_num>/10
        mov eax, edx
        shl eax, 1
        shl edx, 3
        ; ecx=<src_num> eax=(<src_num>/10)*2 edx=(<src_num>/10)*8
        sub ecx, edx
        sub ecx, eax
        shr eax, 1
        ; ecx=<src_num>%10 eax=(<src_num>/10)
        add ecx, 48 
        mov [ebx], cl 
        add ebx, 1
        cmp eax, 0
        ja main_loop
    mov eax, str2
    reverse_loop:
        mov dl, [ebx - 1]
        mov [eax], dl
        sub ebx, 1
        add eax, 1
        cmp ebx, str1
        ja reverse_loop
    mov byte [eax], 10
    mov eax, str2
    xor edx,edx
    ret
