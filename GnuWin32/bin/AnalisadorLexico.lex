/* Trabalho 1 - Tradutores --> Analisador Léxico */

/* Nomes: Daniel Lopes Ferreira, Maxwell Frank Barbosa, Vítor Kehl Matter */

%option noyywrap

/* Definitions */
%{ 

#include <math.h>
#include <string.h>
int currentId = 0;
// TODO: PROBLEMA NA MATRIZ, Soh preenche o primeiro elemento
char* name[10][10] = {{"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}, {"", "", "", "", "", "", "", "", "", ""}};
int id[10][10];
int scope = 0;

%}

/* Variáveis ou identificadores: este analisador léxico deve ser capaz de reconhecer
* nomes de variáveis, funções, parâmetros de funções em um código fonte. Além disso,
* deve ser tratada a análise de escopo para a correta definição dos identificadores:
*/

/* Constantes numéricas (números inteiros): este analisador léxico deve ser capaz de
* reconhecer um número inteiro qualquer e convertê-lo para os respectivos tokens:*/

/* Palavras reservadas: este analisador léxico deve ser capaz de reconhecer palavras
* reservadas. Por exemplo, do, while, if, else, switch, for, return, null, int, float, double,
* string, bool, break, case, etc e convertê-las para os respectivos tokens:
*/

/* Operadores relacionais: este analisador léxico deve ser capaz de reconhecer os
* operadores relacionais: <, <=, ==, !=, >=, > e convertê-los para os respectivos tokens:*/

/* Números de ponto flutuante (números reais): este analisador léxico deve ser capaz de
* reconhecer números reais quaisquer e convertê-los para os respectivos tokens: 
*/

/* Remoção de espaços em branco e comentários: este analisador léxico deve ser capaz
* de reconhecer espaços em branco e comentários no código fonte e removê-los
* (ignorá-los) .
*/

/* Strings:este analisador léxico deve ser capaz de reconhecer os strings e convertê-las
* para seus respectivos tokens:
*/

/* Operadores lógicos: este analisador léxico deve ser capaz de reconhecer os operadores
* lógicos:|| && e convertê-los para os respectivos tokens:
*/

/* Demais caracteres:este analisador léxico deve ser capaz de reconhecer os caracteres:
* = ( ) { } , ; e convertê-los para seus respectivos tokens:
*/



/* TODO:
* 		Armazenar variável com seu ID, quando ela aparecer novamente usar o mesmo ID já criado.
*/

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

\ "*"\ ?\(?{ID}\)?						{printf("[pointer_value, %s]", yytext);}

^\*\ ?\(?{ID}\)?						{printf("[pointer_value, %s]", yytext);}

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
	        										//printf("\n name[scope][k] --> '%s' \n", name[scope][k]);
	        										printf("[id, %d]", id[scope][k]);
	        										break;
												}
											}
										}

{TYPE}\ *?.*\,?\ ?{ID}			{	for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
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
	    													//printf("\n strComma Antes --> '%s'\n", strComma);
	    													lenYytext = strlen(str);
	    													//printf("\n lenYytext --> '%d'\n", lenYytext);
	    													ptr = strtok(strComma, delimComma);
	    													printPtr =  malloc(strlen(ptr)+1);
	    													strcpy(printPtr, ptr);
	    													for (int i = 0; i < strlen(printPtr); i++) { 
	        													if (printPtr[i] != ' ') {
	        													   //char* printStr =  malloc(strlen(printPtr)+1);
	        													    strncpy(printPtr, printPtr + i, strlen(printPtr));
	            													//printf("\n printPtr Depois --> '%s'\n", printPtr);
	            													currentId++;
	            													k++;
	            													id[scope][k] = currentId;
	            													name[scope][k] = printPtr;
	            													//printf("\n name[scope][k] --> '%s' \n", name[scope][k]);
	            													printf("[id, %d]", id[scope][k]);
	            													break;
	        													}
													        }
	    													//currentId++;
	    													//k++;
														    //id[scope][k] = currentId;
	    													//name[scope][k] = printPtr;
	    													//printf("[id, %d]", id[scope][k]);
	    													//printf("[printPtr, %s]", printPtr);
	    													lenPtr = strlen(ptr);
	    													strncpy(strComma, str + (lenPtr + 1), lenYytext);
	    													str =  malloc(strlen(strComma)+1);
	    													strncpy(str, strComma, strlen(strComma));
													    }
													    if (str[0] == ' ') {
	    													for (int i = 0; i < strlen(str); i++) { 
	        													if (str[i] != ' ') {
	        													   //char* printStr =  malloc(strlen(str)+1);
	        													    strncpy(str, str + i, strlen(str));
	            													//printf("\n str Depois --> '%s'\n", str);
	            													currentId++;
	            													k++;
	            													id[scope][k] = currentId;
	            													name[scope][k] = str;
	            													//printf("\n name[scope][k] --> '%s' \n", name[scope][k]);
	            													printf("[id, %d]", id[scope][k]);
	            													break;
														        }
	        												    }
	        											} else {
	        												    currentId++;
	        													k++;
	        													id[scope][k] = currentId;
	        													name[scope][k] = strComma;
	        													//printf("\n name[scope][k] --> '%s' \n", name[scope][k]);
	        													printf("[id, %d]", id[scope][k]);
	        												}
													} else {
													    currentId++;
	        											id[scope][k] = currentId;
	        											name[scope][k] = str;
	        											//printf("\n name[scope][k] --> '%s' \n", name[scope][k]);
	        											printf("[id, %d]", id[scope][k]);
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
                                                    //if (strcmp(str, "") == 0) abort();
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
