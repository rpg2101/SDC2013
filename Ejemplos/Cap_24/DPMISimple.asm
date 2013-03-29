        cpu 386  ; Vamos a usar instrucciones 386
        
        ; Generaremos un COM
        org 100h

;*********************************
; Segmento de código
;*********************************
Inicio:
        ; Ajustamos el bloque de memoria
        ; ocupado por el programa
        mov bx, FinPrograma
        ; Convertimos a párrafos
        shr bx, 4
        inc bx
        ; ajustamos
        mov ah, 4ah
        int 21h

        ; Comprobamos si hay un anfitrión
        ; DPMI instalado en el sistema
        mov ax,1687h
        int 2fh
        
        ; en caso de no ser así
        or ax, ax
        ; salir directamente
        jnz Error

        ; Si no se permite la ejecución de
        ; aplicaciones de 32 bits
        test bx, 1
        ; salir
        jz Error

        ; Guardamos la dirección del punto
        ; de entrada al modo protegido
        mov [DirModoProtegido],di
        mov [DirModoProtegido+2],es
        
        ; ¿Hay que reservar memoria?
        or si, si
        ; si no es así saltar
        jz EntrarModoProtegido 

        ; Reservamos el número de párrafos
        ; solicitado por el anfitrión           
        mov bx, si
        mov ah, 48h
        int 21h
        jc ErrorMemoria
        
        ; Ponemos en ES el segmento del
        ; área de datos
        mov es, ax
        
EntrarModoProtegido:
        ; indicamos 32 bits
        mov ax, 1
        ; Entramos en modo protegido
        call far [DirModoProtegido]
        ; saltar si hay error
        jc ErrorEntrada

        ;--------------------------
        ; Estamos en modo protegido
        ;--------------------------
        
        ; Solicitamos un selector para acceder
        ; al segmento de pantalla
        mov ax,2
        mov bx,0b800h
        int 31h
        ; si no se puede obtener saltar
        jc SalirModoProtegido
        
        ; Ponemos el selector en ES
        mov es,ax
        
        ; Llenamos la pantalla de asteriscos
        xor di, di
        mov ax,1F2Ah
        mov cx,2000
        cld
        rep stosw
        
SalirModoProtegido:        
        ; Devolvemos el control al modo real
        mov ah, 4ch
        int 21h
        
        ; Apartados que muestran los 
        ; distintos errores
ErrorMemoria:
        mov dx, MsgErrorMemoria
        jmp Salir
        
ErrorEntrada:
        mov dx, MsgErrorEntrada
        jmp Salir
                
Error:
        ; No hay un anfitrión DPMI instalado
        mov dx, MsgNoDPMI

Salir:        
        ; Mostrar el último mensaje
        mov ah, 9
        int 21h

        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h

; Para guardar la dirección de entrada a modo protegido
DirModoProtegido dd 0

; Mensajes informativos        
MsgNoDPMI db 'No es posible entrar en modo protegido.$'
MsgErrorEntrada db 'Error al intentar cambiar.$'
MsgModoProtegido db 'Estoy en modo protegido.$'
MsgErrorMemoria db 'No puede asignarse la memoria.$'

FinPrograma:
