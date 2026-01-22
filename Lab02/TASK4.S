.text

.globl main
main:

li x5, 5 #a
li x6, 5 #b
li x7, 0 #i
li x29, 0 #j
li x11, 0 #offset
li x10,0x200   #assumimg this has the base address
li x12, 0 #temp

blt x7, x5, OuterLoop

OuterLoop:
    bge x7, x5, Exit
    blt x29, x6, InnerLoop
    InnerLoop:

    slli x11, x29, 4
    add x12, x7, x29
    add x11, x10,x11  
    sw x12, 0(x11)
    addi x29, x29, 1
    blt x29, x6, InnerLoop
    sub x29, x29,x29
    addi x7, x7, 1

blt x7, x5, OuterLoop

Exit:

end: 
    j end



