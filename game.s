.data
character:  .byte 0,0
box:        .byte 0,0
target:     .byte 0,0
winPrompt:  .string "Congratulations, you've solved the puzzle\n"
losePrompt: .string "You Lost!\n"
invalidPrompt: .string "Invalid Move!\n"
characterCoord:.string "<- character is at\n"
boxCoord:      .string "<- box is at\n"
targetCoord:   .string "<- target is at\n"
playerPrompt:  .string "Player "
detailPrompt:  .string " has won the game by "
movesPrompt:   .string " move(s)\n"
winnerPrompt:  .string "the winner goes to..(drumrolls)..Player Number "
askUserPrompt: .string "Please enter how many player(s) are playing: "
numberError:   .string "You've entered a negative/zero number, please enter a positive number: "
withPrompt:    .string " with "
losePrompt2:   .string " failed to complete the game\n"
charactercopy: .byte 0,0
boxcopy:       .byte 0,0
targetcopy:    .byte 0,0
turnPrompt:    .string "'s turn\n"
player1Start:  .string "Player 1's turn\n"
everyoneLostPrompt: .string "Unfortunately, no one has won the game. Nice try."
doubleEnterPrompt:  .string "\n\nOverall..\n"
restartPrompt:  .string "The round has been restarted\n"
endGamePrompt:  .string "The game has been ended. Thank you for playing."

.globl main
.text

