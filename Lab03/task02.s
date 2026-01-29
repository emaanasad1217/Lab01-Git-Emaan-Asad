.text

.globl main

main:

addi x10, x0, 13
addi x11, x0, 12
addi x12, x0, 11
addi x13, x0, 10

jal x1, leaf_example
mv x11, x10

li x10, 1
ecall
end: 
    j end 
leaf_example:
    addi sp, sp, -12
    sw x18, 0(sp)
    sw x19, 4(sp)
    sw x20, 8(sp)

    add x18, x10, x11
    add x19, x12, x13 
    sub x20, x18, x19

    mv x10, x20

    lw x18, 0(sp)
    lw x19, 4(sp)
    lw x20, 8(sp)

    addi sp, sp, 12
    jalr x0, 0(x1) 






