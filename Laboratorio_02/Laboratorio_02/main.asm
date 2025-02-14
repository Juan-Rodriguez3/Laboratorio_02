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
	//pin4=a
	//pin5=b
	//pin6=c
	//pin7= punto





//MainLoop
MAIN:
	IN		R16, PINC		//Leer el pinc
	CP		R17, R16		//Comparar el estado de los botones.
	BREQ	MAIN			//No hay cambios, releer
	IN		R16, PINC		//confirmar si hay botonazo
	CP		R17, R16
	BREQ	MAIN			//No hay cambios, releer
	MOV		R17, R16		//Actualizar el estado de los botones.
	SBRS	R16, 0			//Revisar si el bit 0 esta en Set
	CALL	increment
	SBRS	R16,	1		//Revisar si el bit 1 esta en Set	
	CALL	decrement
	CALL	DISPLAY
	OUT		PORTD, R19		//Actualizar salida
	RJMP	MAIN


//Subrutinas

//Incrementar el contador
increment:
	CPI		R18, 0x0F		//Limite del contador
	BREQ	REI				//Reiniciar si hay overflow
	INC		R18
	RET
REI:
	LDI		R18, 0x00		//Reiniciar contador
	RET

//Decrementar el contador
decrement:
	CPI		R18, 0x00		//Limite del contador
	BREQ	RED				//Reiniciar si hay overflow
	DEC		R18
	RET
RED:
	LDI		R18, 0x0F		//Reiniciar contador
	RET

DISPLAY:
	CPI		R18, 0x00
	BREQ	ZERO
ZERO:
	//Todos los pines en HIGH menos el pin3 y el pin7
	LDI		R19, 0b01110111	//Asignarle el valor para formar el zero	
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
	