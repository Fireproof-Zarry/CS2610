.section .text
.global main

.align 12
main:
    li t0, 0x00000800 # MPP (11th bit - 1)      
    csrr t1, mstatus
    or t1, t1, t0
    csrw mstatus, t1

    # Jump to supervisor mode
    la t0, supervisor
    csrw mepc, t0
    mret

.align 4
supervisor:
################ Initialize your page tables here ################
    # data
    li t0, 0x82001000  # level2[0] -> level1 
    srli t0, t0, 12      # get PPN from PA
    li t1, 0x1          # 1101111  AGUXWRV
    slli t0, t0, 10     
    or t0, t0, t1        
    li t2, 0x81000000
    sd t0, 0(t2)

    li t0, 0x83001000  # level1[0] -> level0
    srli t0, t0, 12      # t0 = PPN(level0_table)
    li t1, 0x1          # V = 1
    slli t0, t0, 10 
    or t0, t0, t1       
    li t2, 0x82001000
    sd t0, 0(t2)

    la t0, user_code      # level0[0] -> user_code
    srli t0, t0, 12
    li t1, 0x7F           # UXWRV = 1111111 AGUXWRV
    slli t0, t0, 10
    or t0, t0, t1
    li t2, 0x83001000
    sd t0, 0(t2)

    #
    li t0, 0x82000000  # level2[0] -> level1  
    srli t0, t0, 12     
    li t1, 0x1          
    slli t0, t0, 10      
    or t0, t0, t1        
    li t2, 0x81000000
    sd t0, 16(t2)

    li t0, 0x83000000  # level1[0] -> level0
    srli t0, t0, 12     
    li t1, 0x1         
    slli t0, t0, 10 
    or t0, t0, t1       
    li t2, 0x82000000
    sd t0, 0(t2)

    li t0, 0x80000000      # level0[0] -> main
    srli t0, t0, 12
    li t1, 0x6F           # 1101111 U=0
    slli t0, t0, 10
    or t0, t0, t1
    li t2, 0x83000000
    sd t0, 0(t2)

    li t0, 0x83001000
    srli t0, t0, 12
    li t1, 0x6F           # 1101111 U=0
    slli t0, t0, 10
    or t0, t0, t1
    li t2, 0x80002000

    sd t0, 0(t2)
   

####################################################################
    # Prepare jump to user mode
    csrw sstatus, zero
    
################ DO NOT MODIFY THESE INSTRUCTIONS ################
    la t1, satp_config    # load satp val
    ld t2, 0(t1)
    sfence.vma zero, zero
    csrrw zero, satp, t2
    sfence.vma zero, zero

    li t4, 0
    csrrw zero, sepc, t4 
    sret
####################################################################

.align 12
user_code:
    la t1,var1
    la t2,var2
    la t3,var3
    la t4,var4
    j user_code

.data
.align 12
var1:  .word  1
var2:  .word  2
var3:  .word  3
var4:  .word  4

.align 12
satp_config: .dword  0x8000000000081000 # Value to set in satp

.section .data
.align 12
level2_table : .dword  0x81000000
.align 12
level1_table : .dword  0x82001000
.align 12
level0_table : .dword  0x83001000
.align 12
level1_table2 : .dword  0x82000000
.align 12
level0_table2 : .dword  0x83000000
