Pila    segment stack 'stack'
        db 256 dup (?)        
Pila    ends
                                  

Datos   segment 'data'
        Saludo db '­Hola DOS!$'
Datos   ends

Codigo  segment 'code'
        assume CS:Codigo, DS:Datos, SS:Pila

Main:

        mov     ax, seg Datos
        mov     ds, ax                   
        mov     dx, offset Saludo
        mov     ah, 9                    
        int     21h                     

        mov     ah, 4Ch                
        int     21h

Codigo  ends

        end Main

