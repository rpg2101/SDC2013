        segment Pila stack
          resw 512
FinPila:

        segment Datos
MsgHayEPP db 'Est  instalada la BIOS EPP$'
MsgNoHayEPP db 'No est  instalada la BIOS EPP$'

        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS apunta al segmento
        ; que contiene los datos
        mov ax, Datos
        mov ds, ax

        ; Servicio 2 con
        ; AL a 0
        mov ax, 200h
        ; BH y BL tienen P
        mov bx, 'PP'
        ; CH tiene E
        mov ch, 'E'
        ; comprobamos el
        ; puerto 0
        xor dx, dx
        
        ; llamamos
        int 17h
        
        ; comprobamos que 
        ; AH sea cero
        or ah, ah
        jnz NoHayEPP
        
        ; que AL contenga 'E'
        cmp al, 'E'
        jnz NoHayEPP
        ; y que CX tenga 'PP'
        cmp cx, 'PP'
        jnz NoHayEPP
        
        ; Si se pasan todas las
        ; condiciones es que
        ; existe la BIOS EPP        
        mov dx, MsgHayEPP
        jmp Salir

NoHayEPP:        
        ; Si no se cumple alguna
        ; de las condiciones es
        ; que no existe la BIOS EPP
        mov dx, MsgNoHayEPP
        
Salir:
        ; mostramos el mensaje
        mov ah, 9
        int 21h
                
        ; y salimos
        mov ah, 4ch
        int 21h
        
