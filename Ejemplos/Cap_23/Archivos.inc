;--------------------------------------
; Este archivo contiene constantes y
; macros que simplifican el trabajo con
; archivos.
;--------------------------------------

; Constantes de acceso a los servicios
%define __NR_exit  1
%define __NR_read  3
%define __NR_write 4
%define __NR_open  5
%define __NR_close 6
%define __NR_creat 8
%define __NR_lseek 19

; Constantes de modo de apertura
%define O_RDONLY 00000h
%define O_WRONLY 00001h
%define O_RDWR   00002h
%define O_APPEND 02000h
%define O_CREAT  00100h

; Y permisos
%define S_IRUSR 00400h
%define S_IWUSR 00200h

; Constantes para movernos
%define SEEK_SET 0
%define SEEK_CUR 1
%define SEEK_END 2

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

; Macro para leer de un archivo
%macro LeeArchivo 3
    INT80 __NR_read, %1, %2, %3
%endmacro

; Macro para escribir en un archivo
%macro EscribeArchivo 3
    INT80 __NR_write, %1, %2, %3
%endmacro

; Macro para abrir archivo
%macro AbreArchivo 2
    INT80 __NR_open, %1, %2, 0
%endmacro

; Macro para crear archivo
%macro CreaArchivo 2
    INT80 __NR_creat, %1, %2, 0
%endmacro

; Macro para cerrar un archivo
%macro CierraArchivo 1
    INT80 __NR_close, %1, 0, 0
%endmacro

; Macro para desplazar el puntero
%macro MuevePuntero 3
    INT80 __NR_lseek, %1, %2, %3
%endmacro

