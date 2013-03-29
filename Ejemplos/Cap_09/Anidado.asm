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

        ; DS apuntará al segmento
        ; de pantalla
        mov ax, 0b800h
        mov ds, ax
        
        mov dl, 8 ; primera línea
        mov cx, 8 ; número de líneas
        
BucleLineas:
        ; guardamos CX en la pila
        push cx
        
        mov dh, 25 ; primera columna
        mov cx, 20 ; número de columnas
        
BucleColumnas:
 
         ; Calculamos la posición
         mov al, 160 ; bytes por línea
         mul dl ; por número de línea
         
         mov bx, ax ; guardamos en BX
         
         mov al, 2 ; bytes por columna
         mul dh ; por número de columna
         
         add bx, ax ; sumamos a bx
         
         ; ponemos un carácter en esa posición
         mov word [bx], 070feh
         
         inc dh ; incrementamos la columna
         
         loop BucleColumnas ; y repetimos
         
         ; al finalizar todas las columnas
         ; de una línea
         
         pop cx ; recuperamos contador líneas
         
         inc dl ; pasamos a línea siguiente
         
         loop BucleLineas ; y repetimos
        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

