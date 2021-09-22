/* Trabalho 1 - Tradutores --> Analisador Léxico */

/* Nomes: Daniel Lopes Ferreira, Maxwell Frank Barbosa, Vítor Kehl Matter */

%option noyywrap

/* Definitions */
%{ 

#include <math.h>
#include <string.h>
int currentId = 0;
char* name[10][10] = {{"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}};
int id[10][10];
int scope = 0;

%}


%x C_COMMENT
DIGIT			[0-9]
ID				[a-z|A-Z][a-z0-9|A-Z0-9]*
FUNCTION 		int|float|double|string|bool|void\ +[a-z|A-Z][a-z0-9|A-Z0-9]*\ ?\(
STRING			\".*\"
COMMENT			\/\/.*
RESERVED		while|if|else|switch|for|return|NULL|break|case|#include|printf|clrscr|getch|scanf
TYPE			int|float|double|string|bool
LOGIC			&&|!|"||"
START_SCOPE  	\{
END_SCOPE		\}
HAS_SEMICOLON	^\;


%%

<INITIAL>"/*"         					{BEGIN(C_COMMENT);}
<C_COMMENT>"*/"							{BEGIN(INITIAL);}
<C_COMMENT>[^*\n]+   						
<C_COMMENT>"*"       
<C_COMMENT>\n        

{COMMENT}

{START_SCOPE} 							{scope++;}

{END_SCOPE} 							{
										 for(int i = 0; i < sizeof name[scope] / sizeof name[scope][0]; i++){ 
											 name[scope][i] = "";
										 }
									     scope--; 
										 }

\<.+\>									{printf("[include, %s]\n", yytext);}

{DIGIT}*"."{DIGIT}* 					{printf("[num, %.2f]", atof(yytext));}

{DIGIT}+ 								{printf("[num, %d]", atoi(yytext));}

{RESERVED}\ ?"*"\ ?{ID}					{printf("[pointer_declaration, %s]", yytext);}

{RESERVED}								{printf("[reserved_word, %s]", yytext);}

{LOGIC}									{printf("[Logic_op, %s]", yytext);}

{FUNCTION}								{	for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												if (strcmp(name[scope][k], "") == 0) {
													
													// Handle space.
													char delim[] = " ";
													char* str =  malloc(strlen(yytext)+1);
													strcpy(str, yytext);
													int lenYytext = strlen(yytext);
													char* ptr = strtok(str, delim);
													char* printPtr =  malloc(strlen(ptr)+1);
													strcpy(printPtr, ptr);
													int lenPtr = strlen(ptr);
													strncpy(str, yytext + (lenPtr + 1), lenYytext);
													str[strlen(str) - 1] = '\0';
													printf("[reserved_word, %s]", printPtr);
													currentId++;
	        										id[scope][k] = currentId;
	        										name[scope][k] = str;
	        										printf("[id, %d]", id[scope][k]);
	        										break;
												}
											}
										}
										
{TYPE}\ *?.*\,?\ ?{ID}\ *\)		{		yytext[strlen(yytext) - 1] = '\0';
										for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
											if (strcmp(name[scope][k], "") == 0) {
												
												// Handle space.
												char delim[] = " ";
												char* str =  malloc(strlen(yytext)+1);
												char* str2 =  malloc(strlen(yytext)+1);
												strcpy(str, yytext);
												int lenYytext = strlen(yytext);
												char* ptr = strtok(str, delim);
												char* printPtr =  malloc(strlen(ptr)+1);
												strcpy(printPtr, ptr);
												int lenPtr = strlen(ptr);
												strncpy(str, yytext + (lenPtr + 1), lenYytext);
												printf("[reserved_word, %s]", printPtr);
												
												// Handle comma.
												if (strchr(str, ',') != NULL) {
													k--;
													char* strComma;
													while(strchr(str, ',') != NULL) {
														char delimComma[] = ",";
														// Aloca memoria.
														strComma =  malloc(strlen(str)+1);
														strcpy(strComma, str);
														lenYytext = strlen(str);
														// Separa elements pela virgula.
														ptr = strtok(strComma, delimComma);
														printPtr =  malloc(strlen(ptr)+1);
														strcpy(printPtr, ptr);
														for (int i = 0; i < strlen(printPtr); i++) { 
															if (printPtr[i] != ' ' && printPtr[i] != '*') {
																strncpy(printPtr, printPtr + i, strlen(printPtr));
																currentId++;
																k++;
																id[scope][k] = currentId;
																name[scope][k] = printPtr;
																printf("[id, %d]", id[scope][k]);
																break;
															}
														}
														
														lenPtr = strlen(ptr);
														strncpy(strComma, str + (lenPtr + 1), lenYytext);
														str =  malloc(strlen(strComma)+1);
														strncpy(str, strComma, strlen(strComma));
														
														char delim[] = " ";
														str2 =  malloc(strlen(str)+1);
														strcpy(str2, str);
														int lenYytext = strlen(str);
														char* ptr = strtok(str2, delim);
														char* printPtr =  malloc(strlen(ptr)+1);
														strcpy(printPtr, ptr);
														int lenPtr = strlen(ptr);
														strncpy(str2, str + (lenPtr + 1), lenYytext);
														printf("[reserved_word, %s]", printPtr);
													}
													if (str2[0] == ' ' || str2[0] == '*') {
														for (int i = 0; i < strlen(str2); i++) { 
															if (str2[i] != ' ' && str2[i] != '*') {
																strncpy(str2, str2 + i, strlen(str2));
																currentId++;
																k++;
																id[scope][k] = currentId;
																name[scope][k] = str2;
																printf("[id, %d]", id[scope][k]);
																break;
															}
														}
													} else {
															currentId++;
															k++;
															id[scope][k] = currentId;
															name[scope][k] = strComma;
															printf("[id, %d]", id[scope][k]);
														}
												} else {
												    for (int i = 0; i < strlen(str); i++) { 
															if (str[i] != ' ' && str[i] != '*') {
																strncpy(str, str + i, strlen(str));
																currentId++;
																id[scope][k] = currentId;
																name[scope][k] = str;
																printf("[id, %d]", id[scope][k]);
																break;
															}
													}
												}
												break;
											}
										}
									}

