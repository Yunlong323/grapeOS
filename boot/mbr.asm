org 0x7c00
;empty MBR
times 510-($-$$) db 0
db 0x55,0xaa