        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Para guardar el punto de entrada
GestorXMS dd 0  

; Mensajes informativos        
MsgNoHay db 'No hay instalado un controlador XMS.$'
MsgFalloAsignacion db 'No puede asignarse el bloque.$'
MsgCorrecto db 'Proceso finalizado.$'

; Estructura para las transferencias
DatosTransferencia
  Longitud         dd 4000
  IdOrigen         dw 0
  DireccionOrigen  dd 0
  IdDestino        dw 0
  DireccionDestino dd 0

;*********************************
; Segmento de código
;*********************************
        segment Codigo
..start:
        ; Preparar los registros de pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; y del segmento de datos
        mov ax, Datos
        mov ds, ax

        ; comprobamos si existe
        mov ax, 4300h
        int 2Fh
        
        cmp al, 80h
        
        ; Si no hay controlador no
        ; podemos continuar
        jne NoHayXMS

        ; pedimos el punto de entrada
        ; al gestor XMS
        mov ax, 4310h  
        int 2fh
        
        ; y lo guardamos
        mov [GestorXMS], bx
        mov [GestorXMS+2], es

        ; Solicitamos 4 K de memoria
        mov dx, 4        
        mov ah, 9
        ; llamamos al gestor
        call far [GestorXMS]      
        
        ; comprobamos la existencia
        ; de un error
        or ax, ax
        jz FalloAlAsignar

        ; Tenemos en DX el identificador
        ; del bloque, lo guardamos
        mov [IdDestino], dx
        
        ; Establecemos la dirección
        ; de origen
        mov word [DireccionOrigen+2],0B800h
        
        ; y copiamos la memoria de pantalla
        ; en el bloque de memoria extendida
        mov si, DatosTransferencia
        mov ah, 0Bh
        call far [GestorXMS]
        
        ; borramos el contenido de pantalla
        call BORRA
        ; y esperamos la pulsación de una tecla
        xor ah, ah
        int 16h
                
        ; Invertimos los identificadores
        mov ax, [IdDestino]
        mov [IdOrigen], ax
        mov word [IdDestino], 0
        
        ; y las direcciones
        mov word [DireccionOrigen+2], 0
        mov word [DireccionDestino+2], 0B800h
        
        ; y copiamos la memoria extendida en
        ; la de pantalla
        mov si, DatosTransferencia
        mov ah, 0Bh
        call far [GestorXMS]
        
        ; liberamos el bloque de memoria
        mov dx, [IdOrigen]
        mov ah, 0Ah
        call far [GestorXMS]
        
        ; Terminamos
        mov dx, MsgCorrecto
        jmp Salir
        
FalloAlAsignar:
        ; No se puede asignar la memoria
        mov dx, MsgFalloAsignacion
        jmp Salir
                        
NoHayXMS:        
        ; indicamos que no hay controlador
        mov dx, MsgNoHay
        
Salir:  
        ; mostramos el mensaje
        mov ah, 9
        int 21h
              
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h

%include "Borra.inc"
