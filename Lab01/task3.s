.text
.globl main
main:
    li x20, 5
    add x21, x0, x0
    addi x20, x21, 32 
    add x22, x20, x21
    addi x23, x22, -5
    sub x24, x20, x23
    add x24, x24, x21
    sub x24, x24, x20
    add x24, x24, x23
    add x25, x22, x23
    add x24, x25, x24

end:
    j end

