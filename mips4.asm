#=============================================
.eqv STACK_SIZE 2048
#=============================================
.data
	sys_stack_addr: .word 0			# Obszar na zapamiêtanie adresu stosu systemowego
	stack: .space STACK_SIZE			# Deklaracja w³asnego obszaru stosu
	global_array: .word 1,2,3,4,5,6,7,8,9,10	# Array do zsumowania
# ============================================
.text
	# czynnoœci inicjalizacyjne:
	sw $sp, sys_stack_addr	# Zachowanie adresu stosu systemowego
	la $sp, stack+STACK_SIZE	# Zainicjowanie obszaru stosu

	#Wykonanie wlasciwego programu:
	jal main			# Wykonuje main i zapisuje $ra
	lw $sp, sys_stack_addr	# Odtworzenie wskaŸnika stosu systemowego
	li $v0, 10
	syscall 			# Koniec programu


main:
	subi $sp, $sp, 4		# Przesuwam stack pointer aby wskazywal na poczatek zapisanej wartosci
	sw   $ra, ($sp) 		# Umieszczam na wierzcholku stosu adres powrotu

	# £aduje argumenty funckji na stos:
	la   $t0, global_array	# Wskaznik na poczatek array
	subi $sp, $sp, 4		# Przesuwam stack pointer aby wskazywal na poczatek zapisanej wartosci
	sw   $t0, ($sp)		# Zapisuje wskaznik na poczatek array na stosie
	li   $t0, 10 		# Zapsiuje array_size
	subi $sp, $sp, 4 	# Przesuwam $sp przed zapisem
	sw   $t0, ($sp)		# Zapsiuje array_size na stosie 
	# Zapis specjalnie bez optymalizacji jak w poleceniu, moglibyœmy zmieniaæ wartosc $sp tylko raz rezerwujac cale miejsce na poczatku
	
	jal  sum			# Wywoluje podprogram i zapisuje obecny adres w $ra
	lw   $a0, ($sp)		# Pobieram wartosc powrotu podprogramu
	addi $sp, $sp, 12	# Usuwam wartosc powrotu i argumenty ze stosu (przywracam $sp jaki byl przed wywolaniem podprogramu)
	li   $v0, 1
	syscall			# Wyswietlam sume pobrana ze stosu
# koniec podprogramu main: (powrot do $ra)
	lw $ra ($sp)		# Pobieram return adress ze stosu
	jr $ra			# Koniec main, powrot.
	

sum:
	#inicjalizacja wartosci na stosie:
	subi $sp, $sp, 4 	# Robie miejsce na wartosc zwracana
	subi $sp, $sp, 4 	# Przesuwam $sp przed zapisem (specjalnie bez optymalizacji, -4 i -4 zamiast -8
	sw   $ra, ($sp) 		# Umieszczam na wierzcholku stosu adres powrotu
	subi $sp, $sp, 8 	# Robie miejsce na zmienne lokalne
# i= 0($sp),  s= 4($sp),  $ra= 8($sp),  returnValue= 12($sp),  array_size= 16($sp),  array_pointer= 20($sp)
	#obliczenia, clalo programu
	
	sw   $zero 4($sp)	# Inicjalizuje s = 0
	lw   $t0, 16($sp)	# Pobieram array_size
	subi $t0, $t0, 1 	# i = array_size - 1
	sw   $t0, 0($sp)		# Zapisuje nowa wartosc i
	petla:
		lw   $t0, 0($sp) 		# Pobieram wartosc i ze stosu
		sll  $t4, $t0, 2 		# i*4 (uzyskuje adres indeksu i w array)
		lw   $t2, global_array($t4) 	# Pobieram array[i*4] z array
		lw   $t1, 4($sp) 		# Pobieram wartosc s ze stosu
		
		add  $t1, $t1, $t2 		# s = s + array[i]
		sw   $t1, 4($sp)			# zapisuje wartosc s na stosie
		subi $t0, $t0, 1 		# i = i-1
		sw   $t0, 0($sp)			# zapisuje wartosc i na stosie
		
		bgez $t0 petla 			# while (i>=0)
	
	# Zakonczenie podprogramu:
	lw   $t0, 4($sp)		# Pobieram wartosc zmiennej lokalnej s
	sw   $t0, 12($sp)	# Zapisuje s jako wartosc zwracana
	addi $sp, $sp, 8 	# Usuwam zmienne lokalne przeuwajac wskaznik stosu
	lw   $ra, ($sp) 		# Pobieram adres powrotu
	addi $sp, $sp, 4 	# Przesuwam stack pointer, na szczycie stosu jest wartosc zwracana
	jr   $ra
	