/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+ return "WSPACE"
"</>" return "EMPTY"
"</" return 'END'
"<" return 'OPEN'
">" return 'CLOSE'
"/>" return 'OPENEND'
"\"" return 'QUOTE'
"\\" return 'BSLASH'
"=" return 'EQUAL'
[0-9] return 'NUMBER'
[A-Za-z] return 'LETTER'
[-_] return 'SPECIAL'
. return 'CHAR'

/lex

/* operator associations and precedence */

%start expressions

%% /* language grammar */

expressions
    : tree_list
        {return $1;}
    | tree_list WSPACE
        { return $1; }
    ;

any
    : NUMBER
    | LETTER
    | CHAR
    | OPEN
    | CLOSE
    | WSPACE
    | SPECIAL
    ;

charlist
    : BSLASH any charlist
      { $$ = $1 + $2 + $3; }
    | any charlist
      { $$ = $1 + $2; }
    | BSLASH any
      { $$ = $1 + $2; }
    | any
      { $$ = $1; }
    ;

string
    : QUOTE QUOTE
      { $$ = ""; }
    | QUOTE charlist QUOTE
      { $$ = $2; }
    ;

word
    : wordchar word { $$ = $1 + $2; }
    | wordchar { $$ = $1; }
    |
    ;

wordchar
    : LETTER
    | NUMBER
    | SPECIAL
    ;

tree_list
    : tree_list tree { b=$1;if(b===undefined){b=[]};b.push($2);$$ =b; }
    | tree { b=[$1];$$ = b; }
    ;

number_list
    : NUMBER number_list
      { $$ = $1 + $2; }
    | NUMBER
      { $$ = $1; }
    ;

aval
    : number_list
      { $$ = $1; }
    | string
      { $$ = $1; }
    ;

tree
    /* empty node */
    : EMPTY
        {$$ = {} ;}
    /* leaf node */
    | OPEN word OPENEND
        { var b={};b.n=$2;b.t='L';$$ = b; }
    /* simple tree */
    | OPEN word CLOSE tree_list EMPTY
        { var b={};c={c:$4};b.n=$2;b.v=c;b.t='t';$$ = b; }
    | OPEN word CLOSE tree_list END word CLOSE
        {if($2!=$6){return -1}var b={};c={c:$4};b.n=$2;b.t='T';b.v=c;$$ = b; }
    | OPEN word EQUAL aval CLOSE tree_list EMPTY
        { var b={};b.n=$2;b.v=$4;b.c=$6;b.t='a';$$ = b; }
    | OPEN word EQUAL aval CLOSE tree_list END word CLOSE
        {if($2!=$8){return -1}var b={};b.n=$2;b.e=$8;b.v=$4;b.c=$6;b.t='A';$$ = b; }
    | OPEN word EQUAL aval OPENEND
        { var b={};b.n=$2;b.v=$4;b.t='l';$$ = b; }
    ;