{TYPE}\ *?.*\,\ ?{ID}			{	for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												if (strcmp(name[scope][k], "") == 0) {
													
													// Handle space.
													char delim[] = " ";
													char* str =  malloc(strlen(yytext)+1);
													strcpy(str, yytext);
													int lenYytext = strlen(yytext);
													char* ptr = strtok(str, delim);
													char* printPtr =  malloc(strlen(ptr)+1);
													strcpy(printPtr, ptr);
													int lenPtr = strlen(ptr);
													strncpy(str, yytext + (lenPtr + 1), lenYytext);
													printf("[reserved_word, %s]", printPtr);
													
													// Handle comma.
													if (strchr(str, ',') != NULL) {
													    k--;
													    char* strComma;
													    while(strchr(str, ',') != NULL) {
	    													char delimComma[] = ",";
	    													strComma =  malloc(strlen(str)+1);
	    													strcpy(strComma, str);
	    													lenYytext = strlen(str);
	    													ptr = strtok(strComma, delimComma);
	    													printPtr =  malloc(strlen(ptr)+1);
	    													strcpy(printPtr, ptr);
	    													for (int i = 0; i < strlen(printPtr); i++) { 
	        													if (printPtr[i] != ' ') {
	        													    strncpy(printPtr, printPtr + i, strlen(printPtr));
	            													currentId++;
	            													k++;
	            													id[scope][k] = currentId;
	            													name[scope][k] = printPtr;
	            													printf("[id, %d]", id[scope][k]);
	            													break;
	        													}
													        }
	    													lenPtr = strlen(ptr);
	    													strncpy(strComma, str + (lenPtr + 1), lenYytext);
	    													str =  malloc(strlen(strComma)+1);
	    													strncpy(str, strComma, strlen(strComma));
													    }
													    if (str[0] == ' ') {
	    													for (int i = 0; i < strlen(str); i++) { 
	        													if (str[i] != ' ') {
	        													    strncpy(str, str + i, strlen(str));
	            													currentId++;
	            													k++;
	            													id[scope][k] = currentId;
	            													name[scope][k] = str;
	            													printf("[id, %d]", id[scope][k]);
	            													break;
														        }
	        												    }
	        											} else {
	        												    currentId++;
	        													k++;
	        													id[scope][k] = currentId;
	        													name[scope][k] = strComma;
	        													printf("[id, %d]", id[scope][k]);
	        												}
													} else {
													    for (int i = 0; i < strlen(str); i++) { 
															if (str[i] != ' ' && str[i] != '*') {
																strncpy(str, str + i, strlen(str));
																currentId++;
																id[scope][k] = currentId;
																name[scope][k] = str;
																printf("[id, %d]", id[scope][k]);
																break;
															}
													    }
													}
													break;
												}
											}
										}
										
