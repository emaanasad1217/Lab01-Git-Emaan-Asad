.text

.globl main

main:
    addi sp, x0, 500
    addi x10, x0, 5
    jal x1, ntri
    li x10, 1              # print integer syscall
    ecall
    beq x0, x0, Exit
    
    ntri:
        addi sp, sp, -8
        sw x1, 4(sp)
        sw x10, 0(sp)
        addi x5, x10, -1
        bgt x5, x0 , L1 

        addi x10, x0 , 1 # return 1
        addi sp , sp , 8 # pop stack
        jalr x0 , 0(x1) 
    L1:
        addi x10 , x10 , -1 # argument = n - 1
        jal x1 , ntri # recursive call

        addi x6 , x10 , 0 # save result of ntri(n-1)
        lw x10 , 0(sp) # restore original n
        lw x1 , 4(sp) # restore return address
        addi sp , sp , 8 # pop stack

        add x10 , x10 , x6 # n + ntri(n-1)
        mv  x11, x10
        jalr x0 , 0(x1) 

    Exit:
        end:
            j end