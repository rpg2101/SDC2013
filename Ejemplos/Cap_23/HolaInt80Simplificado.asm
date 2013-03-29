; Constantes de acceso a los servicios
%define __NR_exit  1
%define __NR_read  3
%define __NR_write 4

; Definimos una macro genérica para
; invocar a la interrupción 80
; recibiendo como máxima 4 parámetros
%macro INT80 4
    mov eax, %1
    mov ebx, %2
    mov ecx, %3
    mov edx, %4
    int 80h
%endmacro

; Macro para leer de consola
%macro LeeConsola 2
    INT80 __NR_read, 0, %1, %2
%endmacro

; Macro para escribir en consola
%macro EscribeConsola 2
    INT80 __NR_write, 1, %1, %2
%endmacro

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
    EscribeConsola Pregunta, 17

    ; Leemos como máximo 127 caracteres
    LeeConsola Nombre, 127

    ; Guardamos el número
    ; de caracteres introducidos
    push eax

    ; Mostramos el saludo
    EscribeConsola Saludo, 5

    ; y el dato recogido de la consola
    pop edx
    EscribeConsola Nombre, edx

    ; Devolvemos el control al sistema
    INT80 __NR_exit, 0,0,0
