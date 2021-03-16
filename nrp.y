%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int yylex(void);
void yyerror (char *s);
extern int yylineno;

char *integerIds[100];
char *charIds[100];
char *boolIds[100];

int integerValues[100];
char *charValues[100];

void setIntID(char * variableName);
void setCharID(char * variableName);
void setBoolID(char * variableName);

void setIntValue(char *index, int value);
void setCharValue(char *index, char* value);

int charCounter = 0;
int intCounter = 0;
int boolCounter = 0;

int IntsymbolVal(char* symbol);
char* CharSymbolVal(char* symbol);

int temp;
char tempc[100];

void print(char *ptr);

%}

%union {int number; char id[30];}

%start language 
%token IF THEN ELSE ENDIF
%token WHILE DO ENDWHILE
%token <number> VAL
%token <id> ID
%token <id> STRING
%token START END

%token SET AS
%token ASSIGNOPERATOR
%token EXITCOMMAND
%token OUTPUT
%token OUTPUTC
%token COMMENT
%token INPUT
%token INPUTC

%token INTEGER
%token CHARACTER
%token BOOLEAN
%token AND
%token OR
%token EQUAL

%type <number> arthm
%type <number> precedence
%type <id> character characterOut

%right SUM MINUS
%left MULTI DIVISION

%%

language:
	START block END ;

block:
	line
	| line block
	| COMMENT
	| COMMENT block
	| EXITCOMMAND ';' {printf("Program terminated\n");exit(EXIT_SUCCESS);}
;

line:
	stmt ';' ;

stmt:
	%empty	
	| asgn
	| defn
	| IF '(' opr ')' THEN block ENDIF
	| IF '(' opr ')' THEN block ELSE block ENDIF
	| WHILE '(' opr ')' DO block ENDWHILE
	| OUTPUT	arthm		{printf("%d",$2);}
	| OUTPUTC character 	{print($2);}
	| OUTPUTC characterOut 	{print($2);}
	| INPUT ID				{scanf("%d",&temp);setIntValue($2,temp);}
	| INPUTC ID				{scanf("%s",tempc);setCharValue($2,tempc);}
;

opr:
	 arthm
    | logical
;

asgn:
	ID ASSIGNOPERATOR arthm		{ setIntValue($1,$3); }
	| ID ASSIGNOPERATOR character		{setCharValue($1,$3);}
	
;

character:
	 STRING			{strcpy($$,$1);}
;

characterOut:
	ID				{strcpy($$,CharSymbolVal($1));}
;

logical: 
	  VAL cmpop VAL
	| ID cmpop ID
	| ID cmpop VAL
	| VAL cmpop ID
	| logical lgcop VAL
	| logical lgcop ID
	| ID lgcop ID
	| ID lgcop VAL
	| VAL lgcop VAL
	| VAL lgcop ID
;	
cmpop: '>' | EQUAL | '<';

lgcop: OR | AND ;

arthm:
	 arthm '+' precedence          {$$ = $1 + $3;}
	| arthm '-' precedence          {$$ = $1 - $3;}
	| precedence			{$$ = $1;}
;

precedence:
	VAL		{$$ = $1;}
	| ID		{$$ = IntsymbolVal($1);}
	| precedence '*' VAL          {$$ = $1 * $3;}
	| precedence '/' VAL          {if($3 != 0){$$ = $1 / $3;}else{yyerror("0 can't be divisor");exit(EXIT_SUCCESS);}}
	| precedence '*' ID          {$$ = $1 * IntsymbolVal($3);}
	| precedence '/' ID          {if(IntsymbolVal($3) != 0){$$ = $1 / IntsymbolVal($3);}else{yyerror("0 can't be divisor");exit(EXIT_SUCCESS);}}

;

defn:
	SET ID AS INTEGER	    {setIntID($2);}
	| SET ID AS CHARACTER	{setCharID($2);}
	| SET ID AS BOOLEAN 	{setBoolID($2);}
;

%%
//*****************************************************************************************************
void print(char *ptr){
	
	if(ptr[1] == '\\' && ptr[2] == 'n'){printf("\n");return;}
	for(int i = 0;i<strlen(ptr);i++){
		if(ptr[i] != '"' && ptr[i] != '\'')
			printf("%c",ptr[i]);
	}
}

void setIntID(char * variableName){
	char error[100] = "error : ";
	strcat(error,variableName); strcat(error," has alread been declared as integer");
	int i;
	for(i = 0;i<intCounter;i++){
		if(strcmp(integerIds[i],variableName) == 0){yyerror(error);exit(EXIT_SUCCESS);}
	}
	
	char error1[100] = "error : ";
	strcat(error1,variableName); strcat(error1," has alread been declared as character");
	i = 0;
	for(i = 0;i<charCounter;i++){
		if(strcmp(charIds[i],variableName) == 0){yyerror(error1);exit(EXIT_SUCCESS);}
	}

	char error2[100] = "error : ";
	strcat(error2,variableName); strcat(error2," has alread been declared as boolean");
	i = 0;
	for(i = 0;i<boolCounter;i++){
		if(strcmp(boolIds[i],variableName) == 0){yyerror(error2);exit(EXIT_SUCCESS);}
	}


	integerIds[intCounter] = (char*)malloc(sizeof(char) * strlen(variableName));
	strcpy(integerIds[intCounter],variableName);
	intCounter++;
}

