%option noyywrap
%{
#include <stdio.h>
#include <string.h>

char *keywords[] = {
    "int", "float", "double", "char", "if", "else", "while", "for",
    "return", "void", "break", "continue", "do", NULL
};

int isKeyword(char *word) {
    int i;
    for (i = 0; keywords[i] != NULL; i++) {
        if (strcmp(word, keywords[i]) == 0)
            return 1;
    }
    return 0;
}
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]

%%

"//".*                  { /* single-line comment: ignore */ }
"/*"([^*]|\*+[^*/])*\*+"/"  { /* multi-line comment: ignore */ }

\"([^\\\"]|\\.)*\"      { printf("STRING       : %s\n", yytext); }

{LETTER}({LETTER}|{DIGIT})*  {
                            if (isKeyword(yytext))
                                printf("KEYWORD      : %s\n", yytext);
                            else
                                printf("IDENTIFIER   : %s\n", yytext);
                         }

{DIGIT}+"."{DIGIT}+     { printf("FLOAT NUMBER : %s\n", yytext); }
{DIGIT}+                { printf("INTEGER      : %s\n", yytext); }

"=="|"!="|"<="|">="     { printf("REL-OPERATOR : %s\n", yytext); }
[<>]                    { printf("REL-OPERATOR : %s\n", yytext); }
[+\-*/=]                { printf("OPERATOR     : %s\n", yytext); }

[;,]                    { printf("PUNCTUATION  : %s\n", yytext); }
[(){}]                  { printf("BRACKET      : %s\n", yytext); }

[ \t\n]+                { /* ignore whitespace */ }
.                        { printf("UNKNOWN TOKEN: %s\n", yytext); }

%%

int main() {
    printf("Enter code (Ctrl+Z then Enter to end):\n\n");
    yylex();
    return 0;
}
