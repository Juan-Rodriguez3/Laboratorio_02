/*
* EjemploTimer0.asm
*
* Creado: 04-Feb-25 10:25:52 AM
* Autor : Pedro Castillo
* Descripci n:?
*/
/**************/
// Encabezado (Definici n de Registros, Variables y Constantes)?
.include "M328PDEF.inc" // Include definitions specific to ATMega328P
.cseg
.org 0x0000
.def COUNTER = R20
/**************/
	// Configuraci n de la pila?
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	/**************/
	// Configuracion MCU
	SETUP:
	// Configurar Prescaler "Principal"
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16	// Habilitar cambio de PRESCALER
	LDI		R16, 0b00000100
	STS		CLKPR, R16	// Configurar Prescaler a 16 F_cpu = 1MHz
	// Inicializar timer0
	CALL	INIT_TMR0
	// Configurar PB5 como salida para usarlo como "LED"
	SBI		DDRB, 5			// Establecer bit PB5 como salida
	SBI		DDRB, 0
	CBI		PORTB, 5		// Obligar a LED a estar "APAGADO" inicialmente
	CBI		PORTB, 0
	// Deshabilitar serial (esto apaga los dem s LEDs del Arduino)?
	LDI		R16, 0x00
	STS		UCSR0B, R16
	LDI		COUNTER, 0x00
	/**************/
	// Loop Infinito
	MAIN_LOOP:
	IN		R16, TIFR0		// Leer registro de interrupci n de TIMER 0?
	SBRS	R16, TOV0		// Salta si el bit 0 est "set" (TOV0 bit)?
	RJMP	MAIN_LOOP		// Reiniciar loop
	SBI	 TIFR0, TOV0		// Limpiar bandera de "overflow"
	LDI		R16, 100
	OUT		TCNT0, R16		// Volver a cargar valor inicial en TCNT0
	INC		COUNTER
	CPI		COUNTER, 50		// R20 = 50 after 500ms (since TCNT0 is set to
	10 ms)
	BRNE MAIN_LOOP
	CLR COUNTER
	SBI PINB, PB5
	SBI PINB, PB0
	RJMP MAIN_LOOP
	/**************/
	// NON-Interrupt subroutines
	INIT_TMR0:
	LDI		R16, (1<<CS01) | (1<<CS00)
	OUT		TCCR0B, R16		// Setear prescaler del TIMER 0 a 64
	LDI		R16, 100
	OUT		TCNT0, R16		// Cargar valor inicial en TCNT0
	RET
	/**************/
	// Interrupt routines
	/*************//*************/
	// NON-Interrupt subroutines
	INIT_TMR0:
	LDI		R16, (1<<CS01) | (1<<CS00)
	OUT		TCCR0B, R16		// Setear prescaler del TIMER 0 a 64
	LDI		R16, 100
	OUT		TCNT0, R16		// Cargar valor inicial en TCNT0
	RET
	/**************/
	// Interrupt routines
	/**************