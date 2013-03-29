global main
extern printf

section .data
Saludo db "¡Hola Linux!", 0ah, 0

section .text
main:
    push dword Saludo
    call printf
    pop eax
    ret


