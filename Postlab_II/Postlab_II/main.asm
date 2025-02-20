;*********************
; Universidad del Valle de Guatemala
; IE2025: Programacion de Microcontroladores
;
; Author: Juan Rodriguez
; Proyecto: Post-lab II
; Hardware: ATmega328P
; Creado: 18/02/2025
; Modificado: 20/02/2025
; Descripcion: Este programa consiste en un contador binario de 4 bits que incrementa cada 100 ms. 
;*********************
.include "M328PDEF.inc"
.def COUNTER = R20
.def COUNT_DISP = R21
.def DISPLAY = R22
.def LIMIT_DISPL = R23
.def LIMIT_DISPH = R24
.cseg

.org 0x0000
	RJMP	SETUP			//Salto al SETUP

//Saltar a la subrutina de interrupción
.org PCI2addr
    RJMP	PCINT1_ISR      //Vector de interrupción por cambio de pin en PCINT1 (PC0-PC6)

// Tabla de conversión hexadecimal a 7 segmentos
TABLA:
    .DB 0x77, 0x50, 0x3B, 0x7A, 0x5C, 0x6E, 0x6F, 0x70, 0x7F, 0x7E, 0x7D, 0x4F, 0x27, 0x5B, 0x2F, 0x2D



SETUP:
	//Configuracion de pila //0x08FF
	LDI		R16, LOW(RAMEND)			// Cargar 0xFF a R16
	OUT		SPL, R16					// Cargar 0xFF a SPL
	LDI		R16, HIGH(RAMEND)			//	
	OUT		SPH, R16					// Cargar 0x08 a SPH

	// Configurar Prescaler 
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16					// Habilitar cambio de PRESCALER
	LDI		R16, 0b00000100
	STS		CLKPR, R16					// Configurar Prescaler en 1MHz
	
	// Inicializar timer0
	CALL    INIT_TMR0

	  //Configurar los pines como entradas y salidas

	  //Puerto C como entrada
	LDI		R16, 0x00
	OUT		DDRC, R16
	LDI		R16, 0xFF
	OUT		PORTC, R16		;Pull-up

	//Puerto B como salida
	LDI		R16, 0xFF
	OUT		DDRB, R16				// Puerto B como salida
	LDI		R16, 0x00
	OUT		PORTB, R16				//El puerto B conduce cero logico.

	//Puerto D como salida
	LDI		R16, 0xFF
	OUT		DDRD, R16				// Puerto D como salida
	LDI		R16, 0x00
	OUT		PORTD, R16				//El puerto D conduce cero logico.

	// Deshabilitar serial 
	LDI		R16, 0x00
	STS		UCSR0B, R16

	//Variables
	LDI		COUNTER, 0x00			//Contador de desbordamientos del TIMER0
	LDI		DISPLAY, 0x00			//Salida del display
	LDI		COUNT_DISP, 0X00		//Es el top del contador del leds
	LDI		R18, 0x00				//Salida de LEDS
	LDI		LIMIT_DISPL, 0x00		//Limite bajo para el display
	LDI		LIMIT_DISPH, 0x0F		//Limite alto para el display

	//Habilitar el Pin Change Interrupt Control Register
	LDI		R16,	0X02			//Encender el bit PCIE1
	STS		PCICR,	R16				//Habilitar el PCI en el pin C
	LDI		R16,	(1<<PCINT8) | (1<<PCINT9)	//Habilitar pin 0 y pin 1
	STS		PCMSK1,	R16				//	Cargar a PCMSK1

	SEI              ; Habilita interrupciones globales

	//Cargar la tabla como salida
	LDI		ZH, HIGH(TABLA<<1)  //Carga la parte alta de la dirección de tabla en el registro ZH
	LDI		ZL, LOW(TABLA<<1)	//Carga la parte baja de la dirección de la tabla en el registro ZL
	LPM		DISPLAY, Z			    //Carga en R16 el valor de la tabla en ela dirreción Z
	OUT		PORTD, DISPLAY	

