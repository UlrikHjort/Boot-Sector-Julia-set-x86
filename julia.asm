; *************************************************************************** 
;                    Boot Sector Julia set  
;
;           Copyright (C) 2026 By Ulrik Hørlyk Hjort
;
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:
;
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; *************************************************************************** 	


[BITS 16]
[ORG 0x7C00]

start:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10
    
    ; Set ES to video memory segment
    mov ax, 0xA000
    mov es, ax

    ; Julia set constant: c = -0.7 + 0.27i (classic interesting value)
    ; In fixed point 8.8: -0.7 * 256 = -179, 0.27 * 256 = 69
    mov word [c_real], -179
    mov word [c_imag], 69
    
    xor di, di        ; DI = screen offset
    mov word [py], 0  ; Start at y=0
    
y_loop:
    mov word [px], 0  ; Start at x=0
    
x_loop:
    ; Map pixel to complex plane (start point z0)
    ; z0_real = (px - 160) * 2
    mov ax, [px]
    sub ax, 160
    shl ax, 1
    mov si, ax        ; SI = z_real (x)
    
    ; z0_imag = (py - 100) * 2
    mov ax, [py]
    sub ax, 100
    shl ax, 1
    mov bp, ax        ; BP = z_imag (y)
    
    mov cl, 100        ; iteration counter 
    
iter_loop:
    ; x_squared = (x * x) / 256
    mov ax, si
    imul si
    mov bx, ax
    mov ax, dx
    shl ax, 8
    mov al, bh
    mov [x_sq], ax    ; Store x*x in memory instead of stack
    
    ; y_squared = (y * y) / 256
    mov ax, bp
    imul bp
    mov bx, ax
    mov ax, dx
    shl ax, 8
    mov al, bh
    mov [y_sq], ax
    
    ; Check if x*x + y*x > 1024 (represents 4.0)
    mov ax, [x_sq]
    add ax, [y_sq]
    cmp ax, 1024
    ja done
    
    ; new_y = (2 * x * y) / 256 + c_imag
    mov ax, si
    imul bp
    mov bx, ax
    mov ax, dx
    shl ax, 8
    mov al, bh
    shl ax, 1         ; * 2
    add ax, [c_imag]
    mov bp, ax        ; y = new_y
    
    ; new_x = x*x - y*y + c_real
    mov ax, [x_sq]
    sub ax, [y_sq]
    add ax, [c_real]
    mov si, ax        ; x = new_x
    
    dec cl
    jnz iter_loop
    
done:
    ; Color based on iteration count
    mov al, cl
    shl al, 2         ; * 4 for brighter colors
    stosb
    
    inc word [px]
    cmp word [px], 320
    jb x_loop
    
    inc word [py]
    cmp word [py], 200
    jb y_loop
    
forever:
	jmp forever

px: dw 0
py: dw 0
c_real: dw 0
c_imag: dw 0
x_sq: dw 0
y_sq: dw 0

times 510-($-$$) db 0
dw 0xAA55
