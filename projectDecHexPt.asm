.data

Bienvenida: .asciiz "Bienvenido al conversor de unidades\n 1. Acceder conversor Decimal-PuntoF \n 2. Acceder conversor hexadecimal-PuntoF\n "

inputNumeroDecimal: .asciiz "Ingrese un numero Decimal --> "

inputNumeroHexadecimal: .asciiz "Ingrese un numero Hexadecimal --> \n"

mensajeNormalizado: .asciiz "Su numero decimal normalizado --> \n"

mensajePuntoflotante: .asciiz "\n Su numero decimal normalizado --> \n"

decimalNumber: .space 12

hexaNumber: .space 12

binaryNumber1: .space 20

binaryNumber2: .space 20

binaryNormalizado: .space 33

numeroPuntoFlotante: .space 33



.text



#Lectura de Datos 

	# => Lectura de Bienvendia
	
	li $v0 4
	la $a0 Bienvenida
	syscall
	
	# => Pedir al usuario la opcion a escoger
	
	li $v0 5
	syscall
	
	# => Movemos la opcion seleccionada por el usuario al registro $t0
	
	move $t0 $v0
	
	# => Se compara si el usuario desea ir a conversor decimal o hexadecimal
	
	beq $t0 1 ingresoDecimal
	
	beq $t0 2 ingresoHexadecimal
	
	ingresoDecimal: 
	
	# => Se muestra el mensaje de ingreso de numero decimal
	li $v0 4 
	la $a0 inputNumeroDecimal 
	syscall
	
	li $v0 8
	la $a0 decimalNumber 
	li $a1 12 # => maxima cantidad de caracteres a almacenar
	syscall 
	sb $zero, decimalNumber($a1) # => incluye el caracter nulo al final del string
	
	li $s6 20
	
	li $s7 12
	
	sb $zero, binaryNumber1($s6)
	
	sb $zero, binaryNumber1($s7)
	
	j decimalConversorMain
	
	
	
	ingresoHexadecimal:
	
	# => Se muestra el mensaje de ingreso de numero hexadecimal
	
	li $v0 4 
	la $a0 inputNumeroHexadecimal 
	syscall
	
	li $v0 8
	la $a0 hexaNumber 
	li $a1 12 # => maxima cantidad de caracteres a almacenar
	syscall 
	sb $zero, hexaNumber($a1) # => incluye el caracter nulo al final del string
	
	j hexaConversorMain
	
	

#Main

	# => convertir la cadena en numero 
	
	decimalConversorMain:
	
	li $t7 0 # => parte entera del numero
	li $t8 0 # => parte decimal del numero
	
	li $t1 0 # => iterador de la cadena
	
	lb $t2 decimalNumber($t1) # => Almacenamos el signo del numero en el registro para usarlo en la normalizacion
	
	addi $t1 $t1 1 # => empezar a iterar desde la posicion 1 para poder almacenar solo parte numerica
	
	# => $t3 almacenaremos los caracteres leidos
	# => $t4 almacenaremos su representacion numerica
	
	loopConversorEntero:
	
		lb $t3 decimalNumber($t1)
	
		beq $t3 44 loopConversorDecimal # => cuando halle la coma va al almacenamiento de la parte decimal
		
		beq $t3 46 loopConversorDecimal # => cuando halle el punto va al almacenamiento de la parte decimal
		
		mul $t7 $t7 10
	
		subi $t4 $t3 48 # => adquirimos la representacion numerica del caracter
	
		add $t7 $t7 $t4 # => agregamos el numero al registro donde tendremos la parte entera
	
		addi $t1 $t1 1
	
		b loopConversorEntero
		
		
	
	loopConversorDecimal:
	
		addi $t1 $t1 1 # => para que agarre la posicion despues de la coma
		
		lb $t3 decimalNumber($t1) # => el registro $t3 adquiere el valor del array en la posicion indicada
			
		beq $t3 10 ConversorBinario # => si tiene un NL salte al conversor binario 
		beq $t3 0 ConversorBinario # => si un cero que salte al conversor binario 
		
		subi $t4 $t3 48 # => se le resta 48 para hallar su valor numerico
		
		mul $t8 $t8 10 # => se multiplica por 10 para desplazarnos a la derecha
		
		add $t8 $t8 $t4 # => se le suma el nuevo valor de $t3
		
		b loopConversorDecimal
		
		
		
		

