.section .text
.global main

.align 8
main: # set the csrs
la t0, mtrap_handler
csrw mtvec, t0     # mtvec points to mtrap_handler

li t0, 1
slli t0, t0, 3
csrs mstatus, t0   # MIE = 1

li t0, 3
slli t0, t0, 11
csrc mstatus, t0   # MPP = 00 (prev mode is user)

la t1, user
csrw mepc, t1      # mepc points to user

li s0, 0x200bff8   # t0 = address(mtime)
li s1, 0x2004000   # t1 = address(mtimecmp)
li t0, 10000
sd t0, 0(s1)       # mtimecmp = 10000

li t0, 0x80    
csrs mie, t0      # mie.MTIE = 1
mret

.align 8
mtrap_handler:
ld t0, 0(s1)        # t0 = mtimecmp
li t1, 10000        # t1 = 10000
add t0, t0, t1    
sd t0, 0(s1)        # mtimecmp = mtimecmp + 10000
la t1, user
csrw mepc, t1       # mepc points to user
mret

.align 8
user:
j user



