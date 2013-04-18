segment Pila stack

FinPila:          
               
        segment Codigo
..start:
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        mov ax, 0b800h
        mov ds, ax
        
        mov dl, 8 ; comienza linea
        mov cx, 10 ; repite lineas
       
	    xor al,al
        mov dh,20 ;comienza columna
        
BucleLineas:
        push cx  
                       
	    mov ah,20   ;
    	sub ah,al
    	push ax
        and ax,0FF00h
        shr ax,8
    	mov cx, ax ; repite columnas
    	xor al,al

BucleColumnas:
 
         ; Calculamos la posici�n
         mov al, 160 ; bytes por l�nea
         mul dl ; por n�mero de l�nea
         
         mov bx, ax ; guardamos en BX
         
         mov al, 2 ; bytes por columna
         mul dh ; por n�mero de columna
         
         add bx, ax ; sumamos a bx
         
         mov word [bx], 070feh
         
       	 inc dh ; incrementamos la columna

	loop BucleColumnas ; y repetimos
    	 pop ax
    	 
	     inc al         
         inc al
	 
	     pop cx ; recuperamos contador l�neas
         
         inc dl ; pasamos a l�nea siguiente 
         
         mov dh,dl
         add dh,12

         loop BucleLineas ; y repetimos
        
Salir:  mov ah, 4ch
        int 21h
