%option noyywrap

%x SLC
%x MLC
%x CHAR_LIT
%x STR


%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include<string>
#include<fstream>
#include<cstring>
#include<bits/stdc++.h>
#include "symbolTableOffline.cpp"
#include "y.tab.h"


using namespace std;

extern YYSTYPE yylval;
extern SymbolTable table;
extern fstream ofsLog;
extern fstream ofsError;
void yyerror(char *);


int word_count=0;
int line_count=1;
int error_count=0;
string scopetableString="";

//string str="";
string strToken;

//SymbolTable st(7);


void IncWc(){
	word_count++;
}
%}

Letter [a-zA-Z]

%%
[ \t\v]+ {}

(if) { string *str=new string("if"); yylval.st=str; return IF;}
       
(for) { string *str=new string("for"); yylval.st=str; return FOR;}
             
(else) { string *str=new string("else"); yylval.st=str; return ELSE;}
       
(while) { string *str=new string("while"); yylval.st=str; return WHILE;}   
       
       
(return) { string *str=new string("return"); yylval.st=str; return RETURN;}

(println) { string *str=new string("printf"); yylval.st=str; return PRINTLN; }

(void) { string *str=new string("void"); yylval.st=str; return VOID;}
       
(int) { string *str=new string("int"); yylval.st=str; return INT;}
         
(float) { string *str=new string("float"); yylval.st=str; return FLOAT;}
             
([0-9]+)?\.[0-9]+(E[+-]?[0-9]+)? { 

	SymbolInfo *si = new SymbolInfo(yytext, "CONST_FLOAT");
	
	yylval.s = si;		
	
	return CONST_FLOAT;
	
	}

[0-9]+ { 	
	SymbolInfo *si = new SymbolInfo(yytext, "CONST_INT");
	
	yylval.s = si;	
	
	return CONST_INT;
	
	
	}


([0-9]+)E([+-]?[0-9]+) { 

	SymbolInfo *si = new SymbolInfo(yytext, "CONST_FLOAT");
	
	yylval.s = si;		
	
	return CONST_FLOAT;
	
	}
	
([0-9])*\.([0-9])*((\.)+([0-9])*)+ {	
	
	error_count++;
	
	}
	
([0-9])+E[+-]?([0-9])+(\.([0-9])+)+ {
	
	error_count++;
	
	}

([0-9])*\.([0-9])+(E[+-]?([0-9])+)?E[+-]?([0-9])+(\.([0-9])+)+ {

	error_count++;

	}
	
	
([0-9])*\.([0-9])*((\.)+([0-9])*)+E[+-]?([0-9])+(\.([0-9])+)+ {
	
	error_count++;
	
	}


[+-] { 	
	SymbolInfo *si = new SymbolInfo(yytext, "ADDOP");
	
	yylval.s = si;

	return ADDOP; }
 
[*/%] { SymbolInfo *si = new SymbolInfo(yytext, "MULOP");
	
	yylval.s = si;

	return MULOP; }
 
(\+\+)  { string *str=new string("++"); yylval.st=str; return INCOP;}
(\-\-)  { string *str=new string("--"); yylval.st=str; return DECOP;}
 
(<|<=|>|>=|==|!=) { SymbolInfo *si = new SymbolInfo(yytext, "RELOP");
	
	yylval.s = si;

	return RELOP; }
 
[=] { string *str=new string("="); yylval.st=str; return ASSIGNOP; }
 
(&&) { string *str=new string("&&"); yylval.st=str; return LOGICOP; }
 
(\|\|) { string *str=new string("||"); yylval.st=str; return LOGICOP;}
 
[!] { string *str=new string("!"); yylval.st=str; return NOT;}
 
[(] { string *str=new string("("); yylval.st=str; return LPAREN;}
 
[)] { string *str=new string(")"); yylval.st=str; return RPAREN;}

[{] { /*table.EnterScope(30);*/ string *str=new string("{"); yylval.st=str; return LCURL; }
	 
[}] { scopetableString=table.PrintAllScopeTables(); /*table.ExitScope(30);*/ string *str=new string("}"); yylval.st=str;  return RCURL; }


[\[] { string *str=new string("["); yylval.st=str; return LTHIRD; }
 
[\]] { string *str=new string("]"); yylval.st=str; return RTHIRD; }
 
[,] { string *str=new string(","); yylval.st=str; return COMMA; }
 
[;] { string *str=new string(";"); yylval.st=str; return SEMICOLON; }
 


[A-Za-z_]([A-Za-z0-9_])* {

	SymbolInfo *si = new SymbolInfo(yytext, "ID");
	
	//SymbolInfo si2(yytext, "ID");
	
	//bool i = table.Insert(si2);
	
	yylval.s = si;

	return ID;

	}

([0-9]+)([A-Za-z_])+ {
	
	error_count++;	
	
	}




((\n)|(\r\n)) {line_count++;}
<<EOF>> { return 0;/*ofsLog<<"The symbol table: "<<table.PrintAllScopeTables()<<endl;*/ }
	 
. { }
%%

