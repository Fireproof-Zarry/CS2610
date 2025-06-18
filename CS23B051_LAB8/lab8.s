
.section .text
.global main



main:
    # Prepare jump to super mode
    li t1, 1
    slli t1, t1, 11   #mpp_mask
    csrs mstatus, t1
    
    la t4, supervisor       #load address of user-space code
    csrrw zero, mepc, t4    #set mepc to user code
    
    la t5, page_fault_handler
    csrw mtvec, t5
   
    mret

supervisor:
################## Setting up page tables ##############
    # Set value in PTE2 (Initial Mapping)
    li a0,0x81000000
    li a1, 0x82000
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 16(a0)

    # To set V.A 0x0 -> P.A 0x0
    li a1, 0x82001
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 0(a0)

    # Set value in PTE1 (Initial Mapping)
    li a0,0x82000000
    li a1, 0x83000
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 0(a0)

    # Set Frame number in PTE0 (Initial Mapping)
    li a0,0x83000000
    li a1, 0x80000
    slli a1, a1, 0xa
    ori a1, a1, 0xef # D | A | G | - | X | W | R |V
    sd a1, 0(a0)

    li a1, 0x80001
    slli a1, a1, 0xa
    ori a1, a1, 0xef # D | A | G | - | X | W | R |V
    sd a1, 8(a0)

    # Set value in PTE1 (Code Mapping)
    li a0,0x82001000
    li a1, 0x83001
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 0(a0)

    # Set value in PTE0 (Code Mapping)
    li a0,0x83001000
    li a1, 0x80001
    slli a1, a1, 0xa
    ori a1, a1, 0xf9 # D | A | G | U | X | - | - |V
    sd a1, 0(a0)

    # Data Mapping
    li a1, 0x80002
    slli a1, a1, 0xa
    ori a1, a1, 0xf7 # D | A | G | U | - | W | R |V
    sd a1, 8(a0)
    

####################################################################

    # Prepare jump to user mode
    li t1, 0
    slli t1, t1, 8   #spp_mask
    csrs sstatus, t1

    # Configure satp
    la t1, satp_config 
    ld t2, 0(t1)
    sfence.vma zero, zero
    csrrw zero, satp, t2
    sfence.vma zero, zero

    li t4, 0       # load VA address of user-space code
    csrrw zero, sepc, t4    # set sepc to user code
    
    sret



###################################################################
##################### ADD CODE ONLY HERE  #########################
###################################################################
.align 4
page_fault_handler:

#t5,t6,t4
mv a0, t0
mv a1, t1
mv a2, t2
mv a3, t3
mv a4, t4
mv a5, t5

csrr s0, mcause
csrr s1, mtval
srli s2, s1, 12
li s3, 0x1FF     
and s2, s2, s3    # s2 = VPN[0]

li t0, 12      # instruction page fault

beq s0, t0, instruction_fault_handler
li t1, 0x80002000   # data_fault_handler
srli t3, s1, 12
slli t3, t3, 10
li t0, 0x7D        # 0111 1101  DAGU XRWV
or t3, t3, t0
slli t2, t2, 3    # each entry 8B so multiply by vpn[0] by 8
add t1, t1, t2   
sd t3, 0(t1)

instruction_fault_handler:
la t1, var_count
lw t2, 0(t1)
la t3, code_jump_position
li s3, 0x80002000 
slli s5, t2, 12
add s3, s3, s5
li s4, 0x80001000
# 2^12 entries  8B each entry
li t5, 4096
li t0, 0 # t0 = i
loop:
bge t0, t5, loop_done  # i=0 to i=4095
    slli t6, t0, 3     # t6 = 8*i
    add t1, t6, s4    # t1 = address(PT[i])
    ld t1, 0(t1)      # t1 = PT[i]
    add t3, s3, t6    # t3 = address(newPT[i])
    sd t1, 0(t3)      # newPT[i] = PT[i]
    addi t0, t0, 1    # i++
    j loop
loop_done:
srli t4, s3, 12   # s1 - mtval
slli t4, t4, 10
li t5, 0x7B        # 0111 1011  DAGU XWRV
or t4, t4, t5      # t4 is the PTE 
slli s2, s2, 3    # each entry 8B so multiply by vpn[0] by 8
li t0, 0x83001000
add t0, t0, s2   
sd t4, 0(t0)

mv t0, a0
mv t1, a1
mv t2, a2
mv t3, a3
mv t4, a4
mv t5, a5

mret

###################################################################
###################################################################



.align 12
user_code:
    la t1,var_count
    lw t2, 0(t1)
    addi t2, t2, 1
    sw t2, 0(t1)

    la t5, code_jump_position
    lw t3, 0(t5)
    li t4, 0x2000
    add t3, t3, t4
    sw t3, 0(t5)
    
    jalr t0, t3


.data
.align 12
var_count:  .word  0
code_jump_position: .word 0x0000


.align 8
# Value to set in satp
satp_config: .dword 0x8000000000081000