main:
    # TODO: Before we deal with the LEDs, generate random locations for
    # the character, box, and target. static locations have been provided
    # for the (x,y) coordinates for each of these elements within the 8x8
    # gri
    init:
       # register prep
       
       askUser:
        li a7, 4
        la, a0, askUserPrompt
        ecall 
        askforNewNumber:
        call readInt
        checkNumber:
        bge x0, a0, negativeAnswer
        j normalNumber
        negativeAnswer:
            li a7, 4
            la a0, numberError
            ecall
            j askforNewNumber
        normalNumber:    
        mv s11, a0
        li s10, 0
        
        #li t0, -4
        #mul t0, t0, s11
        #add sp, sp, t0
        
        loopMultiplayer:
            
        # sendResult of Last Player
        j reset
        afterReset:
            beq s10, s11, announceWinner
            bne s10, x0, sendResult
            li s9, 0
            afterSendResult:
            bne s10, x0, transferCopies
            li a7, 4
            la, a0, player1Start
            ecall
            addi s10, s10, 1
            li s9, 0
         
            
        
       li s0 LED_MATRIX_0_BASE
       li s1 LED_MATRIX_0_HEIGHT
       li s2 LED_MATRIX_0_WIDTH
       li a7, 30
       ecall
       mv s8, a0
       li a0 0xA9A9A9            # grey, color for walls
       
       addi, s3, s1, -1
       addi s4, s2, -1
       # creating temporaries for WallsMaking
       li a1, 0
       li a2, 0
       startWallsMaking:
           jal setLED
           addi a1, a1, 1
           bne a1, s2, startWallsMaking
       
       li a2, 1   # a2 to check the height
       loopWallsMaking:
           li a1, 0
           jal setLED
           mv a1, s4
           jal setLED
           addi a2, a2, 1
           bne a2, s3, loopWallsMaking
        
        mv a2, s3
        li a1, 0
        
        
        finishWallsMaking:
            jal setLED
            addi a1, a1, 1
            bne a1, s2, finishWallsMaking
        
        # we wont be needing all the temporaries created 
        # above at this point since walls have been created
        
        la t0, character  # load the address of "character" to t0
        createCharacter:
            mv a0, s4                    # load the width of matrix in a0
            jal rand                     # call rand to generate random from 0-a0
            beq a0, x0, createCharacter
            la t0, character           # load the address of "character" to t0
            sb a0, 0(t0)               # store the generated width to 0(t0)
         
            mv a0, s3                  # load the height of matrix in a0
            jal rand
            beq a0, x0, createCharacter 
            la t0, character           # load the address of "character" to t0                    
            sb a0, 1(t0)               # store the generated height to 1(t0)
        
        lb t2, 0(t0)                   # temporary to store character x-coord
        lb t3, 1(t0)               # store character y-coord
        createBox:
            generateRandBoxWidth:
                mv a0, s4
                jal rand
                beq a0, x0, generateRandBoxWidth
                la t0, box
                sb a0, 0(t0)
            generateRandBoxHeight:
                mv a0, s3
                jal rand
                beq a0, x0, generateRandBoxHeight
                la t0, box
                sb a0, 1(t0)
        
        
        lb t4, 0(t0)
        lb t5, 1(t0)
        beq t4, s4, checkCornerBoxY
        j initialOverlapBC
        checkCornerBoxY:
            beq t5, s3, createBox
        initialOverlapBC:
        beq t4, t2, checkOverlapBC
        j createTarget
        checkOverlapBC:
            beq t5, t3, createBox
        
        createTarget:
            la t0, target
            generateRandTargetWidth:
                mv a0, s4
                jal rand
                beq a0, x0, generateRandTargetWidth
                la t0, target
                sb a0, 0(t0)
            generateRandTargetHeight:
                mv a0, s3
                jal rand
                beq a0, x0, generateRandTargetHeight
                la t0, target
                sb a0, 1(t0)
        
        lb t1, 0(t0)
        lb t6, 1(t0)
        beq t1, t2, checkOverlapTC
        j initialCheckOverlapTB
        checkOverlapTC:
            beq t6, t3, createTarget
        initialCheckOverlapTB:
            beq t1, t4, checkOverlapTB
            j checkSolvability
        checkOverlapTB:
            beq t6, t5, createTarget
        
        checkSolvability:
            li t0, 1
            beq t4, t0, checkSolvableTop
            j solvableCaseLeft
            checkSolvableTop: 
                beq t1, t0, createLEDforAll
                j createBox
            solvableCaseLeft:
                beq t5, t0, checkSolvableLeft
                j solvableCaseBottom
            checkSolvableLeft:
                beq t6, t0, createLEDforAll
                j createBox
            solvableCaseBottom:
                addi t0, s3, -1
                beq t4, t0, checkSolvableBottom
                j solvableCaseRight
            checkSolvableBottom:
                beq t1, t0, createLEDforAll
                j createBox
            solvableCaseRight:
                addi t0, s4, -1
                beq t5, t0, checkSolvableRight
                j createLEDforAll
            checkSolvableRight:
                beq t6, t0, createLEDforAll
                j createBox
        
        createLEDforAll:
            li a0 0xF6FA70
            la t2, character
            lb a1, 0(t2)
            lb a2, 1(t2)
            jal setLED    # set the color for character to yellow
            li a0 0xFF0060
            la t4, box
            lb a1, 0(t4)
            lb a2, 1(t4)
            jal setLED    # set the color of box to red
            li a0 0x0079FF
            la t1, target
            lb a1, 0(t1)
            lb a2, 1(t1)
            jal setLED    # set the color for target to blue
            
            # at this point, t1 is something else from setLED
            
    # generate copies of character, box, and target
    la t0, character
    lb t1, 1(t0)
    lb t0, 0(t0)
    la t2, charactercopy
    sb t0, 0(t2)
    sb t1, 1(t2)
    la t0, box
    lb t1, 1(t0)
    lb t0, 0(t0)
    la t2, boxcopy
    sb t0, 0(t2)
    sb t1, 1(t2)
    la t0, target
    lb t1, 1(t0)
    lb t0, 0(t0)
    la t2, targetcopy
    sb t0, 0(t2)
    sb t1, 1(t2)
    
    
    # at this point, you can choose any registers you want to use

    la t0, character
    la t2, box
    la t4, target
    lb t1, 1(t0)
    lb t0, 0(t0)
    lb t3, 1(t2)
    lb t2, 0(t2)
    lb t5, 1(t4)
    lb t4, 0(t4)
    
    
    
    play:
        # t0-t5 are the 0 and 1 values of 
        # character, box, and target respectively
        la t0, character
        la t2, box
        la t4, target
        lb t1, 1(t0)
        lb t0, 0(t0)
        lb t3, 1(t2)
        lb t2, 0(t2)
        lb t5, 1(t4)
        lb t4, 0(t4)
        bne t0, t4, setBlue
        bne t1, t5, setBlue
        setOrange:
            li a0 0xFFA500
            la t1, target
            lb a1, 0(t1)
            lb a2, 1(t1)
            jal setLED
            j realPlay
        setBlue:
            li a0 0x0079FF
            la t1, target
            lb a1, 0(t1)
            lb a2, 1(t1)
            jal setLED
        realPlay:
        jal checkSolvability2
        jal pollDpad
        addi s9, s9, 1
        la t0, character
        la t2, box
        la t4, target
        lb t1, 1(t0)
        lb t0, 0(t0)
        lb t3, 1(t2)
        lb t2, 0(t2)
        lb t5, 1(t4)
        lb t4, 0(t4)
        jal validityCheck
        afterValidity:
        mv t6, a0
        li a0, 0x000000
        mv a1, t0
        mv a2, t1
        jal setLED
        mv a0, t6
        li t6, 0
        
        beq a0, t6, zeroValue
        addi t6, t6, 1
        beq a0, t6, oneValue
        addi t6, t6, 1
        beq a0, t6, twoValue
        addi t6, t6, 1
        beq a0, t6, threeValue
        zeroValue:
            la a0, character
            lb t1, 1(a0)
            lb t0, 0(a0)
            addi t1, t1, -1
            sb t1, 1(a0)
            li a0, 0xF6FA70
            mv a1, t0
            mv a2, t1
            jal setLED
            la t0, character
            la t2, box
            la t4, target
            lb t1, 1(t0)
            lb t0, 0(t0)
            lb t3, 1(t2)
            lb t2, 0(t2)
            lb t5, 1(t4)
            lb t4, 0(t4)
    
            beq t0, t2, preOverlapTop
            j noOverlapTop
            preOverlapTop:
            beq t1, t3, overlapTop
            noOverlapTop:
            j play
        oneValue:
            la a0, character
            
            lb t1, 1(a0)
            lb t0, 0(a0)
            addi t1, t1, 1
            sb t1, 1(a0)
            li a0, 0xF6FA70
            mv a1, t0
            mv a2, t1
            jal setLED
            la t0, character
            la t2, box
            la t4, target
            lb t1, 1(t0)
            lb t0, 0(t0)
            lb t3, 1(t2)
            lb t2, 0(t2)
            lb t5, 1(t4)
            lb t4, 0(t4)
 
            beq t0, t2, preOverlapBottom
            j noOverlapBottom
            preOverlapBottom:
            beq t1, t3, overlapBottom
            noOverlapBottom:
            j play
        twoValue:
            la a0, character
            lb t1, 1(a0)
            lb t0, 0(a0)
            addi t0, t0, -1
            sb t0, 0(a0)
            li a0, 0xF6FA70
            mv a1, t0
            mv a2, t1
            jal setLED
            la t0, character
            la t2, box
            la t4, target
            lb t1, 1(t0)
            lb t0, 0(t0)
            lb t3, 1(t2)
            lb t2, 0(t2)
            lb t5, 1(t4)
            lb t4, 0(t4)
    
            beq t1, t3, preOverlapLeft
            j play
            preOverlapLeft:
            beq t0, t2, overlapLeft
            noOverlapLeft:
            j play
        threeValue:   
            la a0, character
            lb t1, 1(a0)
            lb t0, 0(a0)
            addi t0, t0, 1
            sb t0, 0(a0)
            li a0, 0xF6FA70
            mv a1, t0
            mv a2, t1
            jal setLED
            la t0, character
            la t2, box
            la t4, target
            lb t1, 1(t0)
            lb t0, 0(t0)
            lb t3, 1(t2)
            lb t2, 0(t2)
            lb t5, 1(t4)
            lb t4, 0(t4)
    
            beq t1, t3, preOverlapRight
            j play
            preOverlapRight:
            beq t0, t2, overlapRight
            j play
       
    # character = yellow
    # box = red
    # target = blue
    # if box hits target = field is green
        
    
    
    
    
    # There is a rand function, but note that it isn't very good! You 
    # should at least make sure that none of the items are on top of each
    # other.
   
    # TODO: Now, light up the playing field. Add walls around the edges
    # and light up the character, box, and target with the colors you have
    # chosen. (Yes, you choose, and you should document your choice.)
    # Hint: the LEDs are an array, so you should be able to calculate 
    # offsets from the (0, 0) LED.

 
        
        
    

    # TODO: Enter a loop and wait for user input. Whenever user input is
    # received, update the grid with the new location of the player <and
    # if applicable, box and target>. You will also need to restart the
    # game if the user requests it and indicate when the box is located
    # in the same position as the target.

    # TODO: That's the base game! Now, pick a pair of enhancements and
    # consider how to implement them.

