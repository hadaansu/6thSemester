/*
 * dfa_direct.l
 * -----------------------------------------------------------
 * LEX program:  Direct Method construction of a DFA from a
 * regular expression (syntax tree + nullable/firstpos/lastpos/
 * followpos).
 *
 * Lex is used to scan/read the regular expression typed by the
 * user (letters,  digits,  |,  *,  ( ) ). The DFA-construction
 * algorithm itself runs in the C code embedded in this file.
 *
 * Compile :   flex dfa_direct.l
 *            gcc lex.yy.c -o dfa_direct -lfl
 * Run     :   ./dfa_direct
 * Example :   (a|b)*abb
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAXPOS    50
#define MAXSTATES 100
#define MAXSYM    30
#define MAXBUF    200

typedef struct node {
    char symbol;
    int  position;
    int  nullable;
    int  firstpos[MAXPOS],  nfirst;
    int  lastpos[MAXPOS],   nlast;
    struct node *left,  *right;
} Node;

char postime[MAXPOS];
int  posCount = 0;

int  followpos[MAXPOS][MAXPOS];
int  nfollow[MAXPOS];

char alphabet[MAXSYM];
int  nalpha = 0;

typedef struct {
    int positions[MAXPOS];
    int count;
    int marked;
    int isFinal;
} DState;

DState states[MAXSTATES];
int    nstates = 0;
int    trans[MAXSTATES][MAXSYM];

char inputRegex[MAXBUF];

/* ---------- Step 1:  insert explicit concatenation ---------- */
void insertConcat(char *re,  char *res) {
    int j = 0;
    for (int i = 0; re[i] != '\0'; i++) {
        char c1 = re[i];
        res[j++] = c1;
        if (re[i + 1] == '\0') break;
        char c2 = re[i + 1];
        int c1ok = (isalnum((unsigned char)c1) || c1 == ')' || c1 == '*');
        int c2ok = (isalnum((unsigned char)c2) || c2 == '(' || c2 == '#');
        if (c1ok && c2ok) res[j++] = '.';
    }
    res[j] = '\0';
}

/* ---------- Step 3:  infix -> postfix ---------- */
int prec(char c) {
    if (c == '*') return 3;
    if (c == '.') return 2;
    if (c == '|') return 1;
    return 0;
}

void infixToPostfix(char *in,  char *post) {
    char stack[MAXBUF]; 
    int top = -1, j = 0;
    
    for (int i = 0; in[i] != '\0'; i++) {
        char c = in[i];
        if (isalnum((unsigned char)c) || c == '#') {
            post[j++] = c;
        } else if (c == '(') {
            stack[++top] = c;
        } else if (c == ')') {
            while (top >= 0 && stack[top] != '(') 
                post[j++] = stack[top--];
            top--;
        } else {
            while (top >= 0 && stack[top] != '(' && prec(stack[top]) >= prec(c))
                post[j++] = stack[top--];
            stack[++top] = c;
        }
    }
    while (top >= 0) post[j++] = stack[top--];
    post[j] = '\0';
}

/* ---------- Step 4/5:  syntax tree with attributes ---------- */
Node *newNode(void) {
    Node *n = (Node *)malloc(sizeof(Node));
    n->left = n->right = NULL;
    n->position = -1;
    n->nfirst = n->nlast = 0;
    n->nullable = 0;
    return n;
}

Node *makeLeaf(char c) {
    Node *n = newNode();
    n->symbol = c;
    n->position = ++posCount;
    postime[posCount] = c;
    n->firstpos[0] = posCount; 
    n->nfirst = 1;
    n->lastpos[0]  = posCount; 
    n->nlast  = 1;
    return n;
}

Node *makeStar(Node *c) {
    Node *n = newNode();
    n->symbol = '*';
    n->left = c;
    n->nullable = 1;
    memcpy(n->firstpos,  c->firstpos,  sizeof(int) * c->nfirst); 
    n->nfirst = c->nfirst;
    memcpy(n->lastpos,   c->lastpos,   sizeof(int) * c->nlast);  
    n->nlast  = c->nlast;
    return n;
}

