.section .data
n1_upper : .dword 0x1234567887654321
n1_lower : .dword 0x1234567887654321
n2_upper : .dword 0x8765432112345678
n2_lower : .dword 0x8765432112345678
result_1 : .dword 0  # rightmost 64 bits
result_2 : .dword 0  # second from right 64 bits
result_3 : .dword 0  # second from left 64 bits
result_4 : .dword 0  #leftmost 64 bits

# result is result_1 to result_4 ordered right to left

.section .text
.globl main

main:

# let the numbers be BA x DC
ld t0, n1_upper #B
ld t1, n1_lower #A
ld t2, n2_upper #D
ld t3, n2_lower #C

la t4, result_1
mul t5, t1, t3  # T5=AC
sd  t5, 0(t4) #AC is stored in result_1

mulhu t4, t1, t3  # t4 = (AC)u
mul t5, t0, t3    # t5 = (BC)l
mul t6, t1, t2    # t6 = (AD)l

addi sp, sp, -16   #storing A and C in stack to free up registers
sd t1, 0(sp)     #A
sd t3, 8(sp)     #C
 
add t3, t5, t6   # t3 = BCl + ADl
sltu t1, t3, t5  # carry from first addition
add t3, t3, t4   # t3 = BCl + ADl + ACu
sltu t5, t3, t4   #carry from second addition
la t4, result_2  
sd t3, 0(t4)     # storing added value to result_2
add t1, t1, t5   # overall carry  

# t5, t6 random
ld t3, 0(sp) #A = t3
ld t4, 8(sp) #C = t4
mulhu t3, t3, t2  #ADu = t3
mulhu t4, t4, t0  #BCu = t4

add t3, t3, t4                 # t3 = ADu+BCu
sltu t4, t3, t4                # t4 = carry from first addition
mul t5, t0, t2                 # BD = t5 
add t3, t3, t5                 # t3 = ADu+BCu+BD
sltu t6, t3, t5                # t6 = carry from second addition
add t4, t4, t6                 # t4 = carry 1 + carry 2
add t3, t3, t1                 # t3 = ADu+BCu+BD + previous carry
sltu t5, t3, t1                # t5 = carry from third addition
add t4, t4, t5                 # t4 = carry 1 + carry 2 + carry 3
la t1, result_3                # t1 = address (result_3)
sd t3, 0(t1)                   # t3 is stored in result_3

mulhu t3, t0, t2               # t3 = BDu
add t3, t3, t4                 # adding previous carry 
sltu t5, t3, t4                # overflow
la t6, result_4                # t6 = address(result_4)
sd t3, 0(t6)                   # t3 is stored in result_4

end :
li a7, 93
ecall