/* Trabalho 1 - Tradutores --> Analisador Léxico */

/* Nomes: Daniel Lopes Ferreira, Maxwell Frank Barbosa, Vítor Kehl Matter */

%option noyywrap

/* Definitions */
%{ 
// Package included.
#include <string.h>

// Current Id.
int currentId = 0;

// Current scope.
int scope = 0;

// Matrix of elements and scope.
char* name[10][10] = {{"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}};

// Ids matrix.
int id[10][10];

%}

%x C_COMMENT
DIGIT			[0-9]
ID				[a-z|A-Z][a-z0-9|A-Z0-9]*
FUNCTION		int|float|double|string|bool|void\ +[a-z|A-Z][a-z0-9|A-Z0-9]*\ ?\(
STRING			\".*\"
COMMENT			\/\/.*
RESERVED		while|if|else|switch|for|return|NULL|break|case|#include|printf|clrscr|getch|scanf
TYPE			int|float|double|string|bool
LOGIC			&&|!|"||"
START_SCOPE		\{
END_SCOPE		\}
HAS_SEMICOLON	^\;


%%

<INITIAL>"/*"							{BEGIN(C_COMMENT);}
<C_COMMENT>"*/"							{BEGIN(INITIAL);}
<C_COMMENT>[^*\n]+
<C_COMMENT>"*"
<C_COMMENT>\n

{COMMENT}

{START_SCOPE} 							{scope++;}

{END_SCOPE}								{ 	// Removes the stored variables and descreases the scope.
											for(int i = 0; i < sizeof name[scope] / sizeof name[scope][0]; i++){ 
												name[scope][i] = "";
											}
											scope--; 
										}

\<.+\>									{ 	// "Include" regex.
											printf("[include, %s]\n", yytext);
										}

{DIGIT}*"."{DIGIT}*						{ 	// "float" regex.
											printf("[num, %.2f]", atof(yytext));
										}

{DIGIT}+								{ 	// "numeric" regex.
											printf("[num, %d]", atoi(yytext));
										}

{RESERVED}\ ?"*"\ ?{ID}					{	// "pointer declaration" regex.
											printf("[pointer_declaration, %s]", yytext);
										}

{RESERVED}								{ 	// "reserved words" regex.
											printf("[reserved_word, %s]", yytext);
										}

{LOGIC}									{ 	// "logic operators" regex.
											printf("[Logic_op, %s]", yytext);
										}

{FUNCTION}								{	// "function" regex. Example: void CalculoMedia.

											// For that iterates over the scope getting the function type and its name.
											for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												// Verifies if the current position value has an empty value.
												if (strcmp(name[scope][k], "") == 0) {
													
													/* 
													 * Splits the input using ' ' and populates the id and the name 
													 * matrixes with the obtained values.
													*/
													char delim[] = " ";													// Sets a delimiter.
													char* str =  malloc(strlen(yytext)+1);								// Allocates memory space.
													strcpy(str, yytext);												// Copies the string.
													int lenYytext = strlen(yytext);										// Gets the yytext length.
													char* ptr = strtok(str, delim);										// Applies the split.
													char* printPtr =  malloc(strlen(ptr)+1);							// Allocates memory space.
													strcpy(printPtr, ptr);												// Copies the string.
													int lenPtr = strlen(ptr);											// Gets the ptr length.
													strncpy(str, yytext + (lenPtr + 1), lenYytext);						// Applies a trim function to ignore blank spaces.
													str[strlen(str) - 1] = '\0';										// Removes the parameters' starting parentheses.
													printf("[reserved_word, %s]", printPtr);							// Prints the reserved_word.
													currentId++;														// Increases the currentId.
													id[scope][k] = currentId;											// Populates the id matrix.
													name[scope][k] = str;												// Populates the name matrix.
													printf("[id, %d]", id[scope][k]);									// Prints the id.
													break;
												}
											}
										}
										
{TYPE}\ *?.*\,?\ ?{ID}\ *\)				{	// Verifies the variables creation inside parameters. Example: (int * vetor, int elementos).

											// Removes the closing parentheses. 
											yytext[strlen(yytext) - 1] = '\0';
											
											// For that iterates over the name matrix verifying the variables.
											for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												// Verifies if the current position value has an empty value.
												if (strcmp(name[scope][k], "") == 0) {
													
													/* 
													 * Splits the input using ' ' and populates the id and the name 
													 * matrixes with the obtained values.
													*/
													char delim[] = " ";													// Sets a delimiter.
													char* str =  malloc(strlen(yytext)+1);								// Allocates memory space.
													char* str2 =  malloc(strlen(yytext)+1);								// Allocates memory space.
													strcpy(str, yytext);												// Copies the string.
													int lenYytext = strlen(yytext);										// Gets the yytext length.
													char* ptr = strtok(str, delim);										// Applies the split.
													char* printPtr =  malloc(strlen(ptr)+1);							// Allocates memory space.
													strcpy(printPtr, ptr);												// Copies the string.
													int lenPtr = strlen(ptr);											// Gets the ptr length.
													strncpy(str, yytext + (lenPtr + 1), lenYytext);						// Copies the string.
													printf("[reserved_word, %s]", printPtr);							// Prints the reserved_word.
													
													/*
													 * If the expression contains comma, the split is applied and for 
													 * each value inside the spplited values a new id will be allocated.
													*/ 
													if (strchr(str, ',') != NULL) {
														k--;															// Decreases the iterator.
														char* strComma;													// Instantiates the strComma.
														
														// While comma exists.
														while(strchr(str, ',') != NULL) {
															char delimComma[] = ",";									// Sets a delimiter.
															strComma =  malloc(strlen(str)+1);							// Allocates memory space.
															strcpy(strComma, str);										// Copies the string.
															lenYytext = strlen(str);									// Gets the str length.
															ptr = strtok(strComma, delimComma);							// Applies the split.
															printPtr =  malloc(strlen(ptr)+1);							// Allocates memory space.
															strcpy(printPtr, ptr);										// Copies the string.
															
															// Navigates through the splitted variables.
															for (int i = 0; i < strlen(printPtr); i++) { 
																// If the character is different than ' ' and '*' populates the matrixes.
																if (printPtr[i] != ' ' && printPtr[i] != '*') {
																	strncpy(printPtr, printPtr + i, strlen(printPtr));	// Copies the string.
																	currentId++;										// Increases the currentId.
																	k++;												// Increases the iterator.
																	id[scope][k] = currentId;							// Populates the id matrix.
																	name[scope][k] = printPtr;							// Populates the name matrix.	
																	printf("[id, %d]", id[scope][k]);					// Prints the id.
																	break;
																}
															}
															
															lenPtr = strlen(ptr);										// Gets the ptr length.
															strncpy(strComma, str + (lenPtr + 1), lenYytext);			// Copies the string.
															str =  malloc(strlen(strComma)+1);							// Allocates memory space.
															strncpy(str, strComma, strlen(strComma));					// Copies the string.
															char delim[] = " ";											// Sets a delimiter.
															str2 =  malloc(strlen(str)+1);								// Allocates memory space.
															strcpy(str2, str);											// Copies the string.
															int lenYytext = strlen(str);								// Gets the str length.
															char* ptr = strtok(str2, delim);							// Applies the split.
															char* printPtr =  malloc(strlen(ptr)+1);					// Allocates memory space.
															strcpy(printPtr, ptr);										// Copies the string.
															int lenPtr = strlen(ptr);									// Gets the ptr length.
															strncpy(str2, str + (lenPtr + 1), lenYytext);				// Copies the string.
															printf("[reserved_word, %s]", printPtr);					// Prints the reserved_word.
														}
														// Verifies if the variable containts ' ' or '*' and works like a trim function.
														if (str2[0] == ' ' || str2[0] == '*') { 
														
															// Iterates over ' ' and '*' until the character is different.
															for (int i = 0; i < strlen(str2); i++) { 
																// If the character is different than ' ' and '*' populates the matrixes.
																if (str2[i] != ' ' && str2[i] != '*') {
																	strncpy(str2, str2 + i, strlen(str2));				// Copies the string.
																	currentId++;										// Increases the currentId.
																	k++;												// Increases the iterator.
																	id[scope][k] = currentId;							// Populates the id matrix.
																	name[scope][k] = str2;								// Populates the name matrix.
																	printf("[id, %d]", id[scope][k]);					// Prints the id.
																	break;
																}
															}
														// else if character is different than ' ' and '*' populates the matrixes and updates the iterators.
														} else {
															currentId++;												// Increases the currentId.
															k++;														// Increases the iterator.
															id[scope][k] = currentId;									// Populates the id matrix.
															name[scope][k] = strComma;									// Populates the name matrix.
															printf("[id, %d]", id[scope][k]);							// Prints the id.
														}
													// else if the expression does not contain comma. Only contains one variable (id).
													} else {
														// Navigates through the variables and works like a trim function.
														for (int i = 0; i < strlen(str); i++) {
															// If the character is different than ' ' and '*' populates the matrixes.
															if (str[i] != ' ' && str[i] != '*') {
																strncpy(str, str + i, strlen(str));						// Copies the string.
																currentId++;											// Increases the currentId.
																id[scope][k] = currentId;								// Populates the id matrix.
																name[scope][k] = str;									// Populates the name matrix.
																printf("[id, %d]", id[scope][k]);						// Prints the id.	
																break;
															}
														}
													}
													break;
												}
											}
										}

