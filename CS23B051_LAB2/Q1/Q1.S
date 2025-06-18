.section .data
n1 : .dword 0x1234567887654321
n2 : .dword 0x8765432112345678
l_result :  .dword 0
u_result :  .dword 0

.section .text
.globl main

main:
ld t0, n1       # loading the value of n1 in t0
ld t1, n2       # loading the value of n2 in t1
la t2, l_result # address of lower 64 bits of result
la t3, u_result # address of upper 64 bits of result

mul t4, t0, t1  
sd t4, 0(t2)    # lower 64 bits is stored in t2
mulhu t4, t0, t1
sd t4, 0(t3)    # upper 64 bits is stored in t3

end :
li a7, 93
ecall
