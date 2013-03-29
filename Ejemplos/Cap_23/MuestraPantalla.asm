%include "Archivos.inc"

; Punto de entrada a la aplicación
global main

    ; Datos con valor inicial
    section .data
    
; Nombre del archivo destino    
NombreArchivo db 'Pantallas.dat',0

; Nombre del dispositivo de pantalla
NombrePantalla db '/dev/vcsa',0

; Mensaje de error
MsgError db 'Se produce un error.',0

    ; Datos sin valor inicial
    section .bss

; Para guardar los descriptores
fdPantalla resd 1
fdEntrada resd 1

; Bytes que ocupa la pantalla
Bytes resd 1

; Pantalla
Contenido resb 16384

    ; Código del programa
    section .text
main:
    ; Abrimos el archivo de origen
    AbreArchivo NombreArchivo, O_RDONLY
    
    ; Comprobamos si hay error
    or eax,eax
    js Error
    
    ; guardamos el descriptor de archivo
    mov [fdEntrada],eax
    
    ; Abrimos la memoria de consola
    AbreArchivo NombrePantalla,O_RDWR
    or eax,eax
    js Error

    mov [fdPantalla],eax
    ; Leemos el número de bytes que ocupa la pantalla
    LeeArchivo [fdEntrada],Bytes,4
   
    LeeArchivo [fdPantalla],Contenido,4
    ; Saltamos en la pantalla las posiciones que
    ; indican tamaño y posición del cursor
    ;MuevePuntero [fdPantalla],SEEK_SET,4

    ; Leemos los datos del archivo
    LeeArchivo [fdEntrada],Contenido,[Bytes]
    
    ; y lo escribimos en la pantalla
    EscribeArchivo [fdPantalla],Contenido,[Bytes]
    
    ; Cerramos ambos archivos
    CierraArchivo [fdPantalla]
    CierraArchivo [fdEntrada]
    
    jmp Salir ; terminar
    
Error:
    ; Mostramos el mensaje de error
    EscribeConsola MsgError,20
    
Salir:
    ; Devolvemos el control al sistema
    INT80 __NR_exit, 0,0,0
