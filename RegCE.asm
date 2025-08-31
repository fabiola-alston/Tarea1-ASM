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
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES
    
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