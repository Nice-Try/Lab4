addi $t5, $zero, 10
addi $t6, $zero, 11
slt $t7, $t5, $t6
slt $t4, $t6, $t5
xori $a3, $t5, 65535
addi $a0, $zero, 6
sw	$a0, 0($zero)
lw $a2, 0($zero)
addi $t1, $zero, 12
addi $t2, $zero, 12
bne 	$t2, $t1, END

j TARGET
SUBTRACT:
sub $t3, $t1, $a0
beq $t2, $t1, END


TARGET:
add $a2, $t1, $a0
j SUBTRACT

END:
