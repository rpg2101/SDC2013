
        segment Pila stack
          resw 512
FinPila:          

        ; Segmento de código
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; ES:DI apuntan al inicio
        ; de la memoria de pantalla
        mov ax, 0b800h
        mov es, ax
        xor di, di
        
        ; Carácter y número de ciclos
        mov ax, 6020h
        mov cx, 2000
        
        ; incrementando el
        ; valor de DI
        cld
            
        ; llenamos la pantalla
        rep stosw

        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
