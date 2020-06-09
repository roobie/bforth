BF_VERSION: equ 0

%macro next 0
        lodsw
        jmp eax
%endmacro

%macro pushrsp 1        ; push return stack pointer
        lea ebp,[ebp-4]
        mov ebp,%1
%endmacro

%macro poprsp 1         ; pop return stack pointer
        mov %1,ebp
        lea ebp,[ebp+4]
%endmacro


section .data
link:      db 4 ; dictionary


section .text
        align 4

docol:  pushrsp esi
        add eax,4
        mov esi,eax
        next


global _start

section .text
        align 4

_start: cld
        mov var_S0,esp
        mov ebp,return_stack_top
        call setup_data_segment
        mov esi,cold_start
        next

section .rodata
cold_start: int quit

section .data
        F_IMMED   db 0x80
        F_HIDDEN  db 0x20
        F_LENMASK db 0x1f

        ;; defword name,flags(0),label
%macro defword 3
        section .rodata
        align 4
        global name_%3
name_%3:
        db link
        link db name_%3
        db %2,$-%1 ; plus or comma?
        db '%1'
        align 4
        global %3
%3:     int docol
%endmacro


        ;; defcode name,flags(0),label
%macro defcode 4
section .rodata
        align 4
        global name_%4
name_%4:
        db link
        ;;stosb [link],name_%4
        ;;db %2
        ;;db '%1'
        align 4
        global %4
%4:     
        db code_%4
        global code_%4
section .text
code_%4:
%endmacro

        defcode 'drop',4,0,drop
        pop eax
        next
