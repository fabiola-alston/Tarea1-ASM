; Proyecto en TASM 8086

.MODEL SMALL
.STACK 100h


DATA_SEG    SEGMENT ; Inicia el segmento de datos, para almacenar mensajes estaticos y variables relacionadas a las operaciones
    ;Variables de mensajes
    MENU db 10,13,10, "Digite:", 0ah,"", 0ah, "1. Ingresar calificaciones (15 estudiantes -Nombre Apellido1 Apellido2 Nota-)", 0ah, "2. Mostrar estadisticas.", 0ah, "3. Buscar estudiante por posicion (indice)", 0ah, "4. Ordenar calificaciones (ascendente/descendente).", 0ah, "5. Salir", 0ah, "$"
    WELC_MSG db 0ah, 0dh, "***************  Bienvenido a RegistroCE  ***************", 0ah,"",0ah, "$"
    EXIT_MSG db 0ah, 0dh, "", 0ah,"*************  Gracias por usar RegistroCE  *************",0ah, "$" 
    
    MSG1    DB  10,13,10,'digite 1 para ingresar a su estudiante o digite 9 para salir al menu principal $' 
    MSG2    DB  10,13,10,'El promedio de notas de los estudiantes ingresados es: $'
    MSG3    DB  13,10,'La nota maxima de los estudiantes ingresados es: $'
    MSG4    DB  13,10,'La nota minima de los estudiantes ingresados es: $'
    MSG5    DB  13,10,'La cantidad de estudiantes aprobados es: $'
    MSG6    DB  13,10,'    Porcentaje(%) $'
    MSG7    DB  13,10,'La cantidad de estudiantes reprobados es: $'
    MSG8    DB  13,10,'    Porcentaje(%) $'
    MSG9    DB  10,13,10,'Digite numero de estudiante a mostrar $'
    MSG10   DB  10,13,10, "Como desea ordenar las calificaciones:", 0ah,"", 0ah, "1. Orden Ascendente.", 0ah, "2. Orden Descendente.", 0ah, "$"
    MSG11   DB  10,13,10, "LLEGO aqui", 0ah, "$"
    MSG12   DB  10,13,10, "Su estudiante se registr? correctamente", 0ah, "$"
    PROMPT_NOMBRE DB 13,10,'Ingrese nombre completo: $'
    PROMPT_NOTA DB 13,10,'Nota: $'
    ERROR_NOTA db 10,13,'Error: Ingrese una nota valida (0-100): $'
    
    K DB 0        ;VARIABLE PARA GUARDAR ESTUDIANTES
    CONT_EST DB 0   ;Cuantos estudiantes est?n registrados
    
    
    NAME_BUF DB 42,0,42 DUP(0)
    NOTA DW 0 ;NOTA DE ENTERO
    MUL_FAC DB  10
    
    ESTUDIANTES_R DB 15 DUP(49 DUP(?)) ;Arreglo de todos los estudiantes
     
    CONFIRM_1 DB 13,10,'Ingresado -> ', '$'
    SPC DB ' ', '$'
    BLANK_SPACE DB ''
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
                
            MOV AH, 01H        ; lee un caracter del teclado
            INT 21H            ; llama a la interrupcion 21H de DOS
            SUB AL, 30H        ; convierte el caracter ingresado por el usuario ASCII a su equivalente num?rico
                
            CMP AL, 1          ; compara el valor ingresado con 1
            JE REGISTRO    ; salta a REGISTER si es igual a 1
            CMP AL, 9          ; compara el valor ingresado con 2
            JE MENU_LOOP   ; salta al menu si es 9     
    
    REGISTRO:     
         ; ===== Nombre =====
            LEA DX, PROMPT_NOMBRE
            MOV AH, 09h
            INT 21h
            
            LEA DX, NAME_BUF
            MOV AH, 0Ah ; leer cadena (buffer estilo 0Ah)
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
            
            JMP ESCRIBIR_NOTA
            
    ESCRIBIR_NOTA:
            
            ; ===== Nota (texto) =====
            LEA DX, PROMPT_NOTA
            MOV AH, 09h
            INT 21h
            
            MOV NOTA, 0                 ; Hacer la nota 0
            
            JMP LEER_NOTA
        
        LEER_NOTA:    
            
            MOV     AH, 01h              ; Funci?n para leer un car?cter del teclado
            INT     21h                  ; Llama a la interrupci?n 21H de DOS para leer el car?cter
            CMP     AL, 13               ; Verifica si es el car?cter de retorno (ASCII 13)
            JZ      VALIDAR_NOTA           ; Si es retorno, salta a SECOND_MSG
            CMP     AL, '0'              ; Compara con el car?cter '0'
            JL      NOTA_INVALIDA  ; Salta a INVALID_INPUT si es menor que '0'
            CMP     AL, '9'              ; Compara con el car?cter '9'
            JG      NOTA_INVALIDA  ; Salta a INVALID_INPUT si es mayor que '9'

            ; Convertir y acumular
            SUB AL, 48         ; ASCII a n?mero
            MOV BL, AL
            MOV BH, 0          ; BX = nuevo d?gito
            
            MOV AX, [NOTA]     ; Cargar el VALOR de NOTA
            MUL MUL_FAC        ; AX = NOTA_actual * 10
            ADD AX, BX         ; AX = (NOTA_actual * 10) + nuevo_d?gito
            MOV [NOTA], AX     ; Guardar el nuevo valor
            JMP LEER_NOTA      ;Para seguir leyendo digitos
            
      NOTA_INVALIDA:
            LEA DX, ERROR_NOTA
            MOV AH, 09h
            INT 21h
            
            JMP ESCRIBIR_NOTA
     
      VALIDAR_NOTA:
            CMP     NOTA, 100
            JA      NOTA_INVALIDA
            CMP     NOTA, 0
            JL      NOTA_INVALIDA
            
            JMP GUARDAR_DATOS

      
      GUARDAR_DATOS:
            
            INC CONT_EST ; Incrementar contador de cuantos estudiantes se han guardado
            
            ; K = CONT_EST -1
            MOV AL, CONT_EST ;Movemos a AL el valor del contador
            SUB AL, 1        ;Le restamos 1
            MOV K, AL        ;Guardamos este valor en K
            
            ; EStructura: [(indice de estudiante, nombre estudiante, nota), (indice de estudiante, nombre estudiante, nota),]
            
            ; //////// Guardar CONT_EST en el primer byte de cada estudiante, ya que es su indice ///////
            ; Calcular posici?n en el array: DI = ESTUDIANTES_R + (49 * K)
            MOV AX, 49            ; Bytes por estudiante
            MOV BL, K             ; ?ndice del estudiante
            MUL BL                ; AX = 49 * K
            LEA DI, ESTUDIANTES_R ; DI apunta al inicio del array
            ADD DI, AX            ; DI apunta al estudiante K
            
            ; Guardar ?ndice en el PRIMER byte del estudiante
            MOV AL, BYTE PTR CONT_EST    ; AL = ?ndice (1-15)
            MOV [DI], AL          ; Va a la direccion que tiene guardada DI y guardar el primer byte (posici?n 1)
            
            
            ; //////// Guardar el buffer con el nombre que es de tama?o 42, pero empezaria en el byte 1
            ;calculo seria: (49*K) + 1
            ADD DI, 1            ;Sumamos 1 para que apunte al nombre del estudiante K
            LEA SI, NAME_BUF + 2 ; Saltar bytes de control del buffer
            MOV CL, NAME_BUF + 1 ; N?mero de caracteres le?dos
            MOV CH, 0
            
            CMP CX, 0           ; Verificar si hay caracteres
            JE FIN_NOMBRE       ; Si no hay nombre, saltar
            
        COPIAR_NOMBRE:
            MOV AL, [SI]
            MOV [DI], AL
            INC SI
            INC DI
            LOOP COPIAR_NOMBRE

        FIN_NOMBRE:
            ; DI ahora apunta despu?s del ?ltimo car?cter copiado
            ; Puedes agregar un terminador si lo necesitas
            MOV byte ptr [DI], '$'
            
            
            ;/////// Guardar la nota, que es NOTA, este seria en el byte 43
            ;calculo seria: (49*K) + 43
            ; Calcular posici?n en el array: DI = ESTUDIANTES_R + (49 * K)
            MOV AX, 49            ; Bytes por estudiante
            MOV BL, K             ; ?ndice del estudiante
            MUL BL                ; AX = 49 * K
            LEA DI, ESTUDIANTES_R ; DI apunta al inicio del array
            ADD DI, AX            ; DI apunta a la nota del estudiante K
            
            MOV AX, [NOTA]          ; AX = valor de la nota (DW)
            MOV [DI + 43], AX       ; Guardar en bytes 43-44  Le suma el desplazamiento
            
            JMP LIMPIAR_NOMBRE_BUF
            
     
        LIMPIAR_NOMBRE_BUF:
            LEA DI, NAME_BUF    ; DI apunta al buffer
            MOV byte ptr [DI], 42    ; Tama?o m?ximo (42)
            MOV byte ptr [DI+1], 0   ; Caracteres usados (0)
            ADD DI, 2           ; Apuntar al ?rea de datos
            
            ; Limpiar los 42 bytes de datos (llenar con 0's)
            MOV CX, 42          ; 42 bytes a limpiar
            MOV AL, 0           ; Valor para limpiar (0)
            REP STOSB           ; Llenar con ceros
            
            LEA DX, MSG12       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP ENTER_GRADES
            
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
