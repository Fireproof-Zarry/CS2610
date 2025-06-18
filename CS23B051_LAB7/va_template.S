.section .text
.global main


main:


    # Jump to supervisor mode


supervisor:

################ Initialize your page tables here ################


####################################################################





    # Prepare jump to user mode






################ DO NOT MODIFY THESE INSTRUCTIONS ################
    la t1, satp_config # load satp val
    ld t2, 0(t1)
    sfence.vma zero, zero
    csrrw zero, satp, t2
    sfence.vma zero, zero

    li t4, 0
    csrrw zero, sepc, t4 
    sret
####################################################################


.align 
user_code:
    la t1,var1
    la t2,var2
    la t3,var3
    la t4,var4
    j user_code


.data
.align
var1:  .word  1
var2:  .word  2
var3:  .word  3
var4:  .word  4

.align
satp_config: .dword  # Value to set in satp