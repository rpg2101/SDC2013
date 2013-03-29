        segment Pila stack
          resw 512
FinPila:

        ; Segmento de c�digo
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; partimos de la 
        ; columna 0
        xor dl, dl
        
        ; vamos a leer y
        ; escribir de la
        ; p�gina 0
        xor bh, bh
        
        ; 80 columnas en total
        mov cx, 80
Bucle:
       ; guardamos el contador
       ; del bucle
        push cx 
        
        ; ponemos el cursor
        ; en la l�nea 2
        mov ah, 2
        mov dh, 2
        int 10h
        
        ; y leemos el car�cter
        ; y atributo de esa posici�n
        mov ah, 8
        int 10h
        
        ; pasamos el atributo
        ; al registro BL
        mov bl, ah        
        
        ; colocamos el cursor
        ; en la l�nea 15
        mov ah, 2
        mov dh, 15
        int 10h

        ; y escribimos el car�cter
        ; y atributo antes le�dos        
        mov ah, 9
        mov cx, 1
        int 10h
        
        ; pasamos a la
        ; columna siguiente
        inc dl
        
        ; recuperamos el
        ; contador
        pop cx
        ; y repetimos
        loop Bucle        
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
