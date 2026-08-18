%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 100

char regex[MAX];
int pos = 0;
int stateCount = 0;

typedef struct {
    int from;
    int to;
    char symbol;
} Transition;

Transition transitions[500];
int transitionCount = 0;

typedef struct {
    int start;
    int end;
} Fragment;

void addTransition(int from, int to, char symbol)
{
    transitions[transitionCount].from = from;
    transitions[transitionCount].to = to;
    transitions[transitionCount].symbol = symbol;
    transitionCount++;
}

int newState()
{
    return stateCount++;
}

Fragment makeSymbol(char symbol)
{
    Fragment f;

    f.start = newState();
    f.end = newState();

    addTransition(f.start, f.end, symbol);

    return f;
}

Fragment concatenate(Fragment a, Fragment b)
{
    Fragment f;

    addTransition(a.end, b.start, 'e');

    f.start = a.start;
    f.end = b.end;

    return f;
}

Fragment unionFrag(Fragment a, Fragment b)
{
    Fragment f;

    f.start = newState();
    f.end = newState();

    addTransition(f.start, a.start, 'e');
    addTransition(f.start, b.start, 'e');

    addTransition(a.end, f.end, 'e');
    addTransition(b.end, f.end, 'e');

    return f;
}

Fragment star(Fragment a)
{
    Fragment f;

    f.start = newState();
    f.end = newState();

    addTransition(f.start, a.start, 'e');
    addTransition(f.start, f.end, 'e');

    addTransition(a.end, a.start, 'e');
    addTransition(a.end, f.end, 'e');

    return f;
}

int precedence(char op)
{
    if (op == '*')
        return 3;

    if (op == '.')
        return 2;

    if (op == '|')
        return 1;

    return 0;
}

void infixToPostfix(char *infix, char *postfix)
{
    char stack[MAX];
    int top = -1;
    int j = 0;

    for (int i = 0; infix[i] != '\0'; i++)
    {
        char c = infix[i];

        if (c == ' ')
            continue;

        if ((c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9'))
        {
            postfix[j++] = c;
        }
        else if (c == '(')
        {
            stack[++top] = c;
        }
        else if (c == ')')
        {
            while (top >= 0 && stack[top] != '(')
                postfix[j++] = stack[top--];

            if (top >= 0)
                top--;
        }
        else
        {
            while (top >= 0 &&
                   precedence(stack[top]) >= precedence(c))
            {
                postfix[j++] = stack[top--];
            }

            stack[++top] = c;
        }
    }

    while (top >= 0)
        postfix[j++] = stack[top--];

    postfix[j] = '\0';
}

Fragment buildNFA(char *postfix)
{
    Fragment stack[MAX];
    int top = -1;

    for (int i = 0; postfix[i] != '\0'; i++)
    {
        char c = postfix[i];

        if ((c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9'))
        {
            stack[++top] = makeSymbol(c);
        }
        else if (c == '.')
        {
            Fragment b = stack[top--];
            Fragment a = stack[top--];

            stack[++top] = concatenate(a, b);
        }
        else if (c == '|')
        {
            Fragment b = stack[top--];
            Fragment a = stack[top--];

            stack[++top] = unionFrag(a, b);
        }
        else if (c == '*')
        {
            Fragment a = stack[top--];

            stack[++top] = star(a);
        }
    }

    return stack[top];
}

void printNFA(Fragment result)
{
    printf("\nNFA Transition Table\n");
    printf("-----------------------------\n");
    printf("From\tSymbol\tTo\n");
    printf("-----------------------------\n");

    for (int i = 0; i < transitionCount; i++)
    {
        printf("q%d\t%c\tq%d\n",
               transitions[i].from,
               transitions[i].symbol,
               transitions[i].to);
    }

    printf("-----------------------------\n");
    printf("Start State : q%d\n", result.start);
    printf("Final State : q%d\n", result.end);
}

%}

%%

[^\n]+ {
    strcpy(regex, yytext);

    char postfix[MAX];

    printf("\nGiven Regular Expression: %s\n", regex);

    infixToPostfix(regex, postfix);

    printf("Postfix Expression: %s\n", postfix);

    Fragment result = buildNFA(postfix);

    printNFA(result);

    stateCount = 0;
    transitionCount = 0;
}

\n {
}

%%

int main()
{
    printf("Enter Regular Expression:\n");
    yylex();

    return 0;
}

int yywrap()
{
    return 1;
}