ConversorBinario:

		
	
		li $t1 19 # => Variables que me permitan iterar, accede a la ultima posicion de mi arreglo binario para guardalo de forma ordenada
	
		li $a2 2 # => divisor entre 2 que me permite hacer la conversion
		
		li $t3 0
		
		li $t4 0 # => iterador del vector donde se almacena el binario de la parte decimal
		
		
		loopEnteroBinario:

		
			beq $t7 1 loopDecimalBinario # => cuando el cociente sea 1 que deje de iterar al no poder dividirse mas
	
			div $t7 $a2 # => divide el cociente entre 2
			
			mflo $t7 # => almacena en el $t7 el nuevo cociente 
			 
			mfhi $t3 # => se guarda el digito binario
			
			sb $t3 binaryNumber1($t1)  # => almacena en el array de la parte entera el binario organizado
			
			subi $t1 $t1 1 # => va iterando desde la ultima posicion hasta la primera
			
			b loopEnteroBinario 
			
			
		loopDecimalBinario: 
		
			beq $t8 0 Normalizacion
		
			mul $t8 $t8 $a2 # => multiplicamos el numero decimal por 2
			
			div $t8 $t8 100 # => dividimos por 100 
			
			mfhi $t8 # => almacenamos el residuo en $t8 para volver a dividirlo 
			
			mflo $t5 # => el cociente lo almacenamos en $t5
			
			sb $t5 binaryNumber2($t4)
			
			addi $t4 $t4 1
			
			b loopDecimalBinario
			
		
Normalizacion: 

		# => Primero verificamos si la normalizacion es de dere-izq o de izq-derecha 
		
		li $t3, 0 # => iterador del array entero 
		li $t4, 0 # => permite comparar si es vacio el array o no
		li $t5, 0 # => almacena cuantas veces se mueve la coma
		li $t6, 0
		li $t9, 0 
		
		verificacionNorm:
		
			lb $t4 binaryNumber1($t3) # => le asiga al registro el valor que tiene el array en la posicion $t3
	
			beq $t4 1, normalizacionDerIzq # => si hay un 1 en el array entero, debemos normalizacion de DerIzq 
			
			beq $t3 19, normalizacionIzqDer # => si recorre todo mi array entero hasta llegar a la ultima posicion y no haya un 1, la normalizacion debe ser Izq-Der
			
			addi $t3 $t3 1 # => aumenta el iterador
			
			b verificacionNorm
			
			
			
				normalizacionDerIzq:
				
					
					
					beq $t3 19 finNormalizacion # => recorra el array hasta que llegue a la ultima posicion
					
					addi $t5 $t5 1 # => vaya sumando 1 al registro que guarda la cantidad de veces que se movio la coma
					
					addi $t3 $t3 1 # => para que el loop se acabe que $t3 aumente hasta que llegue al ultimo valor
					
					b normalizacionDerIzq
					
					
				
					
				normalizacionIzqDer:
				
					beq $t6 1 finNormalizacion # => a penas encuentre el primer 1 que se acabe el recorrido
				
					lb $t6 binaryNumber2($t9) # => vemos que valor adquiere $t6 en la posicion $t9 del array binaryNumber2
					
					addi $t9 $t9 1 # => aumentamos en 1 el iterador para desplazarnos en el array
					
					addi $t5 $t5 1 # => aumentamos en 1 el registro para conocer cuantas veces se movio la coma hasta que $t6 tome valor 1
					
					li $v0 1
					move $a0 $t5
					syscall
					
					b normalizacionIzqDer
					
					
					 
					

# => numero normalizado				 
finNormalizacion: 


		li $t3 0 # => con esto solo colocare el signo del numero en la primera posicion
		
		li $t4 0 # => iterador del array que contiene el numero normalizado
		
		li $t6 0 # => iterador del numero binario
		
		li $t7 3 # => iterador del numero Normalizado
		
		li $t8 44 # => comma
		
		li $t9 120 # => "x"
		
		li $s1 50 # => "2"
		
		li $s2 94 # => "^"
		
		li $s3 49 # => "1"
		
		move $s4 $t2 # => mueve el signo a $s4 para poder obtener la normalizacion
		
		move $s5 $t5 # => mueve el exponente a $s5 para poder obtener la normalizacion
		
		
		
		
		
		
		numeroBinario1:
			
			beq $t4 1 normalNumber1 # => cuando encuentre el primer uno pase al loop
		
			lb $t4 binaryNumber1($t6) # => $t4 toma los valores del array en la posicion $t6
			
			addi $t6 $t6 1
			
			b numeroBinario1
			
			

			normalNumber1:
				
		
				sb $t2 binaryNormalizado($t3) # => guarda els signo en la primera posicion
				
				addi $t3 $t3 1 # => aumenta el iterador en 1
				
				sb $s3 binaryNormalizado($t3) # => guarda en la posicion 1 el caracter 1
				
				addi $t3 $t3 1 # => aumenta el iterador en 1
				
				sb $t8 binaryNormalizado($t3) # => guarda en la posicion 2 la coma
				
					finalNumber1:
					
						beq $t7 8 showNumber1
						
						addi $t6 $t6 1 # => aumenta el iterador del binario para agrega el primer numero despues del primer 1
						
						lb $t4 binaryNumber1($t6) # => almacena en $t4 el valor del array en la posicion $t6
						
						addi $t4 $t4 48
					
						sb $t4 binaryNormalizado($t7) # => almacena los digitos binarios
						
						addi $t7 $t7 1 
						
						b finalNumber1
						
			#normalNumber2:
			
			#sb $t2 binaryNormalizado($t3)
			 
		
						


						
						
