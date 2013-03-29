;***************************
; Constantes
;***************************

; N�mero de descriptores
%define NumDescriptores 6 

; Selectores de esos descriptores
; para asignar a los registros de
; segmento
%define SELNulo   0
%define SELCod32  8
%define SELDat32 16
%define SELCod16 24
%define SELDat16 32
%define SELPlano 40

          ; Creamos un COM
          ORG 100h
          ; Zona de c�digo de 16 bits
          BITS 16

;*********************************
; Segmento de c�digo
;*********************************
Inicio:
        ; Configuramos los descriptores
        call ConfiguraDescriptores
        
        ; Desactivamos interrupciones
        cli
        
        ; cargamos la GDT
        lgdt [DatosGDTR]
        
        ; activamos el modo protegido
        mov eax,cr0
        or al, 1
        mov cr0, eax

        ; y descartamos todo el contenido
        ; de la cola de instrucciones del
        ; procesador        
        jmp SELCod32:CodigoProtegido

        ; Zona de c�digo de 32 bits
        BITS 32
CodigoProtegido:
        
        ; Tomamos el selector de datos
        mov ax,SELDat32
        ; y lo ponemos en DS
        mov ds,ax
        
        ; Tomamos el selector correspondiente
        ; al segmento plano de 4 Gb
        mov ax,SELPlano
        ; y lo ponemos en ES
        mov es,ax
        
        ; Tomamos la direcci�n del segmento
        mov esi, MsgProtegido
        
        ; introducimos en DI la direcci�n
        ; f�sica de la memoria de pantalla
        mov edi, 0B8000h
        cld
        
        ; Borramos todo
        mov ax, 7020h
        mov ecx, 2000
        rep stosw
        
        ; Tomamos de nuevo la direcci�n
        mov edi, 0B8000h
        
Bucle:  ; y mostramos el mensaje
        
        lodsb        ; Leer un car�cter
        or al, al    ; Si es 0
        jz FinBucle  ; hemos terminado
        
        stosb        ; En caso contrario escribir
        mov al, 70h  ; junto con el atributo
        stosb
        
        jmp Bucle    ; repetir hasta el fin
        
FinBucle: ; Hemos terminado 

        ; Descartamos el contenido de la cola
        ; de instrucciones y saltamos usando
        ; el descriptor de segmento de c�digo
        ; de 16 bits
        jmp SELCod16:SalirModoProtegido
      
        ; Zona de c�digo de 16 bits
        BITS 16        
SalirModoProtegido:        
        ; Tomamos el descriptor del segmento
        ; de datos de 16 bits
        mov ax,SELDat16
        ; y lo ponemos en DS
        mov ds,ax
        
        ; Desactivamos el modo protegido
        mov eax,cr0
        and eax,0Feh
        mov cr0,eax
        
        ; Terminamos
        jmp Salir
        
Salir:   
        sti ; reactivando las interrupciones
        
        ; y devolviendo el control al sistema
        mov ah, 4ch
        int 21h


