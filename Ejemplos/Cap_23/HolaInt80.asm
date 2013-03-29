; Constantes de acceso a los servicios
%define __NR_exit  1
%define __NR_read  3
%define __NR_write 4

; Punto de entrada a la aplicación
global main

    ; Datos con valor inicial
    section .data

Pregunta db '¿Cómo te llamas?',10,0
Saludo db 'Hola ',0

    ; Datos sin valor inicial
    section .bss

Nombre resb 128

    ; Código del programa
    section .text
main:
    ; Escribimos la cadena de texto con
    ; la pregunta
    mov eax, __NR_write
    mov ebx, 1 ; salida por consola
    mov ecx, Pregunta
    mov edx, 17 ; longitud
    int 80h

    ; Leemos como máximo 127 caracteres
    mov eax, __NR_read
    mov ebx, 0
    mov ecx, Nombre
    mov edx, 127
    int 80h

    ; Guardamos el número
    ; de caracteres introducidos
    push eax

    ; Mostramos el saludo
    mov eax, __NR_write
    mov ebx, 1
    mov edx, 5
    mov ecx, Saludo
    int 80h

    ; y el dato recogido de la consola
    mov eax, __NR_write
    mov ebx, 1
    pop edx ; recuperamos el número de caracteres
    mov ecx, Nombre
    int 80h

    ; Devolvemos el control al sistema
    mov eax, __NR_exit
    xor ebx, ebx ; con el código 0
    int 80h
