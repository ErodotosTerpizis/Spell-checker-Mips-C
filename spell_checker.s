
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
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
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL
token_num:              .word 0        
tokens:                 .space 411849
dict_num:               .word 0         # int dict_number=0;global variable holds the number of tokens created from the dictionary
                                        #use word as it must be able to store up tp 10,000
dicttokens:             .space 200001   #  char dicttokens[MAX_DICTIONARY_WORDS][MAX_WORD_SIZE]; 


# You can add your data here!
        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
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
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
jal tokenizer
jal tokenize_dict                
jal spell_checker

j main_end

#------------------------------------------------------------------
#Tokenize_dict function
#-------------------------------------------------------------------
#Registers used:
# $s1=dict number
# $t0=dict_c_idx
# $t1=c
# $t2=ascii code for comparison
# $t3=d_idx
# $t4=tokens index(big array)

tokenize_dict:
       li $t3,0                         # d_idx = 0;
       

doloop_big:
       lb $t1,dictionary($t3)           # c = dictionary[d_idx]; 
       beqz $t1,end_tok_dict            #if(c == '\0')
       
       li $t2,10
       beq $t1,$t2,end_tok_dict         #if(c!='\n'){
       li $t0,0                         #int dict_c_idx = 0;
       
doloop_small:

       lw $s1,dict_num                  #$s1 has the dict_num
       li $t4,0                         #$t4 will be the index of the dicttokens big array
       move $t4,$s1
       li $t2,20
       mul $t4,$t4,$t2                   # row*20
       add $t4,$t4,$t0                  # big array index: row*20 +column
       sb $t1,dicttokens($t4)           #dicttokens[dict_number][dict_c_idx] = c
       
       addi $t0,$t0,1                   # dict_c_idx++
       addi $t3,$t3,1                   # d_idx++
       
       lb $t1,dictionary($t3)           # c = dictionary[d_idx];
       li $t2,10                        #while(c!='\n')
       beq $t1,$t2, terminate_token     #$t2 hold the ascii code for new line
       j doloop_small
       
terminate_token:
       
       li $t4,0
       move $t4,$s1
       li $t2,20
       mul $t4,$t4,$t2                  # row*20
       add $t4,$t4,$t0                  # big array index: row*20 +column
       sb $0,dicttokens($t4)            #dicttokens[dict_number][dict_c_idx] = '\0'
       
       
       addi $t3,$t3,1                   # d_idx++
       addi $s1,$s1,1
       sw $s1,dict_num                  #dict_number += 1;
       
     
       j doloop_big
       
end_tok_dict:
       jr $ra       
      
#------------------------------------------------------------------
#compare_tokens function
#-------------------------------------------------------------------
#Registers used:
# $a1=pointer to first element of a token in token array
# $a2= pointer to first element of a token in dicttokens array
# $v0=return value
# $t1=i
# $t2=token_c
# $t3=dict_c
# $t4=  value of (token_c>dict_c), (token_c<dict_c)
# $t5=ascii codes to compare
# $t6=index of tokens big array
# $t7=index of dicttokens big array         
            
       
compare_tokens:
       
       li $t1,0                         #i=0;
       
       lb $t2 ,tokens($a1)              # token_c=t[i];
       lb $t3, dicttokens($a2)          #dict_c=d[i];
       li $v0,1                         # initialize the return value to true
                                        # if match then the value won't change
        
ifcapital: 
                                        #while ((token_c!='\0') || (dict_c!='\0'))
       beqz $t2,second_cond             # if its over,check the other one, otherwise enter the loop
       j inside_loop                    #keep going if either of them hasnt finished

second_cond:
       beqz $t3, end_compare            #if its over, terminate function,otherwise enter the loop
                                            
inside_loop:                            #if (token_c>=65 && token_c<=90)
       li $t5,65
       blt $t2,$t5,check1               #if less than 65, then its the '\0' symbol
       li $t5,90                        #check if capital
       ble, $t2,$t5,tolower
check1:  
       slt $t4,$t3,$t2 
       beqz $t4,check2                  # if (token_c>dict_c)
                                        #  return 0;
       li $v0,0
       j end_compare
check2: 
      slt $t4,$t2,$t3
      beqz $t4,increment                # (token_c<dict_c)
                                        # return 0;
      li $v0,0 
      j end_compare
 
increment:
     addi $t1,$t1,1
     add $t6,$a1,$t1                    #$t6 will hold the address of next char to be checked
     add $t7,$a2,$t1                    #$t7 will hold the address of next char to be checked
     lb $t2 ,tokens($t6)                # token_c=t[i];
     lb $t3, dicttokens($t7)            #dict_c=d[i];
     
     j ifcapital
           
       
tolower:
      addi $t2,$t2,32                   # token_c+=32;
      j check1      
