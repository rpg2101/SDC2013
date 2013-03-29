Codigo segment 'code'

        org 100h
Entrada:
        jmp Main

Saludo  db '­Hola COM!$'

Main:

        mov     dx, offset Saludo
        mov     ah, 9                    
        int     21h                     

        mov     ah, 4Ch                
        int     21h

Codigo ends
        end Entrada

