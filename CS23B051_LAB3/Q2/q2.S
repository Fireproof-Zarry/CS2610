.data
str: .asciz "Move from rod X to rod Y\n"
x: .word 14      # X is at offset 14 in the string
y: .word 23      # Y is at offset 23 in the string
n: .word 10

.text
.globl main

main:
    la a0, n
    lw a0, 0(a0)     # a0 = n
    li a1, 49        # a1 = '1' (source rod)
    li a2, 51        # a2 = '3' (destination rod)
    li a3, 50        # a3 = '2' (auxiliary rod)
    jal ra, towerOfHanoi

    li a7, 93        
    li a0, 0
    ecall

towerOfHanoi:
    # Stack allocation
    addi sp, sp, -32
    sw ra, 28(sp)    # Save return address
    sw s0, 24(sp)    # n
    sw s1, 20(sp)    # from_rod
    sw s2, 16(sp)    # to_rod
    sw s3, 12(sp)    # aux_rod

    mv s0, a0        # s0 = n
    mv s1, a1        # s1 = from_rod
    mv s2, a2        # s2 = to_rod
    mv s3, a3        # s3 = aux_rod

    # Base case  n = 1
    li t0, 1
    beq s0, t0, base_case

    # Recursion 1 - towerOfHanoi(n-1, from, aux, to)
    addi a0, s0, -1  # a0 = n - 1
    mv a1, s1        # a1 = from_rod
    mv a2, s3        # a2 = aux_rod (switch to auxiliary)
    mv a3, s2        # a3 = to_rod
    jal ra, towerOfHanoi

    # Print move 
    la t3, str       # t3 = addr(str)
    
    la t4, x         
    lw t4, 0(t4)     # t4 = 14
    add t5, t3, t4   # t5 = address of X in str
    sb s1, 0(t5)     # Store from_rod character

    la t6, y         
    lw t6, 0(t6)     # t6 = 23
    add t6, t3, t6   # t6 = address of Y in str
    sb s2, 0(t6)     # Store to_rod character

    li a0, 1         
    la a1, str     
    li a2, 25       
    li a7, 64        
    ecall

    # Recursion 2 - towerOfHanoi(n-1, aux, to, from)
    addi a0, s0, -1  # a0 = n - 1
    mv a1, s3        # a1 = aux_rod (now source)
    mv a2, s2        # a2 = to_rod (destination remains)
    mv a3, s1        # a3 = from_rod (becomes auxiliary)
    jal ra, towerOfHanoi

    # Restore registers
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    addi sp, sp, 32
    ret

# Base Case
base_case:
    la t3, str
    la t4, x         
    lw t4, 0(t4)     
    add t5, t3, t4   
    sb s1, 0(t5)     # store from_rod 

    la t6, y         
    lw t6, 0(t6)     
    add t6, t3, t6   
    sb s2, 0(t6)     # store to_rod 

    li a0, 1         
    la a1, str       
    li a2, 25       
    li a7, 64       
    ecall

    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    addi sp, sp, 32
    ret