showNumber1:

		# => Muestra el mensaje indicando el numero normalizado
		
		li $v0 4 
		la $a0 mensajeNormalizado
		syscall
		 

		sb $t9 binaryNormalizado($t7) # => agregamos la x
		
		addi $t7 $t7 1	
		
		sb $s1 binaryNormalizado($t7) # => agregamos el 
		
		addi $t7 $t7 1	
		
		sb $s2 binaryNormalizado($t7) # => agregamos "^"
		
		addi $t7 $t7 1		
		
		addi $t5 $t5 48 # => agregamos el exponente
			
		sb $t5 binaryNormalizado($t7)
		
		li $t1 0 # => adquiere el valor del array en la posicion $t2
			
		li $t2 0 # => iterador del array para que se muestre la normalizacion
		
		
		# => se muestra el numero normalizado
		num1:
			beq $t2 12 puntoFlotante
			
			lb $t1 binaryNormalizado($t2)
			
			li $v0 11
			move $a0 $t1 
			syscall
			
			addi $t2 $t2 1
			
			b num1
		
			
			
			
	puntoFlotante:
	
		li $t1 0
		
		li $t2 0
		
		li $t3 48
		
		li $t4 49
		
		li $t5 0
		
		li $t6 0
		
		li $t7 0
		
		li $t8 0
		
		
		# => este algoritmo agrega el signo en binario al punto flotante
		
		
		
	
		beq $s4 43 signo # => si el singo es positivo entra al loop para obtener el binario del "+" 
		
				signo:
				
				subi $t2 $s4 43
				
				b loopb
				
				syscall
				# => sino es positivo entra aqui y a $t2 le almacena 1 que es el binario de negativo
		subi $t2 $s4 44
		
		loopb:
		
			sb $t2 numeroPuntoFlotante($t5) # => almacena el signo en la primera posicion del puntoFlotante
			
			
			# => el exponente lo covertimos a binario 
		
		
		exponenteBinario:
		
			beq $t5 8 addBinaryNumbers # => cuando llegue a la iteracion numero 8 que pase al siguiente loop
			
			addi $t5 $t5 1
		
			div $s4 $s4 2
			
			mfhi $t7
			
			#li $v0 1
			#move $a0 $t7
			#syscall
			
			mflo $t6
			
			#subi $t8 $t7 48
			
			sb $t7 numeroPuntoFlotante($t5) # => almacena el binario del exponente
			
			b exponenteBinario
			
				
				addBinaryNumbers:
				
					li $t2 0
					
					li $t6 0
					
					li $t7 19
					
					li $t8 0
					
					# => almacena la parte entera en binario en el punto flotante
					
					loop1: 
						
						beq $t5 24 addBinaryPart #=> itera hasta la posicion 24, para poder agregar la parte decimal en las posiciones restantes
						
						lb $t2 binaryNumber1($t7)
						
						sb $t2 numeroPuntoFlotante($t5)
						
						addi $t5 $t5 1
						
						subi $t7 $t7 1
						
						b loop1
						
							# => almacena la parte entera en binario en el punto flotante
						
							
							addBinaryPart:
							
								
								beq $t5 32 showPuntoFlotante #=> itera hasta la posicion 32, almacenando la parte decimal 
								
								lb $t8 binaryNumber2($t6)
								
								sb $t8 numeroPuntoFlotante($t5) 
								
								addi $t5 $t5 1
								
								addi $t6 $t6 1
								
								b addBinaryPart
							
							
# => muestra el numero decimal ingresado en punto flotante			
							
showPuntoFlotante:

	li $v0 4 
	la $a0 mensajePuntoflotante
	syscall

	li $t5 0
	li $t6 0
	
	loop2:
		
		beq $t5 31 finProgram
		
		lb $t6 numeroPuntoFlotante($t5)
		
		li $v0 1
		
		move $a0 $t6
		
		syscall
		
		addi $t5 $t5 1
		
		b loop2
		
# => agrega aqui tu parte del codigo verifancado que funcione con los dato que puse arriba en el .data y el mundo 
# => no jurungues el codigo de decimal que asi como esta funciona perfecto

hexaConversorMain: 

																																															

finProgram:
	li $v0 10
	syscall						