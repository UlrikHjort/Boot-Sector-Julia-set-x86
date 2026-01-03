# Boot Sector Julia Set

This is a **16-bit x86 boot sector program** that renders a **Julia set fractal** directly to the screen using BIOS video mode **13h (320×200, 256 colors)**.  
It runs in real mode with **no operating system**, **no filesystem**, and **no floating-point math**.

---

## Features

- Pure **boot sector** code (512 bytes, ends with `0xAA55`)
- Runs in **real mode** on legacy x86 BIOS systems
- Uses **VGA Mode 13h** (`0xA000` framebuffer)
- Implements **Julia set iteration**:  
   Zn+1 = (Zn*Zn) + c
- **Fixed-point 8.8 arithmetic** (no FPU required)
- Constant:  
  `c = -0.7 + 0.27i`
- Direct pixel output for maximum simplicity

---

## How It Works

1. BIOS loads the sector at `0x7C00`
2. Video mode is set to 320×200×256
3. Each pixel is mapped to a complex number
4. The Julia iteration runs up to 100 steps
5. Pixels escape when `|z| * |z| > 4`
6. Color is derived from the remaining iteration count

---

## Building & Running

Assemble with NASM and run with qemu:

```bash
nasm -f bin julia.asm -o julia.bin

qemu-system-i386 julia.bin