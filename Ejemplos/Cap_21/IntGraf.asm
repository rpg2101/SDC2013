;*********************
; Segmento de pila
;*********************
Pila    segment stack 'stack'
        db 256 dup (?)  
  FinPila:              
Pila    ends
                                  
;*********************
; Segmento de datos
;*********************
Datos   segment 'data'

  ; Mensajes informativos
  MsgError db 'No es posible instalar. '
    db 'No se encuentra un vector libre.$'
       
  FinDatos:      
Datos   ends

;*********************
; Segmento de código
;*********************
Codigo  segment 'code'
        assume CS:Codigo, DS:Datos, SS:Pila

        ; saltamos al programa principal
        ; que buscará un vector e instalará
        ; el programa residente
        jmp Main
        
;-------------------------
; Este fragmento de código
; quedará residente y se
; ejecutará al invocar una
; determinada interrupción
;-------------------------
GestorServicio:
        ; si AH no es 0
        or ah, ah
        ; no hacemos nada
        jnz FinGestor
        
        ; si es 0 devolvemos
        ; 255 en AH
        mov ah, 255
        
FinGestor:
        ; salimos del gestor
        iret        
;-------------Fin del gestor        
        
Main: ; Aquí comenzará el programa
      ; cuando se ejecute desde la
      ; línea de comandos
      
        ; Configuramos los registros de pila
        mov ax, seg Pila
        mov ss, ax
        mov sp, FinPila

        ; y los del segmento de datos
        mov ax, seg Datos
        mov ds, ax                   
        
        ; vamos a explorar 128 vectores
        mov cx, 128
Bucle:
        ; calculamos en AX el número
        ; de vector para contar de
        ; 128 a 255, no al revés
        mov ax, 256
        sub ax, cx
        
        ; obtenemos la dirección del vector
        mov ah, 35h
        int 21h
        
        ; si BX no es cero
        or bx, bx
        ; es que está ocupado
        jnz Ocupado
        
        ; si ES no es cero
        mov bx, es
        or bx, bx
        ; es que está ocupado
        jnz Ocupado
         
        ; si llegamos aquí es que el
        ; vector está libre
        mov dx, offset GestorServicio
        ; DS:DX apunta al nuevo gestor
        push cs
        pop ds
        
        ; modificamos el vector
        mov ah, 25h
        int 21h
        
        ; calculamos el tamaño actual
        ; del programa
        mov ax, FinPila
        ; sumando pila, datos y código
        add ax, FinDatos
        ; más el PSP
        add ax, Main+256
        ; convertimos en párrafos
        mov cl, 4
        shr ax, cl
        ; y tenemos en cuenta los
        ; ajustes
        add ax, 3
        
        ; dejamos el código residente
        ; saliendo con el código 0
        mov dx, ax
        xor al, al
        mov ah, 31h
        
        int 21h
        
Ocupado:
        ; continuamos buscando
        loop Bucle

        ; si llegamos aquí es que no
        ; hay ningún vector libre
        
        ; mostramos el mensaje de error        
        mov dx, offset MsgError
        mov ah, 9
        int 21h
        
        ; devolvemos el control al sistema
        mov     ah, 4Ch                
        int     21h


Codigo  ends

        end Main

