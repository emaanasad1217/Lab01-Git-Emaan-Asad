.text

.globl main

main:
    li x20, 5 #n
    li x21, 1 #product
    li x22, 1
    while:
        mul x21, x20, x21
        addi x20, x20, -1
        bge x20, x22, while

    Exit:
        end:
            j end
          

        
        