playerLose:
    li a7, 4
    la a0, losePrompt
    ecall
    li t0, 1
    beq t0, s10, afterStandingLoop2
    li t2, 4
    mul t2, t2, s10
    add sp sp t2
    addi sp sp -4
    prepreStandingLoop2:
    blt t0, s10, preStandingLoop2
    j afterStandingLoop2
    preStandingLoop2:
        mv a1, t0
        jal standingLoop
        addi t0, t0, 1
        j prepreStandingLoop2
    afterStandingLoop2:
    li a7, 4
    la a0, playerPrompt
    ecall
    li a7, 1
    mv a0, s10
    ecall
    li a7, 4
    la a0, losePrompt2
    ecall
    li s9, 0x7FFFFFFF
    sw s9, 0(sp)
    addi sp, sp, -4
    j loopMultiplayer

standingLoop:
    li t3, 0x7FFFFFFF
    lw t4, 0(sp)
    addi sp, sp -4
    beq t3, t4, loseInStandingLoop
    li a7, 4
    la a0, playerPrompt
    ecall
    li a7, 1
    mv a0, a1
    ecall
    li a7, 4
    la a0, detailPrompt
    ecall
    mv a0, t4
    li a7, 1
    ecall
    li a7, 4
    la a0 movesPrompt
    ecall
    jr ra
    loseInStandingLoop:
        li a7, 4
        la a0, playerPrompt
        ecall
        li a7, 1
        mv a0, a1
        ecall
        li a7, 4
        la a0, losePrompt2
        ecall
    jr ra

