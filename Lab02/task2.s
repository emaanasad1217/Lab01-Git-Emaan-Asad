.text

.globl main
main:

li x20, 5 #x
li x21, 2 #a
li x22, 6 #b
li x23, 4 #c
li x24, 1 #1
li x25, 2 #2
li x26, 3 #3
li x27, 4 #4

beq x20,x24, Case1
beq x20,x25, Case2
beq x20,x26, Case3
beq x20,x27, Case4

sub x21, x21, x21
beq x0, x0, Exit

Case1:
    add x21, x22, x23
    beq x0, x0, Exit

Case2:
    sub x21, x22, x23
    beq x0, x0, Exit

Case3:
    slli x21, x22, 1
    beq x0, x0, Exit

Case4:
    srli x21, x22, 1
    beq x0, x0, Exit

Exit:

    end:
        j end