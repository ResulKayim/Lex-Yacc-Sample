%{
	#include <stdlib.h>
	#include <string.h>
 	#include "y.tab.h"
	void extern yyerror(char*);
    void InvalidToken();
%}

letter 	[a-zA-Z]
digit 	[0-9]
alfa 	[a-zA-Z0-9]
whitesp [ \t]

%%

"//".*\n 								{yylineno++;return COMMENT;}
\"(\\.|[^"])*\"						{strcpy(yylval.id,yytext);return STRING;};
\'(\\.|[^"])\'						{strcpy(yylval.id,yytext);return STRING;};

"start"						return START;
"end"							return END;

"||"						return OR;
"&&"							return AND;
"=="						return EQUAL;

"output"								return OUTPUT; // print integer
"outputc"							return OUTPUTC;		//print character 
"exit"						return EXITCOMMAND;		// terminate program
"input"								return INPUT;
"inputc"						return INPUTC;
"if"									return IF;		// if statement
"then"								return THEN;		// then
"else"							return ELSE;			// else statement
"endIf"								return ENDIF;		// end of if statement
"while"							return WHILE;			// while loop 
"do"								return DO;			// do
"endWhile"						return ENDWHILE;		// end of while
"set"								return SET;			// assignment of type decleation 
"as"							return AS;				// specify type
"integer"							return INTEGER;		// Integer
"character"						return CHARACTER;		// Character
"boolean"							return BOOLEAN;		// Boolean
"="								return ASSIGNOPERATOR;	// assign operator
[1-9]{digit}* 						{yylval.number = atoi(yytext);return VAL;};		//integer value
0								{yylval.number = 0;return VAL;};		// 0 value of integer
{alfa}+ 							{strcpy(yylval.id,yytext);return ID;};// ID name
[-+/*><=|;&%^)(] 				return *yytext;
{whitesp}+	
.                                   {InvalidToken();}							;
"\n"                      		{yylineno++;}		//line number

%%

void yyerror(char *s) {
    fprintf(stderr, "\n\x1B[31m ERROR ON LINE %d : \n %s\n", yylineno, s);
	exit(1);
}

int yywrap(void){
    return 1;
}

void InvalidToken(){
    printf("\x1B[31mERROR ON LINE %d : \n Invalid Token %s\n", yylineno,yytext);
    exit(0);
}
