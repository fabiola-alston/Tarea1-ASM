
; Proyecto en TASM 8086

.MODEL SMALL
.STACK 100h


DATA_SEG    SEGMENT ; Inicia el segmento de datos, para almacenar mensajes estaticos y variables relacionadas a las operaciones
    ;Variables de mensajes
    MENU db 10,13,10, "Digite:", 0ah,"", 0ah, "1. Ingresar calificaciones (15 estudiantes -Nombre Apellido1 Apellido2 Nota-)", 0ah, "2. Mostrar estadisticas.", 0ah, "3. Buscar estudiante por posicion (indice)", 0ah, "4. Ordenar calificaciones (ascendente/descendente).", 0ah, "5. Salir", 0ah, "$"
    WELC_MSG db 0ah, 0dh, "***************  Bienvenido a RegistroCE  ***************", 0ah,"",0ah, "$"
    EXIT_MSG db 0ah, 0dh, "", 0ah,"*************  Gracias por usar RegistroCE  *************",0ah, "$" 
    
    MSG1    DB  10,13,10,'Por favor ingrese su estudiante o digite 9 para salir al menu principal $' 
    MSG2    DB  10,13,10,'El promedio de notas de los estudiantes ingresados es: $'
    MSG3    DB  13,10,'La nota maxima de los estudiantes ingresados es: $'
    MSG4    DB  13,10,'La nota minima de los estudiantes ingresados es: $'
    MSG5    DB  13,10,'La cantidad de estudiantes aprobados es: $'
    MSG6    DB  13,10,'    Porcentaje(%) $'
    MSG7    DB  13,10,'La cantidad de estudiantes reprobados es: $'
    MSG8    DB  13,10,'    Porcentaje(%) $'
    MSG9    DB  10,13,10,'Digite numero de estudiante a mostrar $'
    MSG10   DB  10,13,10, "Como desea ordenar las calificaciones:", 0ah,"", 0ah, "1. Orden Ascendente.", 0ah, "2. Orden Descendente.", 0ah, "$"
    
    PROMPT_NOMBRE DB 13,10,'Nombre: $'
    PROMPT_AP1 DB 13,10,'Apellido1: $'
    PROMPT_AP2 DB 13,10,'Apellido2: $'
    PROMPT_NOTA DB 13,10,'Nota (como texto, ej. 80.80): $'
    
    NAME_BUF DB 30,0,30 DUP(0)
    AP1_BUF DB 20,0,20 DUP(0)
    AP2_BUF DB 20,0,20 DUP(0)
    NOTE_BUF DB 10,0,10 DUP(0)
    
    CONFIRM_1 DB 13,10,'Ingresado -> ', '$'
    SPC DB ' ', '$'
    LABEL_NOTA DB 13,10,'Nota: ', '$'
    CRLF DB 13,10,'$'
    
 
    
DATA_SEG    ENDS

CODE_SEG    SEGMENT
   ASSUME CS: CODE_SEG, DS:DATA_SEG
    START:  MOV     AX, DATA_SEG
            MOV     DS, AX

    INITIAL_MSG:
            MOV     AH, 09
            MOV     DX, OFFSET WELC_MSG 
            INT     21H
            
    MENU_LOOP:
            LEA DX, MENU       ; carga la direcci?n del mensaje MENU en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS

            MOV AH, 01H        ; lee un caracter del teclado
            INT 21H            ; llama a la interrupcion 21H de DOS

            SUB AL, 30H        ; convierte el caracter ingresado por el usuario ASCII a su equivalente num?rico
            
            CMP AL, 1          ; compara el valor ingresado con 1
            JE ITS_ENTER_GRADES    ; salta a ENTER_GRADES si es igual a 1
            CMP AL, 2          ; compara el valor ingresado con 2
            JE ITS_STATISTICS   ; salta a ITS_STATISTICS si es igual a 2
            CMP AL, 3          ; compara el valor ingresado con 3
            JE ITS_INDEX_SEARCH  ; salta a ITS_INDEX_SEARCH si es igual a 3
            CMP AL, 4          ; compara el valor ingresado con 4
            JE ITS_SORT_CAL    ; salta a ITS_SORT_CAL si es igual a 4
            CMP AL, 5          ; compara el valor ingresado con 5
            JMP EXIT_PROGRAM   ; salta a EXIT_PROGRAM si es igual a 5
    
    ;Para evitar el excedente de bytes
ITS_ENTER_GRADES:
    JMP ENTER_GRADES       ; salta a ingresar calificaciones
ITS_STATISTICS:
    JMP STATISTICS      ; salta a estadisticas
ITS_INDEX_SEARCH:
    JMP INDEX_SEARCH     ; salta a buscar por indice
