/*
Anita Śledź 406384

Plik obsługujący funkcję changeColoring:
- jako argumenty dostaje:
    - pointer na bitmapę w formacie char*
    - szerokość
    - wysokość
- Iteruje się i dla każdej trójki bitów:
    - liczy średnią ważoną według zmiennych globalnych
        - RW - red weight
        - GW - green weight
        - BW - blue weight
    - nadpisuje pierwszy bit (aby funkcja writeFile w coloring-main.c umiała dobrze pisać do pliku).
*/
.text

@ Getting the constant weights for colors:
@ solution taken from this site: https://stackoverflow.com/questions/13181145/using-global-variables-declared-in-c-in-arm-assembly
.global RW
.global GW
.global BW
.RWaddr:
    .word RW
.GWaddr:
    .word GW
.BWaddr:
    .word BW


.global changeColoring
.func changeColoring
@ Function changes coloring from color to black and white
@ r0 - pointer to matrix
@ r1 - pointer to width
@ r2 - pointer to height
changeColoring:
    @ loop (will be moving +3 each time, take average from ptr, ptr+1 and ptr+2): 
    @   r3 - index (0...r4)
    @   r4 - max index (r1 * r2 * 3)
    @   r5 - will calculate average from: curr_arr_ptr, curr_arr_ptr + 1, curr_arr_ptr + 2
    @   r6 will be storing any additional data.

    push {r4}
    push {r5}
    push {r6}
    push {r7}
    push {r8}
    push {r9}

    @ calculate r4 = r1 * r2 * #3
    mul r4, r1, r2
    mov r6, #3
    mul r4, r6, r4 

    @ set r3
    mov r3, #0

    @ dereference r0
    @ ldr r0, [r0]
    
    @ loop over the array and calculate the mean
    @ red: [r0,r3], green: [r0, r3+1], blue: [r0, r3+2]
    loop:
        cmp r3, r4
        beq end

        @calculation part of loop
        
        @ red color
        ldrb r6, [r0, r3]
        @@ multiply by weight
        ldr r9, .RWaddr
        ldr r9, [r9]
        mul r6, r9, r6
        
        @green color
        @@ address
        mov r7, #1
        add r7, r3, r7 
        ldrb r7, [r0, r7]
        @@ multiply by weight
        ldr r9, .GWaddr
        ldr r9, [r9]
        mul r7, r9, r7

        @blue
        @@ address
        mov r8, #2
        add r8, r3, r8
        ldrb r8, [r0, r8]
        @@ multiply by weight
        ldr r9, .BWaddr
        ldr r9, [r9]
        mul r8, r9, r8
        
        @@@ calculate sum in r6 -> (r*RW + g*GW + b*BW)/256
        add r6, r7, r6
        add r6, r8, r6
        lsr r6, r6, #8

        @ move result to array
        strb r6, [r0, r3]

        @end of calculation part of loop

        mov r6, #3
        add r3, r6, r3
        b loop

    end:

    @ cleaning up
    pop {r9}
    pop {r8}
    pop {r7}
    pop {r6}
    pop {r5}
    pop {r4}

    bx lr

