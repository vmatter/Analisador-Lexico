/* Trabalho 1 - Tradutores --> Analisador Léxico */

/* Nomes: Daniel Lopes Ferreira, Maxwell Frank Barbosa, Vítor Kehl Matter */

%option noyywrap

/* Definitions */
%{ 

#include <math.h>
int currentId = 0;
char* name[10][10] = {NULL};
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
											 name[scope][i] = NULL;
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

{ID} 									{ printf("\n yytext -->  %s \n", yytext);
										  printf("\n scope --> %d \n", scope);
											int existId = 0;
											for(int i = scope; i >= 0; i--) {
												if(existId == 1) {
													break;
												}
												for(int j = 0; j < sizeof name[i] / sizeof name[i][0]; j++){
													printf("\n '%s' ==  '%s' \n",yytext, name[i][j]);
													if (yytext == name[i][j]) {
														printf("Entrou aqui?");
														printf("[id, %d]", id[i][j]);
														existId = 1;
														break;
													}
												}
											}
											if (existId == 0){
												for(int k = 0; k < sizeof name[scope] / sizeof name[scope][0]; k++){
													if (name[scope][k] == NULL) {
														currentId++;
														id[scope][k] = currentId;
														// TODO: Revisar a atribuicao do yytext.
														name[scope][k] = yytext;
														printf("\n name[scope][k] --> %s \n", name[scope][k]);
														printf("[id, %d]", id[scope][k]);
														break;
													}
												}
											}
										}

"+"|"-"|"*"|"/" 						{printf("[Arith_Op, %s]", yytext);}

"<"|"<="|"=="|"!="|">="|">" 			{printf("[Relational_Op, %s]", yytext);}

"=" 									{printf("[Equal_OP, %s]", yytext);}

"("|")"|"{"|"}"							{{printf("[Simbolo, %s]", yytext);}}

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
