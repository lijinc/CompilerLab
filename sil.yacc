%{
#include <stdio.h>
#define VOID 0
#define INTEG 1
#define BOOL 2
#define r 'R'
#define w 'W'
#define con 'c'
#define var 'v'
#define gt 'g'
#define lt 'l'
#define ge 'G'
#define le 'L'
#define eq 'E'
#define ne 'N'
int yylex(void);
extern int yylineno;
struct Gsymbol {
	char* NAME; 		
	int TYPE; 		
	int SIZE; 		
	int *VALUE; 		
	int BINDING;		
	struct Gsymbol *NEXT;	
}*Ghead;

struct Gsymbol* Glookup(char* NAME);	 

void Ginstall(char* NAME, int TYPE, int SIZE); // Installation
struct Lsymbol {
	char *NAME; 		
	int TYPE; 		
	int *VALUE; 		
	int BINDING;		
	struct Lsymbol *NEXT;	
}*Lhead;
struct node* makeTree(char* NAME, struct node* P1,struct node* P2, struct node* P3);
void printTree(struct node* ptr);
struct Lsymbol *Llookup(char* NAME);
void Linstall(char* NAME, int TYPE);
void printSymTable();
int memcount = 0;
int typeval=0;  
char* typ[]={"VOID","INTEGER","BOOLEAN"};
%}


%token <n> EQ NE LT LE GT GE REF MAIN AND OR NOT PLUS MINUS MULT DIVIDE RPAREN BEG LPAREN RCURL LCURL RSQ LSQ ASSIGN SEMICOLON  COLON COMMA ID NUMBER 
%token <n> INTEGER BOOLEAN BNUM DECL ENDDECL END SWITCH CASE IF THEN ELSE ENDIF WHILE
%token <n> DO ENDWHILE RETURN READ WRITE

%type <n> Program MainFunDef GDefblock GDeflist GDecl GIdlist GId LDefblock LDeflist LDecl LIdlist LId Type Statement Statements AssignmentStatement ConditionalStatement SwitchStatement SwitchBody Constant SwStatement IterativeStatement ReturnStatement IOStatements Expresion LogicalExpresion RelationalExpresion expr2 expr3 expr4
%union {

	struct node{
	  	int TYPE; 
		char NODETYPE;
	 	char* NAME; 
		int VALUE;
		struct node *ARGLIST; 
		struct node *P1, *P2, *P3; 
		struct Gsymbol *GENTRY;
		struct Lsymbol *LENTRY; 
        }*n;
};


%%

Program:GDefblock MainFunDef  
;

MainFunDef: INTEGER MAIN LPAREN RPAREN LCURL LDefblock BEG Statements END RCURL {
											
											$$=makeTree("MAIN", NULL, $8, NULL); 
											printTree($$);
										}
;

GDefblock:
| DECL GDeflist ENDDECL	
;

GDeflist: GDecl				
   | GDeflist GDecl			
;

GDecl: Type GIdlist SEMICOLON 		
;

GIdlist: GIdlist COMMA GId
  | GId
;


GId: ID	{Ginstall($1->NAME, typeval, 1);}
  |     ID LSQ NUMBER RSQ {Ginstall($1->NAME, typeval,$3->VALUE); }
;

LDefblock:
| DECL LDeflist ENDDECL	
;

LDeflist: LDecl			
   | LDeflist LDecl			
;

LDecl: Type LIdlist SEMICOLON 		
;

LIdlist: LIdlist COMMA LId
  | LId
;


LId: ID	{Linstall($1->NAME, typeval);}
  |     ID LSQ NUMBER RSQ {Linstall($1->NAME, typeval); }
;


Type: INTEGER {typeval=INTEG;}
    | BOOLEAN {typeval=BOOL;}
;


Statements : Statement SEMICOLON Statements 	{$$=makeTree(NULL, $1, $3, NULL);}		
	   |				     {$$=NULL;}
;							
Statement:  	
    |	    AssignmentStatement 
    |       ConditionalStatement
    |       IterativeStatement
    |       ReturnStatement
    |       IOStatements
    |       SwitchStatement
;

SwitchStatement: SWITCH Expresion LCURL SwitchBody RCURL {$$=makeTree("SWITCH", $2,$4, NULL);}
;

SwitchBody: SwStatement SEMICOLON SwitchBody {$$=makeTree(NULL, $1,$3, NULL);} 
    |		{$$=NULL;}
;

SwStatement: CASE Constant COLON AssignmentStatement {$$=makeTree("CASE", $2,$4, NULL);}
    |  {$$=NULL;}
;

Constant:ID
    |  	 NUMBER