end_compare:
     jr $ra     
       
       
#------------------------------------------------------------------
#spell_checker function
#-------------------------------------------------------------------
#Registers used:
# $a1= argument to compare_token, pointer to first element of a token in token array
# $a2= argument to compare_token, pointer to first element of a token in dicttokens array
# $a3= argument to output_token, row of token to be printed
# $s1=rt
# $s2=rd
# $s3=flag
# $t0=ascii codes/dict_num/token_num-for comparison
# $t4=index for arrays tokens/dicttokens
# $t5=first char of token 
# $t7=test        
       
       
spell_checker:
    li $s1,0                            #int rt=0
    li $s2,0                            #int rd=0
    
doloop_bigsc:
   li $s3,0                             # int flag=0; 
   
   li $t4,0
   li $t0,201
   mul $t4,$s1,$t0
                                        #$t4 hold the address of the first char in a token
   lb $t5,tokens($t4)                   #c=tokens[rt][0]
   
   li $t0,65
   blt $t5,$t0,not_alpha                #if (c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z')

doloop_smallsc:
                                        #test=compare_tokens(tokens[rt],dicttokens[rd])
  
   li $t4,0 
   li $t0,201
   mul $t4,$s1,$t0

   move $a1,$t4                         #$t4 hold the address of tokens[rt][0]      
      
   li $t4,0
   li $t0,20
   mul $t4,$s2,$t0

   move $a2,$t4                         #$t4 holds the address of dicttokens[rd][0]
   
   addi $sp,$sp,-4                      #move sp down
   sw $ra,0($sp)                        #store the $ra register
   
   jal compare_tokens
   
   lw $ra,0($sp)                        # get register back
   addi $sp,$sp,4                       #increament pointer
   
   
   move $t7,$v0                         # $t7 has the value of the compare function
                                        #$t7 is test variable
              
   li $t0,1
   beq $t7,$t0,correct_print            #if (test==1)
    
   addi $s2,$s2,1                       # rd++;
   lw $t0,dict_num
   ble $s2,$t0,doloop_smallsc           #while(rd<=dict_number)
   
check_flag:
   beqz $s3,incorrect_print             #if (flag==0)
   j outloop
   
   
correct_print:
   li $s3,1                             #flag=1
                                        # $t6 is flag variable
   move $a3,$s1                         # $a3 has the row of token to be printed
   
   addi $sp,$sp,-4                      #move sp down
   sw $ra,0($sp)                        #store the $ra register
   
   jal output_token
   
   lw $ra,0($sp)                        # get register back
   addi $sp,$sp,4                       #increament pointer
   
   j check_flag                         #because break statement will exit the while loop but check flag before executing the rest
                                           
       
incorrect_print:        
   li $a0,95                            #print_char(95);
   li $v0,11
   syscall
   
   move $a3,$s1
   
   addi $sp,$sp,-4                      #move sp down
   sw $ra,0($sp)                        #store the $ra register
   
   jal output_token                     # output(tokens[rt])
   
   lw $ra,0($sp)                        # get register back
   addi $sp,$sp,4                       #increament pointer
   
   li $a0,95                            #print_char(95);
   li $v0,11
   syscall
   j outloop   

   
not_alpha:
    move $a3,$s1
    addi $sp,$sp,-4                    #move sp down
    sw $ra,0($sp)                      #store the $ra register
   
    jal output_token                   # output(tokens[rt])
   
    lw $ra,0($sp)                      # get register back
    addi $sp,$sp,4                     #increament pointer
   
    j outloop
     
 
outloop:                                #before the doloop_big is over
  
   addi $s1,$s1,1                       #rt++;
   li $s2,0                             #rd=0;
   lw $t0,token_num     
   ble $s1,$t0,doloop_bigsc             #while(rt<=tokens_number); 
   jr $ra  


#------------------------------------------------------------------
#output_token function-repressent the output function given
#-------------------------------------------------------------------
#Registers used:
# $a3= argument to output_token, row of token to be printed
# $t4=index of tokens big array
# $t0= hold char to be printed 
# $t9=mul factor
   
output_token:
     move $t4,$a3                       #$a3 has the row of token to be printed
     li $t9,201
     mul $t4,$t4,$t9                    #find the proper index in big array
     
     j printlooptoken
nextchar:
     addi $t4,$t4,1                     # after the first loop, increament the index to go to the next char
  
printlooptoken:
     lb $t0,tokens($t4)
     beqz $t0,end_output
                                        
                                        #output(tokens[rt]); 
     move $a0,$t0
     li $v0,11
     syscall
     
     
     j nextchar
     
end_output:
     jr $ra
     

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
	
	jr  $ra                   #go back to main
       
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:         
              
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