{TYPE}\ *?.*\,?\ ?{ID}					{	// Verifies the variables creation outside functions. Example: float NotaDaP1, NotaDaP2;.

											// For that iterates over the name matrix verifying the variables.
											for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												// Verifies if the current position value has an empty value.
												if (strcmp(name[scope][k], "") == 0) {
													
													/* 
													 * Splits the input using ' ' and populates the id and the name 
													 * matrixes with the obtained values.
													*/
													char delim[] = " ";													// Sets a delimiter.
													char* str =  malloc(strlen(yytext)+1);								// Allocates memory space.
													strcpy(str, yytext);												// Copies the string.
													int lenYytext = strlen(yytext);										// Gets the yytext length.
													char* ptr = strtok(str, delim);										// Applies the split.
													char* printPtr =  malloc(strlen(ptr)+1);							// Allocates memory space.
													strcpy(printPtr, ptr);												// Copies the string.
													int lenPtr = strlen(ptr);											// Gets the ptr length.
													strncpy(str, yytext + (lenPtr + 1), lenYytext);						// Copies the string.
													printf("[reserved_word, %s]", printPtr);							// Prints the reserved_word.
													
													/*
													 * If the expression contains comma, the split is applied and for 
													 * each value inside the spplited values a new id will be allocated.
													*/ 
													if (strchr(str, ',') != NULL) {
														k--;															// Decreases the iterator.
														char* strComma;
														// While comma exists.
														while(strchr(str, ',') != NULL) {
															char delimComma[] = ",";									// Sets a delimiter.
															strComma =  malloc(strlen(str)+1);							// Allocates memory space.
															strcpy(strComma, str);										// Copies the string.
															lenYytext = strlen(str);									// Gets the str length.
															ptr = strtok(strComma, delimComma);							// Applies the split.
															printPtr =  malloc(strlen(ptr)+1);							// Allocates memory space.
															strcpy(printPtr, ptr);										// Copies the string.
															for (int i = 0; i < strlen(printPtr); i++) { 
																// If the character is different than ' ' populates the matrixes.
																if (printPtr[i] != ' ') {
																	strncpy(printPtr, printPtr + i, strlen(printPtr));	// Copies the string.
																	currentId++;										// Increases the currentId.
																	k++;												// Increases the iterator.	
																	id[scope][k] = currentId;							// Populates the id matrix.
																	name[scope][k] = printPtr;							// Populates the name matrix.
																	printf("[id, %d]", id[scope][k]);					// Prints the id.
																	break;
																}
															}
															lenPtr = strlen(ptr);										// Gets the ptr length.
															strncpy(strComma, str + (lenPtr + 1), lenYytext);			// Copies the string.
															str =  malloc(strlen(strComma)+1);							// Allocates memory space.
															strncpy(str, strComma, strlen(strComma));					// Copies the string.
														}
														// Verifies if the variable containts ' ' and works like a trim function.
														if (str[0] == ' ') {
															// Iterates over ' ' until the character is different.
															for (int i = 0; i < strlen(str); i++) {
																// If the character is different than ' '.
																if (str[i] != ' ') {
																	strncpy(str, str + i, strlen(str));					// Copies the string.
																	currentId++;										// Increases the currentId.
																	k++;												// Increases the iterator.
																	id[scope][k] = currentId;							// Populates the id matrix.
																	name[scope][k] = str;								// Populates the name matrix.
																	printf("[id, %d]", id[scope][k]);					// Prints the id.
																	break;
																}
															}
														// else if character is different than ' ' populates the matrixes and updates the iterators.
														} else {
															currentId++;												// Increases the currentId.
															k++;														// Increases the iterator.	
															id[scope][k] = currentId;									// Populates the id matrix.
															name[scope][k] = strComma;									// Populates the name matrix.
															printf("[id, %d]", id[scope][k]);							// Prints the id.
														}
													// else if the expression does not contain comma. Only contains one variable (id).
													} else {
														// Navigates through the variables and works like a trim function.
														for (int i = 0; i < strlen(str); i++) { 
															// If the character is different than ' ' and '*' populates the matrixes.
															if (str[i] != ' ' && str[i] != '*') {
																strncpy(str, str + i, strlen(str));						// Copies the string.
																currentId++;											// Increases the currentId.
																id[scope][k] = currentId;								// Populates the id matrix.
																name[scope][k] = str;									// Populates the name matrix.
																printf("[id, %d]", id[scope][k]);						// Prints the id.
																break;
															}
														}
													}
													break;
												}
											}
										}

