%include "Archivos.inc"

; Punto de entrada a la aplicación
global main

    ; Datos con valor inicial
    section .data

; Nombre del dispositivo
NombreDisco db '/dev/fd0',0

; Mensaje de error
MsgError db 'Se produce un error.',0

; Mensajes indicativos

MsgDiscoOrigen db 'Inserte disco de origen:',0
MsgDiscoDestino db 'Inserte disco de destino:',

MsgFin db 'El proceso de copia ha terminado'
       db 10,13,0

    ; Datos sin valor inicial
    section .bss

; Para guardar el descriptor
; de archivo
fdDisco   resd 1

; Espacio para contener el disco
%define Bytes 80*2*18*512
Contenido resb Bytes

Espera resb 10 ; Para esperar Intro

    ; Código del programa
    section .text
main:
    ; Solicita el disco de origen
    call SolicitaOrigen

    ; Copiamos el contenido en archivo
    call LeeDisco

    ; Solicitamos el disco de destino
    call SolicitaDestino

    ; Copiamos en el disco
    call EscribeDisco

    ; Indicamos que ha finalizado el proceso
    call IndicaFin

    ; Devolvemos el control al sistema
    INT80 __NR_exit, 0,0,0

SolicitaOrigen:
    ; Mostramos el mensaje
    EscribeConsola MsgDiscoOrigen,24
    ; y esperamos la pulsación de <Intro>
    LeeConsola Espera,2

    ret ; volver

LeeDisco:
    ; Abrimos el disco
    AbreArchivo NombreDisco,O_RDONLY
    ; comprobando un posible error
    or eax, eax
    js Error

    ; guardamos el identificador
    mov [fdDisco],eax

    ; Leemos el contenido del disco
    LeeArchivo [fdDisco],Contenido,Bytes

    ; Y lo cerramos
    CierraArchivo [fdDisco]

    ret ; volver

SolicitaDestino:
    ; Mostramos el mensaje
    EscribeConsola MsgDiscoDestino,25
    ; y esperamos la pulsación de <Intro>
    LeeConsola Espera,2

    ret ; volver

EscribeDisco:
    ; Abrimos el disco para escritura
    AbreArchivo NombreDisco,O_WRONLY
    ; comprobando un posible error
    or eax, eax
    js Error

    ; Guardamos el identificador
    mov [fdDisco], eax

    ; escribimos los datos en el disco
    EscribeArchivo [fdDisco],Contenido,Bytes

    ; Y lo cerramos
    CierraArchivo [fdDisco]

    ret ; volver

IndicaFin:
    ; Mostramos el mensaje
    EscribeConsola MsgFin, 34

    ret ; volver

Error:
    ; Mostramos el mensaje de error
    EscribeConsola MsgError,20

    ; Devolvemos el control al sistema
    INT80 __NR_exit, 0,0,0

