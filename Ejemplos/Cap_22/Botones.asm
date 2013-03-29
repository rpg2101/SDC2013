    .586  ; Asumimos un procesador Pentium
    ; Trabajaremos con un modelo
    ; de memoria plano
    .model flat,stdcall 

    .stack
    
; Incluimos definiciones de estructuras
; y constantes
include windows.inc 

; así como los prototipos de las funciones
; de uso más habitual
include kernel32.inc 
include user32.inc 

; Importamos las bibliotecas para que el
; enlazador pueda vincular adecuadamente
; las llamadas
includelib kernel32.lib 
includelib user32.lib 

; Estructura para preparar los datos
; de los controles que incluiremos
DatosControl Struct
   Manejador DWORD ?
   Clase   DWORD ?
   PosX    DWORD ?
   PosY    DWORD ?
   Ancho   DWORD ?
   Alto    DWORD ?
   Estilo  DWORD ?
   Texto   DWORD ?
DatosControl Ends

	.Data 

   ; Estructura con todos los datos
   ; necesarios para registrar la 
   ; clase de ventana
   ClaseVentana WNDCLASSEX <size WNDCLASSEX, 0, ProcVentana,0,0,0,0,0,COLOR_BTNSHADOW,0, NombreClase,0>
     
   ; Identificador de la clase de ventana
   NombreClase db 'MiClaseVentana',0

   ; Título de la ventana
   NombreVentana db 'Título de la ventana', 0

   ; Manejador de la ventana
   Manejador DWORD ?
   
   ; Para ir recuperando mensajes
   Mensaje MSG <>

   ; Número de controles a insertar
   NumControles DWORD 8
   
   ; ------ NO INCLUIR NADA ENTRE ESTAS ESTRUCTURAS
   Btn1 DatosControl <?,ClaseBoton,24,24,164,48,BS_PUSHBUTTON,MsgPush>
   Btn2 DatosControl <?,ClaseBoton,260,24,164,48,BS_DEFPUSHBUTTON,MsgDefPush>
   Btn3 DatosControl <?,ClaseBoton,24,120,164,48,BS_AUTOCHECKBOX,MsgCheckBox>
   Btn4 DatosControl <?,ClaseBoton,260,120,164,48,BS_AUTO3STATE,Msg3State>
   Btn5 DatosControl <?,ClaseBoton,24,216,164,48,BS_AUTORADIOBUTTON,MsgRadio1>
   Btn6 DatosControl <?,ClaseBoton,260,216,164,48,BS_AUTORADIOBUTTON,MsgRadio2>   

   Lbl1 DatosControl <?,ClaseTexto,24,168,164,24,SS_CENTER,MsgInactivo>
   
   Edit1 DatosControl <?,ClaseEdit,24,320,240,24*5,ES_LOWERCASE Or ES_MULTILINE Or ES_WANTRETURN Or ES_AUTOVSCROLL,Texto>
   ;-------- DE LO CONTRARIO EL BUCLE NO FUNCIONARÍA
   
   ; Textos para los controles
   MsgPush db 'Botón normal',0
   MsgDefPush db 'Botón por defecto',0
   MsgCheckBox db 'Marcar/Desmarcar',0
   Msg3State db 'Tres estados',0
   MsgRadio1 db 'Opción 1',0
   MsgRadio2 db 'Opción 2',0
  
   MsgInactivo db 'Inactivo',0
   MsgActivo   db 'Activo',0
  
   ; Nombres de las clases de los controles
   ClaseBoton db 'BUTTON', 0
   ClaseTexto db 'STATIC', 0
   ClaseEdit db 'EDIT',0
  
   ; Espacio temporal para recuperar el
   ; texto de los controles
   Texto db 128 dup(0)
     
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
  
  ; Guardamos el manejador
  mov Manejador, eax

  ; Apuntamos al primer control a crear
  mov esi, Offset Btn1
  ; Número de controles a crear
  mov ecx, NumControles
  
CreaControles:  
  ; Guardamos los registros ECX y ESI
  push ecx
  push esi
  ; Añadimos los estilos apropiados
  or [esi].DatosControl.Estilo, WS_CHILD Or WS_VISIBLE
  ; Y creamos el control
  invoke CreateWindowEx, 0, 
    [esi].DatosControl.Clase, 
    [esi].DatosControl.Texto, 
    [esi].DatosControl.Estilo, 
    [esi].DatosControl.PosX, 
    [esi].DatosControl.PosY, 
    [esi].DatosControl.Ancho, 
    [esi].DatosControl.Alto,
    Manejador, 0, ClaseVentana.hInstance, 0

   ; Guardamos su manejador
   mov [esi].DatosControl.Manejador,eax

   ; Recuperamos los registros
   pop esi
   pop ecx    
   
   ; Hacemos avanzar ESI
   add esi, size DatosControl
   
   ; Y seguimos hasta terminar el bucle
   loop CreaControles

;---------------------------------
; Bucle de proceso de mensajes
;---------------------------------
Bucle: 

  ; Obtenemos un mensaje de la cola
  invoke GetMessage, Offset Mensaje, 0, 0, 0
  
  ; Si EAX = 0 hay que salir
  or eax, eax
  jz Salir
  
  ; En caso contrario lo despachamos
  invoke TranslateMessage, Offset Mensaje
  invoke DispatchMessage, Offset Mensaje
  
  ; y seguimos esperando mensajes
  jmp Bucle
  
Salir: ; Se ha recibido EAX = 0 hay que terminar
  ; Facilitamos en EAX el contenido
  ; del wParam del mensaje
  mov eax, Mensaje.wParam
  ; y volvemos
  ret  
  
;---------------------------------------------
; Este procedimiento debería procesar
; los mensaje provenientes de las ventanas
;--------------------------------------------
ProcVentana proc hWnd:HWND, uMesg:UINT, 
          wParam:WPARAM, lParam:LPARAM

  ; Comprobamos el mensaje
  cmp uMesg, WM_DESTROY
  je Quit ; y saltamos al punto adecuado

  ; Ver si es la pulsación de un botón
  cmp uMesg, WM_COMMAND
  jne ProcesoPorDefecto
  
  ; Ver si corresponde al Edit
  mov edx,Edit1.Manejador
  cmp lParam, edx
  jne ClicBoton
  
ProcesoPorDefecto:  
  
  ; Pedimos a Windows que procese el
  ; mensaje él mismo
  invoke DefWindowProc, hWnd,uMesg,wParam,lParam  
  
  ret ; y volvemos

ClicBoton: ; Se ha pulsado uno de los botones

  ; Obtenemos el texto que contiene el botón pulsado
  invoke SendMessage, lParam, WM_GETTEXT, 128, offset Texto
  ; y lo mostramos como título de ventana
  invoke SendMessage, Manejador, WM_SETTEXT, 0, offset Texto

  ; Obtenemos el estado del boton AUTOCHECKBOX
  invoke SendMessage,Btn3.Manejador,BM_GETCHECK,0,0
  ; Si no está pulsado
  cmp eax, BST_CHECKED
  jne Inactivo ; saltamos
  
  ; Inidicar el estado del botón en la etiqueta de texto
  invoke SetWindowText,Lbl1.Manejador,offset MsgActivo
  
  ret ; volver
    
Inactivo:  
  invoke SetWindowText,Lbl1.Manejador,offset MsgInactivo

  ret 

Quit: ; Se ha pedido la salida
  ; Llamamos a PostQuitMessage
  invoke PostQuitMessage, 0 
  ; Ponemos EAX a 0
  xor eax, eax
  
  ret  ; y volvemos
  
ProcVentana Endp  

	end Main 

