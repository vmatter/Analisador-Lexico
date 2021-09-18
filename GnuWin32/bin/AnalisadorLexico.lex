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
ID				[a-z][a-z0-9]*
FUNCTION 		[a-z|A-Z]* ?\(.*\)
STRING			\".*\"
COMMENT			\/\/.*
RESERVED		while|if|else|switch|for|return|null|int|float|double|String|bool|break|case|void|#include|printf|getch|scanf
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

\<.+\>									{printf("[include, %s]", yytext);}

\ "*"\ ?\(?{ID}\)?						{printf("[pointer_value, %s]", yytext);}

^\*\ ?\(?{ID}\)?						{printf("[pointer_value, %s]", yytext);}

{DIGIT}*"."{DIGIT}* 					{printf("[num, %.2f]", atof(yytext));}

{DIGIT}+ 								{printf("[num, %d]", atoi(yytext));}

{RESERVED}\ ?"*"\ ?{ID}					{printf("[pointer_declaration, %s]", yytext);}

{RESERVED}								{printf("[reserved_word, %s]", yytext);}

{RESERVED}\ ?{ID}						{	for (int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
												if (strcmp(name[scope][k], "") == 0) {
													currentId++;
													id[scope][k] = currentId;
													char delim[] = " ";
													char* str =  malloc(strlen(yytext)+1);
													strcpy(str, yytext);
													int lenYytext = strlen(yytext);
													char* ptr = strtok(str, delim);
													char* printPtr =  malloc(strlen(ptr)+1);
													strcpy(printPtr, ptr);
													int lenPtr = strlen(ptr);
													strncpy(str, yytext + (lenPtr + 1), lenYytext);
													name[scope][k] = str;
													printf("[reserved_word, %s][id, %d]", printPtr, id[scope][k]);
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

"+"|"-"|"*"|"/" 						{printf("[Arith_Op, %s]", yytext);}

"<"|"<="|"=="|"!="|">="|">" 			{printf("[Relational_Op, %s]", yytext);}

"=" 									{printf("[Equal_OP, %s]", yytext);}

"("|"{"									{{printf("[Simbolo, %s]", yytext);}}

")"|"}"									{{printf("[Simbolo, %s]\n", yytext);}}

{STRING}								{{printf("[string_literal, %s]", yytext);}}

";" 									{printf("\n");}

[ \t\n]+

.	 									{printf("Caractere nao reconhecido: %s\n", yytext);}

%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
