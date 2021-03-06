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
#define T 1
#define F 0
#define eq 'E'
#define ne 'N'
#define whileloop 'w'
#define ifelse 'i'
int regcount = 0;
int ifcount = 0;
int tcount=0;
int whilecount = 0;
int lbcount = 0;

struct istack
{
 	int value;
 	struct istack *next;
}*itop;

struct wstack{
 	int value;
 	struct wstack *next;
}*wtop;


void ipush(int count)
{
 	struct istack *temp = malloc(sizeof(struct istack));
 	temp->value = count;
 	temp->next = itop;
 	itop = temp;
 }

int ipop()
{
  	struct istack *temp = itop;
  	int res = temp->value;
  	itop = itop->next;
  	free(temp);
  	return res; 
}

void wpush(int count)
{
 	struct wstack *temp = malloc(sizeof(struct wstack));
 	temp->value = count;
 	temp->next = wtop;
 	wtop = temp;
 }

int wpop()
{
 	struct wstack *temp = wtop;
  	int res = temp->value;
  	wtop = wtop->next;
  	free(temp);
  	return res; 
}
struct quad
{
char dest[20],src1[20],src2[20],opr[10];
struct quad *next;

}*qstart,*qcheck;
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
struct node* makeNodeY(int type, char nodetype, char* name, int value);
struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3);
int traverse(struct node* t);
void printTree(struct node* ptr);
struct Lsymbol *Llookup(char* NAME);
void Linstall(char* NAME, int TYPE);
void printSymTable();
int memcount = 0;
int mainflag=0;
int typeval=0; 
int argFlag=0;
char* typ[]={"VOID","INTEGER","BOOLEAN"};
struct node* Thead=NULL;
%}


%token <n> EQ NE LT LE GT GE REF MAIN AND OR NOT PLUS MINUS MULT DIVIDE RPAREN BEG LPAREN RCURL LCURL RSQ LSQ ASSIGN SEMICOLON  COLON COMMA ID NUMBER 
%token <n> INTEGER BOOLEAN BNUM DECL ENDDECL END SWITCH CASE IF THEN ELSE ENDIF WHILE
%token <n> DO ENDWHILE RETURN READ WRITE

%type <n> Program MainFunDef FunDef ArgList ArgID ArgIdlist GDefblock GDeflist GDecl GIdlist GId LDefblock LDeflist LDecl LIdlist LId Type Statement Statements AssignmentStatement ConditionalStatement SwitchStatement SwitchBody Constant SwStatement IterativeStatement ReturnStatement IOStatements Expresion LogicalExpresion RelationalExpresion expr2 expr3 expr4



%union {

	struct node{
	  	int TYPE; 
		char NODETYPE;
	 	char* NAME; 
		int VALUE;
		struct node *ARGLIST; 
		struct node *P1, *P2, *P3;
		struct quad *qd; 
		int dtemp;
		struct Gsymbol *GENTRY;
		struct Lsymbol *LENTRY; 
        }*n;
};


%%

Program:GDefblock GDecl MainFunDef  
;

FunDef: ID LPAREN ArgList RPAREN LCURL LDefblock BEG Statements END RCURL {
										makeSymbolTable(ID->NAME);
						                          }
	|
;



MainFunDef: INTEGER MAIN LPAREN RPAREN LCURL LDefblock BEG Statements END RCURL {  	FILE *fp;
											fp = fopen("sim.asm","a");
											fprintf(fp,"main: \n");
											fprintf(fp,"PUSH BP\n");
											fprintf(fp,"MOV BP,SP\n");
											int i=1;
											fclose(fp);
											mainflag=1;
											memcount=1;
										}
;

GDefblock:
| DECL GDeflist ENDDECL	{
				FILE *fp;
				/*fp = fopen("sim.asm","a");
				int i=0;
				/*for(i=0;i<memcount;i++)
					fprintf(fp,"PUSH R%d\n",regcount);
				fclose(fp);*/		
				argFlag=1;				
				memcount = 1;	
				fp=fopen("sim.asm","a");
				fprintf(fp,"JMP main\n");
				fclose(fp);		
			}