MAIN:
	IN		R16, TIFR0				// Leer registro de interrupcion 
	SBRS	R16, TOV0				// Salta si el bit 0 esta en 1, es la bandera de of
	RJMP	MAIN					// Reiniciar loop si no hay of
	SBI		TIFR0, TOV0				// Limpiar bandera de "overflow"
	LDI		R16, 100
	OUT		TCNT0, R16				// Volver a cargar valor inicial en TCNT0
	INC		COUNTER
	CPI		COUNTER, 100			// R20 = 10 despu?s 100ms (el TCNT0 est? en to 10 ms)
	BRNE	MAIN
	CLR		COUNTER
	CP		R18, COUNT_DISP				//comparar con el desbordamiento
	BREQ	overflow				//si es 16 ejecutar salta a overflow
	INC     R18
	OUT		PORTB, R18				//si no es 16 cargar el valor 
	RJMP	MAIN

overflow:
	ANDI	R18, 0x10			//Se reinician los 4 bit menos significativos
	SBRS	R18, 4				//Salta si el 4to bit is high
	RJMP	ALARMA_SET
	SBRC	R18, 4				//Salta si el 4to bit is low
	RJMP	ALARMA_RESET		
	RJMP	MAIN

ALARMA_SET:
	LDI		R18, 0x10			//Encender la alarma
	ADD		COUNT_DISP, R18		//Agregarle el 4to Bit para el corriemiento.
	OUT		PORTB, R18			//Cargar en el puerto B
	LDI		LIMIT_DISPL, 0x10	//Limite bajo para el display con led encendida
	LDI		LIMIT_DISPH, 0x1F	//Limite alto para el display con led encendida
	RJMP	MAIN

ALARMA_RESET:
	ANDI	COUNT_DISP, 0x0F	//Conservar los 4 bits menos significativos
	LDI		R18, 0x00			//Apagar la alarma
	OUT		PORTB, R18			//Cargar en el puerto B
	LDI		LIMIT_DISPL, 0x00	//Limite bajo para el display con led apagada
	LDI		LIMIT_DISPH, 0x0F	//Limite alto para el display con led apagada
	RJMP	MAIN

// NON-Interrupt subroutines
INIT_TMR0:
	LDI		R16, (1<<CS01) | (1<<CS00)
	OUT		TCCR0B, R16				// Setear prescaler del TIMER 0 a 64
	LDI		R16, 100
	OUT		TCNT0, R16				// Cargar valor inicial en TCNT0
	RET

//Subrutinas de Interrupción
PCINT1_ISR:
	ANDI	R18, 0x10				//Borrar los 4 bits menos significativos
	OUT		PORTB, R18
	IN		R17, PINC				//Leer el estado de los botones
	SBRS	R17, 0					//Revisar si el pin0 esta set
	CALL	increment				//Incrementar el display
	SBRS	R17, 1					//Revisar si el pin1 esta set
	CALL	decrement				//Decrementar el display
	OUT		PORTD, DISPLAY		   //Muestra en el puerto D el valor leido de la tabla
	RETI

//Subrutinas para el display

//Incrementar el contador
increment:
	CP		COUNT_DISP, LIMIT_DISPH
	BREQ	OVF
	INC		COUNT_DISP
	ADIW	Z,	1			//Incrementar el puntero en 1
	LPM		DISPLAY,	Z		//Cargar los datos de la dirrección del puntero
	RET

OVF:
	LDI		ZH, HIGH(TABLA<<1)  //Carga la parte alta de la dirección de tabla en el registro ZH
	LDI		ZL, LOW(TABLA<<1)	//Carga la parte baja de la dirección de la tabla en el registro ZL
	LPM		DISPLAY, Z			    //Carga en R16 el valor de la tabla en ela dirreción Z
	MOV		COUNT_DISP,	LIMIT_DISPL
	RET

UNF:
	LDI		ZH, HIGH(TABLA<<1) //Carga la parte alta de la dirección de la tabla en el registro ZL
	LDI		ZL, LOW(TABLA<<1)	//Carga la parte baja de la dirección de la tabla en el registro ZL
	ADIW	Z,	15
	LPM		DISPLAY, Z			    //Carga en R16 el valor de la tabla en ela dirreción Z
	OUT		PORTD, DISPLAY		   //Muestra en el puerto D el valor leido de la tabla
	MOV		COUNT_DISP,	LIMIT_DISPH
	RET


//Decrementar el contador
decrement:
	CP		COUNT_DISP, LIMIT_DISPL
	BREQ	UNF
	DEC		COUNT_DISP
	SBIW	Z,	1			//Incrementar el puntero en 1
	LPM		DISPLAY, Z		//Cargar los datos de la dirrección del puntero
	RET