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
%token EQ NE LT LE GT GE REF AND OR NOT PLUS MINUS MULT DIVIDE RPAREN BEG LPAREN RCURL LCURL RSQ LSQ ASSIGN SEMICOLON COMMA ID NUMBER YETTOIMP
%token INTEGER BOOLEAN DECL ENDDECL END IF THEN ELSE ENDIF WHILE
%token DO ENDWHILE RETURN READ WRITE

%%

Program:VarDecl MainFunDef  {printf ("Parsed the program with main\n");}
;

MainFunDef: INTEGER ID LPAREN RPAREN LCURL VarDecl BEG Statements END RCURL
;


VarDecl:
    |    DECL INTEGER Variable SEMICOLON ENDDECL
    |    DECL BOOLEAN Variable SEMICOLON ENDDECL
    |	 DECL VarDecl SEMICOLON VarDecl ENDDECL
;

Variable: ID COMMA Variable
    |     ID
    |     ID LSQ Expresion RSQ
;

Statements: 
    |	    AssignmentStatement
    |       ConditionalStatement
    |       IterativeStatement
    |       ReturnStatement
    |       IOStatements
;

AssignmentStatement: ID ASSIGN Expresion SEMICOLON Statements
;

ConditionalStatement: IF LogicalExpresion THEN Statements  ENDIF SEMICOLON Statements
    |                 IF LogicalExpresion THEN  Statements  ELSE  Statements  ENDIF SEMICOLON Statements
;

IterativeStatement: WHILE LogicalExpresion DO  Statements  ENDWHILE SEMICOLON Statements
;

ReturnStatement: RETURN Expresion SEMICOLON Statements
;

IOStatements: READ LPAREN ID RPAREN SEMICOLON Statements
     |        WRITE LPAREN Expresion RPAREN SEMICOLON Statements
;

Expresion:
     expr2 
     | LogicalExpresion
;

LogicalExpresion: LPAREN RelationalExpresion AND RelationalExpresion RPAREN
   | LPAREN RelationalExpresion OR RelationalExpresion RPAREN 
   | LPAREN NOT RelationalExpresion RPAREN
   | LPAREN RelationalExpresion RPAREN
;


RelationalExpresion: expr2 EQ expr2 
   | expr2 NE expr2 
   | expr2 LT expr2 
   | expr2 LE expr2 
   | expr2 GT expr2 
   | expr2 GE expr2
;

expr2:
     expr3 
   | expr2 PLUS expr3 
   | expr2 MINUS expr3 
;

expr3:
     expr4 
   | expr3 MULT expr4 
   | expr3 DIVIDE expr4 
;

expr4:
     PLUS expr4 
   | MINUS expr4 
   | LPAREN Expresion RPAREN 
   | NUMBER 
   | ID
   | ID LSQ expr2 RSQ
;


%%
void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
}
int main(void) {
yyparse();
return 0;
}
