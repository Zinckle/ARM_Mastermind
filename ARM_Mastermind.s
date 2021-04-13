.data
//storing locations
    .balign 4
    scanned:    .asciz "                                      "
    .balign 4
    riddlercode: .skip 5
    .balign 4
    playercode: .skip 5
    .balign 4
    checkcode: .skip 5
    .balign 4
    time:	.space  8
// dialog text-----------------------------------------------------------------------------------
    .balign 4
    ridtext: .asciz "\nPlease enter the Riddler Code: \n"
    .balign 4
    playtext: .asciz "\nPlease enter your guess: \n"
    .balign 4
    turnsleft: .asciz "\nTurns left: "
    .balign 4
    returncode: .asciz "The Code Returned is: "
    .balign 4
    newline: .asciz "\n"
    .balign 4
    clear: .asciz "\33[2J"
    .balign 4
    invalidcode: .asciz "\nEnter four numbers from 1-8:\n "
    .balign 4
    invalidchoice: .asciz "\nPlease only enter 1 or 2\n "
    .balign 4
    boardout: .asciz "|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|     \n|_|_|_|_|    \n"
    .balign 4
    selectmode: .asciz "Please Select Your Game Mode:\nEnter 1 For Player VS Computer\nEnter 2 For 2 Player VS Player\n"
    .balign 4
    master: .asciz "\n   _____                     __                            .__             .___\n  /     \\  _____     _______/  |_   ____  _______   _____  |__|  ____    __| _/\n /  \\ /  \\ \\__  \\   /  ___/\\   __\\_/ __ \\ \\_  __ \\ /     \\ |  | /    \\  / __ | \n/    Y    \\ / __ \\_ \\___ \\  |  |  \\  ___/  |  | \\/|  Y Y  \\|  ||   |  \\/ /_/ | \n\\____|__  /(____  //____  > |__|   \\___  > |__|   |__|_|  /|__||___|  /\\____ | \n        \\/      \\/      \\/             \\/               \\/          \\/      \\/"
// inital text-----------------------------------------------------------------------------------
    .balign 4
    intro0: .asciz "\nWelcome to Mastermind, There are 4 simple rules.\n1. A string of numbers ranging from 1 to 8 \nwill be imputed as the Riddler code from the computer or player 2\nThis will be the code that the user will be trying to guess.\n2. The user will then be prompted to guess the code using the\nsame style of format\n3. You will then recieve a code of numbers 2, 1, or 0. \n   0  =  If one of the inputs is wrong it will return a 0 for that input\n   1  =  If one of the inputs is correct, then the game will return a\n1 to indicate that the input exists in the Riddler code but it\nis currently in the wrong position\n   2  =  If one of the inputs is the correct input and in the\ncorrect position. (keep this number in your input string!) \n4. You will be prompted to guess again until either the input string\nis the same as the Riddle code or the limit of 10 turns has been reached.\nGood Luck!  \n"
//win or loose text--------------------
    .balign 4
    wintext: .asciz "\nCongratulations You Won!\nThe Secret Code was: "
    .balign 4
    losstext: .asciz "\nOh No! You Lost! \nThe Secret Code was: "


.text
//----------------------------------------------------------------------------------------------------------------------------------------------
scan_in:
push {lr}
// standard scan based on his echo
    mov r0, #0
    ldr r1, =scanned
    mov r2, #30 // max char
    mov r7, #3
    svc 0
    mov R4,R0 // actual char read
pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
print:
push {lr}
// set R8 to be what you want to print
    mov r9, #-1

strlen:
// finds the length of the string you are about to print
    add r9, r9, #1
    ldrb r2, [r8, r9]
    cmp r2, #0
    bne strlen

//this part does the actual printing
    mov r0, #1
    mov r1, r8
    mov r2, r9
    mov r7, #4
    svc 0
pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
store:
push {lr}
// set R8 to be memory adress of where you want the code stored too
    ldr r1, =scanned

    add r2, r1, #0
    add r3, r1, #1
    add r4, r1, #2
    add r5, r1, #3
    mov r6, #0

    ldr r2, [r2]
    ldr r3, [r3]
    ldr r4, [r4]
    ldr r5, [r5]

    str r2, [r8, #0]
    str r3, [r8, #1]
    str r4, [r8, #2]
    str r5, [r8, #3]
    str r6, [r8, #4]

pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
checkacc:
push {lr}
// this funtion checks the users guess against the riddeler code and outputs a corisponding code bassed on how rght they are
// this portion initalizes some values we will need later and sets the base values of the check code to be null
    ldr r0, =riddlercode
    ldr r1, =playercode
    mov r2, #0
    mov r3, #0
    ldr r4, =checkcode
    mov r7, #48
    str r7, [r4]
    str r7, [r4, #1]
    str r7, [r4, #2]
    str r7, [r4, #3]
    str r2, [r4, #4]
loopcheck1:
// this is the first loop that check if all of the players guesses have been checked

    cmp r2, #4
    beq end_check
    mov r3, #0

loopcheck2:
// this loop is nested in the other loop to check each guess against all 4 of
// the riddler guesses then set the section of the code you are at to be the right value

    cmp r3, #4
    addeq r2, r2, #1
    beq loopcheck1
    ldrb r5, [r1, r2]
    ldrb r6, [r0, r3]

    cmp r5, r6
    addne r3, r3, #1
    bne loopcheck2
    moveq r8, #49

    cmpeq r2, r3
    moveq r8, #50

    strb r8, [r4, r2]
    addeq r2, r2, #1
    beq loopcheck1

    add r3, r3, #1
    b loopcheck2

end_check:
pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
sort:
push {lr}

ldr r1, =checkcode
mov r0, #-1
sort_loop:
    add r0, r0, #1
    cmp r0, #3
    beq end_sort


    ldrb r2, [r1, r0]
    add r0, r0, #1
    ldrb r3, [r1, r0]

    cmp r3, r2
    bgt greater
    add r0, r0, #-1
    b sort_loop


greater:
    strb r2, [r1, r0]
    sub r0, r0, #1
    strb r3, [r1, r0]
    mov r0, #-1
    b sort_loop

end_sort:
pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
checkifdone:
push {lr}
    ldr r8, =turnsleft
    bl print
    ldr r3, =scanned //scanned value is not used just the memory adress temporarily
    add r4, r11, #48
    str r4, [r3]
    mov r8, r3
    bl print
    ldr r8, =newline
    bl print
    ldr r1, =checkcode
    ldr r1, [r1, #3]
    mov r2, #50
    cmp r1, r2
    moveq r11, #0
    //ldr r8, =returncode
    //bl  print
    //ldr r8, =checkcode
    //bl print

pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
play2players:
push {lr}
    ldr r8, =master
    bl print
// print the rules and info off the bat
    ldr r8, =intro0
    bl print
// prompt the riddler to input their code
    ldr r8, =ridtext
    bl print
// scan and store the riddler code
    bl scan_in
    ldr r8, =riddlercode
    bl store
pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
play1player:
push {lr}
        mov r1, #5      // copies #5 into r1
        mov r2, #6      // copies #6 into r2
        ldr r8, =riddlercode
        mov r6,#3      // specifies the number of random numbers
  loop:         // defines the beginning of the loop
        bl rand_start       // branch with link to the label rand_start
        mov r1, r0      // copies r0 into r1
        strb r0, [r8, r6]       // loads the memory address of int_pattern into r0
//        bl printf       // uses the built in printf function with the random value

        subs r6, r6,#1      // subtracts 1 from r6 while updates data register (flag s)
        bpl loop        // branch loop if positive or 0

        pop {lr}
        bx      lr              @ return        // ends code and closes
//Part 2--------------------------------------------------------
.equ	MAX, 57 // random number from 0 to MAX
.equ    MIN, 49// min

rand_start:
      push {lr}
     MOV 	r7, #78         // syscall 78 returns time_t
     LDR	r0,	=time	//store the time
     MOV 	r1, #0         // discard time zone
     SWI	#0
     LDR	r4, =time	// address of the first byte of time
     LDRB	r0, [r4, #4] 	// take first part of the time

      MOV	r2, r0    // copy the portion we want to work with
divisionloop:
    CMP r2, #MIN
    ADDLT r2, r2, #MIN
    CMP	r2, # MAX
    SUBGE	r2, r2, # MAX
    BGE	divisionloop

    MOV	r0, r2
      pop {lr}
      bx lr

pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
theboard:
push {lr}
ldr r0, =boardout
ldr r3, =playercode
ldr r1, =checkcode

add r12, r12, #1
ldrb r4, [r3]
strb r4, [r0, r12]

add r12, r12, #2
ldrb r4, [r3, #1]
strb r4, [r0, r12]

add r12, r12, #2
ldrb r4, [r3, #2]
strb r4, [r0, r12]

add r12, r12, #2
ldrb r4, [r3, #3]
strb r4, [r0, r12]

add r12, r12, #3

ldrb r2, [r1]
strb r2, [r0, r12]
add r12, r12, #1

ldrb r2, [r1, #1]
strb r2, [r0, r12]
add r12, r12, #1

ldrb r2, [r1, #2]
strb r2, [r0, r12]
add r12, r12, #1

ldrb r2, [r1, #3]
strb r2, [r0, r12]
add r12, r12, #2

ldr r8, =boardout
bl print

pop {lr}
bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
Numcheck:
Push {lr}

startcheck:
Ldr r6, =scanned
Mov r9, #-1
Loopnumcheck:
Add r9, r9, #1
Ldrb r2, [r6, r9]
Cmp r2, #57
Ldrge r8, =invalidcode
bge Checkfailed
Cmp r2, #48
Ldrle r8, =invalidcode
ble Checkfailed
Cmp r9, #3
Bne Loopnumcheck
Beq endcheck

Checkfailed:
Bl print
Bl scan_in
B startcheck

endcheck:
Pop {lr}
Bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
choicecheck:
Push {lr}

choicestartcheck:
Ldr r6, =scanned

Ldrb r2, [r6, #0]
Cmp r2, #51
Ldrge r8, =invalidchoice
bge choicecheckfailed
Cmp r2, #48
Ldrle r8, =invalidchoice
ble choicecheckfailed
B choiceendcheck

choicecheckfailed:
Bl print
Bl scan_in
B choicestartcheck

choiceendcheck:
Pop {lr}
Bx lr
//----------------------------------------------------------------------------------------------------------------------------------------------
.global main
main:
push {lr}
//------select mode
    mov r12, #0
    ldr r8, =master
    bl print
    ldr r8, =newline
    bl print
    ldr r8, =selectmode
    bl print

    bl scan_in
    bl choicecheck
    ldr r11, =scanned
    ldrb r11, [r11]
    cmp r11, #49
    blgt play2players
    cmp r11, #49
    bleq play1player

    ldr r8, =clear
    bl print
    ldr r8, =master
    bl print
    ldr r8, =intro0
    bl print
//ldr r8, =riddlercode
//bl print
//loop head-------------------------
    mov r11, #10
    l1:
    ADD r11, r11, #-1
//-----------------------------------

// output a prompt for the player to give their guess
    ldr r8, =playtext
    bl print


// get the input from the player and store it to the adress
    bl scan_in
    bl Numcheck
    ldr r8, =playercode
    bl store
    ldr r8, =clear
    bl print
    ldr r8, =master
    bl print
    ldr r8, =newline
    bl print

// check how accurate the players guess was the sort it and then check if they got it right
    bl checkacc
    bl sort
    bl theboard
    bl checkifdone

//loop tail------------------------
    CMP R11, #0
    bne l1
//---------------------------------

    ldr r1, =checkcode
    ldr r1, [r1, #3]
    mov r2, #50
    cmp r1, r2
    ldreq r8, =wintext
    ldrne r8, =losstext
    bl print
    ldr r8, =riddlercode
    bl print
    ldr r8, =newline
    bl print
pop {lr}
bx lr

