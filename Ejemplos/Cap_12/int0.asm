        segment Pila stack
          resw 512
       
        ; Segmento de c�digo
        segment Codigo
..start:

        ; provocamos la 
        ; excepci�n 0
        int 0
        
        ; que se produce
        ; autom�ticamente al
        ; ejecutar un divisi�n 
        ; por 0
        mov ax, 10
        xor bl, bl
        div bl
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
