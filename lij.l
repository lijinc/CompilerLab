%{
#include <stdlib.h>
void yyerror(char *);
#include "y.tab.h"
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
struct node* makeNode(int type, char nodetype, char* name, int value);
extern YYSTYPE yylval;
%}
digit [0-9]
letter [a-zA-Z]
%%
"=="      {yylval.n = makeNode(BOOL, eq, NULL, 0); return EQ; }
"!="     {yylval.n = makeNode(BOOL, ne, NULL, 0);return NE; }
"<"      {yylval.n = makeNode(BOOL, lt, NULL, 0); return LT; }
"<="     {yylval.n = makeNode(BOOL, le, NULL, 0); return LE; }
">"      {yylval.n = makeNode(BOOL, gt, NULL, 0); return GT; }
">="     {yylval.n = makeNode(BOOL, ge, NULL, 0); return GE; }
"+"      {yylval.n = makeNode(INTEG, *yytext, NULL, 0); return PLUS; }
"-"      {yylval.n = makeNode(INTEG, *yytext, NULL, 0); return MINUS; }
"*"      {yylval.n = makeNode(INTEG, *yytext, NULL, 0); return MULT; }
"&"      {yylval.n = makeNode(INTEG, *yytext, NULL, 0); return REF; }
"TRUE"	 { return BNUM;yylval.n = makeNode(BOOLEAN, con, NULL, 1);}
"FALSE"  {return BNUM;yylval.n = makeNode(BOOLEAN, con, NULL, 0);}
"AND"    { yylval.n = makeNode(BOOL, 'a', NULL, 0);return AND;}
"OR"     { yylval.n = makeNode(BOOL, 'o', NULL, 0);return OR;}
"NOT"    { yylval.n = makeNode(BOOL, 'n', NULL, 0);return NOT;}
"/"      { return DIVIDE; }
")"      { return RPAREN; }
"("      { return LPAREN; }
"}"      { return RCURL; }
"{"      { return LCURL; }
"]"      { return RSQ; }
"["      { return LSQ; }
"="      { yylval.n = makeNode(VOID, '=', NULL, 0);return ASSIGN; }
";"      { return SEMICOLON; }
","      { return COMMA; }
":"	   {return COLON;}
"main" {return MAIN;}
"switch" {return SWITCH;}
"case" {return CASE;}
"integer" {return INTEGER;}
"boolean" {return BOOLEAN;}
"decl"   {return DECL;}
"begin" {return BEG;}
"enddecl" {return ENDDECL;}
"end" {return END;}
"if"     { return IF; }
"then"   { return THEN; }
"else"   { return ELSE; }
"endif"     { return ENDIF; }
"while"  { return WHILE; }
"do" {return DO;}
"endwhile" {return ENDWHILE;}
"return" {return RETURN;}
"read" {yylval.n = makeNode(VOID, r, NULL, 0);return READ;}
"write" {yylval.n = makeNode(VOID, w, NULL, 0);return WRITE;}
[0-9]+   {	yylval.n = makeNode(INTEG, con, NULL, atoi(yytext));
		return NUMBER;
		}
{letter}({letter}|{digit})*   {
		char *s = malloc(yyleng);
		strcpy(s, yytext);
		yylval.n = makeNode(INTEG, var, s, 0);
		return ID;
			}
[ \t\n] ;  /* skip whitespace */
.        { yyerror("illegal token"); }
%%
struct node* makeNode(int type, char nodetype, char* name, int value){
		struct node* res = malloc(sizeof(struct node));
		res->TYPE=type;
		res->NODETYPE=nodetype;
		res->NAME=name;
		res->VALUE = value;
		res->P1=NULL;
		res->P2=NULL;
		res->P3=NULL;
		res->GENTRY = NULL;
		res->LENTRY = NULL;
		return res;
}
int yywrap(void) {
return 1;
}
