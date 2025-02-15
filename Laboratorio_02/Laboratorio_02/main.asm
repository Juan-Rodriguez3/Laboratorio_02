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
	//pin4=b
	//pin5=a
	//pin6=c
	//pin7= punto
	

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
	CPI		R18, 0x01
	BREQ	ONE
	CPI		R18, 0x02
	BREQ	TWO
	CPI		R18, 0x03
	BREQ	THREE
	CPI		R18, 0x04
	BREQ	FOUR
	CPI		R18, 0x05
	BREQ	FIVE
	CPI		R18, 0x06
	BREQ	SIX
	CPI		R18, 0x07
	BREQ	SEVEN
	CPI		R18, 0x08
	BREQ	EIGHT
	CPI		R18, 0x09
	BREQ	NINE
	CPI		R18, 0x0A
	BREQ	A
	CPI		R18, 0x0B
	BREQ	B
	CPI		R18, 0x0C
	BREQ	C
	CPI		R18, 0x0D
	BREQ	D
	CPI		R18, 0x0E
	BREQ	E
	CPI		R18, 0x0F
	BREQ	F
	RET						//Temporal hasta completar el codigo
ZERO:
	//Todos los pines en HIGH menos el pin3 y el pin7
	LDI		R19, 0b01110111	//Asignarle el valor para formar el zero	
	RET
ONE:
	LDI		R19, 0b01010000
	RET
TWO:
	LDI		R19, 0b00111011
	RET
THREE:
	LDI		R19, 0b01111010
	RET		
FOUR: //J
	LDI		R19, 0b01011100
	RET		

FIVE:
	LDI		R19, 0b01101110
	RET		

SIX:
	LDI		R19, 0b01101111
	RET		

SEVEN:
	LDI		R19, 0b01110000
	RET		
EIGHT:
	LDI		R19, 0b01111111

	RET		
NINE:
	LDI		R19, 0b01111110

	RET		
A:
	LDI		R19, 0b01111101

	RET		
B:
	LDI		R19, 0b01001111

	RET		
C:
	LDI		R19, 0b00100111
	RET		
D:
	LDI		R19, 0b01011011
	RET		
E:
	LDI		R19, 0b00101111
	RET		
F:
	LDI		R19, 0b00101101
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
	