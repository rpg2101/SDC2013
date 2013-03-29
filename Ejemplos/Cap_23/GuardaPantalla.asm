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
; de archivo
fdPantalla resd 1
fdSalida resd 1

; Datos a recuperar de la cabecera
; de la pantalla
Lineas   resb 1
Columnas resb 1
Linea    resb 1
Columna  resb 1

; Para calcular los bytes que
; ocupa la pantalla
Bytes resd 1

; Espacio para la pantalla
Contenido resb 16384

    ; Código del programa
    section .text
main:
    ; Abrimos el archivo de destino
    CreaArchivo NombreArchivo, 0
    
    ; Comprobamos si hay error
    or eax,eax
    js Error
    
    ; guardamos el descriptor de archivo
    mov [fdSalida],eax
   
    ; Abrimos la memoria de consola
    AbreArchivo NombrePantalla,O_RDONLY
    ; guardamos el identificador
    mov [fdPantalla],eax
     
    ; Leemos las dimensiones y posición del cursor
    LeeArchivo [fdPantalla],Lineas,4

    ; Calculamos el número de bytes que ocupa
    ; la pantalla
    xor eax, eax
    mov al, [Lineas]
    mov bl, [Columnas]
    mov cx, 2
    mul bl
    mul cx
    ; y lo guardamos
    mov [Bytes],eax

    ; Escribimos el tamaño de la pantalla
    ; en el archivo
    EscribeArchivo [fdSalida],Bytes,4
    
    ; Leemos el contenido de la pantalla
    LeeArchivo [fdPantalla],Contenido,[Bytes]

    ; y lo escribimos en el archivo
    EscribeArchivo [fdSalida],Contenido,[Bytes]
    
    ; Cerramos ambos archivos
    CierraArchivo [fdPantalla]
    CierraArchivo [fdSalida]
    
    jmp Salir ; terminar
    
Error:
    ; Mostramos el mensaje de error
    EscribeConsola MsgError,20
    
Salir:
    ; Devolvemos el control al sistema
    INT80 __NR_exit, 0,0,0
