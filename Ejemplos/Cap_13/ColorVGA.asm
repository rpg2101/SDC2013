; Macro que introduce las
; sentencias necesarias para
; esperar la pulsación de 
; una tecla sin modificar AX
%macro EsperaTecla 0
    push ax
    xor ah, ah
    int 16h
    pop ax
%endmacro
    
        segment Pila stack
          resw 512
FinPila:

        segment Datos
; Reservamos espacio para
; dos paletas de color
Paleta1 resb 768
Paleta2 resb 768
; Un elemento que define
; el color negro
Negro db 0, 0, 0
                
        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; y los registros que
        ; apuntan a los datos
        mov ax, Datos
        mov ds, ax
        mov es, ax

        ; activamos el modo
        ; 320x200 con 256 colores
        mov al, 13h
        call EstableceModo
        
        ; Dibujamos las
        ; 256 líneas
        call DibujaLineas
        
        ; esperamos la pulsación
        ; de una tecla
        EsperaTecla
        
        ; Guardamos la paleta
        ; por defecto
        call GuardaPaleta
        
        ; Establecemos una paleta
        ; de color con degradados
        call PaletaDegradado
        
        EsperaTecla ; esperamos tecla

        ; Restauramos la paleta
        ; original
        call RestauraPaleta
        
        EsperaTecla ; esperamos tecla
        
        ; efectuamos un
        ; desplazamiento de colores
        call DesplazaColores
        
        EsperaTecla ; esperamos tecla
        
        ; Hacemos un fundido a negro
        call FundidoNegro
        
        ; volvemos al modo
        ; de vídeo de texto
        mov al, 3
        call EstableceModo
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h

;------------------------
; Esta rutina dibuja las
; líneas en pantalla
;------------------------        
DibujaLineas:
        pusha ; guardamos registros
        
        ; vamos a trazar
        ; 256 líneas
        mov cx, 255
Bucle0:
        ; fijamos el color
        mov al, cl
        
        ; y dibujamos una línea
        call LineaVertical
        
        ; repetimos
        loop Bucle0
        
        ; recuperamos registros
        popa
        
        ret ; y volvemos

;-------------------------
; Esta rutina dibuja una
; línea vertical completa
; en la posición horizontal
; facilitada en CX y el 
; color indicado en AL
LineaVertical:    
        pusha ; guardamos registros
        
        ; llevamos la posición
        ; horizontal a DX
        mov dx, cx
        ; centramos en pantalla 
        add dx, 30
        
        ; vamos a dibujar la
        ; linea desde 0 a 199
        mov cx, 199
        ; en la página 0
        xor bh, bh
        ; preparamos el servicio
        mov ah, 0Ch
        
BucleL0:
        ; El servicio espera las
        ; coordenadas en orden
        ; inverso
        xchg dx, cx
        
        ; dibujamos un punto
        int 10h
        
        ; volvemos a tener el
        ; contador en CX
        xchg dx, cx
        
        ; y repetimos hacia atrás
        loop BucleL0

        ; recuperamos registros
        popa
        
        ret ; y volvemos      
        

;-------------------------
; Esta rutina establece el
; modo gráfico deseado, que
; se facilitará en AL
;-------------------------
EstableceModo:
        ; Ponemos AH a cero
        xor ah, ah
        ; y establecemos el modo
        int 10h
        
        ret ; volver

;---------------------------
; Esta rutina guarda la paleta
; actual en Paleta2
;----------------------------
GuardaPaleta:
         pusha ; guardar registros
         
         ; leemos la paleta
         ; actual
         mov dx, Paleta2
         ; desde el elemento 0
         xor bx, bx
         ; 256 elementos
         mov cx, 256
         
         ; la obtenemos
         mov ax, 1017h
         int 10h
         
         popa ; recuperamos
         
         ret ; y volvemos

;------------------------------
; Esta rutina genera y activa
; una paleta compuesta de 
; degradados de color
;------------------------------
PaletaDegradado:
         pusha ; guardamos registros
         
         ; DI apunta a la paleta
         ; que vamos a generar
         ; matemáticamente         
         mov di, Paleta1
         
         ; dividimos el proceso
         ; en 4 bloques
         mov cx, 4
         
         ; AL rojo, BL verde
         ; BH azul
         xor al, al
         xor bl, bl
         xor bh, bh
         
