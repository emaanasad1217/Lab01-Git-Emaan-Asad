.text

.globl main

main:

li x11, 0x200
li x1, 23
sw x1, 0(x11)
li x2, 12
sw x2, 4(x11)
li x3, 5
sw x3, 8(x11)
li x4, 44
sw x4, 12(x11)
li x5, 98
sw x5, 16(x11)
li x6, 53
sw x6, 20(x11)
li x7, 6
sw x7, 24(x11)
li x8, 89
sw x8, 28(x11)
li x9, 32
sw x9, 32(x11)
li x18, 65
sw x18, 36(x11)
li x19, 0 # swapped
li x17, 10 #size


while:

    li x19, 0 # swapped = false
    li x20, 1 #i
   
    ForLoop:
    bge x20, x17, noSwap
    addi x16, x20, -1
    slli x5, x16, 2

    add x5, x5, x11  
    lw x8, 0(x5) # load i-1 element
    lw x9, 4(x5) # load i element

    bgt x8, x9, swap
    beq x0,x0, noSwap
    swap:
   
    sw x9, 0(x5)
    sw x8, 4(x5)
   
    li x19, 1 #swapped = true

    noSwap:
    addi x20, x20, 1
    blt x20, x17, ForLoop
    bne x19, x0, while

end:
    j end