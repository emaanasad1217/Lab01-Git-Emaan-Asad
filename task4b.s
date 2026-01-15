.text
.globl main

main:
    #a, b, c initialized
    li x10, 0x100
    li x11, 0x200
    li x12, 0x300

    li x9, 1
    sw x9, 0(x10)
    li x8, 2
    sw x8, 1(x10)
    li x7, 3
    sw x7, 2(x10)
    li x6, 4
    sw x6, 3(x10)

    li x9, 1
    sw x9, 0(x11)
    li x8, 2
    sw x8, 2(x11)
    li x7, 3
    sw x7, 4(x11)
    li x6, 4
    sw x6, 6(x11)


    #first iteration i = 0
    lb x13, 0(x10)
    lh x14, 0(x11)

    add x15, x14, x13
    sw x15, 0(x12) 

    #first iteration i = 1
    lb x13, 1(x10)
    lh x14, 2(x11)

    add x15, x14, x13
    sw x15, 4(x12) 


    #first iteration i = 2
    lb x13, 2(x10)
    lh x14, 4(x11)

    add x15, x14, x13
    sw x15, 8(x12) 

    #first iteration i = 3
    lb x13, 3(x10)
    lh x14, 6(x11)

    add x15, x14, x13
    sw x15, 12(x12) 

end:
    j end


