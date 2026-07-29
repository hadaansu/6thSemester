%{
#include <stdio.h>
%}

%%
[a-zA-Z]+ { printf("WORD: %s\n", yytext); }
[0-9]+ { printf("NUMBER: %s\n", yytext); }
[ \t\n] { /* ignore whitespace */ }
. { printf("OTHER: %s\n", yytext); }
%%

int yywrap() {
return 1;
}

int main() {
printf("Enter text (Ctrl+D to end):\n");
yylex();
return 0;
}