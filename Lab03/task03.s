.text

.globl main 

main:

    li x10, 0x200 #array base address
    li x9, 1
    sw x9, 0(x10)
    li x8, 2
    sw x8, 4(x10)
    li x7, 3
    sw x7, 8(x10)
    li x6, 4
    sw x6, 12(x10)
    li x6, 5
    sw x6, 16(x10)
    addi x11, x0, 1 #k

    
swap:  
    slli x5,x11, 2 # calculating the address using k * 4
    add x5, x10, x5

    lw x8, 0(x5) # k element
    lw x9, 4(x5) # k+1 element

    sw x9, 0(x5)
    sw x8, 4(x5)


end:
    j end
