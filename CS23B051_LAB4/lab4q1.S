.section .data
.global course_name
course_name : .asciz "CS2610"
first_name  : .asciz "abc"
last_name   : .asciz "xyz"

.section .text
.globl main

main:
# call getCourse
jal ra, getCourse  # a0 = course_name

# call displayStudentProfile
la a1, first_name   
la a2, last_name
jal ra, displayStudentProfile

end:
li a7, 93
ecall

