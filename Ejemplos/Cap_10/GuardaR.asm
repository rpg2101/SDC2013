        segment Datos
; Reservamos espacio para poder
; guardar el contenido de la pantalla
Pantalla resb 25*80*2

        segment Pila stack
          resb 64
FinPila:          

        ; Segmento de código
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; Configuramos DS
        ; para acceder a la pantalla
        mov ax, 0b800h
        mov ds, ax
        
        ; Llenamos la pantalla de asteriscos
        mov cx, 2000 ; 2000 caracteres
        xor bx, bx   ; desde el principio de pantalla
        mov al, '*'  ; asteriscos
        mov ah, 70h  ; en vídeo inverso

        ; Guardamos el contenido
        ; de la pantalla
        call GuardaPantalla

Llena:
        mov [bx], ax ; introducimos carácter y atributo
        inc bx       ; pasamos a la posición siguiente
        inc bx
        loop Llena   ; y repetimos hasta el final
        
        ; esperamos la pulsación de una tecla
        xor ah, ah
        int 16h

        ; restauramos el contenido de la pantalla
        call RecuperaPantalla        
        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h


;----------------------------
; Procedimiento para guardar
; el contenido de la pantalla
; en la variable Pantalla
;----------------------------
GuardaPantalla:
       pusha ; guardar registros
       
        ; DS:SI apunta a la pantalla
        mov ax, 0b800h
        mov ds, ax
        xor si, si
        
        ; ES:DI apunta a nuestra variable
        mov ax, Datos
        mov es, ax
        mov di, Pantalla
        
        ; efectuamos la transferencia
        call TransfiereDatos
       
        ; restaurar registros
        popa
        
        ; y devolvemos el control
        ret
        
;----------------------------
; Procedimiento para retaurar
; el contenido de la pantalla
; desde la variable Pantalla
;----------------------------
RecuperaPantalla:
        ;pusha ; guardar registros
        push ax
        push ds
        push es
        push si
        
        ; DS:SI apunta a la variable
        mov ax, Datos
        mov ds, ax
        mov si, Pantalla
        
        ; ES:DI apunta a la pantalla
        mov ax, 0b800h
        mov es, ax
        xor di, di
        
        ; efectuamos la transferencia
        call TransfiereDatos
        
        ; restaurar registros
        ;popa
        pop si
        pop es
        pop ds
        pop ax
        
        ; y devolvemos el control
        ret

;----------------------------
; Procedimiento que efectúa 
; la transferencia de datos
;----------------------------
TransfiereDatos:
        ; Vamos a copiar 4000 bytes
        mov cx, 4000
        cld ; incrementar automáticamente SI y DI
        
 Bucle0:
        ; movemos el contenido de la celdilla
        ; apuntada por SI a la que indica DI
        movsb 
        loop Bucle0 ; repetir
        
        ret ; devolvemos el control
        