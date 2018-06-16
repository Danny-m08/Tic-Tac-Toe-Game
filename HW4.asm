#---------------------------DANIEL MARQUEZ-----------------------------------------

.data

array: .space 400
prompt: .asciiz "Enter integer value, one per line \n terminated by a negative value\n"
sumprompt: .asciiz "\n	Sum is: "
minprompt: .asciiz "\n	Min is: "
maxprompt: .asciiz "\n	Max is: "
meanprompt: .asciiz " \n	Mean is: "
varprompt: .asciiz "\n	Variance is: "

.text 
.globl main

main: 
	la $a1, array				#A1 = &Array[0]
	jal readarr
	
	
	la $a1, array
	jal sum
	
	la $a1, array
	jal min
	
	la $a1, array
	jal max
	
	la $a1, array
	jal mean
	
	la $a1, array
	jal var
	
	done: li $v0, 10
	syscall
		
readarr: 
	li $t0, -1 				#Flag variable
	li $s0, 0					#Array counter	
	li $v0, 4					#Print Prompt
	la $a0, prompt
		syscall
	
	loop:
		li $v0, 5
			syscall					#Read int
		add $a0, $v0, $0
		li $v0, 1					#Print int
			syscall
		 
		beq $a0, $t0, readend		#End read if int is negative
		addi $s0, $s0, 1			#Increment 
		sw $a0, 0($a1)				#A[i] = $a0
		addi $a1, $a1, 4
		j loop 	
	
readend: add $v1, $s0, $0			#Return # of elements 
		jr $ra	

sum:
	li $t2, 0
	lw $t3, 0($a1)					#First element in array
	loop2:
		addi $t2, $t2, 1			#increment
		addi $t1, $s0, -1			
		bgt $t2, $t1, endsum		#branch if counter exceeds element #
		addi $a1, $a1, 4			#Jump to next element
		lw $t0, 0($a1)				#Store element value
		add $t3, $t3, $t0			#add and store in s1
		j loop2
	
endsum: add $v1, $0, $t3
	add $s1, $0, $t3
	li $v0, 4				#Print 
	la $a0, sumprompt
		syscall
	
	add $a0, $t3, $0
	li $v0, 1
		syscall
	jr $ra	

min:
	li $t0, 0
	lw $t1, 0($a1)				#first element & min number holder
	addi $t2, $s0, -1			#max number of iterations
	
	loop3:	
		addi $t0, $t0, 1		#increment counter
		bgt $t0, $t2, endmin
		addi $a1, $a1, 4			
		lw $t3, 0($a1)			# $t2 = A[i]
		blt $t1, $t3, loop3
		add $t1, $0, $t3		
		j loop3
			
endmin:
	add $v1, $t1, $0
	li $v0, 4
	la $a0, minprompt
		syscall
	
	add $a0, $t1, $0	
	li $v0, 1
		syscall
	jr $ra


 max:
	li $t0, 0 					#counter
	lw $t1, 0($a1)				#first element & min number holder
	addi $t2, $s0, -1			#max number of iterations
	loop4:
		addi $t0, $t0, 1		#increment counter
		bgt $t0, $t2, endmax
		addi $a1, $a1, 4			
		lw $t3, 0($a1)			# $t2 = A[i]
		bgt $t1, $t3, loop4
		add $t1, $0, $t3		
		j loop4
			
endmax:
	add $v1, $t1, $0
	li $v0, 4
	la $a0, maxprompt
		syscall
	
	add $a0, $t1, $0	
	li $v0, 1
		syscall
	jr $ra
	
	
mean:
	mtc1 $s1, $f1
	mtc1 $s0, $f2
	cvt.s.w $f1, $f1
	cvt.s.w $f2, $f2
	div.s $f0, $f1, $f2 
		
	li $v0, 4
	la $a0, meanprompt
		syscall
	
	li $v0, 2
	li.s $f3, 0.0
	add.s $f12, $f3, $f0
	syscall
	
	jal $ra
	
var:
	li $t0, 0
	li.s $f4, 0.0
	
	loop5:
		addi $t0, $t0, 1		#increment
		bgt $t0,$s0, endvar 
		lw $t1, 0($a1)
		addi $a1, $a1, 4
		mtc1 $t1, $f1
		cvt.s.w $f1, $f1
		sub.s $f3, $f1, $f0		# (x - mean)
		mul.s $f3, $f3, $f3		# (x - mean)^2
		div.s $f3, $f3, $f2		# (x - mean)^2/length
		add.s $f4, $f4, $f3
		j loop5

endvar: 
	li $v0, 4
	la $a0, varprompt
		syscall
		
	li $v0, 2
	li.s $f5, 0.0
	add.s $f12, $f4, $f5
		syscall
	
	jr $ra
	