void setCharID(char * variableName){
	char error[100] = "error : ";
	strcat(error,variableName); strcat(error," has alread been declared as integer");
	int i;
	for(i = 0;i<intCounter;i++){
		if(strcmp(integerIds[i],variableName) == 0){yyerror(error);exit(EXIT_SUCCESS);}
	}

	char error1[100] = "error : ";
	strcat(error1,variableName); strcat(error1," has alread been declared as character");
	i = 0;
	for(i = 0;i<charCounter;i++){
		if(strcmp(charIds[i],variableName) == 0){yyerror(error1);exit(EXIT_SUCCESS);}
	}

	char error2[100] = "error : ";
	strcat(error2,variableName); strcat(error2," has alread been declared as boolean");
	i = 0;
	for(i = 0;i<boolCounter;i++){
		if(strcmp(boolIds[i],variableName) == 0){yyerror(error2);exit(EXIT_SUCCESS);}
	}

	charIds[charCounter] = (char*)malloc(sizeof(char) * strlen(variableName));
	strcpy(charIds[charCounter],variableName);
	charCounter++;
}

void setBoolID(char * variableName){
	/*char error[100] = "error : ";
	strcat(error,variableName); strcat(error," has alread been declared as integer");
	int i;
	for(i = 0;i<intCounter;i++){
		if(strcmp(integerIds[i],variableName) == 0){yyerror(error);exit(EXIT_SUCCESS);}
	}

	char error1[100] = "error : ";
	strcat(error1,variableName); strcat(error1," has alread been declared as character");
	i = 0;
	for(i = 0;i<charCounter;i++){
		if(strcmp(charIds[i],variableName) == 0){yyerror(error1);exit(EXIT_SUCCESS);}
	}


	char error2[100] = "error : ";
	strcat(error2,variableName); strcat(error2," has alread been declared as boolean");
	i = 0;
	for(i = 0;i<boolCounter;i++){
		if(strcmp(boolIds[i],variableName) == 0){yyerror(error2);exit(EXIT_SUCCESS);}
	}*/
	
	integerIds[intCounter] = (char*)malloc(sizeof(char) * strlen(variableName));
	strcpy(integerIds[intCounter],variableName);
	intCounter++;
}

void setIntValue(char *index, int value){
	int i = 0;
	char error[100] = "error : ";
	strcat(error,index);  strcat(error,"  ");  strcat(error,"Not declared");
	
	for(i = 0;i<boolCounter;i++){
		if(boolIds[i] == "\0")	{break;}
		if(strcmp(boolIds[i],index) == 0) {
			return;
		}
	}	

	for(i = 0;i<100;i++){
		if(integerIds[i] == "\0")	{yyerror(error);exit(EXIT_SUCCESS);}
		if(strcmp(integerIds[i],index) == 0) {
			integerValues[i] = value;
			break;
		}
	}
	
	if(i == 100)	yyerror(error);
}

void setCharValue(char *index, char* value){
	int i = 0;
	char error[100] = "error : ";
	strcat(error,index);  strcat(error,"  ");  strcat(error,"Not declared");

	for(i = 0;i<100;i++){//printf("%d\t",i);
		if(charIds[i] == "\0")	{yyerror(error);exit(EXIT_SUCCESS);}
		if(strcmp(charIds[i],index) == 0) {
			charValues[i] = "\0";
			charValues[i] = (char*)malloc(sizeof(char) * strlen(value));
			strcpy(charValues[i],value);
			break;
		}
	}
	if(i == 100)	yyerror(error);
}

int IntsymbolVal(char* symbol){
	int i = 0;
	char error1[100];	strcpy(error1,symbol);	strcat(error1," is not integer, is a character");
	for(i = 0;i<charCounter;i++){
		if(strcmp(symbol,charIds[i]) == 0){yyerror(error1);exit(EXIT_SUCCESS);}
	}

	char error2[100];	strcpy(error2,symbol);	strcat(error2," is not integer, is a boolean");
	for(i = 0;i<boolCounter;i++){
		if(strcmp(symbol,boolIds[i]) == 0){yyerror(error2);exit(EXIT_SUCCESS);}
	}

	char error[100] = "error : ";
	strcat(error,symbol);  strcat(error,"  ");  strcat(error,"Not declared");

	for(i = 0;i<100;i++){//printf("%d\t",i);
		if(integerIds[i] == "\0") 	{yyerror(error);exit(EXIT_SUCCESS);}
		if(strcmp(integerIds[i],symbol) == 0)
			return integerValues[i];
	}
	if(i == 100)		yyerror(error);
}

char* CharSymbolVal(char* symbol){
	int i = 0;

	char error1[100];	strcpy(error1,symbol);	strcat(error1," is not integer, is a integer");
	for(i = 0;i<intCounter;i++){
		if(strcmp(symbol,integerIds[i]) == 0){yyerror(error1);exit(EXIT_SUCCESS);}
	}

	char error2[100];	strcpy(error2,symbol);	strcat(error2," is not integer, is a boolean");
	for(i = 0;i<boolCounter;i++){
		if(boolIds[i] == "\0")	break;
		if(strcmp(symbol,boolIds[i]) == 0){yyerror(error2);exit(EXIT_SUCCESS);}
	}
	
	char error[100] = "error : ";
	strcat(error,symbol);  strcat(error,"  ");  strcat(error,"Not declared");

	for(i = 0;i<100;i++){//printf("%d\t",i);
		if(charIds[i] == "\0") 	{yyerror(error);exit(EXIT_SUCCESS);}
		if(strcmp(charIds[i],symbol) == 0)
			return charValues[i];
	}
	if(i == 100)		yyerror(error);
}

//****************************************************************************************************

int main(void) {
	int i;
	for(i=0; i<100; i++) {
		integerValues[i] = 0;
		charValues[i] = "\0";
		integerIds[i] = "\0";
		charIds[i] = "\0";
	}
    yyparse();
	printf("No error\n");
	return 0;
}