Node *makeOr(Node *l,  Node *r) {
    Node *n = newNode();
    n->symbol = '|';
    n->left = l; 
    n->right = r;
    n->nullable = l->nullable || r->nullable;
    
    memcpy(n->firstpos,  l->firstpos,  sizeof(int) * l->nfirst);
    memcpy(n->firstpos + l->nfirst,  r->firstpos,  sizeof(int) * r->nfirst);
    n->nfirst = l->nfirst + r->nfirst;
    
    memcpy(n->lastpos,  l->lastpos,  sizeof(int) * l->nlast);
    memcpy(n->lastpos + l->nlast,  r->lastpos,  sizeof(int) * r->nlast);
    n->nlast = l->nlast + r->nlast;
    return n;
}

Node *makeConcat(Node *l,  Node *r) {
    Node *n = newNode();
    n->symbol = '.';
    n->left = l; 
    n->right = r;
    n->nullable = l->nullable && r->nullable;

    memcpy(n->firstpos,  l->firstpos,  sizeof(int) * l->nfirst);
    n->nfirst = l->nfirst;
    if (l->nullable) {
        memcpy(n->firstpos + n->nfirst,  r->firstpos,  sizeof(int) * r->nfirst);
        n->nfirst += r->nfirst;
    }

    memcpy(n->lastpos,  r->lastpos,  sizeof(int) * r->nlast);
    n->nlast = r->nlast;
    if (r->nullable) {
        memcpy(n->lastpos + n->nlast,  l->lastpos,  sizeof(int) * l->nlast);
        n->nlast += l->nlast;
    }
    return n;
}

Node *buildTree(char *postfix) {
    Node *stack[MAXBUF]; 
    int top = -1;
    
    for (int i = 0; postfix[i] != '\0'; i++) {
        char c = postfix[i];
        if (isalnum((unsigned char)c) || c == '#') {
            stack[++top] = makeLeaf(c);
        } else if (c == '*') {
            stack[++top] = makeStar(stack[top--]);
        } else if (c == '|') {
            Node *b = stack[top--],  *a = stack[top--];
            stack[++top] = makeOr(a,  b);
        } else if (c == '.') {
            Node *b = stack[top--],  *a = stack[top--];
            stack[++top] = makeConcat(a,  b);
        }
    }
    return stack[top];
}

/* ---------- Step 6:  followpos ---------- */
void addFollow(int pos,  int *set,  int n) {
    for (int i = 0; i < n; i++) {
        int val = set[i];
        int dup = 0;
        for (int k = 0; k < nfollow[pos]; k++) 
            if (followpos[pos][k] == val) {
                dup = 1; 
                break;
            }
        if (!dup) 
            followpos[pos][nfollow[pos]++] = val;
    }
}

void computeFollowpos(Node *n) {
    if (n == NULL) return;
    computeFollowpos(n->left);
    computeFollowpos(n->right);
    if (n->symbol == '.') {
        for (int i = 0; i < n->left->nlast; i++)
            addFollow(n->left->lastpos[i],  n->right->firstpos,  n->right->nfirst);
    } else if (n->symbol == '*') {
        for (int i = 0; i < n->nlast; i++)
            addFollow(n->lastpos[i],  n->firstpos,  n->nfirst);
    }
}

/* ---------- alphabet ---------- */
void buildAlphabet(void) {
    nalpha = 0;
    for (int i = 1; i <= posCount; i++) {
        char c = postime[i];
        if (c == '#') continue;
        int found = 0;
        for (int j = 0; j < nalpha; j++) 
            if (alphabet[j] == c) {
                found = 1; 
                break;
            }
        if (!found) 
            alphabet[nalpha++] = c;
    }
}

/* ---------- Step 7:  DFA construction ---------- */
int findState(int *set,  int n) {
    for (int s = 0; s < nstates; s++) {
        if (states[s].count != n) continue;
        int match = 1;
        for (int i = 0; i < n; i++) {
            int found = 0;
            for (int j = 0; j < states[s].count; j++)
                if (states[s].positions[j] == set[i]) { 
                    found = 1; 
                    break; 
                }
            if (!found) { 
                match = 0; 
                break; 
            }
        }
        if (match) return s;
    }
    return -1;
}

