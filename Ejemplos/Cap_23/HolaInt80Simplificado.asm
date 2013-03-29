; Constantes de acceso a los servicios
%define __NR_exit  1
%define __NR_read  3
%define __NR_write 4

; Definimos una macro gen�rica para
; invocar a la interrupci�n 80
; recibiendo como m�xima 4 par�metros
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

; Punto de entrada a la aplicaci�n
global main

    ; Datos con valor inicial
    section .data

Pregunta db '�C�mo te llamas?',10,0
Saludo db 'Hola ',0

    ; Datos sin valor inicial
    section .bss

Nombre resb 128

    ; C�digo del programa
    section .text
main:
    ; Escribimos la cadena de texto con
    ; la pregunta
    EscribeConsola Pregunta, 17

    ; Leemos como m�ximo 127 caracteres
    LeeConsola Nombre, 127

    ; Guardamos el n�mero
    ; de caracteres introducidos
    push eax

    ; Mostramos el saludo
    EscribeConsola Saludo, 5

    ; y el dato recogido de la consola
    pop edx
    EscribeConsola Nombre, edx

    ; Devolvemos el control al sistema
    INT80 __NR_exit, 0,0,0
