%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STATES 20
#define MAX_SYMBOLS 10
#define MAX_DFA_STATES 100

int nfaStates;
int nfaSymbols;

char symbols[MAX_SYMBOLS];

int transition[MAX_STATES][MAX_SYMBOLS][MAX_STATES];
int epsilon[MAX_STATES][MAX_STATES];

int startState;
int finalStates[MAX_STATES];

int dfa[MAX_DFA_STATES][MAX_SYMBOLS][MAX_DFA_STATES];

int dfaSets[MAX_DFA_STATES][MAX_STATES];
int dfaCount = 0;

void epsilonClosure(int state, int closure[])
{
    closure[state] = 1;

    for (int i = 0; i < nfaStates; i++)
    {
        if (epsilon[state][i] && !closure[i])
        {
            epsilonClosure(i, closure);
        }
    }
}

void moveSet(int set[], int symbolIndex, int result[])
{
    for (int i = 0; i < nfaStates; i++)
    {
        if (set[i])
        {
            for (int j = 0; j < nfaStates; j++)
            {
                if (transition[i][symbolIndex][j])
                {
                    result[j] = 1;
                }
            }
        }
    }
}

void closureOfSet(int set[], int result[])
{
    for (int i = 0; i < nfaStates; i++)
    {
        if (set[i])
        {
            int temp[MAX_STATES] = {0};

            epsilonClosure(i, temp);

            for (int j = 0; j < nfaStates; j++)
            {
                if (temp[j])
                    result[j] = 1;
            }
        }
    }
}

int sameSet(int a[], int b[])
{
    for (int i = 0; i < nfaStates; i++)
    {
        if (a[i] != b[i])
            return 0;
    }

    return 1;
}

int findSet(int set[])
{
    for (int i = 0; i < dfaCount; i++)
    {
        if (sameSet(dfaSets[i], set))
            return i;
    }

    return -1;
}

int addDFAState(int set[])
{
    int index = findSet(set);

    if (index != -1)
        return index;

    for (int i = 0; i < nfaStates; i++)
        dfaSets[dfaCount][i] = set[i];

    return dfaCount++;
}

void printSet(int set[])
{
    printf("{");

    int first = 1;

    for (int i = 0; i < nfaStates; i++)
    {
        if (set[i])
        {
            if (!first)
                printf(",");

            printf("q%d", i);

            first = 0;
        }
    }

    printf("}");
}

void constructDFA()
{
    int startClosure[MAX_STATES] = {0};

    epsilonClosure(startState, startClosure);

    addDFAState(startClosure);

    for (int current = 0; current < dfaCount; current++)
    {
        for (int s = 0; s < nfaSymbols; s++)
        {
            int moveResult[MAX_STATES] = {0};
            int closureResult[MAX_STATES] = {0};

            moveSet(dfaSets[current], s, moveResult);

            closureOfSet(moveResult, closureResult);

            if (findSet(closureResult) == -1)
                addDFAState(closureResult);

            int destination = findSet(closureResult);

            dfa[current][s][0] = destination;
        }
    }
}

void printDFA()
{
    printf("\nDFA Transition Table\n");
    printf("--------------------------------------\n");

    printf("State\t");

    for (int i = 0; i < nfaSymbols; i++)
        printf("%c\t", symbols[i]);

    printf("\n--------------------------------------\n");

    for (int i = 0; i < dfaCount; i++)
    {
        printf("D%d ", i);
        printSet(dfaSets[i]);

        printf("\t");

        for (int s = 0; s < nfaSymbols; s++)
        {
            printf("D%d\t", dfa[i][s][0]);
        }

        printf("\n");
    }

    printf("--------------------------------------\n");

    printf("\nDFA Final States: ");

    for (int i = 0; i < dfaCount; i++)
    {
        int isFinal = 0;

        for (int q = 0; q < nfaStates; q++)
        {
            if (dfaSets[i][q] && finalStates[q])
            {
                isFinal = 1;
                break;
            }
        }

        if (isFinal)
            printf("D%d ", i);
    }

    printf("\n");
}

%}

%%

[^\n]+ {
    /*
       Input format:

       First line:
       number of states

       Second line:
       number of symbols

       Third line:
       symbols separated by spaces

       Then transition information is entered
       from the console through scanf().
    */

    nfaStates = atoi(yytext);

    printf("\nNumber of NFA states = %d\n", nfaStates);

    printf("Enter number of input symbols: ");
    scanf("%d", &nfaSymbols);

    printf("Enter input symbols:\n");

    for (int i = 0; i < nfaSymbols; i++)
        scanf(" %c", &symbols[i]);

    printf("Enter start state: ");
    scanf("%d", &startState);

    printf("Enter number of final states: ");

    int nf;
    scanf("%d", &nf);

    printf("Enter final states:\n");

    for (int i = 0; i < nf; i++)
    {
        int f;
        scanf("%d", &f);
        finalStates[f] = 1;
    }

    int transitions;

    printf("Enter number of normal transitions: ");
    scanf("%d", &transitions);

    printf("Enter transitions as:\n");
    printf("from symbol to\n");

    for (int i = 0; i < transitions; i++)
    {
        int from, to;
        char symbol;

        scanf("%d %c %d", &from, &symbol, &to);

        for (int s = 0; s < nfaSymbols; s++)
        {
            if (symbols[s] == symbol)
            {
                transition[from][s][to] = 1;
                break;
            }
        }
    }

    int epsilonTransitions;

    printf("Enter number of epsilon transitions: ");
    scanf("%d", &epsilonTransitions);

    printf("Enter epsilon transitions as:\n");
    printf("from to\n");

    for (int i = 0; i < epsilonTransitions; i++)
    {
        int from, to;

        scanf("%d %d", &from, &to);

        epsilon[from][to] = 1;
    }

    constructDFA();

    printDFA();
}

%%

int main()
{
    printf("Enter number of NFA states:\n");
    yylex();

    return 0;
}

int yywrap()
{
    return 1;
}
