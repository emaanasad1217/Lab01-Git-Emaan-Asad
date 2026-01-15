.text
.globl main

main:
    li x10, 0x78786464
    li x11, 0xA8A81919 
    li x15, 0x100 
    sw x10, 0(x15)
    li x16, 0x1F0
    sw x11, 0(x16)
    lhu x12, 0(x15)
    lh x13, 0(x16)
    lb x14, 0(x16)
end:
    j end


