
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"   
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
token_num:		 .word 0	# initialize token_num to zero
                                        #use word instead of byte to b able to hold the number 2049
.align 0
tokens: 		 .space 411849
                                        # max size * max size  one long array, each element is row*rowlength+ columnt in 2D array 


# You can add your data here!
        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                              # Declare main label to be globally visible.
                                         # Needed for correct operation with MARS
main:
        
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

# reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break } $v0 numbers of characters read, if 0 then EOF
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n ascii code for new line is 10
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
jal tokenizer                    #tokenizer();
j output_tokens                  #output_tokens();


#------------------------------------------------------------------
#Tokenizer function
#-------------------------------------------------------------------
#Registers used:
# $s1=token number
# $t0=token_c_idx
# $t1=c
# $t2=ascii code for comparison
# $t3=c_idx
# $t4=tokens index(big array)
# input1,input2,input3: internal loop that save the token 

tokenizer:
	li $t3,0 		#t3 :c_index initialize to zero
	lb $t1,content($t3) 	#c = content[c_idx];
				# $t1 holds the character
Loop:
	beqz  $t1,end_tok	#if(c == '\0') break
	li $t2,65
	
	blt $t1,$t2,else_if     #check if char is less than 65
	                    	# if less than 65, else
	                    	
alpha:				#if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {
	li $t0,0 		#int token_c_idx = 0
input1:				#input1 ,loop to add to 2D array for alphabetic chars
	
	lw $s1,token_num	#get token_num into $s1
	li $t4,0
	
	li $t2,201
	move $t4,$s1
	mul $t4,$t4,$t2		#mult token_num by 201 (row*row length)
	add $t4,$t4,$t0	        #(row*row length)+column (which is tokens_c_idx)
	sb  $t1 ,tokens($t4)	#tokens[tokens_number][token_c_idx] = c;
		
	
	addi $t0,$t0,1		# token_c_idx += 1;
	addi $t3,$t3,1		#c_idx += 1;
	lb $t1,content($t3)	#c = content[c_idx];
	
	li $t2,65
	bge   $t1,$t2,input1	#while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
	               		#go back to the loop
	               		
	               		#exiting the loop
	lw $s1,token_num	#$s1 has the token number
	li $t4,0		#everytime initialize $t4 to hold the index
	move $t4,$s1
	li $t2,201
	mul $t4,$t4,$t2         #multiply the row by 201		
	add $t4,$t4,$t0	        #(row*row length)+column which is tokens_c_idx $t4 has the index of the array
	sb  $0 ,tokens($t4)	#tokens[tokens_number][token_c_idx] = '\0';
	
	addi $s1,$s1,1	        #tokens_number += 1;
	sw   $s1,token_num	#save the new token number				
	j Loop			#repeat the initial DO loop
	
else_if:			#else if(c == ',' || c == '.' || c == '!' || c == '?') 
	
	li $t2,44		 # ascii code for , is 44
	beq  $t1,$t2,quotation
	li $t2,46		 #ascii code for . is 46
	beq $t1,$t2,quotation
	li $t2,33		 #ascii code for ! is 33
	beq $t1,$t2,quotation
	li $t2,63		 #ascii code for ? is 63
	beq $t1,$t2,quotation
	j else
	
quotation:
	li $t0,0		#int token_c_idx = 0;
	
