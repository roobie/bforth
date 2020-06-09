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
        ;call setup_data_segment
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
          docol
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
