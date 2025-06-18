.section .text
.global main

.align 8
main:
li s5, 1  # denotes if B is executed for the first time
la t0, context_switch
csrw mtvec, t0     # mtvec points to mtrap_handler

li t0, 1
slli t0, t0, 3
csrs mstatus, t0   # MIE = 1

li t0, 3
slli t0, t0, 11
csrc mstatus, t0   # MPP = 00 (prev mode is user)

la t1, Task_A
csrw mepc, t1      # mepc points to Task_A (user mode)

li s4, 0x2004000   # t1 = address(mtimecmp)
li t0, 10000
sd t0, 0(s4)       # mtimecmp = 10000

li t0, 0x80    
csrs mie, t0      # mie.MTIE = 1
mret

.align 8
context_switch:
	# save the context of the interrupted task by looking at the task id (jump to relavent label)
    lw t0, current
    beqz t0, save_context_A  # current = 0
    j save_context_B

.align 8
save_context_A:
	# save all the registers and PC value in stack_a
    # mepc stores the value of PC at the time of interrupt
    lwu s0, stack_a
    csrw mepc, t0
    sd t0, 8(s0)
    sw s1, 4(s0)
    sw t1, 0(s0) 
    j switch

.align 8
save_context_B:
    lwu s0, stack_b
    csrw mepc, t0
    sd t0, 8(s0)
    sw s1, 4(s0)
    sw t1, 0(s0) 
    j switch

.align 8
switch_to_A:
    la t2, current
    li t3, 0
    sw t3, 0(t2)
	# restore the values of registers and PC from stack_a
    lwu s0, stack_a 
    ld t0, 8(s0)
    lw s1, 4(s0)
    lw t1, 0(s0)
    csrw mepc, t0
    mret
.align 8
switch_to_B:
    la t2, current
    li t3, 1
    sw t3, 0(t2)
    # restore the values of registers and PC from stack_b
    lwu s0, stack_a
    ld t0, 8(s0)
    lw s1, 4(s0)
    lw t1, 0(s0)
    csrw mepc, t0
    mret
	
.align 8
initial_switch_to_B:
    # switching to Task B for the first time
    li s5, 0
    la t2, current
    li t3, 1
    sw t3, 0(t2)
    li s1, 0x03ffffff
    la t1, Task_B
    csrw mepc, t1
    mret
.align 8
switch:
	# increment mtimecmp
    ld t0, 0(s4)        # t0 = mtimecmp
    li t1, 10000        # t1 = 10000
    add t0, t0, t1    
    sd t0, 0(s4)        # mtimecmp = mtimecmp + 10000

    li t2, 1
    la t3, current
    beq t3, t2, switch_to_A  # current = 1 (at task B now, switch to A)
    beqz s5, switch_to_B     # current = 0 (at task A, switch to B) (s5=1 means first time task B is executed)
    j initial_switch_to_B

.align 8
Task_A: # increment your reg value
    li s1, 0x0fffffff
    li t1, 0
    loop1:
    beq t1, s1, finish_a
    addi t1, t1, 1
    j loop1
.align 8
finish_a:
    j finish_a
.align 8
Task_B: # decrement the reg value
    li t1, 0
    loop2:
    beq s1, t1, finish_b
    addi s1, s1, -1
    j loop2
.align 8
finish_b:
    j finish_b

.data
.align 8
stack_a:  .word  0xffff7000      # initialize stack for task A (You can choose a random address) 
.align 8
stack_b:  .word  0xffffa000      # initialize stack for task B
.align 8
current:  .dword  0      # 0 - task A, 1 - task B