{TYPE}\ *?\*?\ *?{ID}					{	for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												if (strcmp(name[scope][k], "") == 0) {
													
													// Handle space.
													char delim[] = " ";
													char* str =  malloc(strlen(yytext)+1);
													strcpy(str, yytext);
													int lenYytext = strlen(yytext);
													char* ptr = strtok(str, delim);
													char* printPtr =  malloc(strlen(ptr)+1);
													strcpy(printPtr, ptr);
													int lenPtr = strlen(ptr);
													strncpy(str, yytext + (lenPtr + 1), lenYytext);
													printf("[reserved_word, %s]", printPtr);
													
													// Handle comma.
													if (strchr(str, ',') != NULL) {
														k--;
														char* strComma;
														while(strchr(str, ',') != NULL) {
															char delimComma[] = ",";
															strComma =  malloc(strlen(str)+1);
															strcpy(strComma, str);
															lenYytext = strlen(str);
															ptr = strtok(strComma, delimComma);
															printPtr =  malloc(strlen(ptr)+1);
															strcpy(printPtr, ptr);
															for (int i = 0; i < strlen(printPtr); i++) { 
																if (printPtr[i] != ' ') {
																	strncpy(printPtr, printPtr + i, strlen(printPtr));
																	currentId++;
																	k++;
																	id[scope][k] = currentId;
																	name[scope][k] = printPtr;
																	printf("[id, %d]", id[scope][k]);
																	break;
																}
															}
															lenPtr = strlen(ptr);
															strncpy(strComma, str + (lenPtr + 1), lenYytext);
															str =  malloc(strlen(strComma)+1);
															strncpy(str, strComma, strlen(strComma));
														}
														if (str[0] == ' ') {
															for (int i = 0; i < strlen(str); i++) { 
																if (str[i] != ' ') {
																	strncpy(str, str + i, strlen(str));
																	currentId++;
																	k++;
																	id[scope][k] = currentId;
																	name[scope][k] = str;
																	printf("[id, %d]", id[scope][k]);
																	break;
																}
																}
														} else {
																currentId++;
																k++;
																id[scope][k] = currentId;
																name[scope][k] = strComma;
																printf("[id, %d]", id[scope][k]);
															}
													} else {
														for (int i = 0; i < strlen(str); i++) { 
															if (str[i] != ' ' && str[i] != '*') {
																strncpy(str, str + i, strlen(str));
																currentId++;
																id[scope][k] = currentId;
																name[scope][k] = str;
																printf("[id, %d]", id[scope][k]);
																break;
															}
														}
													}
													break;
												}
											}
										}

{ID} 									{ int existId = 0; // 0 --> Nao existe && 1 --> Existe.
											// Verificar se o elemento jah existe na matriz.
											for (int i = scope; i >= 0; i--) {
												if (existId == 1) {
													break;
												}
												for (int j = 0; j < sizeof name[i] / sizeof name[i][0]; j++){
													//printf("\n yytext '%s' == name[i][j] '%s' \n", yytext, name[i][j]);
													char* str = malloc(strlen(yytext)+1);
                                                    strcpy(str, yytext);
													if (strcmp(str, name[i][j]) == 0) {
														printf("[id, %d]", id[i][j]);
														existId = 1;
														break;
													}
												}
											}
											if (existId == 0){ // Elemento nao encontrado.
												printf("[Variavel %s nao encontrada]", yytext);
											}
										}

"++"|"+"|"--"|"-"|"*"|"/" 				{printf("[Arith_Op, %s]", yytext);}

"<"|"<="|"=="|"!="|">="|">" 			{printf("[Relational_Op, %s]", yytext);}

"=" 									{printf("[Equal_OP, %s]", yytext);}

{STRING}								{printf("[string_literal, %s]", yytext);}

";"										{printf("\n");}

[ \t\n]+

","|"&"|"("|"{"|")"|"}"|"["|"]"									

.	 									{printf("Caractere nao reconhecido: %s\n", yytext);}

%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