{ID} 									{ 	// Verify the scope id and gets the variable id.
											
											// Variable that verify if the id exists.
											int existId = 0; // 0 --> Does not exist && 1 --> Exists.
											
											// Verify if the variable id already exist. Changes the scopes in each iteration.
											for (int i = scope; i >= 0; i--) {
												// If exists breaks out of the loop.
												if (existId == 1) {
													break;
												}
												// Navegates inside each scope verifying if the variable exists.
												for (int j = 0; j < sizeof name[i] / sizeof name[i][0]; j++){
													
													/* 
													 * Debug print:
													 * printf("\n yytext '%s' == name[i][j] '%s' \n", yytext, name[i][j]);
													*/

													char* str = malloc(strlen(yytext)+1);								// Allocates memory space.
                                                    strcpy(str, yytext);												// Copies the string.
													
													// Verifies if the position value is the same as the str variable.
													if (strcmp(str, name[i][j]) == 0) {	
														printf("[id, %d]", id[i][j]);									// Prints the id.	
														existId = 1;													// Sets the id to 1.
														break;
													}
												}
											}
											// Verifies if the variable id was not found.
											if (existId == 0){
												printf("[Variavel %s nao encontrada]", yytext);
											}
										}

"++"|"+"|"--"|"-"|"*"|"/"				{	// "Arithmetics Operators" regex.
											printf("[Arith_Op, %s]", yytext);
										}

"<"|"<="|"=="|"!="|">="|">"				{	// "Relational Operators" regex.
											printf("[Relational_Op, %s]", yytext);
										}

"="										{	// "Equal Operator" regex.
											printf("[Equal_OP, %s]", yytext);
										}

{STRING}								{	// "String" regex.
											printf("[string_literal, %s]", yytext);
										}

";"										{	// "Semicolon" regex.
											printf("\n");
										}

[ \t\n]+								{ 	/* Handles the remotion of tab and new line. */ }

","|"&"|"("|"{"|")"|"}"|"["|"]"			{ 	/* Handles the remotion of other symbols. */ }					

.										{	// Regex that prints the remaining characters.
											printf("Caractere nao reconhecido: %s\n", yytext);
										}

%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
