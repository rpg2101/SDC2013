        segment Pila stack
          resb 64
InicioPila:

        ; Segmento de c�digo
        segment Codigo
..start:
        ; preparamos DS y BX
        ; para acceder al car�cter
        ; de la fila 12 columna 2
        ; de la pantalla de texto
        mov ax, 0b800h
        mov ds, ax
        mov bx, 160*12+1*2

        ' Recuperamos el car�cter en AL
        mov al, [bx]

        cmp al, 'A' ' Comparamos con la A
        jb Salir    ' si es inferior saltamos
        cmp al, 'Z' ' Comparamos con la Z
        ja Salir    ' si es superior saltamos
        
        ; Convertimos a min�scula
        add al, 32 ' sumando 32
        mov [bx], al ' y escribiendo en pantalla
        
Salir:
        ' en cualquier caso modificamos el atributo
        inc bx
        ' para resaltar el car�cter tanto si se ha
        ' cambiado como si no
        mov byte [bx], 0fh
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