;

GDeflist: GDecl				
   | GDeflist GDecl			
;


GDecl: Type GIdlist SEMICOLON {if(argFlag==1){
					yyerror("syntax error");				
				}
			      }
	|Type FunDef
;

GIdlist: GIdlist COMMA GId
  | GId
;


GId: ID	{Ginstall($1->NAME, typeval, 1);}
  |     ID LSQ NUMBER RSQ {Ginstall($1->NAME, typeval,$3->VALUE); }
  |  ID LPAREN ArgList RPAREN 
;

ArgList: ArgIdlist
	|
;

ArgIdlist: ArgIdlist COMMA ArgID
  | ArgID
;

ArgID: Type ID
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


Statements : Statement SEMICOLON Statements 	{		struct node* temp = malloc(sizeof(struct node));
								temp = makeNodeY(VOID, 's',NULL, 0);
								$$ = makeTree(temp, $1, $3, NULL);
								$$->dtemp=1;}		
	   |				     {$$=NULL;}
;							
Statement:  	
    |	    AssignmentStatement {$$=$1;}
    |       ConditionalStatement {$$=$1;}
    |       IterativeStatement {$$=$1;}
    |       ReturnStatement {$$=$1;}
    |       IOStatements {$$=$1;}
    |       SwitchStatement {$$=$1;}
;

SwitchStatement: SWITCH Expresion LCURL SwitchBody RCURL {}
;

SwitchBody: SwStatement SEMICOLON SwitchBody {} 
    |		{}
;

SwStatement: CASE Constant COLON AssignmentStatement {}
    |  {}
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
							$$ = makeTree($2, $1, NULL, $3);
						else{ 
							  yyerror("Type mismatch");
					  	}
						$$->dtemp=1;
					  }
;

ConditionalStatement: IF LogicalExpresion THEN Statements  ENDIF { 
									$$ = makeNodeY(VOID, 'i', NULL, 0);
	                						$$ = makeTree($$, $2, $4, NULL);
	                						$$->dtemp=1;}
    |                 IF LogicalExpresion THEN Statements  ELSE  Statements  ENDIF {   
    							   				$$ = makeNodeY(VOID, 'i', NULL, 0);
							   				$$ = makeTree($$, $2, $4, $7);
							   			   	$$->dtemp=1;}
;

IterativeStatement: WHILE LogicalExpresion DO  Statements  ENDWHILE {$$ = makeNodeY(VOID, 'w', NULL, 0);
							$$ = makeTree($$, $2, $4, NULL);
							$$->dtemp=1;}
;

ReturnStatement: RETURN Expresion {			struct node* temp = makeNodeY(VOID,'x',NULL,0);
							$$ = makeTree(temp, NULL, $2,NULL);
							$$->dtemp=1;}	
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
							       $$ = makeTree($1, $3, NULL, NULL);

						        }
				         	}
						else
						 {
							$3->LENTRY = temp;
							$$ = makeTree($1, $3, NULL, NULL);
						}
						$$->dtemp=1;
					}
     |        WRITE LPAREN Expresion RPAREN   {	$$ = makeTree($1, $3, NULL, NULL);
						$$->dtemp=1;
						}
;


Expresion:
     expr2 {$$=$1;}
     | LogicalExpresion {$$=$1;}
;

LogicalExpresion: LPAREN RelationalExpresion AND RelationalExpresion RPAREN {   if( $2->TYPE == $4->TYPE)
						   	$$ = makeTree($3, $2, $4, NULL);
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
					}
   | LPAREN RelationalExpresion OR RelationalExpresion RPAREN {   if( $2->TYPE == $2->TYPE)
						   	$$ = makeTree($3, $2, $4, NULL);
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
					}
   | LPAREN NOT RelationalExpresion RPAREN  {   
							$$ = makeTree($2, $3, NULL, NULL);
							$$->dtemp=1;
					}
   | LPAREN RelationalExpresion RPAREN {$$=$2;}
;


