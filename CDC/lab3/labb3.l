%option noyywrap
%{
#include <stdio.h>
#include <string.h>

int keyword_count = 0, id_count = 0, num_count = 0;

// List of C keywords
char *keywords[] = {
    "int", "float", "double", "char", "if", "else", "while", "for",
    "do", "switch", "case", "break", "continue", "return", "void",
    "struct", "union", "typedef", "const", "static", "sizeof",
    "default", "goto", "long", "short", "signed", "unsigned",
    "volatile", "enum", "extern", "register", NULL
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

%%
[a-zA-Z_][a-zA-Z0-9_]*   {
                            if (isKeyword(yytext)) {
                                printf("KEYWORD    : %s\n", yytext);
                                keyword_count++;
                            } else {
                                printf("IDENTIFIER : %s\n", yytext);
                                id_count++;
                            }
                         }

[0-9]+(\.[0-9]+)?        {
                            printf("NUMBER     : %s\n", yytext);
                            num_count++;
                         }

[ \t\n]                  { /* ignore whitespace */ }
.                         { /* ignore symbols like ;, {, }, (, ) */ }
%%

int main() {
    printf("Enter C-like code (Ctrl+Z then Enter to end):\n\n");
    yylex();
    printf("\n--- SUMMARY ---\n");
    printf("Total Keywords    : %d\n", keyword_count);
    printf("Total Identifiers : %d\n", id_count);
    printf("Total Numbers     : %d\n", num_count);
    return 0;
}
