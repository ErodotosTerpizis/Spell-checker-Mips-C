/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description: 
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker 
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C 
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }   
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][200 + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!
int dict_number=0;                                         //global variable holds the number of tokens created from the dictionary
char dicttokens[MAX_DICTIONARY_WORDS][MAX_WORD_SIZE];    //2D array to hold the dictionary tokens



void tokenize_dict(){
  // tokenize the dictionary into an 2D array
  int d_idx = 0; // dictionary index
  char c;        //character to be checked
  int dict_c_idx; //index of each token in the rows of the 2D array
 
  do {
    c = dictionary[d_idx];
    // end of content
    if(c == '\0'){       //if we reach the end of dictionary,stop
      break;
    }

    // if the token starts with an alphabetic character
    if(c!='\n'){
      
      int dict_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        dicttokens[dict_number][dict_c_idx] = c; //store the char in the array

        dict_c_idx += 1;
        d_idx += 1;

        c = dictionary[d_idx];
      } while(c!='\n'); //loop while the next character is not a new line char
        dicttokens[dict_number][dict_c_idx] = '\0';  //if its a new line char then replace it with the end of string char
        d_idx++;
        dict_number += 1;
    }   
    //d_idx++;
  }while(1);
}

int compare_punctuation(int t){
//function to check if punctuation follow the rules
int row=t;
char previous='\0';
char next='\0';
int elipsis=0; //flag for elipsis

if (row!=0){
  previous=tokens[t-1][0];
}
if (row!=tokens_number){
   next=tokens[t+1][0];
}
if (tokens[row][0]=='.'){
  if (tokens[row][1]=='.' && tokens[row][2]=='.' && tokens[row][3]=='\0'){
    elipsis=1;
  }
}
//printf("string %s has elipsis %d",tokens[row],elipsis);
//print_char('\n');
//rules
if (previous==32){
//  printf("check %s in rule 1 is 0",tokens[row]);
  return 0;
}
else if (next>=65){
 //  printf("check %s in rule 2 is 0",tokens[row]);
  return 0;
}
else if (elipsis==1){
  // printf("check %s in rule 3 is 1",tokens[row]);
  return 1;
}
else if (tokens[row][1]=='\0'){
  // printf("check %s in rule 4 is 1",tokens[row]);
  return 1;
}
else if (tokens[row][1]!='\0'){
  // printf("check %s in rule 5 is 0",tokens[row]);
  return 0;
}
return 0;

}





int compare_tokens(const char *t, const char *d){
  //function to compare between the 2 char array, if there is a match return 1 otherwise 0

 int i=0;
 char token_c;
 char dict_c;
 
 token_c=t[i];
 dict_c=d[i];
 
  while ((token_c!='\0') || (dict_c!='\0')){ //check if we reach the end of both of the 2 strings
  // print_char(token_c);
  // print_char(dict_c);
  // printf("\n");

  if (token_c>=65 && token_c<=90){  //if the char from the token is capital ,turn it to lower
    token_c+=32;
  }
  if (token_c>dict_c)
    return 0;
  if (token_c<dict_c)
    return 0;

    i++;  //increament as long as the characters match
    token_c=t[i];
    dict_c=d[i];
  };

  return 1;
}
   


void spell_checker() {
   int rt=0;         // row of tokens
   int rd=0;       //row of dicttokens 
   int test;  //contains the result of the comparison
   char c;   //hold the char to be checked
   
   
  
  do{
    int flag=0; 
    c=tokens[rt][0];  //from he first char of the token we can say if its a word
    // compare each token with all tokens of dictionary
    if (c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z'){  //if the char is not alphabetic, then is either space or punctuation token, dont check
     do{
       test=compare_tokens(tokens[rt],dicttokens[rd]);
      
       if (test==1){  
         flag=1;          //If token is correct print it and exit the loop
         output(tokens[rt]); 
         break;            
       }

       rd++; //if they dont match go to the next row in the dictionary array

      }while(rd<=dict_number); //call the compare function until i reach the end of the dictionary array

      if (flag==0){
        print_char(95); //print underscore  before and after the token
        output(tokens[rt]);
        print_char(95); 

      }      
    }
    else{ 
      //if its not a word,print as it is
      if (c!=32){
        test=compare_punctuation(rt);
        if (test!=1){
          print_char(95); //print underscore  before and after the token
          output(tokens[rt]);
          print_char(95);
        }
        else{
          output(tokens[rt]);

        }
      }
      else{
        output(tokens[rt]);

      }
    }    
    
    rt++; //change token
    rd=0; //check from the start of the dictionary

  }while(rt<=tokens_number); //check all tokens

  
  return;
}



//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer(){
  char c;
  

  // index of content 
  int c_idx = 0;
  c = content[c_idx];
  do {

    // end of content
    if(c == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {
      
      int token_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with one of punctuation marks
    } else if(c == ',' || c == '.' || c == '!' || c == '?') {
      
      int token_c_idx = 0;
      // copy till see any non-punctuation mark character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ',' || c == '.' || c == '!' || c == '?');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with space
    } else if(c == ' ') {
      
      int token_c_idx = 0;
      // copy till see any non-space character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ' ');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;
    }

  } while(1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{


  /////////////Reading dictionary and input files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;
  
  // open input file 
  FILE *input_file = fopen(input_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the input file failed
  if(input_file == NULL){
    print_string("Error in opening input file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }

  // reading the input file
  do {
    c_input = fgetc(input_file);
    // indicates the the of file
    if(feof(input_file)) {
      content[idx] = '\0';
      break;
    }
    
    content[idx] = c_input;

    if(c_input == '\n'){
      content[idx] = '\0'; 
    }

    idx += 1;

  } while (1);

  // closing the input file
  fclose(input_file);

  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ////////////////////////////////////////////////////////////////

  tokenizer();
  tokenize_dict();
  spell_checker();
  
//  output_tokens();

  return 0;
}
