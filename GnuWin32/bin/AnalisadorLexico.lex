/* Trabalho 1 - Tradutores --> Analisador Léxico */

/* Nomes: Daniel Lopes Ferreira, Maxwell Frank Barbosa, Vítor Kehl Matter */

%option noyywrap

/* Definitions */
%{ 

#include <math.h>
int id = 0;

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



DIGIT	[0-9]
ID	[a-z][a-z0-9]*

%%

{DIGIT}+ 								{ printf("[num, %d]", atoi(yytext));}

{DIGIT}* 								{ printf("[num-Novamente, %d]", atoi(yytext));}

{DIGIT}"."{DIGIT}* 						{printf("Numero float encontrado: %s (%f)\n", yytext, atof(yytext));}

if|then|begin|procedure|function|int 	{printf("[reserved_word, %s]", yytext);}

{ID} 									{id++;printf("[id, %d]", id);}

"=" 									{printf("Equal_OP, %s]", yytext);}

"+"|"-"|"*"|"/" 						{printf("Operador encontrado: %s\n", yytext);}

"{"[\^{}}\n]*"}"

[ \t\n]+

";" 									{printf("\n");}

	. 									{printf("Caractere nao reconhecido: %s\n", yytext);}

%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
