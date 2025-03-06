section .data
    str1 db "Foo", 0   ; First string
    str2 db "Bar", 0   ; Second string
    msg  db "The hamming distance is: ", 0
    len_msg equ $ - msg
    newline db 10, 0

section .bss
    result resb 4
    count  resb 4

section .text
    global _start

_start:
    xor ecx, ecx        ; ECX will be our loop counter (index)
    xor eax, eax        ; Clear EAX for result count

loop_chars:
    mov dl, [str1 + ecx]  ; Load character from str1
    mov dh, [str2 + ecx]  ; Load character from str2
    test dl, dl           ; Check if we hit null terminator
    jz print_result       ; If so, exit loop
    xor dl, dh            ; XOR both characters
    call count_bits       ; Count differing bits
    inc ecx               ; Move to next character
    jmp loop_chars        ; Repeat

count_bits:
    push ecx             ; Save ECX
    mov ecx, 8        
    xor ebx, ebx         ; Clear bit count

bit_count_loop:
    test dl, 1           ; Check least significant bit
    jz skip_inc          ; If 0, skip increment
    inc ebx              ; Otherwise, increase count

skip_inc:
    shr dl, 1            ; Shift right to check next bit
    loop bit_count_loop  ; Loop for all 8 bits

    add eax, ebx         ; Accumulate total differences
    pop ecx              ; Restore ECX
    ret

print_result:
    ; Convert number to string
    mov edi, result
    mov ebx, eax
    add ebx, '0'        ; Convert to ASCII
    mov [edi], ebx
    mov byte [edi+1], 0 ; Null terminate

    ; print the base string message
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len_msg
    int 0x80

    ; print the result from hamming
    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 1
    int 0x80

    ; print new line
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    
    mov eax, 1
    xor ebx, ebx
    int 0x80