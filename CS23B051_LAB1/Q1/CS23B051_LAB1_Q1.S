.section .data
arr : .word 5, 3, 4, 6, 5
n : .word 5

.section .text
.globl main

main :
la t0, arr      # t0 has address of arr[0]
li t1, 0        # t1 = 0
li t2, 0        # t2 = i = 0
lw t3, n        # t3 = n

loop1 :             # for loop
bge t2, t3, end     # i>=n terminate the loop
slli t4, t2, 2      # find offset of arr[i] 
add t5, t0, t4      # t5 is address of arr[i]
lb t6, 0(t5)        # t6=arr[i]
add t6, t6, t2      # t6 = arr[i]+i
sw t6, 0(t5)        # store it in the correct address
addi t2, t2, 1      # i++
j loop1 

end :
li a7, 93
ecall

