section .data
    pathname db "randomInt100.txt", 0
    newline db 10, 0
    sum_msg db "Sum: ", 0

section .bss
    buffer resb 1000   ; Buffer to store file content
    sum resd 1         ; Variable to store the sum
    num resd 1         ; Temporary storage for the current number
    sum_str resb 12    ; String to hold sum (max 10 digits + newline)

section .text
    global _start

_start:
    ; Open the file (taken from previous lab)
    mov eax, 5 ; move 5 into register eax for sys open
    mov ebx, pathname ; move the path into ebx 
    mov ecx, 0 ; set ecx to read only    
    int 0x80 

    mov ebx, eax     ; Store file descriptor

    mov eax, 3 ; move 3 into register eax for sys read
    mov ecx, buffer 
    mov edx, 1000 
    int 0x80

    mov edx, eax     ; Store bytes read

    ; Initialize sum and num to 0
    mov dword [sum], 0 
    mov dword [num], 0
    mov esi, buffer 

parse_loop:
    ; Read character
    mov al, [esi]
    cmp al, 0 
    je finalize_sum   ; End of buffer
    cmp al, '0'
    jl handle_delimiter
    cmp al, '9'
    jg handle_delimiter

    ; Convert ASCII to integer
    sub al, '0'
    movzx eax, al

    ; Multiply current number by 10 and add new digit
    mov ebx, [num] 
    imul ebx, ebx, 10
    add ebx, eax
    mov [num], ebx

    jmp next_char

handle_delimiter:
    ; If we have accumulated a number, add it to sum
    mov eax, [num] ; Load the current number
    add [sum], eax ; add to the sum 
    mov dword [num], 0   ; Reset num for next number

next_char:
    inc esi ; Move to next character
    jmp parse_loop ; call parse_loop again to loop

finalize_sum:
    ; If there's a last number (e.g., no newline at the end)
    mov eax, [num] ; Load the last number
    add [sum], eax ; add to the sum

    ; Convert sum to string
    mov eax, [sum] ; Load the sum
    mov edi, sum_str 
    call int_to_str ; Convert integer to string

    ; Print "Sum: "
    mov eax, 4 ; move 4 into register eax for sys write
    mov ebx, 1 ; move 1 into register ebx for stdout
    mov ecx, sum_msg
    mov edx, 5 ; length of "Sum: "
    int 0x80

    ; Print sum
    mov eax, 4 
    mov ebx, 1
    mov ecx, sum_str ; Pointer to sum string
    mov edx, 12   ; Ensure we print full sum
    int 0x80

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline 
    mov edx, 1
    int 0x80

    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80


int_to_str: ; Convert integer in EAX to string for printing
    ; Converts integer in EAX to string in sum_str buffer
    mov ecx, 10        ; Base 10
    mov ebx, 0         ; Counter for string length
    mov edi, sum_str + 11 ; Start at end of buffer
    mov byte [edi], 0  ; Null-terminate string
    dec edi

convert_loop:
    mov edx, 0 ; Clear edx before division
    div ecx ; Divide EAX by 10
    add dl, '0' ; Convert remainder to ASCII
    mov [edi], dl ; Store ASCII character
    dec edi 
    inc ebx ;increment ebx
    test eax, eax ; Check if EAX is zero
    jnz convert_loop ; ; If not, continue converting

    inc edi
    ret