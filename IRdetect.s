;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
			AREA    	main, READONLY, CODE
			THUMB
			EXPORT		loop1
			EXPORT		next
			EXPORT		setup
			EXPORT  	__main			; Make available
			
DELAY_CLOCKS		EQU	399999 ; 
GPIO_PORTB_DATA 	EQU 0x400053FC ;PortB_DATA R/W all bits
GPIO_PORTB_DIR 		EQU 0x40005400
GPIO_PORTB_AFSEL 	EQU 0x40005420
GPIO_PORTB_DEN 		EQU 0x4000551C
IOB 				EQU 0x0 ;for DIR setting
GPIO_PORTB_CR 		EQU 0x40005524
GPIO_PORTB_PUR 		EQU 0x40005510

SYSCTL_RCGCGPIO 	EQU 0x400FE608 ;clock control all ports
	
GPIO_PORTE_DATA 	EQU 0x400243FC ;PortE_DATA R/W all bits
GPIO_PORTE_DIR 		EQU 0x40024400
GPIO_PORTE_AFSEL 	EQU 0x40024420
GPIO_PORTE_DEN 		EQU 0x4002451C
IOE 				EQU 0xF ;for DIR setting
GPIO_PORTE_CR 		EQU 0x40024524
GPIO_PORTE_PUR 		EQU 0x40024510
	
	
	
GPIO_PORTA_DATA 	EQU 0x400043FC ;PortB_DATA R/W all bits
GPIO_PORTA_DIR 		EQU 0x40004400
GPIO_PORTA_AFSEL 	EQU 0x40004420
GPIO_PORTA_DEN 		EQU 0x4000451C
IOA 				EQU 0xF ;for DIR setting
GPIO_PORTA_CR 		EQU 0x40004524
GPIO_PORTA_PUR 		EQU 0x40004510
	
__main
		;turn on clock
setup	LDR R1, =SYSCTL_RCGCGPIO ; load R1 with RCGCGPIO address
		LDR R0, [R1] ; load R0 with value in RCGCGPIO
		ORR R0, #2_010011 ; set bit 4 to turn on Port E clock. 
		STR R0, [R1] ; store value in RCGCGPIO
		NOP ; three non-GPIO instruction times
		NOP ; needed to allow
		NOP ; time for clock to finish
		
		;Configure Port B
		LDR R1, =GPIO_PORTB_DIR ; Data direction setup
		LDR R0, [R1]
		BIC R0, #0xFF

		ORR R0, #IOB ; Set bits 1,2,3 as input
		STR R0, [R1]
		LDR R1, =GPIO_PORTB_AFSEL ; Set up standard GPIO functionality
		LDR R0, [R1] ; rather than some special use (A/D...)
		BIC R0, #0xFF
		STR R0, [R1]
		LDR R1, =GPIO_PORTB_DEN ; Enable digital (vs. Analog) function
		LDR R0, [R1]
		ORR R0, #0xFF
		STR R0, [R1]
		
		;Configure Port A
		LDR R1, =GPIO_PORTA_DIR ; Data direction setup
		LDR R0, [R1]
		BIC R0, #0xFF

		ORR R0, #IOA ; Set bits 1,2,3 as output
		STR R0, [R1]
		LDR R1, =GPIO_PORTA_AFSEL ; Set up standard GPIO functionality
		LDR R0, [R1] ; rather than some special use (A/D...)
		BIC R0, #0xFF
		STR R0, [R1]
		LDR R1, =GPIO_PORTA_DEN ; Enable digital (vs. Analog) function
		LDR R0, [R1]
		ORR R0, #0xFF
		STR R0, [R1]
		
		;Configure Port E
		LDR R1, =GPIO_PORTE_DIR ; Data direction setup
		LDR R0, [R1]
		BIC R0, #0xFF
		ORR R0, #IOE
		STR R0, [R1]
		LDR R1, =GPIO_PORTE_AFSEL ; Set up standard GPIO functionality
		LDR R0, [R1] ; rather than some special use (A/D...)
		BIC R0, #0xFF
		STR R0, [R1]
		LDR R1, =GPIO_PORTE_DEN ; Enable digital (vs. Analog) function
		LDR R0, [R1]
		ORR R0, #0xFF
		STR R0, [R1]
		
		;enable PUR
		LDR R1, =GPIO_PORTB_PUR
		MOV R0,#0xF
		STR R0,[R1]
		
		LDR	R2,=GPIO_PORTE_DATA
		MOV R3,#0xFF
		STR R3,[R2]

		
		
loop1	LDR R1,=GPIO_PORTB_DATA 
		LDR R0,[R1]
		BL loop1
        
next	LDR R1,=GPIO_PORTA_DATA
		MOV R0,#0xF
		STR R0,[R1]
		BL loop1
		

		ALIGN
		END