.text

.globl main

main:
li x10, 0x200 #array base address
li x9, 1
sb x9, 0(x10)
li x8, 2
sb x8, 1(x10)
li x7, 3
sb x7, 2(x10)
li x6, 4
sb x6, 3(x10)
li x6, 5
sb x6, 4(x10)


addi x18, x0, 0 #i

li x11, 0x300 #array base address
li x9, 'a'
sb x9, 0(x11)
li x8, 'b'
sb x8, 1(x11)
li x7, 'c'
sb x7, 2(x11)
li x6, 'd'
sb x6, 3(x11)
li x6, 'e'
sb x6, 4(x11)

while:
add x5, x11, x18
add x6, x10, x18

lb x8, 0(x5)

sb x8, 0(x6)
beq x8, x0, Exit

addi x18, x18, 1
bne x8, x0, while

Exit:
end:
j end
