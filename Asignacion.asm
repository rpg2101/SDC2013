
        ; Definimos el segmento de datos
        segment Datos
        
; definiendo varios campos
Asterisco db '*'
Blanco    db 0f0h
Posicion  dw 3280 ; l:20,c:40
Valor32   dd 0        

        ; Segmento para la pila
        segment Pila stack
          resb 256
InicioPila:

        ; Segmento de código
        segment Codigo
..start:

        ; inicializamos ds
        mov ax, Datos
        ; para acceder a los datos
        mov ds, ax

        ; preparamos el registro es
        ; para acceder al segmento
        ; donde está el contenido de 
        ; la pantalla        
        mov ax, 0b800h
        mov es, ax

        ; recuperamos en AL el
        ; valor que hay en Asterisco
        mov al,[Asterisco]
        
        ; en AH el color
        mov ah,[Blanco]

        ; y en BX la posición
        mov bx,[Posicion]

        ; transferimos el contenido
        ; de AX a la dirección ES:BX
        mov [es:bx], ax

        ; escribimos directamente en la pantalla un valor inmediato
        mov word [es:5*160+35*2], 00a41h
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