BucleP1: 
         ; guardamos contador
         ; del bucle        
         push cx
         
         ; vamos a generar 64 entradas
         mov cx, 64
         
         cld ; incrementar DI
BucleP0:       
         ; almacenamos rojo  
         stosb 
         
         push ax
         mov al, bl
         stosb ; verde
         
         mov al, bh
         stosb ; y azul
         
         ; recuperamos rojo
         pop ax
         ; e incrementamos
         inc al
         
         ; repetimos bucle interno
         loop BucleP0

         ; ponemos a 0 el rojo
         xor al, al
         ; incrementamos verde
         add bh, 12
         ; y azul
         add bl, 4
         
         ; recuperamos contador
         pop cx
         ; y repetimos bucle externo
         loop BucleP1
         
         ; establecemos paleta
         mov ax, 1012h
         xor bx, bx
         mov cx, 256
         mov dx, Paleta1
         int 10h
         
         popa ; recuperamos registros
         
         ret ; y volvemos

;---------------------------
; Esta rutina restablece la
; paleta de colores original
;---------------------------
RestauraPaleta:
         pusha ; guardar registros
         
         ; restablecemos la 
         ; paleta original
         mov ax, 1012h
         xor bx, bx
         mov cx, 256
         mov dx, Paleta2
         int 10h
         
         popa ; restaurar
         
         ret ; y volver

;---------------------------
; Esta rutina rota los colores
; copiando los elementos de
; los registros del DAC
;---------------------------
DesplazaColores:
         pusha ; guardamos registros
         
         ; Hay 256 líneas
         mov cx, 256
BucleP2:
         push cx ; guardamos contador
         
         ; apuntamos al inicio
         ; de la paleta
         mov di, Paleta2
         mov si, Paleta2+3
         
         ; compuesta de
         ; 768 bytes
         mov cx, 768
         rep movsb

         ; Activamos la paleta
         ; recién generada         
         mov ax, 1012h
         mov bx, 1
         mov cx, 255
         mov dx, Paleta2
         int 10h
         
         ; y esperamos una
         ; fracción de segundo
         call Espera
         
         ; recuperamos contador
         pop cx
         
         ; y repetimos
         loop BucleP2                  

         ; recuperamos registros         
         popa
         
         ret ; y volvemos
         
;----------------------------
; Esta rutina efectúa un
; fundido a negro de la 
; Paleta1
;----------------------------         
FundidoNegro:
         ; Número de valores 
         ; para cada componente
         ; del color
         mov cx, 64

BucleF0:
         ; guardamos contador
         push cx
         
         ; la paleta tiene
         ; 768 bytes
         mov cx, 768
         
         ; vamos a ir leyendo
         ; y escribiendo en 
         ; la misma paleta
         mov si, Paleta1
         mov di, Paleta1
         
         ; dejamos DX preparado
         ; para establecerla
         mov dx, Paleta1
BucleF1:
         ; leemos un byte
         mov al, [si]
         ; comprobamos si es 0
         or al, al
         ; en caso afirmativo
         jz YaEsCero ; saltamos
         
         ; en caso contrario
         dec al ; reducimos
         ; y sustituimos
         mov [di], al
YaEsCero:
         ; avanzar en la paleta
         inc si
         inc di
         
         ; y repetir
         loop BucleF1
         
         ; establecer la 
         ; nueva paleta
         mov ax, 1012h
         mov bx, 0
         mov cx, 256
         int 10h

         ; y esperar un momento
         call Espera
                  
         ; recuperamos contador
         pop cx
         ; y repetimos bucle exterior
         loop BucleF0
         
         ret ; volver
                  
;-----------------------------
; Rutina que espera una fracción
; de segundo         
;-----------------------------
Espera:
         pusha ; guardar registros
         
         ; leer número de pulsos
         xor ah, ah
         int 1Ah
         
         ; copiar en BX
         mov bx, dx
         inc bx ; e incrementar
BucleE0:
         ; esperar hasta que 
         ; haya transcurrido
         int 1Ah
         cmp bx, dx
         
         ja BucleE0
         
         popa ; recuperar
         
         ret ; y volver
        