int addState(int *set,  int n) {
    int idx = findState(set,  n);
    if (idx != -1) return idx;
    
    states[nstates].count = n;
    for (int i = 0; i < n; i++) 
        states[nstates].positions[i] = set[i];
    states[nstates].marked  = 0;
    states[nstates].isFinal = 0;
    
    for (int i = 0; i < n; i++)
        if (postime[set[i]] == '#') {
            states[nstates].isFinal = 1;
            break;
        }
    return nstates++;
}

void buildDFA(Node *root) {
    addState(root->firstpos,  root->nfirst);
    
    for (int progress = 1; progress; ) {
        progress = 0;
        for (int s = 0; s < nstates; s++) {
            if (states[s].marked) continue;
            states[s].marked = 1;
            progress = 1;
            
            for (int a = 0; a < nalpha; a++) {
                char sym = alphabet[a];
                int U[MAXPOS],  nU = 0;
                
                for (int i = 0; i < states[s].count; i++) {
                    int p = states[s].positions[i];
                    if (postime[p] == sym) {
                        for (int k = 0; k < nfollow[p]; k++) {
                            int val = followpos[p][k];
                            int dup = 0;
                            for (int m = 0; m < nU; m++) 
                                if (U[m] == val) {
                                    dup = 1; 
                                    break;
                                }
                            if (!dup) 
                                U[nU++] = val;
                        }
                    }
                }
                trans[s][a] = (nU > 0) ? addState(U,  nU) :  -1;
            }
        }
    }
}

/* ---------- printing ---------- */
void printSet(int *set,  int n) {
    printf("{");
    for (int i = 0; i < n; i++) 
        printf("%d%s",  set[i],  (i < n - 1) ? ", " : "");
    printf("}");
}
%}

/* ================= LEX RULES:  scan the regex typed by the user ================= */
%%
[a-zA-Z0-9\|\*\(\)]+   { strncpy(inputRegex,  yytext,  MAXBUF - 1); }
[ \t]+                 { /* skip spaces */ }
\n                      { return 0; }
.                       { /* ignore anything unexpected */ }
%%

int yywrap(void) { return 1; }

/* ================= main:  runs after lex has read the regex ================= */
int main(void) {
    char withConcat[MAXBUF],  augmented[MAXBUF],  finalRe[MAXBUF],  postfix[MAXBUF];

    printf("Enter regular expression (letters/digits,  | * ( ) ),  e.g. (a|b)*abb :  ");
    yylex();

    insertConcat(inputRegex,  withConcat);
    snprintf(augmented,  MAXBUF,  "(%s)#",  withConcat);
    insertConcat(augmented,  finalRe);

    infixToPostfix(finalRe,  postfix);
    printf("\nAugmented regex :  %s\n",  augmented);
    printf("Postfix form    :  %s\n",  postfix);

    Node *root = buildTree(postfix);

    printf("\nLeaf positions: \n");
    for (int i = 1; i <= posCount; i++)
        printf("  pos %d -> '%c'\n",  i,  postime[i]);

    computeFollowpos(root);
    printf("\nFollowpos table: \n");
    for (int i = 1; i <= posCount; i++) {
        if (postime[i] == '#') continue;
        printf("  followpos(%d) = ",  i);
        printSet(followpos[i],  nfollow[i]);
        printf("\n");
    }

    buildAlphabet();
    buildDFA(root);

    printf("\nDFA States (as position sets): \n");
    for (int i = 0; i < nstates; i++) {
        printf("  D%d = ",  i);
        printSet(states[i].positions,  states[i].count);
        if (i == 0) printf("   (start)");
        if (states[i].isFinal) printf("   (final)");
        printf("\n");
    }

    printf("\nTransition Table: \n");
    printf("State\t");
    for (int a = 0; a < nalpha; a++) 
        printf("%c\t",  alphabet[a]);
    printf("\n");
    
    for (int i = 0; i < nstates; i++) {
        printf("%s%d%s\t",  (i == 0 ? "->" :  "  "),  i,  (states[i].isFinal ? "*" :  ""));
        for (int a = 0; a < nalpha; a++) {
            if (trans[i][a] == -1) 
                printf("-\t");
            else 
                printf("D%d\t",  trans[i][a]);
        }
        printf("\n");
    }

    printf("\nStart state :  D0\n");
    printf("Final state(s) :  ");
    for (int i = 0; i < nstates; i++) 
        if (states[i].isFinal) 
            printf("D%d ",  i);
    printf("\n");

    return 0;
}