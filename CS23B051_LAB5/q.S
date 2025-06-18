.section .text
.globl main

main:
# mie(3), mpp(12,11), mpie(7), mepc, mtvec

# medeleg
li t0, 0x100
csrrs zero, medeleg, t0   # sets 8th bit of medeleg to 1 

#mtvec
la t0, mtrap_handler
csrw mtvec, t0

#mepc
la t0, scode
csrw mepc, t0

#stvec
la t0, strap_handler
csrw stvec, t0

#sepc
la t0, ucode
csrw sepc, t0

#mstatus  priv mode y to x tehn xIE=0 xPP=y 
csrr t0, mstatus            # set 12-11th bit as 01  (prev mode is supervisor)
li t1, 0x1000
csrrc zero, mstatus, t1       # clears 12th bit
li t1, 0x800                # sets 11th bit as 1
csrrs zero, mstatus, t1
andi t1, t0, 0x000000008    # t1  = value of mie  = 1000 or 0000
slli t1, t1, 4             
csrrs zero, mstatus, t1     # set 7th bit

#sstatus
csrr t0, sstatus
li t1, 0x1000
csrrc zero, sstatus, t1       # clears 12th bit
li t1, 0x800
csrrc zero, sstatus, t1       # clears 11th bit           
andi t1, t0, 0x000000008    # t1  = value of sie  = 1000 or 0000
sll t1, t1, 4             
csrrs zero, sstatus, t1     # set 7th bit

mret

scode:
sret

mtrap_handler:
csrr t0, mcause
csrr t1, mepc
la t2, strap_handler
csrw mepc, t1
mret

strap_handler:
csrr t0, scause
csrr t1, sepc
li a7, 11
ecall
la t1, ucode
csrw sepc, t1
sret

ucode:
li a7, 11
ecall