;


AssignmentStatement: ID ASSIGN Expresion {
						struct Lsymbol* temp = Llookup($1->NAME);
						if(temp==NULL){
							struct Gsymbol* gtemp = Glookup($1->NAME);
							if(gtemp==NULL||gtemp->SIZE!=1){
								yyerror("Undefined Var..");
							}
							else{
							     	 $1->GENTRY = gtemp;
							     	 $1->TYPE = gtemp->TYPE;
							    }	
						}
						else{
							 $1->LENTRY = temp;
							 $1->TYPE = temp->TYPE;
						}
						if($1->TYPE == $3->TYPE) 
							$$=makeTree("ASGN", $1,$3, NULL);
						else{ 
							  yyerror("Type mismatch");
					  	}

					  }
;

ConditionalStatement: IF LogicalExpresion THEN Statements  ENDIF {$$=makeTree("IF", $2,$4, NULL);}
    |                 IF LogicalExpresion THEN Statements  ELSE  Statements  ENDIF {$$=makeTree("IFELSE", $2,$4, $6);}
;

IterativeStatement: WHILE LogicalExpresion DO  Statements  ENDWHILE {$$=makeTree("WHILE", $2,$4,NULL);}
;

ReturnStatement: RETURN Expresion {$$=makeTree("RET", $2,NULL,NULL);}	
;

IOStatements: READ LPAREN ID RPAREN 	{ 
						struct Lsymbol *temp = Llookup($3->NAME);
             					if(temp==NULL)
						{ 
							struct Gsymbol *gtemp = Glookup($3->NAME);
							if(gtemp==NULL || gtemp->SIZE!=1)
							{
							       yyerror("Undefined variable");
							}
							else
							{
							       $3->GENTRY = gtemp;
							       $$ = makeTree("READ", $3,NULL,NULL);
						        }
				         	}
						else
						 {
							$3->LENTRY = temp;
							$$ =makeTree("READ", $3,NULL,NULL);
						}
					}
     |        WRITE LPAREN Expresion RPAREN   {$$=makeTree("WRITE", $3,NULL,NULL);}
;


Expresion:
     expr2 {$$=$1;}
     | LogicalExpresion {$$=makeTree(NULL, $1,NULL,NULL);}
;

LogicalExpresion: LPAREN RelationalExpresion AND RelationalExpresion RPAREN {   if( $2->TYPE == $4->TYPE)
						$$=makeTree("AND", $2,$4,NULL);
					else{
						yyerror("Type Mismatch");
					}
					}
   | LPAREN RelationalExpresion OR RelationalExpresion RPAREN {   if( $2->TYPE == $2->TYPE)
						$$=makeTree("OR", $2,$4,NULL);
					else{
						yyerror("Type Mismatch");
					}
					}
   | LPAREN NOT RelationalExpresion RPAREN  {   
						$$=makeTree("NOT", $3,NULL,NULL);
					}
   | LPAREN RelationalExpresion RPAREN {$$=$2;}
;


