# Function call example
# Take two numbers, add 2 to one of them twice, and then add them together

main:
# Set up an argument to call for sum2:
addi $a0, $zero, 4      # arg = 4
# Call sum2
jal sum2
# add it to something else
addi $t1, $v0, 12

j end

sum2:
addi $v0, $a0, 2
addi $v0, $v0, 2
jr $ra

end:
j end
