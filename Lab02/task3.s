.text

.globl main
main:

li x22, 0 #i
li x23, 0 #sum
li x24, 0x200 #base address
li x25, 10
li x26,0 

blt x22, x25, cond
beq x0,x0, Exit

cond:
    slli x26, x22, 2
    sw x22, x26(x24)
    addi x22, x22, 1
    blt x22, x25, cond
    beq x0,x0, Exit
