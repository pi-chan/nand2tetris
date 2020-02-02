// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed.
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.

   @8192
   D=A
   @size
   M=D
   @R0 // 以前のキー状態
   M=0
   @R1 // 今のキー状態
   M=1
(LOOP)
   @KBD
   D=M
   @KEY
   D;JNE
   @R1
   M=0
   @CHECK
   0;JMP
(KEY)
   @R1
   M=1
(CHECK)
   @R0
   D=M
   @R1
   D=D-M
   @END
   D;JEQ // 0ならキーが変化していない
   @R1
   D=M
   @WHITE
   D;JEQ
   @i
   M=0
(INNER_BLACK_BEGIN)
   @i
   D=M
   @size
   D=D-M
   @INNER_BLACK_END
   D;JGT
   @i
   D=M
   @SCREEN
   A=A+D
   M=-1
   @i
   M=M+1
   @INNER_BLACK_BEGIN
   0;JMP
(INNER_BLACK_END)
   @END
   0;JMP
(WHITE)
   @i
   M=0
(INNER_WHITE_BEGIN)
   @i
   D=M
   @size
   D=D-M
   @INNER_WHITE_END
   D;JGT
   @i
   D=M
   @SCREEN
   A=A+D
   M=0
   @i
   M=M+1
   @INNER_WHITE_BEGIN
   0;JMP
(INNER_WHITE_END)
   @END
   0;JMP
(END)
   @R1
   D=M
   @R0
   M=D
   @LOOP
   0;JMP