RelationalExpresion: expr2 EQ expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
						{
						$$=makeTree("EQ", $1,$3,NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
		}
   | expr2 NE expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$=makeTree("NE", $1,$3,NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
		}
   | expr2 LT expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$=makeTree("LT", $1,$3,NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
		}
   | expr2 LE expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$=makeTree("LE", $1,$3,NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
		}
   | expr2 GT expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$=makeTree("GT", $1,$3,NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
		}
   | expr2 GE expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$=makeTree("GE", $1,$3,NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
		}
   | BNUM 	{
   			$$=makeTree("BOOLNUM", NULL,NULL,NULL);
   			$$->TYPE=BOOL;}
 
;

expr2:
     expr3 {$$=$1;}
   | expr2 PLUS expr3  {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
						{$$=makeTree("PL", $1,$3,NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
			}
   | expr2 MINUS expr3  {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
   						{
						$$=makeTree("MI", $1,$3,NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
			}
;

expr3:
     expr4 {$$=$1;}
   | expr3 MULT expr4 {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
   						{
						$$=makeTree("MU", $1,$3,NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
			}
   | expr3 DIVIDE expr4 {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
   						{
						$$=makeTree("DI", $1,$3,NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
			}
;

expr4:
     PLUS expr4 {if( $1->TYPE == $2->TYPE)
     				{
				$$=makeTree("PL", $2,NULL,NULL);
				$$->TYPE=INTEG;}
			else{
				yyerror("Type Mismatch");
			}
		}
   | MINUS expr4 {if( $1->TYPE == $2->TYPE)
        			{
				$$=makeTree("MI", $2,NULL,NULL);
				$$->TYPE=INTEG;}
			else{
				yyerror("Type Mismatch");
			}
		}
  
   | LPAREN Expresion RPAREN {$$=$2;}
   | NUMBER {
   	$$=makeTree("NUMBER", NULL,NULL,NULL);
   	$$->TYPE=INTEG;}
   | ID {	$$=$1;
   		struct Lsymbol* temp = Llookup($$->NAME);
		if(temp==NULL) 
		{
			struct Gsymbol* gtemp = Glookup($$->NAME);
			if(gtemp==NULL) 
				yyerror("Undefined Variable in Expression");
			else
			{
				$$->GENTRY = gtemp;
				$$->TYPE = gtemp->TYPE;
			}
		 }
		 else{ 
		 	$$->LENTRY = temp;
			$$->TYPE = temp->TYPE;
		 }
       }
   		
   | ID LSQ expr2 RSQ { $$=makeTree("ARRAY", $3,NULL,NULL);
   		        struct Gsymbol* gtemp = Glookup($$->NAME);
		        if(gtemp==NULL) 
		        	yyerror("Undefined Variable1");
			else {
				$$->GENTRY = gtemp;
				$$->TYPE = gtemp->TYPE;
			}
   			}
;


%%
void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
exit(0);
}
int main(void) {
yyparse();
printSymTable();
return 0;
}


struct node * makeTree(char *NAME, struct node *P1,struct node *P2, struct node *P3)
{
	struct node *temp = malloc(sizeof(struct node));
	temp->NAME=NAME;
	temp->P1=P1;
	temp->P2=P2;
	temp->P3=P3;
	return temp;
}

void printTree(struct node * ptr)
{
	if(ptr==NULL){
		return;
	}
	if(ptr->NAME!=NULL)
		printf(" [ ");
	if(ptr->NAME!=NULL)
		printf("%s", ptr->NAME);
	printTree(ptr->P1);
	printTree(ptr->P2);
	printTree(ptr->P3);
	if(ptr->NAME!=NULL)
		printf(" ]");
}


void Ginstall(char* NAME, int TYPE, int SIZE)
 {
	   struct Gsymbol* temp = malloc(sizeof(struct Gsymbol));
	   temp->NAME = NAME;
	   temp->TYPE = TYPE;
	   temp->SIZE = SIZE; 
	   temp->VALUE = malloc(sizeof(int)*SIZE);
	   if(SIZE!=0)
	   {	   temp->BINDING = memcount;
		   memcount = memcount+SIZE;
	   }
	   temp->NEXT = Ghead;
	   Ghead = temp;
 }
void Linstall(char* NAME, int TYPE)
 {
	   struct Lsymbol* temp = malloc(sizeof(struct Lsymbol));
	   temp->NAME = NAME;
	   temp->TYPE = TYPE;
	   temp->VALUE = malloc(sizeof(int));
	   temp->BINDING = memcount;
	   memcount++;
	   temp->NEXT = Lhead;
	   Lhead = temp;
 }
 
struct Gsymbol* Glookup(char* NAME)
 {
	   struct Gsymbol* temp;
	   temp = Ghead;
	   while(temp != NULL)
	    {
	      if(strcmp(temp->NAME, NAME) == 0)
		 return temp;
	      else
		 temp = temp->NEXT;
	     }
	   return NULL;  
 }

struct Lsymbol* Llookup(char* NAME)
 {
	   struct Lsymbol* temp;
	   temp = Lhead;
	   while(temp != NULL)
	    {
	      if(strcmp(temp->NAME, NAME)==0)
		 return temp;
	      else
		 temp = temp->NEXT;
	     }
	   return NULL;  
 }


void printSymTable(){
	printf("\n\nGlobal Symbol Table\n");
	printf("-----------------------------------------\n");
	struct Gsymbol* tempg=Ghead;
	while(tempg!=NULL){
		printf(tempg->NAME);
		printf("->");
		printf(typ[(int)tempg->TYPE]);
		printf("->");
		printf("%d",tempg->VALUE);
		printf("->");
		printf("%d",tempg->BINDING);
		printf("\n");
		tempg=tempg->NEXT;
	}
	printf("\nLocal Symbol Table\n");
printf("-----------------------------------------\n");
	struct Lsymbol* templ=Lhead;
	while(templ!=NULL){
		printf(templ->NAME);
		printf("->");
		printf(typ[(int)templ->TYPE]);
		printf("->");
		printf("%d",templ->BINDING);
		printf("\n");
		templ=templ->NEXT;
	}
	printf("-----------------------------------------\n");		
}


		
