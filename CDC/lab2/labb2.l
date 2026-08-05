%option noyywrap
%{
#include <stdio.h>

int vowels = 0, consonants = 0, words = 0, lines = 0;
int inword = 0;
%}

%%
[aeiouAEIOU]    { vowels++; if(!inword){words++; inword=1;} }
[a-zA-Z]        { consonants++; if(!inword){words++; inword=1;} }
[ \t]           { inword = 0; }
\n              { lines++; inword = 0; }
.               { /* ignore other symbols */ }
%%

int main() {
    printf("Enter text (Ctrl+Z then Enter to end):\n");
    yylex();
    printf("\n--- RESULTS ---\n");
    printf("Vowels     : %d\n", vowels);
    printf("Consonants : %d\n", consonants);
    printf("Words      : %d\n", words);
    printf("Lines      : %d\n", lines);
    return 0;
}
