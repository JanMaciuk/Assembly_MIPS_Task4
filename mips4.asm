#=============================================
.eqv STACK_SIZE 2048
#=============================================
.data
# obszar na zapamiêtanie adresu stosu systemowego
sys_stack_addr: .word 0
# deklaracja w³asnego obszaru stosu
stack: .space STACK_SIZE
global_array: .word 1,2,3,4,5,6,7,8,9,10
# ============================================
.text
# czynnoœci inicjalizacyjne
sw $sp, sys_stack_addr # zachowanie adresu stosu systemowego
la $sp, stack+STACK_SIZE # zainicjowanie obszaru stosu

# pocz¹tek programu programisty - zak³adamy, ¿e main
# wywo³ywany jest tylko raz

main:
# cia³o programu . . .
	# £aduje argumenty funckji na stos:
	la   $t0, global_array	# Wskaznik na poczatek array
	subi $sp, $sp, 4		# Przesuwam stack pointer aby wskazywal na poczatek zapisanej wartosci
	sw   $t0, ($sp)		# Zapisuje wskaznik na poczatek array na stosie
	li   $t0, 10 		# Zapsiuje array_size
	subi $sp, $sp, 4 	# Przesuwam $sp przed zapisem
	sw   $t0, ($sp)		# Zapsiuje array_size na stosie 
	# Zapis specjalnie bez optymalizacji, moglibyœmy zmieniaæ wartosc $sp tylko raz.
	
	jal  sum			# Wywoluje podprogram i zapisuje obecny adres w $ra
	lw   $a0, ($sp)		# Pobieram wartosc powrotu podprogramu
	addi $sp, $sp, 12	# Usuwam wartosc powrotu i argumenty ze stosu (przywracam $sp jaki byl przed wywolaniem podprogramu)
	li   $v0, 1
	syscall			# Wyswietlam sume pobrana ze stosu
# koniec podprogramu main:
	lw $sp, sys_stack_addr	# Odtworzenie wskaŸnika stosu systemowego
	li $v0, 10
	syscall 		# Koniec programu

sum:
	#inicjalizacja wartosci na stosie:
	subi $sp, $sp, 4 	# Robie miejsce na wartosc zwracana
	subi $sp, $sp, 4 	# Przesuwam $sp przed zapisem (specjalnie bez optymalizacji, -4 i -4 zamiast -8
	sw $ra, ($sp) 		# Umieszczam na wierzcholku stosu adres powrotu
	subi $sp, $sp, 8 	# Robie miejsce na zmienne lokalne
# i= 0($sp),  s= 4($sp),  $ra= 8($sp),  returnValue= 12($sp),  array_size= 16($sp),  array_pointer= 20($sp)
	#obliczenia, clalo programu
	
	
	lw   $t0, 4($sp)		# Pobieram wartosc zmiennej lokalnej s
	sw   $t0, 12($sp)	# Zapisuje s jako wartosc zwracana
	addi $sp, $sp, 8 	# Usuwam zmienne lokalne przeuwajac wskaznik stosu
	lw   $ra, ($sp) 		# Pobieram adres powrotu
	addi $sp, $sp, 4 	# Przesuwam stack pointer, na szczycie stosu jest wartosc zwracana
	jr   $ra
	