win:
    li a7 4
    la a0 winPrompt
    ecall
    la a1, target
    li a7, 1
    li a0 0x00FF00
    lb a2, 1(a1)
    lb a1, 0(a1)
    jal setLED
    li t0, 1
    beq t0, s10, afterStandingLoop
    li t2, 4
    mul t2, t2, s10
    add sp sp t2
    addi sp sp -4
    prepreStandingLoop:
    bne t0, s10, preStandingLoop
    j afterStandingLoop
    preStandingLoop:
        mv a1, t0
        jal standingLoop
        addi t0, t0, 1
        j prepreStandingLoop
        
    afterStandingLoop:
    li a7, 4
    la a0, playerPrompt
    ecall
    li a7, 1
    mv a0, s10
    ecall
    li a7, 4
    la a0, detailPrompt
    ecall
    li a7, 1
    mv a0, s9
    ecall
    li a7, 4
    la a0 movesPrompt
    ecall
    sw s9, 0(sp)
    addi sp, sp, -4
    li s9, 0
    j loopMultiplayer
exit:
    li t5, 0x7FFFFFFF
    beq t5, t3, everyoneLoses
    li a7, 4
    la a0, winnerPrompt
    ecall
    li a7, 1
    mv a0, t4
    ecall
    li a7, 4
    la a0, withPrompt
    ecall
    li a7, 1
    mv a0, t3
    ecall
    li a7, 4
    la a0, movesPrompt
    ecall
    li t6, 4
    mul t6, t6, s11
    add, sp, sp, t6
    li a7, 10
    ecall
    everyoneLoses:
        li a7, 4
        la a0, everyoneLostPrompt
        ecall
        li t6, 4
        mul t6, t6, s11
        add, sp, sp, t6
        li a7, 10
        ecall
        
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit

