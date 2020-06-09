BF_VERSION: equ 0

%define ALIGN 4


%macro next 0
        lodsd ; or lodsw?
        jmp eax
%endmacro

%macro pushrsp 1        ; push return stack pointer
        lea ebp,[ebp-ALIGN]
        mov ebp,%1
%endmacro

%macro poprsp 1         ; pop return stack pointer
        mov %1,ebp
        lea ebp,[ebp+ALIGN]
%endmacro


section .text
        align ALIGN
docolon:
        pushrsp esi
        add eax,ALIGN
        mov esi,eax
        next


section .rodata
F_IMMED:   dd 0x80
F_HIDDEN:  dd 0x20
F_LENMASK: dd 0x1f
quit:      dd 0x80
section .data
link:             dd 0 ; dictionary
var_S0:           dd 0
return_stack_top: dd 0

section .text
global _start
_start: cld
        mov [var_S0],esp
        mov ebp,return_stack_top
        ;call setup_data_segment ;FIXME: uncomment when implemented
        mov esi,cold_start
        next

section .rodata
cold_start: dd quit

;; defword NAME,LEN(NAME),FLAGS(0),LABEL
%macro defword 4
section .rodata
        align ALIGN
        global name_%4
name_%4:
        dd link                   ; current link address
        mov dword [link],name_%4  ; update link
        db %3+%2                  ; store FLAGS+LEN as byte
        dd '%1'                   ; store the actual name
        align ALIGN
        global %4
%4:
        dd docolon
%endmacro

;; defcode NAME,LEN(NAME),FLAGS(0),LABEL
%macro defcode 4
section .data
        align ALIGN
        global name_%4
name_%4:
        dd link                   ; current link address
        mov dword [link],name_%4  ; update link
        db %3+%2                  ; store FLAGS+LEN as byte
        dd '%1'                   ; store the actual name
        align ALIGN
        global %4
%4:
        dd code_%4
section .text
        global code_%4
code_%4:
%endmacro

        defcode 'drop',4,0,drop
        pop eax
        next

        defcode 'swap',4,0,swap
        pop eax
        pop ebx
        push eax
        push ebx
        next

        defcode 'dup',3,0,dup
        mov eax,esp
        push eax
        next

        defcode 'over',4,0,over
        mov eax,[esp+ALIGN]
        push eax
        next

        defcode 'rot',3,0,rot
        pop eax
        pop ebx
        pop ecx
        push ebx
        push eax
        push ecx
        next

        defcode '-rot',4,0,nrot
        pop eax
        pop ebx
        pop ecx
        push eax
        push ecx
        push ebx
        next

        defcode '2drop',5,0,twodrop
        pop eax
        pop eax
        next

        defcode '2dup',4,0,twodup
        mov eax,esp
        mov ebx,[esp+ALIGN]
        push ebx
        push eax
        next

        defcode '2swap',5,0,twoswap
        pop eax
        pop ebx
        pop ecx
        pop edx
        push ebx
        push eax
        push edx
        push ecx
        next

        defcode '?dup',4,0,qdup
        mov dword eax,esp
        test eax,eax
        jz .1
        push eax
.1:     next

        defcode '+',1,0,_add
        pop eax
        add dword esp,eax
        next

        defcode '-',1,0,_sub
        pop eax
        sub dword esp,eax
        next

        defcode '*',1,0,_mul
        pop eax
        pop ebx
        imul dword eax,ebx
        push eax
        next

        ;; FIXME: implement more arithmetic

        defcode '/mod',4,0,divmod
        xor edx,edx
        pop ebx
        pop eax
        idiv dword ebx
        push edx
        push eax
        next

        defcode '=',1,0,equal
        pop eax
        pop ebx
        cmp eax,ebx
        sete al
        movzx eax,al
        push dword eax
        next

        ;; FIXME: implement more comparisons

        defcode 'exit',4,0,exit
        poprsp esi
        next

        defcode 'lit',3,0,lit
        lodsd
        push eax
        next

        ;; FIXME: implement memory access (!, @ etc)

%macro defvar 3
        push dword %2+4 ;var_
        next
section .data
        align ALIGN
        var_%1 dd %3
%endmacro
        defcode 'latest',6,0,latest
        defvar latest,6,0
        ;push dword 10
        ;next
        ;section .data
        ;align ALIGN
        ;var_latest dd 0

        defword ":",1,0,colon
        dd dup
        ;;dd _word
        ;;dd create
        ;;dd lit, docolon, comma
        ;;dd latest, fetch, hidden
        ;;dd pbrac
        ;;dd exit

