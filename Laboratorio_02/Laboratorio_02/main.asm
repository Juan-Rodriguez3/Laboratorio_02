;*********************
; Universidad del Valle de Guatemala
; IE2025: Programacion de Microcontroladores
;
; Author: Juan Rodriguez
; Proyecto: Lab II
; Hardware: ATmega328P
; Creado: 14/02/2025
; Modificado: 14/02/2025
; Descripcion: Este programa consiste en un contador binario de 4 bits que incrementa cada 100 ms. 
;*********************
.include "M328PDEF.inc"
.cseg
.org 0x0000

// Tabla de conversión hexadecimal a 7 segmentos
TABLA:
    .DB 0x77, 0x50, 0x3B, 0x7A, 0x5C, 0x6E, 0x6F, 0x70, 0x7F, 0x7E, 0x7D, 0x4F, 0x27, 0x5B, 0x2F, 0x2D

//Configuraci?n de pila //0x08FF
	LDI		R16, LOW(RAMEND)	// Cargar 0xFF a R16
	OUT		SPL, R16			// Cargar 0xFF a SPL
	LDI		R16, HIGH(RAMEND)	
	OUT		SPH, R16			// Cargar 0x08 a SPH

SETUP:
	// Configurar Prescaler 
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16		// Habilitar cambio de PRESCALER
	LDI		R16, 0b00000100
	STS		CLKPR, R16		// Configurar Prescaler en 1MHz
	

	  //Configurar los pines como entradas y salidas

	  //Puerto C como entrada
	LDI		R16, 0x00
	OUT		DDRC, R16
	LDI		R16, 0xFF
	OUT		PORTC, R16		//Pull-up

	//Puerto B como salida
	LDI		R16, 0xFF
	OUT		DDRB, R16		// Puerto B como salida
	LDI		R16, 0x00
	OUT		PORTB, R16		//El puerto B conduce cero logico.

	//Puerto D como salida
	LDI		R16, 0xFF
	OUT		DDRD, R16		// Puerto D como salida
	LDI		R16, 0x00
	OUT		PORTD, R16		//El puerto D conduce cero logico.

	// Deshabilitar serial 
	LDI		R16, 0x00
	STS		UCSR0B, R16

	//Estado de los botones
	LDI		R17, 0xFF

	//Salidas
	LDI		R18, 0x00		//Contador de 4 bit
	LDI		R19, 0x00		//Salida del display
	//pin0=e
	//pin1=d
	//pin2=f
	//pin3=g
	//pin4=b
	//pin5=a
	//pin6=c
	//pin7= punto
	
	//Cargar la tabla como salida
	LDI		ZH, HIGH(TABLA<<1)  //Carga la parte alta de la dirección de tabla en el registro ZH
	LDI		ZL, LOW(TABLA<<1)	//Carga la parte baja de la dirección de la tabla en el registro ZL
	LPM		R19, Z			    //Carga en R16 el valor de la tabla en ela dirreción Z
	OUT		PORTD, R19		   //Muestra en el puerto D el valor leido de la tabla

//MainLoop
MAIN:
	IN		R16, PINC		//Leer el pinc
	CP		R17, R16		//Comparar el estado de los botones.
	BREQ	MAIN			//No hay cambios, releer
	CALL	DELAY
	IN		R16, PINC		//confirmar si hay botonazo
	CP		R17, R16
	BREQ	MAIN			//No hay cambios, releer
	MOV		R17, R16		//Actualizar el estado de los botones.
	SBRS	R16, 0			//Revisar si el bit 0 esta en Set
	CALL	increment
	SBRS	R16,	1		//Revisar si el bit 1 esta en Set	
	CALL	decrement
	OUT		PORTD, R19		//Actualizar salida
	RJMP	MAIN


//Subrutinas

//Incrementar el contador
increment:
	INC		R18
	CPI		R18, 0x10
	BREQ	OVF
	ADIW	Z,	1			//Incrementar el puntero en 1
	LPM		R19,	Z		//Cargar los datos de la dirrección del puntero
	RET

OVF:
	LDI		ZH, HIGH(TABLA<<1)  //Carga la parte alta de la dirección de tabla en el registro ZH
	LDI		ZL, LOW(TABLA<<1)	//Carga la parte baja de la dirección de la tabla en el registro ZL
	
	LPM		R19, Z			    //Carga en R16 el valor de la tabla en ela dirreción Z
	OUT		PORTD, R19		   //Muestra en el puerto D el valor leido de la tabla
	LDI		R18,	0xFF
	RET

UNF:
	LDI		ZH, HIGH(TABLA +15) //Carga la parte alta de la dirección de la tabla en el registro ZL
	LDI		ZL, LOW(TABLA +15)	//Carga la parte baja de la dirección de la tabla en el registro ZL
	LPM		R19, Z			    //Carga en R16 el valor de la tabla en ela dirreción Z
	OUT		PORTD, R19		   //Muestra en el puerto D el valor leido de la tabla
	LDI		R18,	0xFF
	RET


//Decrementar el contador
decrement:
	CPI		R18, 0x00
	BREQ	UNF
	SBIW	Z,	1			//Incrementar el puntero en 1
	LPM		R19,	Z		//Cargar los datos de la dirrección del puntero
	RET




DELAY:
	LDI		R20, 0
SUBDELAY1:
	INC		R20
	CPI		R20,0
	BRNE	SUBDELAY1
	LDI		R20, 0
SUBDELAY2:
	INC		R20
	CPI		R20,0
	BRNE	SUBDELAY2
	RET