input2:				#inputing quotation marks in 2D array

	lw $s1,token_num	#get token_num into $s1
	li $t4,0
	move $t4,$s1
	li $t2,201
	mul $t4,$t4,$t2		#mult token_num by 201 (row*row length)
	add $t4,$t4,$t0	        #(row*row length)+column 
	sb  $t1 ,tokens($t4)	#tokens[tokens_number][token_c_idx] = c;
	
	
	addi $t0,$t0,1		# token_c_idx += 1;
	addi $t3,$t3,1		#c_idx += 1;
	lb $t1,content($t3)	#c = content[c_idx];
	  
                                #while(c == ',' || c == '.' || c == '!' || c == '?');
	li $t2,33		# ascii code for , is 33
	beq  $t1,$t2,input2
	li $t2,44		#ascii code for . is 44
	beq $t1,$t2,input2
	li $t2,46		#ascii code for ! is 46
	beq $t1,$t2,input2
	li $t2,63		#ascii code for ? is 63
	beq $t1,$t2,input2					
				# check if the next char is any quotation mark
				#if yes, go back to the input loop	
				#if not, enter the 0 char to mark the end of token
	
	lw $s1,token_num	#$s1 now has the token numer
	li $t4,0
	move $t4,$s1
	li $t2,201
	mul $t4,$t4,$t2	
	add $t4,$t4,$t0      	#(row*row length)+column which is tokens_c_idx
	sb  $0 ,tokens($t4)	#tokens[tokens_number][token_c_idx] = '\0';
	
	addi $s1,$s1,1		#tokens_number += 1;
	sw $s1,token_num
	j Loop			# repeat the initial DO loop
		
	
else:
	li $t2,32		# ascii code for ' ' is 32
	beq  $t1,$t2,space	#else if(c == ' ') 
	j Loop                  #while(1);
	
	
space:	
	li $t0,0		#int token_c_idx = 0;
input3:	

	lw $s1,token_num	#get token_num into $s1
	li $t4,0
	move $t4,$s1
	li $t2,201
	mul $t4,$t4,$t2       	#mult token_num by 201 (row*row length)
	add $t4,$t4,$t0	        #(row*row length)+column 
	sb  $t1 ,tokens($t4)	#tokens[tokens_number][token_c_idx] = c;
	
	addi $t0,$t0,1		# token_c_idx += 1;
	addi $t3,$t3,1		#c_idx += 1;
	lb $t1,content($t3)	#c = content[c_idx];
				
				# check if the next char is space
				#if yes, go back to the input loop
	li $t2,32           	# ascii code for ' ' is 32
	beq $t1,$t2,input3      #while(c == ' ')
	
	lw $s1,token_num	#$s1 now has the token numer
	li $t4,0
	move $t4,$s1
	li $t2,201
	mul  $t4,$t4,$t2 
	add $t4,$t4,$t0	        #(row*row length)+column which is tokens_c_idx
	sb  $0 ,tokens($t4)	#tokens[tokens_number][token_c_idx] = '\0';
	
	addi $s1,$s1,1		#tokens_number += 1;
	sw $s1,token_num        #save the new token number
	j Loop	                #while(1);


end_tok:
	
	jr  $ra                 #go back to main

#------------------------------------------------------------------
# Function: output_tokens
#------------------------------------------------------------------
#Registers used:
# $t0=token_num
# $t1=i
# $t3= i<token_num
# $t4=c
# $t5= index of tokens big array

output_tokens:                     
                                # $t1 the i counter
	li $t1,0	        #initialize int i=0
	lw $t2,token_num        # get token num in $t2	

	lw $t0,token_num        #to check against the counter

	li $t5,0               
	                        # initialize big array index
	j printloop
		
next_line:
        li $t3,201	
	mul $t5,$t1,$t3         #change row by multiplying by 201	
	
printloop: 
	
	slt $t3,$t1,$t0         #for (i = 0; i < tokens_number; ++i) 
	beqz $t3,main_end 	
	                        #print character by character
        lb $t4,tokens($t5)      #if char is null then we reach the end of the token
        beqz $t4,endprint       #$t4 hold the character 
		
	li $v0,11               #print statement
	move $a0,$t4
	syscall
	
	addi $t5,$t5,1          #go to the next character
	j printloop
	
	
endprint:	
	addi $t1,$t1,1         #increment the i counter
	beq $t0,$t1,main_end   #no new line at the end of the program, MIPS prints new line at the end.
	                       #if the number of tokens is the same as token number then just terminate without printing.
	la $a0,newline	       #print a new line
	li $v0,4
	syscall
	
	j next_line           #go change the row before the next loop





        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
