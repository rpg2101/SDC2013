        segment Pila stack
          resb 64
FinPila:          

        ; Segmento de c�digo
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; DS apuntar� al segmento
        ; de pantalla
        mov ax, 0b800h
        mov ds, ax
        
        mov dl, 8 ; primera l�nea
        mov cx, 8 ; n�mero de l�neas
        
BucleLineas:
        ; guardamos CX en la pila
        push cx
        
        mov dh, 25 ; primera columna
        mov cx, 20 ; n�mero de columnas
        
BucleColumnas:
 
         ; Calculamos la posici�n
         mov al, 160 ; bytes por l�nea
         mul dl ; por n�mero de l�nea
         
         mov bx, ax ; guardamos en BX
         
         mov al, 2 ; bytes por columna
         mul dh ; por n�mero de columna
         
         add bx, ax ; sumamos a bx
         
         ; ponemos un car�cter en esa posici�n
         mov word [bx], 070feh
         
         inc dh ; incrementamos la columna
         
         loop BucleColumnas ; y repetimos
         
         ; al finalizar todas las columnas
         ; de una l�nea
         
         pop cx ; recuperamos contador l�neas
         
         inc dl ; pasamos a l�nea siguiente
         
         loop BucleLineas ; y repetimos
        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