RelationalExpresion: expr2 EQ expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
		}
   | expr2 NE expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
		}
   | expr2 LT expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
		}
   | expr2 LE expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
		}
   | expr2 GT expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
		}
   | expr2 GE expr2 {   if( $1->TYPE == $3->TYPE && $1->TYPE == INTEG )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=BOOL;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
		}
   | BNUM 	{
			$$=$1;
   			$$->TYPE=BOOL;
   			$$->dtemp=-1;}
 
;

expr2:
     expr3 {$$=$1;}
   | expr2 PLUS expr3  {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
						{
						 $$ = makeTree($2, $1, $3, NULL);
						 $$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
			}
   | expr2 MINUS expr3  {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
			}
;

expr3:
     expr4 {$$=$1;}
   | expr3 MULT expr4 {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
			}
   | expr3 DIVIDE expr4 {   if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE  )
   						{
						$$ = makeTree($2, $1, $3, NULL);
						$$->TYPE=INTEG;}
					else{
						yyerror("Type Mismatch");
					}
					$$->dtemp=1;
			}
;

expr4:
     PLUS expr4 {if( $1->TYPE == $2->TYPE)
     				{
     				struct node* temp = makeNodeY(INTEG, 'p',NULL, 0);
			        $$ = makeTree(temp, $2, NULL, NULL);
				$$->TYPE=INTEG;}
			else{
				yyerror("Type Mismatch");
			}
			$$->dtemp=1;
		}
   | MINUS expr4 {if( $1->TYPE == $2->TYPE)
        			{
        			struct node* temp = makeNodeY(INTEG, 'm',NULL, 0);
			        $$ = makeTree(temp, $2, NULL, NULL);
				$$->TYPE=INTEG;}
			else{
				yyerror("Type Mismatch");
			}
			$$->dtemp=1;
		}
  
   | LPAREN Expresion RPAREN {$$=$2;}
   | NUMBER {
	$$=$1;
   	$$->TYPE=INTEG;
   	$$->dtemp=-1;}
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
		 $$->dtemp=-1;
       }
   		
   | ID LSQ expr2 RSQ { $$ = makeTree($1,$3,NULL,NULL);
   		        struct Gsymbol* gtemp = Glookup($$->NAME);
		        if(gtemp==NULL) 
		        	yyerror("Undefined Variable1");
			else {
				$$->GENTRY = gtemp;
				$$->TYPE = gtemp->TYPE;
			}
		 	$$->dtemp=-1;
   			}
;


%%
void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
exit(0);
}
int main(void) {
FILE *fp;
fp = fopen("sim.asm","w");
fprintf(fp,"START\n");
fprintf(fp,"MOV SP, 0\n");
fprintf(fp,"MOV BP, 0\n");
fclose(fp);
yyparse();
printSymTable();
traverse(Thead); 
fp=fopen("sim.asm","a");
fprintf(fp,"HALT\n");
fclose(fp);
return 0;
}


struct node* makeNodeY(int type, char nodetype, char* name, int value){
	struct node* res = malloc(sizeof(struct node));
	res->TYPE=type;
	res->NODETYPE=nodetype;
	res->NAME=name;
	res->VALUE = value;
	res->ARGLIST = NULL;
	res->P1	     = NULL;
	res->P2      = NULL;
	res->P3      = NULL;
	res->GENTRY  = NULL;
	res->LENTRY  = NULL;
	return res;
}

struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3)
{ 
 	struct node* res = parent;
	res->P1 = P1;
	res->P2 = P2;
	res->P3 = P3;
	Thead = res;
	return res;
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

int traverse(struct node* t)
{
	if(t==NULL){
		return 0;
	}
	else{
		int res; 
		switch(t->NODETYPE){
			case 's':
				traverse(t->P1);
				traverse(t->P2);
				break;
			case '=':{
				struct Lsymbol *lCheck = Llookup(t->P1->NAME);
	  	 		if(lCheck==NULL){
		  		      struct Gsymbol* gCheck = Glookup(t->P1->NAME);
		  		      if(gCheck==NULL)
		  		      		yyerror("Undefined Variable in assignment statement");
				      else{
				      		*(gCheck->VALUE) = traverse(t->P3);
						FILE *fp;
						fp = fopen("sim.asm","a");
						fprintf(fp,"MOV [%d],R%d\n", gCheck->BINDING, regcount-1);
						regcount--;
						fclose(fp);
				      }
				  }
				  else{
				    		*(lCheck->VALUE) = traverse(t->P3);
			   			FILE *fp;
			   			fp = fopen("sim.asm","a");
			  			fprintf(fp,"MOV R%d,BP\n",regcount);
			  			regcount++;
			   			fprintf(fp,"MOV R%d,%d\n",regcount, lCheck->BINDING);
			   			regcount++;
			   			fprintf(fp,"ADD R%d,R%d\n",regcount-2, regcount-1);
			   			regcount--;					   
			   			fprintf(fp,"MOV [R%d],R%d\n",regcount-1,regcount-2);
			   			regcount=regcount-2;
			   			fclose(fp);

				  }
				  }
				  break;
			case 'v':
				if(t->P1==NULL){
					if(t->LENTRY!=NULL){
						res = *(t->LENTRY->VALUE);
						FILE *fp;
				   		fp = fopen("sim.asm","a");
				   		fprintf(fp,"MOV R%d,BP\n",regcount);
				   		regcount++;
				   		fprintf(fp,"MOV R%d,%d\n",regcount, t->LENTRY->BINDING);
				   		regcount++;
				   		fprintf(fp,"ADD R%d,R%d\n",regcount-1, regcount-2);			   
				   		fprintf(fp,"MOV R%d,[R%d]\n", regcount-2, regcount-1);
				   		regcount--;
				   		fclose(fp);
					}
					else{
						res = *(t->GENTRY->VALUE);
				   		FILE *fp;
				   		fp = fopen("sim.asm","a");
				   		fprintf(fp,"MOV R%d,[%d]\n", regcount, t->GENTRY->BINDING);
				   		regcount++;
				   		fclose(fp);
					}
					

				}
				else{
						int pos = traverse(t->P1);
						if(pos < t->GENTRY->SIZE || pos >= 0){
							//res = *(t->GENTRY->VALUE + pos);
				   			FILE *fp;
				   			fp = fopen("sim.asm","a");
				   			fprintf(fp,"MOV R%d,%d\n", regcount, t->GENTRY->BINDING);
				   			regcount++;
				   			fprintf(fp,"ADD R%d,R%d\n", regcount-2,regcount-1);
				  			regcount--;
				   			fprintf(fp,"MOV R%d,[R%d]\n", regcount-1, regcount-1);    
				   			fclose(fp);
						}


				}
				break;
			case 'm':
	  			{traverse(t->P1);
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				regcount++;
				fprintf(fp,"..MOV R%d,%d\n", regcount-1, -1);
				fprintf(fp,"..MUL R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}	
				break;
			case 'p':
				traverse(t->P1);
				break;		
			case '+':
				{res = traverse(t->P1)+traverse(t->P2);
	  			t->dtemp=tcount;
				tcount++;
				printf("_t%d=",t->dtemp);
				if(t->P1->dtemp==-1)
					printf(t->P1->NAME);
				else
					printf("_t%d",t->P1->dtemp);
				printf("+");
				if(t->P2->dtemp==-1)
					printf(t->P2->NAME);
				else
					printf("_t%d",t->P2->dtemp);
				printf("\n");
	  			FILE *fp;
				fp = fopen("sim.asm","a");	
				fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);
				}
				break;
			case '-':
				{res = traverse(t->P1)-traverse(t->P2);
				t->dtemp=tcount;
				tcount++;
				printf("_t%d=",t->dtemp);
				if(t->P1->dtemp==-1)
					printf(t->P1->NAME);
				else
					printf("_t%d",t->P1->dtemp);
				printf("-");
				if(t->P2->dtemp==-1)
					printf(t->P2->NAME);
				else
					printf("_t%d",t->P2->dtemp);
				printf("\n");
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"SUB R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);				
				}
				break;
			case '*':
				{res = traverse(t->P1)*traverse(t->P2);
				t->dtemp=tcount;
				tcount++;
				printf("_t%d=",t->dtemp);
				if(t->P1->dtemp==-1)
					printf(t->P1->NAME);
				else
					printf("_t%d",t->P1->dtemp);
				printf("*");
				if(t->P2->dtemp==-1)
					printf(t->P2->NAME);
				else
					printf("_t%d",t->P2->dtemp);
				printf("\n");
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				regcount--;
				fclose(fp);
				}
				break;
			case '/':
				{res = traverse(t->P1)/traverse(t->P2);
				t->dtemp=tcount;
				tcount++;
				printf("_t%d=",t->dtemp);
				if(t->P1->dtemp==-1)
					printf(t->P1->NAME);
				else
					printf("_t%d",t->P1->dtemp);
				printf("/");
				if(t->P2->dtemp==-1)
					printf(t->P2->NAME);
				else
					printf("_t%d",t->P2->dtemp);
				printf("\n");
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"DIV R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);
				}
				break;
			case gt:
				{if(traverse(t->P1) > traverse(t->P2))
  			   		res = T;
  				else  
  			   		res = F;
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"GT R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case lt:
				{if(traverse(t->P1) < traverse(t->P2))
  			   		res = T;
  				else  
  			   		res =  F;
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"LT R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case le:
				{if(traverse(t->P1) <= traverse(t->P2))
  			   		res = T;
  				else  
  			   		res = F;
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"LE R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case ge:
				{if(traverse(t->P1) >= traverse(t->P2))
  			   		res = T;
  				else  
  			   		res = F;
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"GE R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case eq:
				{if(traverse(t->P1) == traverse(t->P2))
  			   		res = T;
  				else  
  			   		res = F;
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"EQ R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case ne:
				{if(traverse(t->P1) != traverse(t->P2))
  			   		res = T;
  				else  
  			   		res =  F;
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"NE R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case 'a':
				{traverse(t->P1);
  				traverse(t->P2);
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"MUL R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case 'o':
				{traverse(t->P1);
  				traverse(t->P2);
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
				regcount--;
				fclose(fp);}
				break;
			case 'n':
				{traverse(t->P2);
	  			FILE *fp;
				fp = fopen("sim.asm","a");
				fprintf(fp,"MOV R%d,1\n", regcount);
				regcount++;
				fprintf(fp,"SUB R%d,R%d\n", regcount-1, regcount-2);
				fprintf(fp,"MOV R%d,%d\n", regcount-2,regcount-1 );
				regcount--;
				fclose(fp);}
				break;
			case 'R':
				{struct Lsymbol* check = Llookup(t->P1->NAME);
	  		   	if(check==NULL)					
	  		    	{
		  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
		  		      if(gcheck==NULL)						
		  		      	yyerror("Undefined Variable in read statement");
				      else				
				       { 
						if(t->P2 == NULL)						
						  {
							   FILE *fp;
							   fp = fopen("sim.asm","a");
							   fprintf(fp,"IN R%d\n",regcount);
							   regcount++;
							   fprintf(fp,"MOV [%d],R%d\n",gcheck->BINDING,regcount-1);
							   regcount--;
							   fclose(fp);
						}
						else							
						 {
							   int pos = traverse(t->P2);
							   if(pos >= (gcheck->SIZE) || pos<0 )
							   	yyerror("Exceeding size of array");
							   else
							    {
								   FILE *fp;
								   fp = fopen("sim.asm","a");
								   fprintf(fp,"MOV R%d,%d\n", regcount, gcheck->BINDING);
								   regcount++;
								   fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
								   regcount--;
								   fprintf(fp,"IN R%d\n", regcount);
								   regcount++;
								   fprintf(fp,"MOV [R%d],R%d\n", regcount-2, regcount-1);
								   regcount=regcount-2;
								   fclose(fp);

							    }
					  	}
				       }
			   	} 
			   	else
			   	{          
					   FILE *fp;
					   fp = fopen("sim.asm","a");
					   fprintf(fp,"IN R%d\n",regcount);
					   regcount++;
					   fprintf(fp,"MOV R%d,BP\n",regcount);
					   regcount++;
					   fprintf(fp,"MOV R%d,%d\n",regcount, check->BINDING);
					   regcount++;
					   fprintf(fp,"ADD R%d,R%d\n",regcount-2, regcount-1);
					   regcount--;					   
					   fprintf(fp,"MOV [R%d],R%d\n",regcount-1,regcount-2);
					   regcount=regcount-2;
					   fclose(fp);
					
			   	}}
			   	break;	
			   case 'W':
			   		{traverse(t->P1);
			   		FILE *fp;
			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"OUT R%d\n", regcount-1);
			   		regcount--;
			   		fclose(fp);}
			   		break;
			   
			   case 'i':
			   		{FILE *fp;
			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"I%d:", ifcount);
			   		ipush(ifcount);
			   		ifcount++;
			   		fclose(fp);

			   		traverse(t->P1);

			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"JZ R%d,E%d\n", regcount-1,ifcount-1);
			   		regcount--;
			   		fclose(fp);

			   		traverse(t->P2);

			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"JMP EI%d\n", itop->value);
			   		fprintf(fp,"E%d:\n", itop->value);
			   		fclose(fp);
			   		traverse(t->P3);

			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"EI%d:\n", ipop());
			   		fclose(fp);}
					break;
			case 'w':
					{FILE *fp;
			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"W%d:", whilecount);
			   		wpush(whilecount);
			   		whilecount++;
			   		fclose(fp);

			   		traverse(t->P1);

			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"JZ R%d,EW%d\n", regcount-1,whilecount-1);
			   		regcount--;
			  		fclose(fp);

			   		traverse(t->P2);

			   		fp = fopen("sim.asm","a");
			   		fprintf(fp,"JMP W%d\n", wtop->value);
			   		fprintf(fp,"EW%d:", wpop());
			   		fclose(fp);}
			   		break;
			case 'c':
			   		{res = t->VALUE;
	  	 			FILE *fp;
					fp = fopen("sim.asm","a");
					fprintf(fp,"MOV R%d,%d\n", regcount, res);
					regcount++;
					fclose(fp);}
					break;
			case 'x':	
					{if(t->P2!=NULL)
					{
						traverse(t->P2);
					}

					if(mainflag!=1)
					{
	  	 				FILE *fp;
						fp = fopen("sim.asm","a");
						fprintf(fp,"MOV R%d,BP\n",regcount);
						regcount++;
						fprintf(fp,"MOV R%d,-2\n",regcount);
						regcount++;
						fprintf(fp,"ADD R%d,R%d\n",regcount-2,regcount-1);
						regcount--;
						fprintf(fp,"MOV [R%d],R%d\n",regcount-1,regcount-2);
						regcount = regcount-2;
						int i;
						for(i=1;i<=memcount-1;i++)
						{
			 				fprintf(fp,"POP R%d\n",regcount);
						}
						fprintf(fp,"POP BP\n");
						fprintf(fp,"RET\n");
						fclose(fp);
					}}
					break;
				
					
			   
		}
	}
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
 
 
void stringconv(int num,char ch[10])
{
int i =0;
int j=num,k,cnt=0;
while(j>0)
{
	k=j%10;
	j=j/10;
	if(cnt!=0)
	{
		for(i=cnt;i>0;i--)
		ch[i]=ch[i-1];
	}
	
	ch[0]=(char)k+48;
	cnt++;
}
ch[cnt]='\0';

}

 
void genCode(struct node *t,int ch){
	char temp[20]="_t";
	switch(ch){
		case 1:
			tcount++;
			char c[10];
			stringconv(tcount,c);
			strcat(temp,c);
			strcpy(t->qd->dest,temp);
			if(t->P1->dtemp==0)
				strcpy(t->qd->src1,t->P1->NAME);
			else
				strcpy(t->qd->src1,t->P1->qd->dest);
			if(t->P2->dtemp==0)
				strcpy(t->qd->src2,t->P2->NAME);
			else
				strcpy(t->qd->src1,t->P2->qd->dest);	
			break;
		}
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


		
