        segment Pila stack
          resb 64
InicioPila:

        ; Segmento de código
        segment Codigo
..start:

        ; Inicializamos los registros
        ; relacionados con la pila
        mov ax, Pila
        mov ss, ax
        mov sp, InicioPila
        
        pushf ; guardamos registro de indicadores
        pop ax ; recuperando en AX
        or ax, 1 ; activamos el bit 0
        push ax ; guardamos AX en la pila
        popf ; y devolvemos al registro de indicadores
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

