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
  MsgVector db 'Buscando en el vector '
    NumVector db '     ',13,10,'$'
    
  MsgEncontrado db 'IntGraf est� instalado.', 13, 10, '$'
  MsgNoEncontrado db 'IntGraf no est� instalado.', 13, 10, '$'
       
Datos   ends

;*********************
; Segmento de c�digo
;*********************
Codigo  segment 'code'
        assume CS:Codigo, DS:Datos, SS:Pila

Main:
        ; Configuramos los registros de pila
        mov ax, seg Pila
        mov ss, ax
        mov sp, FinPila

        ; y los del segmento de datos
        mov ax, seg Datos
        mov ds, ax                   
        mov es, ax
        
        ; vamos a explorar 128 vectores
        mov cx, 128
Bucle:
        ; calculamos en AX el n�mero
        ; de vector para contar de
        ; 128 a 255, no al rev�s
        mov ax, 256
        sub ax, cx
        
        ; guardamos el n�mero de vector
        push ax

        ; lo convertimos a cadena
        mov di, offset NumVector+3
        call EnteroCadena
        
        ; y mostramos el n�mero de vector
        ; que est� inspeccion�ndose
        mov dx, offset MsgVector
        mov ah, 9
        int 21h
        
        ; recuperamos el n�mero de vector
        pop ax

        ; guardamos ES porque la pr�xima
        ; llamada al DOS lo modificar�
        push es
        
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
        
        ; el vector est� libre
        ; y por tanto no lo podemos
        ; invocar
        pop es
        
        ; seguimos buscando
        loop Bucle
        
    ; Hemos encontrado un vector
    ; que no est� a cero
Ocupado:
        ; recuperamos ES
        pop es
        ; ponemos AH a 0 para invocar
        ; al servicio de identificaci�n
        xor ah, ah
        ; Modificamos la instrucci�n 
        ; siguiente para que invoque a
        ; la interrupci�n deseada
        mov byte ptr [Interrupcion+1], al
Interrupcion:
        int 0 ; invocamos a la interrupci�n
        
        ; si nos devuelve 255 en AH
        cmp ah, 255
        ; hemos encontrado nuestro residente
        je Encontrado
        
        ; en caso contrario seguimos 
        loop Bucle
        
        ; si llegamos aqu� es que hemos
        ; recorrido todos los vectores
        ; sin encontrar el programa
        mov dx, offset MsgNoEncontrado
        jmp Notifica           
        
Encontrado:
        mov dx, offset MsgEncontrado
        
Notifica:
        ; notificamos si se encontr� o no
        mov ah, 9
        int 21h
        
        ; devolvemos el control al sistema
        mov     ah, 4Ch                
        int     21h

;-----------------------------
; Este procedimiento convierte
; el valor de AX en una cadena
; de hasta cinco caracteres
; 
; Entrada: AX = n�mero a convertir
;          ES:DI = destino cadena
;-----------------------------
EnteroCadena:
        ; DX debe estar a cero
        push dx ; lo guardamos
        xor dx, dx
        
        ; establecemos valor inicial
        mov byte ptr [di], '0'
        
        ; comprobamos si AL es cero
        or ax, ax
        ; de ser as�, no hay m�s
        ; que hacer
        jz FinConversion

        push bx ; guardamos bx
        ; y establecemos el divisor
        mov bx, 10        
        
 Bucle0:
        ; vamos dividiendo por 10
        div bx 
        
        ; qued�ndonos con el resto
        ; que convertimos a ASCII
        add dl, '0'
        ; y guardamos
        mov byte ptr [di], dl
        ; retrocediendo al d�gito anterior
        dec di
        
        ; eliminamos el contenido
        ; de DX para quedarnos con
        ; el cociente de AX
        xor dx, dx
        
        ; si el cociente es mayor que 9
        cmp ax, 9
        ; seguimos dividiendo
        ja Bucle0
        
        ; en caso contrario guardamos
        add al, '0'
        mov byte ptr [di], al
        
        pop bx ; recuperamos BX
        
FinConversion:
        pop dx ; recuperamos DX
        ret


Codigo  ends

        end Main

