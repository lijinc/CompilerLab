%{
#include <stdlib.h>
void yyerror(char *);
#include "y.tab.h"
%}
digit [0-9]
letter [a-zA-Z]
%%
"=="      { return EQ; }
"!="     { return NE; }
"<"      { return LT; }
"<="     { return LE; }
">"      { return GT; }
">="     { return GE; }
"+"      { return PLUS; }
"-"      { return MINUS; }
"*"      { return MULT; }
"&"      { return REF; }
"AND"    { return AND;}
"OR"     { return OR;}
"NOT"    { return NOT;}
"/"      { return DIVIDE; }
")"      { return RPAREN; }
"("      { return LPAREN; }
"}"      { return RCURL; }
"{"      { return LCURL; }
"]"      { return RSQ; }
"["      { return LSQ; }
"="      { return ASSIGN; }
";"      { return SEMICOLON; }
","      { return COMMA; }
"main" {return MAIN;}
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
"read" {return READ;}
"write" {return WRITE;}
[0-9]+   {
		yylval.ptr=makenode("NO", NULL, NULL, NULL);
		return NUMBER;
		}
{letter}({letter}|{digit})*   {
			yylval.ptr=makenode("ID", NULL, NULL, NULL);
			return ID;
			}
[ \t\n] ;  /* skip whitespace */
.        { yyerror("illegal token"); }
%%
int yywrap(void) {
return 1;
}