overlapTop:
    la a1, box
    lb t3, 1(a1)
    lb t2, 0(a1)
    addi t3, t3, -1
    sb t3, 1(a1)
    li a0 0xFF0060
    mv a1, t2
    mv a2, t3
    jal setLED
    j winCheck

overlapBottom:
    la a1, box
    lb t3, 1(a1)
    lb t2, 0(a1)
    addi t3, t3, 1
    sb t3, 1(a1)
    li a0 0xFF0060
    mv a1, t2
    mv a2, t3
    jal setLED
    j winCheck

overlapLeft:
    la a1, box
    lb t3, 1(a1)
    lb t2, 0(a1)
    addi t2, t2, -1
    sb t2, 0(a1)
    li a0 0xFF0060
    mv a1, t2
    mv a2, t3
    jal setLED
    j winCheck

overlapRight:
    la a1, box
    lb t3, 1(a1)
    lb t2, 0(a1)
    addi t2, t2, 1
    sb t2, 0(a1)
    li a0 0xFF0060
    mv a1, t2
    mv a2, t3
    jal setLED
    j winCheck

winCheck:
    la a1, box
    la a2, target
    lb t2, 0(a1)
    lb t3, 1(a1)
    lb t4, 0(a2)
    lb t5, 1(a2)
    bne t2, t4, play
    bne t3, t5, play
    j win
    
validityCheck:
    li t6, 0
    beq a0, zero, checkZero
    li t6, 1
    beq a0, t6, checkOne
    li t6, 2
    beq a0, t6, checkTwo
    li t6, 3
    beq a0, t6, checkThree
 
    checkZero:
        la t0, character
        la t2, box
        la t4, target
        lb t1, 1(t0)
        lb t0, 0(t0)
        lb t3, 1(t2)
        lb t2, 0(t2)
        lb t5, 1(t4)
        lb t4, 0(t4)
        li t6, 1 # check if character is at the top
        beq t1, t6, checkRestart
        j notRestart
        checkRestart:
        bne t0, t6, invalidMove
        j restart
        notRestart:
        beq t3, t6, boxAtTop
        j afterValidity
    checkOne:
        la t0, character
        la t2, box
        la t4, target
        lb t1, 1(t0)
        lb t0, 0(t0)
        lb t3, 1(t2)
        lb t2, 0(t2)
        lb t5, 1(t4)
        lb t4, 0(t4)
        li t6 LED_MATRIX_0_HEIGHT
        addi t6, t6, -2    # check if character is at the bottom
        beq t1, t6, invalidMove
        beq t3, t6, boxAtBottom
        j afterValidity
    checkTwo:
        la t0, character
        la t2, box
        la t4, target
        lb t1, 1(t0)
        lb t0, 0(t0)
        lb t3, 1(t2)
        lb t2, 0(t2)
        lb t5, 1(t4)
        lb t4, 0(t4)
        li t6, 1 # check if character is at the left
        beq t0, t6, checkEndGame
        j notEndGame
        checkEndGame:
            beq t1, t6, endGame
            j invalidMove
        notEndGame:
        beq t2, t6, boxAtLeft
        j afterValidity
    checkThree:
        la t0, character
        la t2, box
        la t4, target
        lb t1, 1(t0)
        lb t0, 0(t0)
        lb t3, 1(t2)
        lb t2, 0(t2)
        lb t5, 1(t4)
        lb t4, 0(t4)
        li t6 LED_MATRIX_0_WIDTH
        addi t6, t6, -2    # check if character is at the right
        beq t0, t6, invalidMove
        beq t2, t6, boxAtRight
        j afterValidity
    
