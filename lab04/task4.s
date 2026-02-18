.text
.globl main

main:

    li x21, 5      #n = 5       
   

    jal x1, sum_squares
   
    
    li x10, 1    #print integer 1       
    ecall


    j end


sum_squares:
    addi sp, sp, -16    
    sw x1, 12(sp)       
    sw x8, 8(sp)        
    sw x9, 4(sp)        
    sw x18, 0(sp)        

    mv x9, x21     #n      
    li x8, 0       #sum     
    li x18, 1      #i     

sum_loop:
    bgt x18, x9, sum_exit 

    mv x10, x18           
    jal x1, square      

    add x8, x8, x10      
    addi x18, x18, 1      
    beq x0, x0, sum_loop

sum_exit:
    mv x11, x8          

    lw x1, 12(sp)       
    lw x8, 8(sp)
    lw x9, 4(sp)
    lw x18, 0(sp)
    addi sp, sp, 16     
    
    jalr x0, 0(x1)      

square:
    mul x10, x10, x10      
    jalr x0, 0(x1)      
end:
    j end
