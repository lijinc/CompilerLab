%{
#include <stdio.h>
int yylex(void);
void yyerror(char *);
%}
%token INTEGER ID KEYWORD LOGOP
%%



%%
void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
}
int main(void) {
yyparse();
return 0;
}

