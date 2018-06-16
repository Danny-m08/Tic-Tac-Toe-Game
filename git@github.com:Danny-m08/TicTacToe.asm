.data
board: .byte '_','_','_','_','_','_','_','_','_'
tab: .byte '\n'
space: .ascii " "
players: .ascii "_XO"
error_msg: .asciiz " is an invalid position.\n\n"
prompt: .asciiz " Player: Please enter a valid position (0 - 8):\t"
winner: .asciiz " won the game, exiting."
cats_msg: .asciiz "cat's game!"

.text
.globl main


main:
	jal print_board
	la $s0, players
	la $s1, board
	li $s2, 0
		gameloop:
			
			
			lb $a0, 1($s0)			#Player X move 
			jal get_valid_move
			
			lb $t0, 1($s0)			#$t0 holds X
			sb $t0, 0($v0)			#Store x in address returned
			
			add $a0, $t0, $0
			jal check_for_win
			jal print_board
			
			li $t0, 4
			beq $s2, $t0, cats_game
			
			lb $a0, 2($s0)
			jal get_valid_move
			
			lb $t0, 2($s0)			#$t0 holds O
			sb $t0, 0($v0)
			
			add $a0, $t0 $0
			jal check_for_win
			jal print_board
			addi $s2, $s2, 1
			
			
			j gameloop
	
cats_game:
	li $v0, 4
	la $a0, cats_msg
	syscall
	
	li $v0, 10
	syscall
#-----------------------------------Print board------------------------------------------

print_board: 
	la $t0, board	
	li $t1, 0			#element index
	li $t3, 3			#element to indicate when to print tab
	li $t4, 9			
	
	loop:
		beq $t1, $t3, print_tab		
		beq $t1, $t4, done			#Exit after 10 loops
		
		lb $a0, 0($t0)				#Store char in $a0
		li $v0, 11
		syscall						#Print char in array
		
		li $v0, 11
		lb $a0, space
		syscall
		
		addi $t1, $t1, 1			#increment counter
		addi $t0, $t0, 1			#increment to next char
		j loop
		
	print_tab: 
			li $v0, 11				#Prints tab for each row
			lb $a0, tab
			syscall
			
			addi $t3, $t3, 3		
			j loop
	
		done: jr $ra

#------------ returns the address of element (0-8) passed in through $a0-----------------

entry_address:
	add $v0, $s1, $a0		#offset address by int passed through
	jr $ra

#--------------------Is pos => 0 & pos <= 8----------------------------------


valid_position:	
		li $t6, 8					#t6 = 8
		bgt $a0, $t6, notvalid		#pos > 8 -> invalid
		blt $a0, $0, notvalid		#pos < 0 -> invalid
		addi $v0, $0, 1				#return 1
		jr $ra
		
	notvalid:	add $v0, $0, $0		#return 0
				jr $ra
					
#-------------Gets valid move from user and returns address ----------------#		

get_valid_move:				
		add $t0, $a0, $0
		lb $t1, 0($s0)				
cinloop:
		li $v0, 11					#print character passed through
		add $a0, $t0, $0			#
		syscall						#

		li $v0, 4					#print prompt
		la $a0, prompt				#
		syscall 					#	

		
		li $v0, 5					#read integer 
		syscall						#
		add $s4, $v0, $0			#S4 stores valid # until next valid move is called
		
		add $a0, $v0, $0
		li $v0, 1
		syscall
		
		li $v0, 11
		la $t2, tab
		lb $a0, 0($t2)
		syscall
		

		add $a0, $s4, $0			#Pass integer into valid_position
		addi $sp, $sp, -4			#Save $ra to stack
		sw $ra, 0($sp)				#
		jal valid_position			
		lw $ra, 0($sp)				#
		addi $sp, $sp, 4			#Deallocate stack
		beq $v0, $0, error			#error if returns 0
		
		
		addi $sp, $sp, -4			#Save $ra to stack
		sw $ra, 0($sp)
		jal entry_address			#go to address passed through
		lw $ra, 0($sp)
		addi $sp, $sp, 4			#deallocate stack memory
		
		lb $t2, 0($v0)				#load byte in address
		bne $t2, $t1, error			#error if byte in address isn't '_'
		
		jr $ra
		
error:	
		add $a0, $s4, $0
		li $v0, 1						#print number
		syscall							#
		
		li $v0, 4						#Print error message
		la $a0, error_msg				#
		syscall
		j cinloop						#

#--------------	Returns 1 if player symbol matches addresses passes -------------------

check_all_match:
		lb $t0, 0($a0)				#byte in Address 1
		lb $t1, 0($a1)				#2
		lb $t2, 0($a2)				#3
		
		bne $a3, $t0, notequal		#not equal if byte passed in doesn't match byte in...
		bne $a3, $t1, notequal		#addresses
		bne $a3, $t2, notequal		#
		addi $v0, $0, 1				#return 1
		jr $ra
		
		notequal:	
			add $v0, $0, $0			#return 0
			jr $ra