ITS_SORT_CAL:
    JMP SORT_CAL       ; salta a ordnar calificaciones
    
            
    ;//////////////////////////////////////////////////////////////// INGRESAR CALIFICACION ////////////////////////////////////////////////////////////           
    ENTER_GRADES:
            LEA DX, MSG1       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            ; ===== Nombre =====
            LEA DX, PROMPT_NOMBRE
            MOV AH, 09h
            INT 21h


            LEA DX, NAME_BUF
            MOV AH, 0Ah ; leer cadena (buffer estilo 0Ah)
            INT 21h
            
            ; ===== Apellido1 =====
            LEA DX, PROMPT_AP1
            MOV AH, 09h
            INT 21h


            LEA DX, AP1_BUF
            MOV AH, 0Ah
            INT 21h
            
            ; ===== Apellido2 =====
            LEA DX, PROMPT_AP2
            MOV AH, 09h
            INT 21h


            LEA DX, AP2_BUF
            MOV AH, 0Ah
            INT 21h


            ; ===== Nota (texto) =====
            LEA DX, PROMPT_NOTA
            MOV AH, 09h
            INT 21h


            LEA DX, NOTE_BUF
            MOV AH, 0Ah
            INT 21h


            ; [ADDED] ? Eco de lo ingresado (convierte buffers 0Ah a '$' y los imprime)
            LEA DX, CONFIRM_1
            MOV AH, 09h
            INT 21h


            ; Imprime: Nombre Apellido1 Apellido2
            LEA DX, NAME_BUF
            CALL PrintInputBuffer
            LEA DX, SPC
            MOV AH, 09h
            INT 21h


            LEA DX, AP1_BUF
            CALL PrintInputBuffer
            LEA DX, SPC
            MOV AH, 09h
            INT 21h


            LEA DX, AP2_BUF
            CALL PrintInputBuffer


            ; Imprime: Nota
            LEA DX, LABEL_NOTA
            MOV AH, 09h
            INT 21h


            LEA DX, NOTE_BUF
            CALL PrintInputBuffer


            LEA DX, CRLF
            MOV AH, 09h
            INT 21h
            
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES

    
;//////////////////////////////////////////////////////////////// MOSTRAR ESTADISTICAS ////////////////////////////////////////////////////////////////    
    STATISTICS:
            LEA DX, MSG2       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG3       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG4       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG5       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG6       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG7       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG8       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES
            
            
    
;//////////////////////////////////////////////////////////////// BUSCAR ESTUDIANTE POR POSICION //////////////////////////////////////////////////////   
    INDEX_SEARCH:
            LEA DX, MSG9       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES
    
;//////////////////////////////////////////////////////////////// ORDENAR CALIFICACIONES //////////////////////////////////////////////////////////////  
    SORT_CAL:
            LEA DX, MSG10       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            MOV AH, 01h
            INT 21h ; AL = '1' o '2'
            SUB AL, 30h ; a valor num?rico 1/2
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES

;////////////////////////////////////////////////////////////////       SUBRUTINAS DE SOPORTE //////////////////////////////////////////////////////////

; Convierte un buffer le?do con INT 21h/0Ah a cadena '$' y lo imprime con AH=09h.
; Entrada: DX = direcci?n del buffer (est?ndar 0Ah: [max][len][data..][0Dh])
PrintInputBuffer PROC
PUSH AX
PUSH BX
PUSH CX
PUSH DX
PUSH SI
PUSH DI


MOV BX, DX ; BX = base del buffer
MOV AL, [BX+1] ; AL = longitud real digitada
XOR AH, AH
MOV CX, AX ; CX = longitud


LEA SI, [BX+2] ; SI = inicio de los datos
MOV DI, SI
ADD DI, CX ; DI = posici?n despu?s del ?ltimo car?cter


MOV BYTE PTR [DI], '$' ; sobrescribe el 0Dh con '$'


MOV DX, SI ; DX -> datos ya terminados con '$'
MOV AH, 09h
INT 21h


POP DI
POP SI
POP DX
POP CX
POP BX
POP AX
RET
PrintInputBuffer ENDP         

;////////////////////////////////////////////////////////////////       SALIR       ///////////////////////////////////////////////////////////////////
    EXIT_PROGRAM:
            ; Muestra el mensaje de salida
            LEA     DX, EXIT_MSG   ; Carga la direcci?n del mensaje de salida en DX
            MOV     AH, 09h        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT     21h            ; Llama a la interrupci?n 21H de DOS para imprimir el mensaje en pantalla
            
            MOV     AH, 4CH
            MOV     AL, 0
            INT     21H

CODE_SEG    ENDS
    END START