global main

; Funciones que vamos a usar
extern printf
extern exit

   section .data

; Cadena de caracteres
Formato db "Un número (%d) y el carácter (%c)", 0ah, 0

section .text
main:
    ; introducimos en la pila
    ; dos enteros
    push 115
    push 115
    ; y la dirección de la cadena
    push dword Formato
    ; para llamar a printf
    call printf

    ; eliminamos los parámetros
    add esp,12

    push 0 ; Salimos con el código 0
    call exit