#--------------------------Prints winner message and exits---------------------------
print_winner_and_exit:
	li $v0, 11					#print winner character
	syscall						#
	
	li $v0, 4					#print winner statement
	la $a0, winner				#
	syscall 					#

	li $v0, 10					#End program
	syscall

#------------------checks if all symbols in row match player symbol---------------------
row_winner:
	li $t0, 3					#
	
	add $a3, $a1, $0			#a3 stores player char
	blt $a0,$t0, row1			#test row 1 if slot selected is less than 3
	addi $t0, $t0, 3			#add 3
	blt $a0, $t0, row2			#test row 2 if slot selected is less than 6
	add $a0, $s1, 6				#get address of slot 1 row 3
	addi $a1, $a0, 1			#slot 2 row 3
	addi $a2, $a1, 1			#slot 2 row 3

return:	
	addi $sp, $sp, -4			#Save $ra to stack
	sw $ra, 0($sp)				#
	jal check_all_match
	lw $ra, 0($sp)				#deallocate stack
	addi $sp, $sp, 4
	
	bne $v0, $0, finish			#call winner prompt if check_all_match returns 1
	jr $ra						#else jump back to game
	
	row1:
		add $a0, $s1, 0			#get address of slot 1 row 1
		addi $a1, $a0, 1		#get address of slot 2 row 1
		addi $a2, $a1, 1		#get address of slot 3 row 1
		j return
	row2: 
		add $a0, $s1, 3			#get address of slot 1 row 2
		addi $a1, $a0, 1		#get address of slot 2 row 2
		addi $a2, $a1, 1		#get address of slot 3 row 2
		j return
	finish:
		addi $sp, $sp, -4			#Save $ra to stack
		sw $ra, 0($sp)				#
		jal print_board
		lw $ra, 0($sp)				#deallocate stack
		addi $sp, $sp, 4
		add $a0, $a3, $0
		jal print_winner_and_exit
		
#-----------------checks all symbols in column for match------------------------
col_winner:
	add $a3, $a1, $0
	li $t0, 0
	li $t1, 3
	li $t2, 6
	beq $a0, $t0, col1
	beq $a0, $t1, col1
	beq $a0, $t2, col1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	beq $a0, $t0, col2
	beq $a0, $t1, col2
	beq $a0, $t2, col2
	add $a0, $s1, 2
	addi $a1, $a0, 3
	addi $a2, $a1, 3
return2:
	
	addi $sp, $sp, -4			#Save $ra to stack
	sw $ra, 0($sp)				#
	jal check_all_match
	lw $ra, 0($sp)				#deallocate stack
	addi $sp, $sp, 4
	
	bne $v0, $0, finish			#call winner prompt if check_all_match returns 1
	jr $ra						#else jump back to game
	
	col1:
		add $a0, $s1, $0			#get address of slot 1 col 1
		addi $a1, $a0, 3		#get address of slot 2 col 1
		addi $a2, $a1, 3		#get address of slot 3 col 1
		j return2
	col2: 
		add $a0, $s1, 1			#get address of slot 1 col 2
		addi $a1, $a0, 3		#get address of slot 2 col 2
		addi $a2, $a1, 3		#get address of slot 3 col 2
		j return2
#-----------------checks all symbols in diagonal for matches---------------------------

diag_winner:
	add $a3, $a0, $0		#Store a0 into a3
	add $a0, $0, $s1		#a0 is address of first element
	addi $a1, $s1, 4		#a1 is address of middle element
	addi $a2, $s1, 8		#a2 if address of element 8
	
	addi $sp, $sp, -4			#Save $ra to stack
	sw $ra, 0($sp)				#
	jal check_all_match			#check for matches
	lw $ra, 0($sp)				#deallocate stack
	addi $sp, $sp, 4
	
	bne $v0, $0, finish			#j to finish if v0 returns 1
	
	addi $a0, $a0, 2		#a0 stores address of element 2
	addi $a2, $a2, -2		#a2 stores address of element 6
	
	addi $sp, $sp, -4		#Save $ra to stack
	sw $ra, 0($sp)				#
	jal check_all_match
	lw $ra, 0($sp)				#deallocate stack
	addi $sp, $sp, 4
	
	bne $v0, $0, finish
	jr $ra
	
	
#-------------------------Check for winner---------------------------------------
check_for_win:
	add $a1, $a0, $0 
	add $a0, $s4, $0 
	addi $sp, $sp, -12			#allocate space for ra, a0, a1
	sw $a0, 8($sp)				#load a0 to stack		
	sw $a1, 4($sp)				#load a1 to stack
	sw $ra, 0($sp)				#load ra into stack
	
	jal row_winner				#Checks row that player selected & exits if won

	
	lw $a0, 8($sp)				#load a0 from stack
	lw $a1, 4($sp)				#load value from stack

	jal col_winner				#Checks column & exits if won

	lw $a0, 4($sp)				#load a0 from stack

	jal diag_winner				#checks diagonal & exits if won
	
	lw $ra, 0($sp)				#load $ra from stack
	addi $sp, $sp, 12			#deallocate all of stack
	
	jr $ra