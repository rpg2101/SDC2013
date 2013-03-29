        segment Pila stack
          resw 512
       
        ; Segmento de código
        segment Codigo
..start:

        ; provocamos la 
        ; excepción 0
        int 0
        
        ; que se produce
        ; automáticamente al
        ; ejecutar un división 
        ; por 0
        mov ax, 10
        xor bl, bl
        div bl
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
