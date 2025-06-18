.section .data
n1 : .word 5
n2 : .word 3
arr : .word 0, 0, 0, 0, 0

.section .text
.globl main

main :
lw t0, n1 # t0 contains the value of n1
lw t1, n2 # t1 contains the value of n2
la t2, arr # address of arr[0] in stored in n

add t3, t0, t1    # t3 = t0 + t1
sw t3, 0(t2)      # arr[0] = n1 + n2

sub t3, t0, t1    # t3 = t0 - t1
sw t3, 4(t2)

and t3, t0, t1    # t4 = t0 & t1
sw t3, 8(t2)

or t3, t0, t1     # t5 = t0 | t1
sw t3, 12(t2)

xor t3, t0, t1    # t6 = t0 ^ t1
sw t3, 16(t2)

end :
li a7, 93
ecall