invalidMove:
    mv t6, a0
    li a7, 4
    la a0, invalidPrompt
    ecall
    mv a0, t6
    j play

boxAtTop:
    li t6, 2
    bne t0, t2, afterValidity
    bne t1, t6, afterValidity
    j invalidMove

boxAtBottom:
    la t6, box
    lb t6, 1(t6)
    addi t6, t6, -1
    bne t0, t2, afterValidity
    bne t1, t6, afterValidity
    j invalidMove
    
boxAtLeft:
    li t6, 2
    bne t1, t3, afterValidity
    bne t0, t6, afterValidity
    j invalidMove
boxAtRight:
    la t6, box
    lb t6, 0(t6)
    addi t6, t6, -1
    bne t1, t3, afterValidity
    bne t0, t6, afterValidity
    j invalidMove


    

    
    
announceWinner:
    li a7, 4
    la a0, doubleEnterPrompt
    ecall
    mv t1, s11
    li t5, 4
    mul t5, t5, t1
    add sp, sp, t5
    li t0, 1    # for the # of players
    li t3, 0x7FFFFFFF    # to return the # of steps
    li t4, 0    # to return the player #
    loopToCheckWinner:
    lw t2, 0(sp)# for the # of steps
    jal sendResultFINAL
    afterFailFINAL:
    blt t2, t3, updateWinner
    j afterUpdateWinner
    updateWinner:
        mv t3, t2
        mv t4, t0
    afterUpdateWinner:
    beq t0, s11, exit
    addi t0, t0, 1
    addi sp, sp, -4
    j loopToCheckWinner
    
sendResultFINAL:
    li t5, 0x7FFFFFFF
    beq t2, t5, failMessageFINAL
    li a7, 4
    la a0, playerPrompt
    ecall
    li a7, 1
    mv a0, t0
    ecall
    li a7, 4
    la a0, detailPrompt
    ecall
    li a7, 1
    mv a0, t2
    ecall
    li a7, 4
    la a0, movesPrompt
    ecall
    j afterFailFINAL
    
failMessageFINAL:
    li a7, 4
    la a0, playerPrompt
    ecall
    li a7, 1
    mv a0, t0
    ecall
    li a7, 4
    la a0, losePrompt2
    ecall
    jr ra

restart:
    li a7 4
    la a0 restartPrompt
    ecall
    addi s10, s10, -1
    jal resetforRestart
    j transferCopies

endGame:
    li a7 4
    la a0 endGamePrompt
    ecall
    li a7 10
    ecall

# Takes in a number in a0, and returns a (sort of) (okay no really) random 
# number from 0 to this number (exclusive)
# source: 
# 1. @ARTICLE{apple-libstdcxx-test,
# author = {Apple Inc.},
# title = {libstdc++ test suite},
# year = {2023},
# url = {https://opensource.apple.com/source/libstdcxx/libstdcxx-10/libstdcxx/gcc/testsuite/gcc.dg/compat/generate-random_r.c}
# }
# 2. @ARTICLE{wikipedia-lcg,
# author = {Wikipedia},
# title = {{Linear congruential generator}},
# year = {2023},
# url = {https://en.wikipedia.org/wiki/Linear_congruential_generator}
# }
# the pseudo-random LCG used below is the glibc LCG

rand:
    li s5, 12345             # a
    li s6, 1103515245                # c
    li s7, 0x7fffffff            # for xn and xn+1 in rand
    mv t0, a0                # mod at the end
    mul s8, s8, s5
    add s8, s8, a6
    remu s8, s8, s7
    remu a0, s8, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE 
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra

readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, negativeAnswer
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret


checkSolvability2:
    j createSolvability3
    afterSolvability3:
    la t0, character
    la t2, box
    la t4, target
    lb t1, 1(t0)
    lb t0, 0(t0)
    lb t3, 1(t2)
    lb t2, 0(t2)
    lb t5, 1(t4)
    lb t4, 0(t4)
    li t6, 1
    beq t3, t6, checkTop2
    beq t2, t6, checkLeft2
    addi t6, s3, -1
    beq t3, t6, checkBottom2
    addi t6, s4, -1
    beq t2, t6, checkRight2
    jr ra
    checkTop2:
        beq t5, t6, backToRa
        j playerLose
    checkLeft2:
        beq t4, t6, backToRa
        j playerLose
    checkBottom2:
        beq t5, t6, backToRa
        j playerLose
    checkRight2:
        beq t4, t6, backToRa
        j playerLose
    backToRa:
        jr ra

createSolvability3:
    la t2, box
    lb t3, 1(t2)
    lb t2, 0(t2)
    li t6, 1
    beq t2, t6, checkTopLeftCorner
    j checkRightifCorner
    checkTopLeftCorner:
        beq t3, t6, playerLose
        j checkBottomLeftCorner
    checkBottomLeftCorner:
        addi t6, s1, -2
        beq t3, t6, playerLose
        j afterSolvability3
    checkRightifCorner:
        addi t6, s2, -2
        beq t2, t6, checkTopRightCorner
        j afterSolvability3
    checkTopRightCorner:
        li t6, 1
        beq t3, t6, playerLose
        j checkBottomRightCorner
    checkBottomRightCorner:
        addi t6, s1, -2
        beq t3, t6, playerLose
        j afterSolvability3
        
reset:        # reset is OK here
    li s1 LED_MATRIX_0_HEIGHT
    li s2 LED_MATRIX_0_WIDTH
    li t3, 1
    addi t4, s1, -1
    addi t5, s2, -1
    checkHeight:
    bne t3, t4, resetHeight
    j afterReset
    resetHeight:
        li t2, 1
        resetWidth:
            li a0, 0x000000
            mv a1, t2
            mv a2, t3
            jal setLED
            addi t2, t2, 1
            bne t2, t5, resetWidth
            addi t3, t3, 1
            j checkHeight

resetforRestart:        # reset is OK here
    li s1 LED_MATRIX_0_HEIGHT
    li s2 LED_MATRIX_0_WIDTH
    li t3, 1
    addi t4, s1, -1
    addi t5, s2, -1
    checkHeight2:
    bne t3, t4, resetHeight2
    j transferCopies
    resetHeight2:
        li t2, 1
        resetWidth2:
            li a0, 0x000000
            mv a1, t2
            mv a2, t3
            jal setLED
            addi t2, t2, 1
            bne t2, t5, resetWidth2
            addi t3, t3, 1
            j checkHeight2
            
sendResult:
    li t0, 0x7FFFFFFF
    beq s9, t0, failMessage
    li a7, 4
    la a0, playerPrompt
    ecall
 
    li a7, 1
    mv a0, s10
    addi a0, a0, 1
    ecall
    li a7, 4
    la a0, turnPrompt
    ecall
    j afterSendResult
    
failMessage:
    j afterSendResult
    
transferCopies:
    la t0, charactercopy
    lb t1, 1(t0)
    lb t0, 0(t0)
    la t2, character
    sb t0, 0(t2)
    sb t1, 1(t2)
    la t0, boxcopy
    lb t1, 1(t0)
    lb t0, 0(t0)
    la t2, box
    sb t0, 0(t2)
    sb t1, 1(t2)
    la t0, targetcopy
    lb t1, 1(t0)
    lb t0, 0(t0)
    la t2, target
    sb t0, 0(t2)
    sb t1, 1(t2)
    addi s10, s10, 1
    li s9, 0
    j createLEDforAll