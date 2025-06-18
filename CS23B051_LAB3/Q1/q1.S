.data
N:  .word 6

.text
.globl main

main:
    la a0, N              
    lw a0, 0(a0)       #Load value of N
    mv t3, sp          #intial_sp
    jal sum_fib        #S(N)
    mv s0, a0              
    mv t4, sp          #final_sp
    # compute stack usage
check:
    sub a1, t3, t4
    mv a0, s0            #a0 = S(N), a1 = stack usage       

    ret


fib:
    li t0, 0               # Base case F(0) = 0
    beq a0, t0, fib_base0  

    li t0, 1               # Base case  F(1) = 1
    beq a0, t0, fib_base1

    addi sp, sp, -24
    sd s1, 0(sp)
    sd s2, 8(sp)
    sd ra, 16(sp)
    addi s2, a0, -2    # s2 = n-2
    addi a0, a0, -1    # a0 = n-1
    call fib 
    mv s1, a0 
    mv a0, s2 # a0 = n-2
    call fib
    add a0, a0, s1  
    ld s1, 0(sp)
    ld s2, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24

    ret

fib_base0:
    li a0, 0
    ld s1, 0(sp)
    ld s2, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret

fib_base1:
    li a0, 1
    ld s1, 0(sp)
    ld s2, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret


sum_fib:
    addi sp, sp, -16      
    sd ra, 8(sp)           # Save ra
    sd a0, 0(sp)           # N

    addi a0, a0, 1         # a0 = N+1
    call fib               # Call fib(N+1)
    addi s5, a0, -1        # S(N) = F(N+1) - 1

    ld ra, 8(sp)           # Restore ra
    addi sp, sp, 16     
    mv a0, s5   
    ret