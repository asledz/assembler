section .bss       
    width           resd 1
    height          resd 1

    coolers_temp    resd 1
    coeff           resd 1

    matrix          resq 1
    matrix2         resq 1
    heaters         resq 1

    wsk             resq 1



section .text

start:
    push r12

    add     rsi, 2
    add     rdi, 2

    mov [width], edi
    mov [height], esi

    mov r8, [rdx]
    mov [matrix], r8
    
    movss [coolers_temp], xmm0
    movss [coeff], xmm1

    mov r8, [rdx + 8]
    mov [heaters], r8

    mov r8, [rdx + 16]
    mov [matrix2], r8

    mov [wsk], rdx

    ;; Ustawienie tablicy bool na 1
    mov r8d, [width]
    mov eax, [height]
    mul r8
    mov rcx, rax

    mov rdi, [heaters]
    mov rax, 1
    
    rep stosb

    ;; Ustawienie środka tablicy bool na 0
    xor r8, r8
    add r8, 1
    mov r9d, [height]
    sub r9, 1

    xor r8, r8
    add r8, 1
    mov r9d, [height]
    sub r9d, 1  

    mov eax, [width]
    add rax, 1

    mov rdi, [heaters]

    loop_start_beg:
        cmp r8, r9
        je loop_start_end
        
        xor rcx, rcx
        add rcx, 1
        mov r11d, [width]
        sub r11d, 2
        loop_start_2_beg:
            cmp rcx, r11
            jg loop_start_2_end

            mov rdi, [heaters]
            mov byte[rdi + rax], 0

            add rcx, 1
            add rax, 1
            jmp loop_start_2_beg
        loop_start_2_end:

        add r8, 1
        add rax, 2
        jmp loop_start_beg
    loop_start_end:

    ;; Ustawienie temperatur na granicach

    xor r8, r8
    mov r9d, [width]
    mov r11d, [height]
    movss xmm0, [coolers_temp]
    
    mov r12, r11 ; wysokosc
    sub r12, 1 ; wysokosc - 1
    mov rax, r9 ; szerokosc
    mul r12
    mov r12, rax

    loop_width_beg:
        cmp r8, r9
        je loop_width_end
        
        add r12, r8
        mov rdi, [matrix]        
        movss [rdi + 4 * r8], xmm0
        movss [rdi + 4 * r12], xmm0

        mov rdi, [matrix2]        
        movss [rdi + 4 * r8], xmm0
        movss [rdi + 4 * r12], xmm0
        sub r12, r8

        inc r8
        jmp loop_width_beg
    loop_width_end:


    xor r8, r8

    mov r9d, [height]
    sub r9, 1
    mov eax, [width]
    mul r9
    mov r9, rax ;; r9 = (height - 1) * width
    mov r11d, [width]
    
    loop_height_beg:
        cmp r8, r9
        je loop_height_end

        mov r12, r8
        add r12, r11
        sub r12, 1

        mov rdi, [matrix]        
        movss [rdi + 4 * r8], xmm0
        movss [rdi + 4 * r12], xmm0
        
        mov rdi, [matrix2]        
        movss [rdi + 4 * r8], xmm0
        movss [rdi + 4 * r12], xmm0


        add r8, r11
        jmp loop_height_beg
    loop_height_end:
    
    pop r12
    ret

place:
    push r12
    push r13
    push r14

    xor r13, r13
    xor r12, r12
    xor r8, r8

    mov r12, rdx

    mov rax, 4
    mul rdi
    mov rdi, rax 

    loop_place_beg:
        cmp r8, rdi
        je loop_place_end
        
        movss xmm1, [rcx + r8]  ; temperatura
        mov r11d, [rsi + r8]    ; x 
        mov r13d, [r12 + r8]    ; y
        
        add r11, 1
        add r13, 1

        mov eax, [width]
        mul r13
        add rax, r11

        mov r9, [heaters]
        mov byte[r9 + rax], 1
        mov r9, [matrix]
        movss [r9 + rax * 4], xmm1


        add r8, 4
        jmp loop_place_beg
    loop_place_end:

    pop r14
    pop r13
    pop r12
    ret

step:
    push r12
    push r13
    push r14
    push r15

    xor r8, r8
    add r8, 1
    mov r9d, [height]
    sub r9, 1
    xor r8, r8
    add r8, 1
    mov r9d, [height]
    sub r9d, 1  
    mov rdi, [heaters]
    
    ;; czytam z matrixa rsi
    mov rsi, [matrix]
    mov r13, [matrix2]

    mov r12d, [width]
    add r12, 1

    loop_step_beg:
        cmp r8, r9
        je loop_step_end
        
        xor rcx, rcx
        add rcx, 1
        mov r11d, [width]
        sub r11d, 2
        loop_step_2_beg:
            cmp rcx, r11
            jg loop_step_2_end
            
            cmp byte[rdi + r12], 1
            je skip_number
            
            ; moja aktualna
            movss xmm2, [rsi + 4 * r12]
            mov r14d, [width]

            ; suma sąsiadów
            xorps xmm1, xmm1
            ;; sasiad w dol
            mov r15, r12
            sub r15, r14
            addss xmm1, [rsi + r15 * 4]
            subss xmm1, xmm2
            ;; sasiad w gore
            mov r15, r12
            add r15, r14
            addss xmm1, [rsi + r15 * 4]
            subss xmm1, xmm2
            ;; sasiad w bok
            mov r15, r12
            add r15, 1
            addss xmm1, [rsi + r15 * 4]
            subss xmm1, xmm2
            ;; sasiad w drugi bok
            mov r15, r12
            sub r15, 1
            addss xmm1, [rsi + r15 * 4]
            subss xmm1, xmm2
            ;; moja suma * 4
            
            ;; nowa temperatura:
            movss xmm3, [coeff]
            mulss xmm3, xmm1 ;;  współczynnik * różnica
            addss xmm3, xmm2 ;; (współczynnik * różnica) + akt

            jmp koniec_liczenia
            
            skip_number:
            movss xmm3, [rsi + 4 * r12]
            
            koniec_liczenia:
            movss [r13 + 4 * r12], xmm3

            add rcx, 1
            add r12, 1
            jmp loop_step_2_beg
        loop_step_2_end:

        add r8, 1
        add r12, 2
        jmp loop_step_beg
    loop_step_end:

    ;; podmieniam wskaźniki wsk, wsk + 16
    mov r11, [matrix]
    mov r12, [matrix2]
    mov r13, [wsk]
    mov [matrix], r12
    mov [matrix2], r11
    mov [r13], r12
    mov [r13 + 16], r11


    pop r15
    pop r14
    pop r13
    pop r12
    ret

global start
global step
global place