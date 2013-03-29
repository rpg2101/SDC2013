        segment Pila stack
          resw 512
FinPila:

        segment Datos
; Cadena de datos a mostrar        
Fecha     db 'Fecha: '
 Dia      db '  '
          db '/'
 Mes      db '  '
          db '/'
 Ano      db '    '
          db ' - '
Hora      db 'Hora: '
 Horas    db '  '
          db ':'
 Minutos  db '  '
          db ':'
 Segundos db '  '
          db '$'
       
        ; Segmento de código
        segment Codigo
..start:
       ; Configuramos los registros
       ; de pila
       mov ax, Pila
       mov ss, ax
       mov sp, FinPila
       
       ; DS y ES apuntan
       ; al segmento de datos
       mov ax, Datos
       mov es, ax
       mov ds, ax

       ; recuperamos la fecha
       mov ah, 4
       int 1Ah
       
       ; extraemos el día
       mov di, Dia       
       mov al, dl
       call Convierte
       
       ; el mes
       mov di, Mes
       mov al, dh
       call Convierte
       
       ; y el año
       mov di, Ano
       mov al, ch
       call Convierte
       mov al, cl
       call Convierte
       
       ; recuperamos la hora
       mov ah, 2
       int 1Ah
       
       ; extraemos las horas
       mov di, Horas
       mov al, ch
       call Convierte
       
       ; los minutos
       mov di, Minutos
       mov al, cl
       call Convierte
       
       ; y los segundos
       mov di, Segundos
       mov al, dh
       call Convierte
       
       ; mostramos la información
       mov dx, Fecha
       mov ah, 9
       int 21h

Fin:        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
;--------------------------
; Esta rutina recibe en AL
; un número BCD empaquetado
; y en DI el destino donde
; debe alojar los dos dígitos
; convertidos.
;---------------------------        
Convierte:
        ; guardamos el dato
        push ax
        
        ; nos quedamos con el
        ; primer dígito, que
        ; viene en los bits 4-7
        shr al, 4
        ; convertimos a ASCII
        add al, '0'
        ; y guardamos
        stosb
        
        ; recuperamos el dato
        pop ax
        
        ; nos quedamos con el
        ; segundo dígito, que
        ; viene en los bits 0-3
        and al,0fh
        ; convertimos a ASCII
        add al, '0'
        ' y guardamos
        stosb
        
        ret ' volver