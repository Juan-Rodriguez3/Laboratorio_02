;*********************
; Universidad del Valle de Guatemala
; IE2025: Programacion de Microcontroladores
;
; Author: Juan Rodriguez
; Proyecto: Prelab II
; Hardware: ATmega328P
; Creado: 14/02/2025
; Modificado: 14/02/2025
; Descripcion: Este programa consiste en un contador binario de 4 bits que incrementa cada 100 ms. 
;*********************
.include "M328PDEF.inc"
.def COUNTER = R20
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
	STS		CLKPR, R16 // Habilitar cambio de PRESCALER
	LDI		R16, 0b00000100
	STS		CLKPR, R16 // Configurar Prescaler en 1MHz
	
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
	OUT		DDRB, R16 // Puerto B como salida
	LDI		R16, 0x00
	OUT		PORTB, R16 //El puerto B conduce cero logico.

	//Puerto D como salida
	LDI		R16, 0xFF
	OUT		DDRD, R16 // Puerto D como salida
	LDI		R16, 0x00
	OUT		PORTD, R16 //El puerto D conduce cero logico.

	// Deshabilitar serial 
	LDI		R16, 0x00
	STS		UCSR0B, R16
	LDI		COUNTER, 0x00
	LDI		R17, 0x00

	MAIN:
	IN		R16, TIFR0 // Leer registro de interrupcion 
	SBRS	R16, TOV0 // Salta si el bit 0 esta en 1, es la bandera de of
	RJMP	MAIN // Reiniciar loop si no hay of
	SBI		TIFR0, TOV0 // Limpiar bandera de "overflow"
	LDI		R16, 100
	OUT		TCNT0, R16 // Volver a cargar valor inicial en TCNT0
	INC		COUNTER
	CPI		COUNTER, 10 // R20 = 10 después 100ms (el TCNT0 está en to 10 ms)
	BRNE	MAIN
	CLR		COUNTER
	INC     R17
	CPI		R17, 0x10 //comparar con 16
	BREQ	overflow //si es 16 ejecutar salta a overflow
	OUT		PORTB, R17 //si no es 16 cargar el valor 
	RJMP	MAIN

	overflow:
	LDI		R17, 0x00 //si es 16 el valor hay of y se hace 0
	OUT		PORTB, R17
	RJMP	MAIN

// NON-Interrupt subroutines
INIT_TMR0:
	LDI		R16, (1<<CS01) | (1<<CS00)
	OUT		TCCR0B, R16 // Setear prescaler del TIMER 0 a 64
	LDI		R16, 100
	OUT		TCNT0, R16 // Cargar valor inicial en TCNT0
	RET