;**************************
; Esta rutina se encarga de
; configurar la tabla de
; descriptores de segmentos
;**************************
ConfiguraDescriptores:
        ;---------
        ; Calculamos la direcci�n f�sica del
        ; segmento de datos
        ;---------
        
        xor eax, eax ; ponemos a 0 EAX
        mov ax, ds   ; y obtenemos el segmento
        shl eax,4    ; lo desplazamos 4 bits
        
        ; Lo que tenemos en este momento en 
        ; EAX es la direcci�n f�sica del segmento
        ; de datos. La usamos para establecer la
        ; direcci�n base de los segmentos de 
        ; datos de 16 y 32 bits
        
        push eax ; guardamos temporalmente
        
        ; los bits 0-15 de la direcci�n base
        mov [SelectorDatos32+2],ax
        mov [SelectorDatos16+2],ax
        
        ; tomamos en AX los otros 16 bits
        shr eax, 16
        
        ; colocamos los bits 16-23
        mov [SelectorDatos32+4],al
        mov [SelectorDatos16+4],al
        
        ; y los bits 24-31
        mov [SelectorDatos32+7],ah
        mov [SelectorDatos16+7],ah
        
        ; recuperamos EAX
        pop eax
        
        ;---------
        ; Calculamos la direcci�n f�sica de
        ; la GDT
        ;---------

        ; tomamos el desplazamiento donde
        ; se encuentra el primer selector
        mov ebx, SelectorNulo
        ; y lo sumamos
        add eax, ebx
        
        ; En este momento tenemos en EAX una
        ; direcci�n f�sica de 32 bits, que
        ; establecemos como inicio de la GDT
        mov [DireccionGDT], eax
        
        ;---------
        ; Calculamos la direcci�n f�sica del
        ; segmento de c�digo
        ;---------
        
        xor eax, eax ; ponemos a 0 EAX
        mov ax, cs   ; y obtenemos el segmento
        shl eax,4    ; lo desplazamos 4 bits
        
        ; los bits 0-15 de la direcci�n base
        mov [SelectorCodigo32+2],ax
        mov [SelectorCodigo16+2],ax
        
        ; tomamos en AX los otros 16 bits
        shr eax, 16
        
        ; colocamos los bits 16-23
        mov [SelectorCodigo32+4],al
        mov [SelectorCodigo16+4],al
        
        ; y los bits 24-31
        mov [SelectorCodigo32+7],ah
        mov [SelectorCodigo16+7],ah

        ret ; hemos terminado                
        
; Mensaje a mostrar en modo protegido
MsgProtegido db 'Estoy en modo protegido.'

;------------------------------
; Componemos la GDT
;------------------------------

; El primer descriptor es nulo
SelectorNulo dd 0
             dd 0  ; 8 bytes a cero
             
; El segundo descriptor ser� el de
; c�digo en modo protegido
SelectorCodigo32  
    dw 0FFFFh     ; bits 0-15 longitud
    dw 0          ; bits 0-15 direcci�n base
    db 0          ; bits 16-23 direcci�n base
    db 10011010b  ; bits P,DPL,DT y tipo
    db 11001111b  ; bits G,D y bits 16-19 longitud
    db 0          ; bits 24-31 direcci�n base
    
; El tercer descriptor ser� el de
; datos en modo protegido
SelectorDatos32  
    dw 0FFFFh     ; bits 0-15 longitud
    dw 0          ; bits 0-15 direcci�n base
    db 0          ; bits 16-23 direcci�n base
    db 10010010b  ; bits P,DPL,DT y tipo
    db 11001111b  ; bits G,D y bits 16-19 longitud
    db 0          ; bits 24-31 direcci�n base

; El cuarto descriptor ser� el de
; c�digo en modo real
SelectorCodigo16
    dw 0FFFFh     ; bits 0-15 longitud
    dw 0          ; bits 0-15 direcci�n base
    db 0          ; bits 16-23 direcci�n base
    db 10011010b  ; bits P,DPL,DT y tipo
    db 00000000b  ; bits G,D y bits 16-19 longitud
    db 0          ; bits 24-31 direcci�n base
    
; El quinto descriptor ser� el de
; datos en modo real
SelectorDatos16  
    dw 0FFFFh     ; bits 0-15 longitud
    dw 0          ; bits 0-15 direcci�n base
    db 0          ; bits 16-23 direcci�n base
    db 10010010b  ; bits P,DPL,DT y tipo
    db 00000000b  ; bits G,D y bits 16-19 longitud
    db 0          ; bits 24-31 direcci�n base

; El sexto y �ltimo descriptor nos
; permitir� tratar con 4 Gb planos de memoria
SelectorPlano  
    dw 0FFFFh     ; bits 0-15 longitud
    dw 0          ; bits 0-15 direcci�n base
    db 0          ; bits 16-23 direcci�n base
    db 10010010b  ; bits P,DPL,DT y tipo
    db 11001111b  ; bits G,D y bits 16-19 longitud
    db 0          ; bits 24-31 direcci�n base
    
; El campo siguiente tendr� el tama�o
; y direcci�n f�sica donde est� la GDT,
; datos que se introducir�n en el registro GDTR

DatosGDTR
  ; El tama�o lo conocemos en este moemnto
  TamanoGDT dw NumDescriptores*8
  ; la direcci�n f�sica hay que calcularla    
  DireccionGDT dd 0 
        