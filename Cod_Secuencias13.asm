#include "p16F887.inc"    
; CONFIG1
; __config 0x28D5
 __CONFIG _CONFIG1, _FOSC_INTRC_CLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_ON & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

  LIST p=16F887
   
cont1      EQU 0x20
cont2      EQU 0x21
cont3      EQU 0x22
var        EQU 0x23
var2       EQU 0x24
var3       EQU 0x25
varSec1    EQU 0x26
varSec2    EQU 0x27
varSec3    EQU 0x28
 
    ORG	0x00
    GOTO INICIO
  
INICIO
    BCF  STATUS,RP0 
    BCF  STATUS,RP1     ;Bank 0
    CLRF PORTB          ;Limpiamos las salidas del puerto B
    BSF  STATUS, RP0    ;Bank 1
    CLRF TRISB	        ;Configuramos el PORTB como salidas 8 pines
    BSF  STATUS,RP1     ;Bank 3
    CLRF ANSELH         ;Configuramos el registro de deteccion analogica
    BCF  STATUS,RP0    
    BCF  STATUS,RP1     ;Bank 0 
    BCF  STATUS,C       ;Desabilitamos el bit de carry 
    
INICIA_SECU
    
    MOVLW .3
    MOVWF var3         ;Creamos una variable con proposito de bucle
    MOVLW .3
    MOVWF var2         ;Creamos una variable con proposito de bucle
    MOVLW b'10000001'
    MOVWF PORTB
    CALL RETARDO       ;Encendemos el primer paso de la secuencia
    
LOOP1 
    MOVLW .7
    MOVWF var          ;Variable con proposito de bucle
    MOVLW b'10000000'
    MOVWF varSec1      ;Variable para el patron de la secuencia
    MOVLW b'00000001'
    MOVWF varSec2      ;Variable para el patron de la secuencia
    
SECUENCIA_LED1         ;Inicio de la secuencia
   
    RRF varSec1           ;Desplazamos la variable del MSB hacia la derecha
    RLF varSec2           ;Desplazamos la variable del MSB hacia la izquierda
    MOVF varSec1,0        ;Movemos el la variable desplazada para operacion logica
    IORWF varSec2,0       ;varSec1 or varSec2
    MOVWF PORTB           ;Cargamos el resultado en el puerto de salida
    CALL RETARDO          ;Rutina de retardo
    DECFSZ var,F          ;Hacer los siete pasos restantes de la secuencia
    GOTO SECUENCIA_LED1   ;Volver a iniciar la secuencai
    DECFSZ var2,F         ;Hcer los 8 pasos de la secuencia tres veces
    GOTO LOOP1
    GOTO SECUENCIA_LED2   ;Comienza una secuencia diferente

SECUENCIA_LED2
    
    CLRF var          ;Limpiamos todas las variables usadas anteriomente
    CLRF var2         
    CLRF varSec1  
    CLRF varSec2   
    CLRF varSec3      
    
LOOP2                  ;Etiqueta del bucle
    
    MOVLW .2
    MOVWF var          ;Definimos valores constantes a las variables
    MOVLW .2
    MOVWF var2
    MOVLW b'10000001'
    MOVWF PORTB
    CALL RETARDO       ;Encendemos los leds del primer paso de la secuencia
    MOVLW b'00000001'
    MOVWF varSec1      ;Variable para el patron de la secuencia
    MOVLW b'10000000'
    MOVWF varSec2      ;Variable para el patron de la secuencia
    MOVLW b'11000011'
    MOVWF varSec3      ;Variable estatica para algunos pasos de la secuencia
  
LOOP3
   
    RlF varSec1          ;Desplazamos la variable del MSB hacia la izquieda
    RRF varSec2          ;Desplazamos la variable del MSB hacia la derecha
    MOVF varSec1,0
    IORWF varSec2,0      ;Operacion or con las variables de patron secuencia
    IORWF varSec3,0      ;Resultado anterior hacemos or con variable estatica
    MOVWF PORTB          ;Mostramos resultado en la salida
    CALL RETARDO         ;Rutina de retardo, 1 segundo
    DECFSZ var,F         
    GOTO LOOP3           ;Hacer bucle para las obtencion de los primeros pasos
    CALL ADD_BIT         ;Llamanos a la funcion 
    BTFSS varSec1,3      ;Testear si la varible tiene un 1 en el bit 3?
    GOTO LOOP3           ;Si es falso sigue haciendo el bucle
    MOVLW b'00011000'    ;Caso verdadero cargamos el valor a mostrar
    MOVWF PORTB          ;Mostrar en la salida
    CALL RETARDO
    
REP_PART2                ;Hasta entonces tenemos 4 pasos de la secuancia
    
    RRF varSec1          ;Hacemos los mismos pasos anteriores pero
    RLF varSec2          ;esta vez invirtiendo las variables una vez el testeo 
    MOVLW b'00111100'    ;anterior haya sido verdadero
    MOVWF varSec3
    MOVF varSec1,0
    IORWF varSec2,0
    IORWF varSec3,0
    MOVWF PORTB
    CALL RETARDO
    DECFSZ var2,F
    GOTO REP_PART2
    MOVLW b'11111111'    
    MOVWF PORTB         ;Mostrar el ultimo paso de la secuencia
    CALL RETARDO
    DECFSZ var3,F
    GOTO SECUENCIA_LED2 ;Termonados los ocho pasos, iniciar nuevamente 
    GOTO INICIA_SECU
    
ADD_BIT                 ;Funcion para actualizar la variable estatica
    
    MOVLW b'11100111'   ;Cargar el valor de actualizacion
    MOVWF varSec3       
    MOVLW .1         
    MOVWF var           ;Variable con proposito de usar la varSec3 un solo paso
    RETURN              ;Continuar en lla linea despues de llamar la funcion

RETARDO                 ;Rutina para obtener un retardo de un segundo
    MOVLW .10           ;se hicieron calculos respecto a cuantas instrucciones
    MOVWF cont3         ;son necesarias para obtener 1 segundo de retardo
REP_3
    MOVLW .100          ;Conociendo de antemano la frecuencia del oscilador
    MOVWF cont2 
REP_2
    MOVLW .250
    MOVWF cont1 
REP_1
    Nop                ;No hace nada pero consume 1 us de tiempo
    DECFSZ cont1,F
    GOTO REP_1
    DECFSZ cont2,F
    GOTO REP_2
    DECFSZ cont3,F
    GOTO REP_3
    RETURN
    END