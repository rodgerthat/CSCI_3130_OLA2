;Filename   : asm_program2.asm
;Author     : Norris, Joel R.
;Class      : CSCI_3130
;Description: x86_64 asm that uses functions and a loop and an array of terror to do stuff


global main
extern printf

section .data
    
    ANS     dq  0                                       ; somewhere to put answers
    loopctr db 13                                       ; a loop control condition
    A       dq  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15   ; array of 64-bit ints
    eq_str  db "( %i * %i ) - ( %i * %i ) = %i",10,0    ; pre-formatted string for printf

section .text

main:

    mov rbp, rsp; for correct debugging
    
    mov rbx, 0      ; prep the loop conrol variable, this is our iterator
    mov r13, A      ; this is the array counter. we'll use pointer arithmatic to move through the array.

    loopstart:

        cmp rbx, [loopctr]      ; compare lcv w/ loopctr var, which is 13
        je  exit                ; this will end the loop after 
        
        ; load the parameters into the registers for computeWXYZ function call
        ; argument register order for printf : %rdi, %rsi, %rdx, %rcx, %r8 and %r9. 
        mov rdi, [r13]
        mov rsi, [r13+8]
        mov rdx, [r13+16]
        mov rcx, [r13+24]
        
        call computeWXYZ
        mov [ANS], rax    ; store the result of the computation in ANS

        ; argument register order for printf : %rdi, %rsi, %rdx, %rcx, %r8 and %r9. 
        ; we're using the address stored in r13 to load in the values in from the array
        ; by using pointer arithmatic to get the next four elements in the array
        mov rdi, eq_str
        mov rsi, [r13]
        mov rdx, [r13+8]
        mov rcx, [r13+16]
        mov r8,  [r13+24]
        mov r9,  [ANS]  ; load in the answer from the previous computation

        mov al, 0       ; tells printf there are not floating point args. 
        call printf     ; call clib function printf

        mov rax, rbx    ; move iterator to rax
        add rax, 1      ; i++
        mov rbx, rax    ; put it back
        mov rax, r13    ; gotta increment the array counter as well
        add rax, 8      ; +8 bytes to move forward one quadword element
        mov r13, rax    ; put it back
        
        jmp loopstart   ; back to start of loop
    

; function to compute the following equation: (W*X)-(Y*Z)
; for passing parameters, the registers are rdi, rsi, rcx, rdx, r8, r9
computeWXYZ:

    mov r10, rdx        ; preserve rdx contents from mul op

    mov rax, rdi        ; move first parameter, W into rax
    mul rsi             ; multiply that with second parameter, X
    mov r8, rax         ; store result (WX) in r8
    
    mov rax, rcx        ; move third parameter, Y into rax
    mul r10             ; multiply that with 4th parameter, Z
    mov r9, rax         ; store result (YZ) in r9
    
    mov rax, r8          ; move first part of subtraction op into rax
    sub rax, r9          ; subtract, result stored in rax
     
    ret

exit:

    mov eax, 60     ; system call 60 is exit
    mov rdi, 0      ; exit code 0
    syscall
