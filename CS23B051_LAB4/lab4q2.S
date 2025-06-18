.section .data
.global rev_str
.global reverse
rev_str : .space 50

.section .text
.globl main

reverse:           # a0 = &str[0]
li t0, 0           # t0 = i = 0
mv t1, a0          # t1 = &str[0]
lb t2, 0(t1)          # t2 = str[0]

# length of the string
FOR_LOOP:
    beqz t2, find_rev   
    addi t1, t1, 1
    lb t2, 0(t1)
    addi t0, t0, 1   # i++
j FOR_LOOP

find_rev:    
# t0 = n
mv a1, t0   # a1 = n

li t3, 0           # t3 = i = 0
srai t4, t0, 1     # t4 = n/2
la t2, rev_str     # t2 = &rev_str[0]

for_loop:   # i=0 to i=n   s[i] = rev_str[n-i-1]
beq t3, a1, return_values
sub t5, a1, t3
addi t5, t5, -1    # t5 = n-i-1
add t5, t5, t2    # t5 = &rev_str[n-i-1]
add t2, a0, t3    # t2 = &s[i]
lb t2, 0(t2)       # t2 = s[i]
sw t2, 0(t5)       # rev_str[n-i-1] = s[i]
addi t3, t3, 1     # i++
j for_loop

return_values: 
mv a0, a1         # a0 = n

ret

end:
li a7, 93
ecall