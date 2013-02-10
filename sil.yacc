%{
#include <stdio.h>
int yylex(void);
void yyerror(char *);
	struct Node{

	char *str;
	struct Node *next1;
	struct Node *next2;
	struct Node *next3;
	};

	struct Node * makenode(char *str, struct Node *next1,struct Node *next2, struct Node *next3);
	void printtree(struct Node * ptr);
%}
%token <ptr> EQ NE LT LE GT GE REF MAIN AND OR NOT PLUS MINUS MULT DIVIDE RPAREN BEG LPAREN RCURL LCURL RSQ LSQ ASSIGN SEMICOLON COMMA ID NUMBER 
%token <ptr> INTEGER BOOLEAN DECL ENDDECL END IF THEN ELSE ENDIF WHILE
%token <ptr> DO ENDWHILE RETURN READ WRITE

%type <ptr> Program MainFunDef VarDecl Variable Statement Statements AssignmentStatement ConditionalStatement IterativeStatement ReturnStatement IOStatements Expresion LogicalExpresion RelationalExpresion expr2 expr3 expr4

%union {
	struct Node *ptr;
};


%%

Program:VarDecl MainFunDef  {printf ("Parsed the program with main\n");}
;

MainFunDef: INTEGER MAIN LPAREN RPAREN LCURL VarDecl BEG Statements END RCURL {$$=makenode("MAIN", $6, $8, NULL); printtree($$);}
;


VarDecl:
    |    DECL INTEGER Variable SEMICOLON ENDDECL {$$=makenode("DECL", $3, NULL, NULL);}
    |    DECL BOOLEAN Variable SEMICOLON ENDDECL {$$=makenode("DECL", $3, NULL, NULL);}
    |	 DECL VarDecl SEMICOLON VarDecl ENDDECL  {$$=makenode("DECL", $3, $5, NULL);}
;

Variable: ID COMMA Variable {$$=makenode("VAR", $3, NULL, NULL);}
    |     ID	
    |     ID LSQ Expresion RSQ {$$=makenode("ARRAY", $3, NULL, NULL);}
;


Statements : Statement SEMICOLON Statements {$$=makenode(NULL, $1, $3, NULL);}				
	   |				     {$$=NULL;}	
;							
Statement: 
    |	    AssignmentStatement
    |       ConditionalStatement
    |       IterativeStatement
    |       ReturnStatement
    |       IOStatements
;

AssignmentStatement: ID ASSIGN Expresion {$$=makenode("ASGN", $3,NULL, NULL);}
;

ConditionalStatement: IF LogicalExpresion THEN Statements  ENDIF {$$=makenode("IF", $2,$4, NULL);}
    |                 IF LogicalExpresion THEN Statements  ELSE  Statements  ENDIF {$$=makenode("IFELSE", $2,$4,$5);}
;

IterativeStatement: WHILE LogicalExpresion DO  Statements  ENDWHILE {$$=makenode("WHILE", $2,$4,NULL);}
;

ReturnStatement: RETURN Expresion {$$=makenode("RET", $2,NULL,NULL);}
;

IOStatements: READ LPAREN ID RPAREN {$$=makenode("READ", $3,NULL,NULL);}
     |        WRITE LPAREN Expresion RPAREN {$$=makenode("WRITE", $3,NULL,NULL);}
;

Expresion:
     expr2 {$$=$1;}
     | LogicalExpresion {$$=makenode(NULL, $1,NULL,NULL);}
;

LogicalExpresion: LPAREN RelationalExpresion AND RelationalExpresion RPAREN {$$=makenode("AND", $2,$4,NULL);}
   | LPAREN RelationalExpresion OR RelationalExpresion RPAREN {$$=makenode("OR", $2,$4,NULL);}
   | LPAREN NOT RelationalExpresion RPAREN {$$=makenode("NOT", $3,NULL,NULL);}
   | LPAREN RelationalExpresion RPAREN {$$=$2;}
;


RelationalExpresion: expr2 EQ expr2 {$$=makenode("EQ", $1,$3,NULL);}
   | expr2 NE expr2 {$$=makenode("NE", $1,$3,NULL);}
   | expr2 LT expr2 {$$=makenode("LT", $1,$3,NULL);}
   | expr2 LE expr2 {$$=makenode("LE", $1,$3,NULL);}
   | expr2 GT expr2 {$$=makenode("GT", $1,$3,NULL);}
   | expr2 GE expr2 {$$=makenode("GE", $1,$3,NULL);}
;

expr2:
     expr3 {$$=$1;}
   | expr2 PLUS expr3 {$$=makenode("PL", $1,$3,NULL);}
   | expr2 MINUS expr3 {$$=makenode("MI", $1,$3,NULL);} 
;

expr3:
     expr4 {$$=$1;}
   | expr3 MULT expr4 {$$=makenode("MU", $1,$3,NULL);}
   | expr3 DIVIDE expr4 {$$=makenode("DI", $1,$3,NULL);}
;

expr4:
     PLUS expr4 {$$=$2;}
   | MINUS expr4 {$$=$2;}
   | LPAREN Expresion RPAREN {$$=$2;}
   | NUMBER 
   | ID
   | ID LSQ expr2 RSQ {$$=makenode(NULL, $3,NULL,NULL);}
;


%%
void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
}
int main(void) {
yyparse();
return 0;
}

struct Node * makenode(char *str, struct Node *next1,struct Node *next2, struct Node *next3)
{
	struct Node *node = malloc(sizeof(struct Node));
	node->str=str;
	node->next1=next1;
	node->next2=next2;
	node->next3=next3;
	return node;
}

void printtree(struct Node * ptr)
{

	if(ptr==NULL)
		return;
	if(ptr->str!=NULL)
		printf(" ( ");
	if(ptr->str!=NULL)
		printf("%s", ptr->str);
	printtree(ptr->next1);
	printtree(ptr->next2);
	printtree(ptr->next3);
	if(ptr->str!=NULL)
		printf(" ) ");
}
	

