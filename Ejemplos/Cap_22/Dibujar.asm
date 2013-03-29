    .586  ; Asumimos un procesador Pentium
    ; Trabajaremos con un modelo
    ; de memoria plano
    .model flat,stdcall 

; Incluimos definiciones de estructuras
; y constantes
include windows.inc 

; así como los prototipos de las funciones
; de uso más habitual
include kernel32.inc 
include user32.inc 

; Añadimos los datos de GDI
include gdi32.inc
includelib gdi32.lib

; Importamos las bibliotecas para que el
; enlazador pueda vincular adecuadamente
; las llamadas
includelib kernel32.lib 
includelib user32.lib 

	.Data 

   ; Estructura con todos los datos
   ; necesarios para registrar la 
   ; clase de ventana
   ClaseVentana WNDCLASSEX <size WNDCLASSEX, 0, ProcVentana,0,0,0,0,0,COLOR_BACKGROUND,0, NombreClase,0>
     
   ; Identificador de la clase de ventana
   NombreClase db 'MiClaseVentana',0

   ; Título de la ventana
   NombreVentana db 'Título de la ventana', 0

   ; Para ir recuperando mensajes
   Mensaje MSG <>

   ; Datos necesarios para dibujar   
   Datos PAINTSTRUCT <>
   Texto db 'Dibujando en ensamblador',0

	.Code 
	
Main: 

  ; Obtenemos el identificador de la
  ; aplicación en EAX
  invoke GetModuleHandle, 0
  ; y lo colocamos donde debe estar
  ; en la estructura
  mov [ClaseVentana.hInstance], eax
  
  ; Registramos la clase de ventana
  invoke RegisterClassEx, offset ClaseVentana
  
  ; Creamos la ventana
  invoke CreateWindowEx, 0, 
    Offset NombreClase, 
    Offset NombreVentana, 
    WS_VISIBLE Or WS_OVERLAPPEDWINDOW, 
    CW_USEDEFAULT, CW_USEDEFAULT, 
    CW_USEDEFAULT, CW_USEDEFAULT, 
    0, 0, ClaseVentana.hInstance, 0
  
  ; Si no ha podido crearse la ventana
  or eax, eax
  ; salir
  jz Salir

Bucle: ; Bucle de proceso de mensajes

  ; Obtenemos un mensaje de la cola
  invoke GetMessage, Offset Mensaje, 0, 0, 0
  
  ; Si EAX = 0 hay que salir
  or eax, eax
  jz Salir
  
  ; En caso contrario lo despachamos
  invoke DispatchMessage, Offset Mensaje
  ; y seguimos esperando mensajes
  jmp Bucle
  
Salir: ; Se ha recibido EAX = 0 hay que terminar
  ; Facilitamos en EAX el contenido
  ; del wParam del mensaje
  mov eax, Mensaje.wParam
  ; y volvemos
  ret  
  
; Este procedimiento debería procesar
; los mensaje provenientes de las ventanas
ProcVentana proc hWnd:HWND, uMesg:UINT, 
          wParam:WPARAM, lParam:LPARAM

  ; Comprobamos el mensaje
  cmp uMesg, WM_DESTROY
  je Quit ; y saltamos al punto adecuado

  ; Si hay que dibujar la ventana
  cmp uMesg, WM_PAINT
  je Dibujar ; Saltar

  ; Pedimos a Windows que procese el
  ; mensaje él mismo
  invoke DefWindowProc, hWnd,uMesg,wParam,lParam  
  
  ret ; y volvemos

Quit: ; Se ha pedido la salida
  ; Llamamos a PostQuitMessage
  invoke PostQuitMessage, 0 
  ; Ponemos EAX a 0
  xor eax, eax
  
  ret ; y volvemos
  
Dibujar: ; Hay que dibujar en la ventana

  ; Obtenemos los datos que encesitamos
  invoke BeginPaint,hWnd,offset Datos  
  
  ; Nos movemos a una cierta posición
  invoke MoveToEx,Datos.hdc, 100,100,0
  ; Dibujamos una línea
  invoke LineTo,Datos.hdc, 320, 240
  
  ; Establecemos colores de fondo y tinta
  ; para el texto
  invoke SetBkColor,Datos.hdc,0FFFFFFh
  invoke SetTextColor,Datos.hdc,0FFh
  
  ; y lo imprimimos
  invoke TextOut,Datos.hdc,320,240,offset Texto,sizeof Texto
  
  ; Hemos terminado de dibujar
  invoke EndPaint,hWnd,offset Datos
  
  ret ; volvemos
  
ProcVentana Endp  

	end Main 

