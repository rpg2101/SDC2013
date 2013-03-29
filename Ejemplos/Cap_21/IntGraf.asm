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
; Segmento de c�digo
;*********************
Codigo  segment 'code'
        assume CS:Codigo, DS:Datos, SS:Pila

        ; saltamos al programa principal
        ; que buscar� un vector e instalar�
        ; el programa residente
        jmp Main
        
;-------------------------
; Este fragmento de c�digo
; quedar� residente y se
; ejecutar� al invocar una
; determinada interrupci�n
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
        
Main: ; Aqu� comenzar� el programa
      ; cuando se ejecute desde la
      ; l�nea de comandos
      
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
        ; calculamos en AX el n�mero
        ; de vector para contar de
        ; 128 a 255, no al rev�s
        mov ax, 256
        sub ax, cx
        
        ; obtenemos la direcci�n del vector
        mov ah, 35h
        int 21h
        
        ; si BX no es cero
        or bx, bx
        ; es que est� ocupado
        jnz Ocupado
        
        ; si ES no es cero
        mov bx, es
        or bx, bx
        ; es que est� ocupado
        jnz Ocupado
         
        ; si llegamos aqu� es que el
        ; vector est� libre
        mov dx, offset GestorServicio
        ; DS:DX apunta al nuevo gestor
        push cs
        pop ds
        
        ; modificamos el vector
        mov ah, 25h
        int 21h
        
        ; calculamos el tama�o actual
        ; del programa
        mov ax, FinPila
        ; sumando pila, datos y c�digo
        add ax, FinDatos
        ; m�s el PSP
        add ax, Main+256
        ; convertimos en p�rrafos
        mov cl, 4
        shr ax, cl
        ; y tenemos en cuenta los
        ; ajustes
        add ax, 3
        
        ; dejamos el c�digo residente
        ; saliendo con el c�digo 0
        mov dx, ax
        xor al, al
        mov ah, 31h
        
        int 21h
        
Ocupado:
        ; continuamos buscando
        loop Bucle

        ; si llegamos aqu� es que no
        ; hay ning�n vector libre
        
        ; mostramos el mensaje de error        
        mov dx, offset MsgError
        mov ah, 9
        int 21h
        
        ; devolvemos el control al sistema
        mov     ah, 4Ch                
        int     21h


Codigo  ends

        end Main

