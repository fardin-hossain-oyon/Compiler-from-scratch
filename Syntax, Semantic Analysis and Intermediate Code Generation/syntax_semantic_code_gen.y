%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include<sstream>
#include "symbol_table.cpp"
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int error_count;
extern string scopetableString;

SymbolTable table(30);

int within_function = 0;

fstream ofsLog;
fstream ofsError;
fstream ofsCode;

string *dataSegment = new string("");


void yyerror(char *s)
{
	//write your code
}

string replaceChar(string str, char ch1, char ch2){

  	for(int i=0; i<str.length(); i++){
  	
    		if(str[i] == ch1){
      			str[i] = ch2;
      		}
  	}

  	return str;
}


int labelCount=0;
int tempCount=0;


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}

string printProcedure="OUTDEC PROC\nPUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nCMP AX,0\nJGE @END_IF1\nPUSH AX\nMOV DL,'-'\nMOV AH,2\nINT 21H\n\
POP AX\nNEG AX\n@END_IF1:\nXOR CX,CX\nMOV BX,10D\n@REPEAT1:\nXOR DX,DX\nDIV BX\nPUSH DX\nINC CX\nCMP AX,0\nJNE @REPEAT1\nMOV AH,2\n\
@PRINT_LOOP:\nPOP DX\nOR DL,30H\nINT 21H\nLOOP @PRINT_LOOP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET\nOUTDEC ENDP\n";



%}

%union {
	
	double dval;
	int ival;
	SymbolInfo *s;
	string *st;
	ReturnInfo *ri;
	IDInfo *idinfo;
	vector<IDInfo*>* vect;
	vector<ReturnInfo*>* retVector;
	StrCode *stCode;

	}

%token <st> INT FLOAT VOID LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP NOT INCOP DECOP
%token <s> ID CONST_INT CONST_FLOAT LOGICOP RELOP ADDOP MULOP

%type <stCode> start program unit var_declaration func_declaration func_definition type_specifier compound_statement statements statement expression_statement lcurl_scope_creation

//%type <stCode> start program unit var_declaration func_declaration func_definition type_specifier compound_statement statements statement expression_statement

%type <ri> variable factor unary_expression term simple_expression rel_expression logic_expression expression

%type <vect> declaration_list

%type <retVector> parameter_list argument_list arguments

%type <idinfo> new_scope_creation

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		ofsLog<<"At line no: "<<line_count<<" start : program \n"<<endl;
		//ofsLog<<*$1<<endl;
		ofsLog<<endl;
		
		ofsLog<<table.PrintAllScopeTables()<<"\n"<<endl;
		//ofsLog<<table.PrintAllScopeTablesV2()<<"\n"<<endl;
		
		ofsLog<<"Total Lines : "<<line_count<<"\n"<<"\n"<<endl;
		ofsLog<<"Total Errors: "<<error_count<<"\n"<<endl;
		
		ofsCode<<".MODEL SMALL"<<endl;
		ofsCode<<".STACK 100H\n"<<endl;
		
		ofsCode<<".DATA"<<endl;
		ofsCode<<*dataSegment<<endl;
		ofsCode<<endl;
		
		
		ofsCode<<".CODE"<<endl;
		ofsCode<<$1->getCode()<<endl;
		
		ofsCode<<printProcedure<<endl;
		ofsCode<<"END MAIN"<<endl;
		
		ofsCode<<endl;
	}
	;

program : program unit { ofsLog<<"At line no: "<<line_count<<" program : program unit \n"<<endl;
			 ofsLog<<$1->getBody()<<$2->getBody()<<endl;
			 ofsLog<<endl;
			 
			 //ofsLog<<table.PrintAllScopeTablesV2()<<endl;
			 
			 string *temp = new string("");
			 string *tempCode = new string("");
	
			 temp->append($1->getBody());
			 temp->append($2->getBody());
			 
			 StrCode *stc = new StrCode(*temp, *tempCode);
	
			 $$ = stc; 
			 }
			 
	| unit { ofsLog<<"At line no: "<<line_count<<" program : unit \n"<<endl;
		 ofsLog<<$1->getBody()<<endl; ofsLog<<endl; 
			 
	
		 $$ = $1; }
	;
	
unit : var_declaration { ofsLog<<"At line no: "<<line_count<<" unit : var_declaration \n"<<endl;
			 ofsLog<<$1->getBody()<<endl; ofsLog<<endl; 
			 
	
			 $$ = $1;
			 
			 }
			 
     | func_declaration { ofsLog<<"At line no: "<<line_count<<" unit : func_declaration \n"<<endl; 
			 ofsLog<<$1->getBody()<<endl; ofsLog<<endl; 
			 
	
			 $$ = $1;
			 
			 }
			 
     | func_definition { ofsLog<<"At line no: "<<line_count<<" unit : func_definition \n"<<endl; 
			 ofsLog<<$1->getBody()<<endl; ofsLog<<endl; 
			 
	
			 $$ = $1;
			 
			 }
     ;
     
func_declaration : new_scope_creation parameter_list RPAREN SEMICOLON { ofsLog<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n"<<endl;
		 ofsLog<<$1->getBody()<<endl;
		 //ofsLog<<endl;
		 
		 int i = 0;
		 
		 while(i<$2->size())
		 {
			ofsLog<<$2->at(i)->getReturnType()<<" "<<$2->at(i)->getBody();
		
			i++;
		
			if(i<$2->size()){
			
				ofsLog<<",";
		
			}
	
		 }	
		 
		 ofsLog<<*$3<<*$4<<endl;
		 ofsLog<<endl;	 
		 
		 
		 
		 SymbolInfo l($1->getID(), "ID");
		 SymbolInfo *tempSymbol = table.LookUp(l);
		 
		 if(tempSymbol!=NULL){
		 
		 vector<string> tempVector;
		 
		 for(int i=0;i<$2->size();i++)
		 {
		 	tempVector.push_back($2->at(i)->getReturnType());
		 }
		 
		 tempSymbol->setNumberOfParameters($2->size());
		 tempSymbol->setParameterTypes(tempVector);
		 tempSymbol->setId_array_func(3);
		 
		 table.LookUpAndReplace(*tempSymbol);
		 
		 }
		 
		 
		 
		 i=0;
		 
		 table.ExitScope(30);
		 
		 string *temp = new string("");
		 string *tempCode = new string("");
		 
		 temp->append($1->getBody());

		 
		 while(i<$2->size())
		 {
			
			temp->append($2->at(i)->getReturnType());
			temp->append(" ");
			temp->append($2->at(i)->getBody());
		
			i++;
		
			if(i<$2->size()){
			
				temp->append(",");
		
			}
	
		 }	
		 	 
		 
		 
		 
		 temp->append(*$3);
		 temp->append(*$4);

	
		 $$ = new StrCode(*temp, *tempCode);
			 
		  }
		  
		| new_scope_creation RPAREN SEMICOLON { ofsLog<<"At line no: "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n"<<endl;
		ofsLog<<$1->getBody()<<*$2<<*$3<<endl;
		ofsLog<<endl;
		
	
		 SymbolInfo l($1->getID(), "ID");
		 SymbolInfo *tempSymbol = table.LookUp(l);
		 
		 if(tempSymbol!=NULL){
		 
		 vector<string> tempVector;
		 		 
		 tempSymbol->setNumberOfParameters(0);
		 tempSymbol->setParameterTypes(tempVector);
		 tempSymbol->setId_array_func(3);
		 
		 table.LookUpAndReplace(*tempSymbol);
		 
	
		}	
		
		
		table.ExitScope(30);
		
		string *temp = new string("");
		string *tempCode = new string("");
	
		temp->append($1->getBody());
		//temp->append(" ");
		temp->append(*$2);
		temp->append(*$3);
		
		$$ = new StrCode(*temp, *tempCode);
		
		//within_function=0;
			  }
		;
		 
func_definition : new_scope_creation parameter_list RPAREN compound_statement {

	ofsLog<<"At line no: "<<line_count<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n"<<endl;
	
	
	ofsLog<<$1->getBody();
	
	int i = 0;
		 
		 while(i<$2->size())
		 {
			ofsLog<<$2->at(i)->getReturnType()<<" "<<$2->at(i)->getBody();
		
			i++;
		
			if(i<$2->size()){
			
				ofsLog<<",";
		
			}
	
		 }	
		 
		 ofsLog<<*$3<<$4->getBody()<<endl;
		 ofsLog<<endl;
		 
		 		 
		 SymbolInfo l($1->getID(), "ID");
		 SymbolInfo *tempSymbol = table.LookUp(l);
		 
		 if(tempSymbol->getNumberOfParameters() != -1 && tempSymbol->getNumberOfParameters() != $2->size() && tempSymbol->getId_array_func()==3)
		 {	
		 	error_count++;
		 	ofsLog<<"Error at line no: "<<line_count<<" Total number of arguments mismatch with declaration in function "<<$1->getID()<<" \n"<<endl;
		 	ofsLog<<endl;
		 	
		 	ofsError<<"Error at line no: "<<line_count<<" Total number of arguments mismatch with declaration in function "<<$1->getID()<<" \n"<<endl;
		 	ofsError<<endl;
		 }
		 
		 
		 
		 vector<string> tempVector;
		 
		 for(int i=0;i<$2->size();i++)
		 {
		 	tempVector.push_back($2->at(i)->getReturnType());
		 }
		 
		 tempSymbol->setNumberOfParameters($2->size());
		 tempSymbol->setParameterTypes(tempVector);
		 tempSymbol->setId_array_func(3);
		 
		 table.LookUpAndReplace(*tempSymbol);
		 
		 
	
	table.ExitScope(30);
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	i=0;
	
	temp->append($1->getBody());
	
	
	while(i<$2->size())
	{
			
			temp->append($2->at(i)->getReturnType());
			temp->append(" ");
			temp->append($2->at(i)->getBody());
		
			i++;
		
			if(i<$2->size()){
			
				temp->append(",");
		
			}
	
	}	
	
	
	
	temp->append(*$3);
	temp->append($4->getBody());
	
	
	
	$$ = new StrCode(*temp, *tempCode);
		

	}
		| new_scope_creation RPAREN compound_statement {
		
	ofsLog<<"At line no: "<<line_count<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement \n"<<endl;
	
		
	
	ofsLog<<$1->getBody()<<*$2<<$3->getBody()<<endl;
	ofsLog<<endl;
		
	
	
		 SymbolInfo l($1->getID(), "ID");
		 SymbolInfo *tempSymbol = table.LookUp(l);
		 
		 if(tempSymbol->getNumberOfParameters() != -1 && tempSymbol->getNumberOfParameters() != 0 && tempSymbol->getId_array_func()==3)
		 {	
		 	error_count++;
		 	ofsLog<<"Error at line no: "<<line_count<<" Total number of arguments mismatch with declaration in function "<<$1->getID()<<" \n"<<endl;
		 	ofsLog<<endl;
		 	
		 	ofsError<<"Error at line no: "<<line_count<<" Total number of arguments mismatch with declaration in function "<<$1->getID()<<" \n"<<endl;
		 	ofsError<<endl;
		 }
		 
		 
		 
		 vector<string> tempVector;
		 
		 
		 tempSymbol->setNumberOfParameters(0);
		 tempSymbol->setParameterTypes(tempVector);
		 tempSymbol->setId_array_func(3);
		 
		 table.LookUpAndReplace(*tempSymbol);
		 	
	
	
	
	table.ExitScope(30);
	
	//within_function=0;
	
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getBody());
	temp->append(*$2);
	temp->append($3->getBody());
	
	
	tempCode->append($1->getID());
	tempCode->append(" PROC\n");
	tempCode->append("\n");
	
	if($1->getID().compare("main")==0)
	{	
		tempCode->append(";initialize data segment\n");
		tempCode->append("MOV AX, @DATA\nMOV DS, AX\n");
		tempCode->append("\n");
	}
	
	tempCode->append($3->getCode());
	tempCode->append("\n");
	
	if($1->getID().compare("main")==0)
	{	
		tempCode->append(";returning control to the OS\n");
		tempCode->append("MOV AH, 4CH\nINT 21H\n");
		tempCode->append("\n");
	
	}
	
	
	tempCode->append($1->getID());
	tempCode->append(" ENDP\n");
	//tempCode->append("END ");
	//tempCode->append($1->getID());
	//tempCode->append("\n");
	
	
	
	
	
	$$ = new StrCode(*temp, *tempCode);
	
		
		}
 		;
 		


new_scope_creation : type_specifier ID LPAREN {

	
	SymbolInfo *tempinfo = table.LookUp(*$2);
	
	if(tempinfo!=NULL && tempinfo->getId_array_func()!=3)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$2->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$2->getName()<<" \n"<<endl;
		ofsLog<<endl;
	}
	
	else if(tempinfo!=NULL && tempinfo->getId_array_func()==3)
	{
		if( tempinfo->getReturnType().compare($1->getBody())!=0)
		{
			error_count++;
			ofsLog<<"Error at line no: "<<line_count<<" Return type mismatch in function declaration in function "<<$2->getName()<<" \n"<<endl;
			ofsLog<<endl;
		
			ofsError<<"Error at line no: "<<line_count<<" Return type mismatch in function declaration in function "<<$2->getName()<<" \n"<<endl;
			ofsLog<<endl;
		
		}
	}
	
	
	SymbolInfo si($2->getName(),$2->getType());
	si.setReturnType($1->getBody());
	si.setId_array_func(3);
	si.setNumberOfParameters(-1);
		 
	table.Insert(si);

	
	table.EnterScope(30);
	within_function = 1;
	
		
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getBody());
	temp->append(" ");
	temp->append($2->getName());
	temp->append(*$3);
	
	IDInfo *i = new IDInfo($2->getName(), *temp);
	
	
	i->setCode(*tempCode);
	
	$$ = i;
	
	};


 						


parameter_list  : parameter_list COMMA type_specifier ID { 
	
	ofsLog<<"At line no: "<<line_count<<" parameter_list  : parameter_list COMMA type_specifier ID \n"<<endl;
	
	SymbolInfo *tempSymbol = table.LookUpInCurrentScopeTable(*$4);
	
	if(tempSymbol!=NULL)
	{
	
		error_count++;
		
		ofsLog<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$4->getName()<<" in parameter \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$4->getName()<<" in parameter \n"<<endl;
		ofsError<<endl;
	}
	
	int i=0;
	
	while(i<$1->size())
	{
		ofsLog<<$1->at(i)->getReturnType()<<" "<<$1->at(i)->getBody();
		
		i++;
		
		if(i<$1->size()){
			
			ofsLog<<",";
		
		}
	
	}
	
	
	
	
	ofsLog<<*$2<<$3->getBody()<<" "<<$4->getName()<<endl;
	ofsLog<<endl;
	
	SymbolInfo si($4->getName(),$4->getType());
	si.setReturnType($3->getBody());
	si.setId_array_func(1);
		 
	table.Insert(si);
	
	
	vector<ReturnInfo*>* tempVect = $1;
	
	ReturnInfo* r = new ReturnInfo($4->getName(), $3->getBody(), 1);
	r->setCode("");	
	
	tempVect->push_back(r);
	
	$$ = tempVect;
	

	}
		| parameter_list COMMA type_specifier { 
	
	ofsLog<<"At line no: "<<line_count<<" parameter_list  : parameter_list COMMA type_specifier \n"<<endl;
	
	
	int i=0;
	
	while(i<$1->size())
	{
		ofsLog<<$1->at(i)->getReturnType()<<" "<<$1->at(i)->getBody();
		
		i++;
		
		if(i<$1->size()){
			
			ofsLog<<",";
		
		}
	
	}
	
	
	
	ofsLog<<*$2<<" "<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	
	vector<ReturnInfo*>* tempVect = $1;
	
	ReturnInfo* r = new ReturnInfo("", $3->getBody(), 1);	
	
	r->setCode("");
	
	tempVect->push_back(r);
	
	$$ = tempVect;
	

	}
 		| type_specifier ID { 
	
	ofsLog<<"At line no: "<<line_count<<" parameter_list  : type_specifier ID \n"<<endl;
	
	ofsLog<<$1->getBody()<<" "<<$2->getName()<<endl;
	ofsLog<<endl;
	
	
	SymbolInfo si($2->getName(),$2->getType());
	si.setReturnType($1->getBody());
	si.setId_array_func(1);
		 
	table.Insert(si);
	
	
	vector<ReturnInfo*>* paraVect = new vector<ReturnInfo*>();
	
	ReturnInfo* r = new ReturnInfo($2->getName(), $1->getBody(), 1);
	
	r->setCode("");
	
	paraVect->push_back(r);
	
	$$ = paraVect;
	

	}
		| type_specifier { 
	
	ofsLog<<"At line no: "<<line_count<<" parameter_list  : type_specifier \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	vector<ReturnInfo*>* paraVect = new vector<ReturnInfo*>();
	
	ReturnInfo* r = new ReturnInfo("", $1->getBody(), 1);
	
	r->setCode("");
	
	paraVect->push_back(r);
	
	$$ = paraVect;
	

	}
 		;

 		
compound_statement : lcurl_scope_creation statements RCURL { 
	
	ofsLog<<"At line no: "<<line_count<<" compound_statement : LCURL statements RCURL \n"<<endl;
	
	ofsLog<<$1->getBody()<<$2->getBody()<<*$3<<endl;
	ofsLog<<endl;
	
	ofsLog<<table.PrintAllScopeTables()<<"\n"<<endl;
	
	
	string *temp = new string("");
	string *tempCode = new string($2->getCode());
	
	temp->append($1->getBody());
	temp->append("\n");
	temp->append($2->getBody());
	temp->append(*$3);
	temp->append("\n");
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
 		    | lcurl_scope_creation RCURL { 
	
	ofsLog<<"At line no: "<<line_count<<" compound_statement : LCURL RCURL \n"<<endl;
	
	ofsLog<<$1->getBody()<<*$2<<endl;
	ofsLog<<endl;
	
	ofsLog<<table.PrintAllScopeTables()<<"\n"<<endl;
	
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getBody());
	temp->append("\n");
	temp->append(*$2);
	temp->append("\n");
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
 		    ;
 		    
 		    
 		    
 		    
 		 
lcurl_scope_creation : LCURL {
		
		if(within_function != 1){
			
			table.EnterScope(30);
			
		}
		
		else{
			within_function = 0;
		}
		
		$$ = new StrCode(*$1, "");

	}
	;







 		    
var_declaration : type_specifier declaration_list SEMICOLON { 
	
	ofsLog<<"At line no: "<<line_count<<" var_declaration : type_specifier declaration_list SEMICOLON \n"<<endl;
	
	string t = "void";
	
	if(t.compare($1->getBody())==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Variable type cannot be void \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Variable type cannot be void \n"<<endl;
		ofsLog<<endl;
	}
	
	
	ofsLog<<$1->getBody()<<" ";
	
	int i=0;
	
	while(i<$2->size())
	{
		ofsLog<<$2->at(i)->getBody();
		i++;
		
		if(i<$2->size())
		{
			ofsLog<<",";
		}
	
	}
	
	ofsLog<<*$3<<endl;
	ofsLog<<endl;
	
	
	
	
	
	i=0;
	
	for(i=0;i<$2->size();i++)
	{
		SymbolInfo sp($2->at(i)->getID(), "ID");
		sp.setReturnType($1->getBody());
		sp.setId_array_func( $2->at(i)->getId_arr() );
		
		SymbolInfo *y = table.LookUpInCurrentScopeTable(sp);
		
		if(y->getReturnType().compare("NOT_DEFINED")==0){
		
		table.LookUpAndReplace(sp);
		}
	
	
	}
	
	
	
	
	
	i=0;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	
	
	temp->append($1->getBody());
	temp->append(" ");
	
	while(i<$2->size())
	{
		//ofsLog<<$2[i]->getBody();
		temp->append($2->at(i)->getBody());
		i++;
		
		if(i<$2->size())
		{
			temp->append(",");
		}
	
	}
	
	
	temp->append(*$3);
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
 		 ;
 		 
type_specifier	: INT { 
	
	ofsLog<<"At line no: "<<line_count<<" type_specifier	: INT \n"<<endl;
	
	ofsLog<<*$1<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	
	$$ = new StrCode(*temp, *tempCode);
	
	

	}
 		| FLOAT { 
	
	ofsLog<<"At line no: "<<line_count<<" type_specifier	: FLOAT \n"<<endl;
	
	ofsLog<<*$1<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
 		| VOID { 
	
	ofsLog<<"At line no: "<<line_count<<" type_specifier	: VOID \n"<<endl;
	
	ofsLog<<*$1<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
 		;
 		
declaration_list : declaration_list COMMA ID { 
	
	ofsLog<<"At line no: "<<line_count<<" declaration_list : declaration_list COMMA ID \n"<<endl;
	
	
	SymbolInfo *tempSymbol = table.LookUpInCurrentScopeTable(*$3);
	
	if(tempSymbol!=NULL)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$3->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$3->getName()<<" \n"<<endl;
		ofsError<<endl;
	}
	
	
	
	
	for(int i=0;i<$1->size();i++)
	{
		ofsLog<<$1->at(i)->getBody();
		ofsLog<<",";
	}
	
	ofsLog<<$3->getName()<<endl;
	ofsLog<<endl;
	
	
	
	SymbolInfo si($3->getName(),$3->getType());
	si.setId_array_func(1);
	si.setReturnType("NOT_DEFINED");
		 
	table.Insert(si);
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($3->getName());
	
	
	string *idname = new string("");
	idname->append($3->getName());
	idname->append(replaceChar( table.getCurrentTableID(), '.', '_' ));
	
	dataSegment->append(*idname);
	dataSegment->append(" dw ?\n");
	
	
	
	
	vector<IDInfo*>* vect1 = $1;
	
	IDInfo* info = new IDInfo($3->getName(), *temp);
	info->setId_arr(1);
	info->setCode(*tempCode);
	
	vect1->push_back(info);
	
	
	$$ = vect1;
	

	}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD { 
	
	ofsLog<<"At line no: "<<line_count<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n"<<endl;
	
	
	SymbolInfo *tempSymbol = table.LookUpInCurrentScopeTable(*$3);
	
	if(tempSymbol!=NULL)
	{	
	error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$3->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$3->getName()<<" \n"<<endl;
		ofsError<<endl;
	}
	
	
	
	for(int i=0;i<$1->size();i++)
	{
		ofsLog<<$1->at(i)->getBody();
		ofsLog<<",";
	}
	
	ofsLog<<$3->getName()<<*$4<<$5->getName()<<*$6<<endl;
	ofsLog<<endl;
	
	SymbolInfo si($3->getName(),$3->getType());
	si.setId_array_func(2);
	si.setReturnType("NOT_DEFINED");
		 
	table.Insert(si);
	
	
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($3->getName());
	temp->append(*$4);
	temp->append($5->getName());
	temp->append(*$6);
	
	
	string *idname = new string("");
	idname->append($3->getName());
	idname->append(replaceChar( table.getCurrentTableID(), '.', '_' ));
	
	dataSegment->append(*idname);
	dataSegment->append(" dw");
	
	int arraySize;
	int k=0;
	
	stringstream ss;  
  	ss << $5->getName();  
  	ss >> arraySize;
  	
  	while(k<arraySize)
  	{
  		dataSegment->append(" ?");
  		
  		k++;
  		
  		if(k<arraySize)
  		{
  			dataSegment->append(",");
  		}
  	
  	}
  	
  	dataSegment->append("\n");
	
	
	
	vector<IDInfo*>* vect1 = $1;
	
	IDInfo* info = new IDInfo($3->getName(), *temp);
	info->setId_arr(2);
	info->setCode(*tempCode);
	
	vect1->push_back(info);
	
	
	$$ = vect1;
	

	}
 		  | ID { 
	
	ofsLog<<"At line no: "<<line_count<<" declaration_list : ID \n"<<endl;
	
	
	SymbolInfo *tempSymbol = table.LookUpInCurrentScopeTable(*$1);
	
	if(tempSymbol!=NULL)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$1->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$1->getName()<<" \n"<<endl;
		ofsError<<endl;
	}
	
	
	
	ofsLog<<$1->getName()<<endl;
	//ofsLog<<$1->getType()<<endl;
	ofsLog<<endl;
	
	SymbolInfo si($1->getName(),$1->getType());
	si.setId_array_func(1);
	si.setReturnType("NOT_DEFINED");
		 
	table.Insert(si);
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	
	temp->append($1->getName());
	
	
	string *idname = new string("");
	idname->append($1->getName());
	idname->append(replaceChar( table.getCurrentTableID(), '.', '_' ));
	
	dataSegment->append(*idname);
	dataSegment->append(" dw ?\n");
	
	
	
	
	
	IDInfo *i = new IDInfo($1->getName(), *temp);
	i->setId_arr(1);
	i->setCode(*tempCode);
	
	vector<IDInfo*>* vect1 = new vector<IDInfo*>();
	
	vect1->push_back(i);
	
	$$ = vect1;
	
	

	}
 		  | ID LTHIRD CONST_INT RTHIRD { 
	
	ofsLog<<"At line no: "<<line_count<<" declaration_list : ID LTHIRD CONST_INT RTHIRD \n"<<endl;
	
	
	SymbolInfo *tempSymbol = table.LookUpInCurrentScopeTable(*$1);
	
	if(tempSymbol!=NULL)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$1->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Multiple declaration of "<<$1->getName()<<" \n"<<endl;
		ofsError<<endl;
	}
	
	
	ofsLog<<$1->getName()<<*$2<<$3->getName()<<*$4<<endl;
	ofsLog<<endl;
	
	SymbolInfo si($1->getName(),$1->getType());
	si.setId_array_func(2);
	si.setReturnType("NOT_DEFINED");
		 
	table.Insert(si);
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getName());
	temp->append(*$2);
	temp->append($3->getName());
	temp->append(*$4);
	
	
	string *idname = new string("");
	idname->append($1->getName());
	idname->append(replaceChar( table.getCurrentTableID(), '.', '_' ));
	
	dataSegment->append(*idname);
	dataSegment->append(" dw");
	
	int arraySize;
	int k=0;
	
	stringstream ss;  
  	ss << $3->getName();  
  	ss >> arraySize;
  	
  	while(k<arraySize)
  	{
  		dataSegment->append(" ?");
  		
  		k++;
  		
  		if(k<arraySize)
  		{
  			dataSegment->append(",");
  		}
  	
  	}
  	
  	dataSegment->append("\n");
	
	
	
	
	
	IDInfo *i = new IDInfo($1->getName(), *temp);
	i->setId_arr(2);
	i->setCode(*tempCode);
	
	vector<IDInfo*>* vect1 = new vector<IDInfo*>();
	
	vect1->push_back(i);
	
	$$ = vect1;
	
	//$$ = temp;
	

	}
 		  ;
 		  
statements : statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statements : statement \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	
	temp->append($1->getBody());
	temp->append("\n");
	
	ofsLog<<endl;
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
	   | statements statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statements : statements statement \n"<<endl;
	
	ofsLog<<$1->getBody()<<$2->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	tempCode->append($2->getCode());
	
	temp->append($1->getBody());
	//temp->append(" ");
	temp->append($2->getBody());
	temp->append("\n");
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
	   ;
	   
statement : var_declaration { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : var_declaration \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	$$ = $1;
	

	}
	  | expression_statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : expression_statement \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;

	
	$$ = $1;
	

	}
	  | compound_statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : compound_statement \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	table.ExitScope(30);

	
	$$ = $1;
	

	}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n "<<endl;
	ofsLog<<*$1<<*$2<<$3->getBody()<<$4->getBody()<<$5->getBody()<<*$6<<$7->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($3->getCode());
	
	/*
						$3's code at first, which is already done by assigning $$=$3
						create two labels and append one of them in $$->code
						compare $4's symbol with 0
						if equal jump to 2nd label
						append $7's code
						append $5's code
						append the second label in the code
					*/
	
	char *label1=newLabel();
	char *label2=newLabel();				
	
	tempCode->append("; FOR\n");
	tempCode->append("\n");				
	tempCode->append(string(label1));
	tempCode->append(": \n");
	tempCode->append($4->getCode());
	tempCode->append("MOV AX, ");
	tempCode->append($4->getSymbol());
	tempCode->append("\n");
	tempCode->append("CMP AX, 0\n");
	tempCode->append("JE ");
	//tempCode->append("\n");
	tempCode->append(string(label2));
	tempCode->append("\n");
	tempCode->append($7->getCode());
	tempCode->append($5->getCode());
	tempCode->append("\n");
	tempCode->append("JMP ");
	tempCode->append(string(label1));
	tempCode->append("\n");
	tempCode->append(string(label2));
	tempCode->append(": \n");
	//tempCode->append("\n");			
					
	
	temp->append(*$1);
	temp->append(*$2);
	temp->append($3->getBody());
	temp->append(" ");
	temp->append($4->getBody());
	temp->append(" ");
	temp->append($5->getBody());
	temp->append(*$6);
	temp->append(" ");
	temp->append($7->getBody());
	temp->append("\n");
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
	  | IF LPAREN expression RPAREN statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : IF LPAREN expression RPAREN statement \n"<<endl;
	
	ofsLog<<*$1<<*$2<<$3->getBody()<<*$4<<$5->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	temp->append(*$2);
	temp->append($3->getBody());
	temp->append(*$4);
	temp->append(" ");
	temp->append($5->getBody());
	temp->append("\n");
	
	
	tempCode->append(";");
	tempCode->append(*$1);
	tempCode->append(*$2);
	tempCode->append($3->getBody());
	tempCode->append(*$4);
	tempCode->append(" ");
	tempCode->append($5->getBody());
	tempCode->append("\n");
	
	
	char *label=newLabel();
	
	tempCode->append("MOV AX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	tempCode->append("CMP AX, 0\n");
	tempCode->append("JE ");
	tempCode->append(string(label));
	tempCode->append("\n");
	tempCode->append($5->getCode());
	tempCode->append(string(label));
	tempCode->append(": \n");
	
	
	$$ = new StrCode(*temp, *tempCode);
	

	}  %prec LOWER_THAN_ELSE
	  | IF LPAREN expression RPAREN statement ELSE statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : IF LPAREN expression RPAREN statement ELSE statement \n"<<endl;
	
	ofsLog<<*$1<<*$2<<$3->getBody()<<*$4<<" "<<$5->getBody()<<"\n"<<*$6<<" "<<$7->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($3->getCode());
	
	temp->append(*$1);
	temp->append(*$2);
	temp->append($3->getBody());
	temp->append(*$4);
	temp->append(" ");
	temp->append($5->getBody());
	temp->append("\n");
	temp->append(*$6);
	temp->append(" ");
	temp->append($7->getBody());
	temp->append("\n");
	
	
	tempCode->append(";");
	tempCode->append(*$1);
	tempCode->append(*$2);
	tempCode->append($3->getBody());
	tempCode->append(*$4);
	tempCode->append(" ");
	tempCode->append($5->getBody());
	tempCode->append(*$6);
	tempCode->append(" ");
	tempCode->append($7->getBody());
	tempCode->append("\n");
	
	
	
	char *label=newLabel();
	char *label2=newLabel();
	
	tempCode->append("MOV AX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	tempCode->append("CMP AX, 0\n");
	tempCode->append("JE ");
	tempCode->append(string(label));
	tempCode->append("\n");
	tempCode->append($5->getCode());
	
	tempCode->append("JMP ");
	tempCode->append(string(label2));
	tempCode->append("\n");
	
	tempCode->append(string(label));
	tempCode->append(": \n");
	tempCode->append($7->getCode());
	tempCode->append("\n");
	
	tempCode->append(string(label2));
	tempCode->append(": \n");
	
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
	  | WHILE LPAREN expression RPAREN statement { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : WHILE LPAREN expression RPAREN statement \n"<<endl;
	
	ofsLog<<*$1<<*$2<<$3->getBody()<<*$4<<$5->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	
	
	char *label1=newLabel();
	char *label2=newLabel();
	
	
	string *tempCode = new string("\n");
	tempCode->append("; WHILE\n");
	tempCode->append(string(label1));
	tempCode->append(":\n");
	
	//tempCode->append($3->getCode());
	tempCode->append("MOV AX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	tempCode->append("CMP AX, 0\n");
	tempCode->append("JE ");
	tempCode->append(string(label2));
	tempCode->append("\n");
	tempCode->append($3->getCode());
	tempCode->append($5->getCode());
	//tempCode->append($3->getCode());
	tempCode->append("JMP ");
	tempCode->append(string(label1));
	tempCode->append("\n");
	tempCode->append(string(label2));
	tempCode->append(":\n");
	tempCode->append($3->getCode());
	/*
						$3's code at first, which is already done by assigning $$=$3
						create two labels and append one of them in $$->code
						compare $4's symbol with 0
						if equal jump to 2nd label
						append $7's code
						append $5's code
						append the second label in the code
					*/
	
	
	
	
	
	temp->append(*$1);
	temp->append(*$2);
	temp->append($3->getBody());
	temp->append(*$4);
	temp->append(" ");
	temp->append($5->getBody());
	temp->append("\n");
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n"<<endl;
	
	ofsLog<<*$1<<*$2<<$3->getName()<<*$4<<*$5<<endl;
	ofsLog<<endl;
	
	SymbolInfo *sinfo = table.LookUp(*$3);
	
	if(sinfo==NULL)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Undeclared variable "<<$3->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Undeclared variable "<<$3->getName()<<" \n"<<endl;
		ofsError<<endl;
	}
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	string *varSymbol = new string("");
	varSymbol->append($3->getName());
	varSymbol->append(replaceChar(table.getCurrentTableID(), '.', '_' ));
	
	tempCode->append("MOV AX, ");
	tempCode->append(*varSymbol);
	tempCode->append("\n");
	tempCode->append("CALL OUTDEC\n");
	
	/*MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h*/

	tempCode->append("MOV DL, 10\nMOV AH, 02H\nINT 21H\nMOV DL, 13\nMOV AH, 02H\nINT 21H\n\n");
	
	temp->append(*$1);
	temp->append(*$2);
	temp->append($3->getName());
	temp->append(*$4);
	temp->append(*$5);
	
	$$ = new StrCode(*temp, *tempCode);
	

	}
	  | RETURN expression SEMICOLON { 
	
	ofsLog<<"At line no: "<<line_count<<" statement : RETURN expression SEMICOLON \n"<<endl;

	ofsLog<<*$1<<" "<<$2->getBody()<<*$3<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	temp->append(" ");
	temp->append($2->getBody());
	temp->append(*$3);
	
	$$ = new StrCode(*temp, *tempCode);
	
	}
	  ;
	  
expression_statement 	: SEMICOLON { 
	
	ofsLog<<"At line no: "<<line_count<<" expression_statement 	: SEMICOLON \n"<<endl;
	
	ofsLog<<*$1<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	
	
	
	$$ = new StrCode(*temp, *tempCode);
	

	}			
			| expression SEMICOLON { 
	
	ofsLog<<"At line no: "<<line_count<<" expression_statement 	: expression SEMICOLON \n"<<endl;
	
	ofsLog<<$1->getBody()<<*$2<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	
	temp->append($1->getBody());
	temp->append(*$2);
	
	//tempCode->append($1->getCode());
	
	$$ = new StrCode(*temp, *tempCode);
	
	$$->setSymbol($1->getSymbol());
	

	}
			;
	  
variable : ID { 
	
	ofsLog<<"At line no: "<<line_count<<" variable : ID \n"<<endl;
	
	ofsLog<<$1->getName()<<endl;
	ofsLog<<endl;
	
	
	SymbolInfo *s = table.LookUp(*$1);
	
	if(s==NULL)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Undeclared Variable "<<$1->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Undeclared Variable "<<$1->getName()<<" \n"<<endl;
		ofsError<<endl;
		
		ReturnInfo *r = new ReturnInfo($1->getName(),"",1);
		r->setId("");
		r->setCode("");
		
		$$=r;
	}
	
	else{
	
	
	ReturnInfo *r = new ReturnInfo($1->getName(), s->getReturnType(), s->getId_array_func());
	
	r->setId($1->getName());
	
	string *varSymbol = new string("");
	varSymbol->append($1->getName());
	varSymbol->append(replaceChar(table.getScopeID(*$1), '.', '_' ));
	
	r->setCode("");
	
	r->setSymbol(*varSymbol);
	
	//r->setId_or_array(1);
	
	$$ = r;
	}
	
	}		
	 | ID LTHIRD expression RTHIRD { 
	
	ofsLog<<"At line no: "<<line_count<<" variable : ID LTHIRD expression RTHIRD \n"<<endl;
	
	ofsLog<<$1->getName()<<*$2<<$3->getBody()<<*$4<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	
	temp->append($1->getName());
	temp->append(*$2);
	temp->append($3->getBody());
	temp->append(*$4);

	SymbolInfo *s = table.LookUp(*$1);

	if(s==NULL)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Undeclared Variable "<<$1->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Undeclared Variable "<<$1->getName()<<" \n"<<endl;
		ofsError<<endl;
		
		ReturnInfo *r = new ReturnInfo(*temp,"",1);
		r->setId("");
		r->setCode("");
		
		$$=r;
	}
	
	else{
	
	
	if($3->getReturnType().compare("int")!=0)
	{
		error_count++;
		
		ofsLog<<"Error at line no: "<<line_count<<" Expression inside third bracket is not an integer. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Expression inside third bracket is not an integer. \n"<<endl;
		ofsError<<endl;
	}
	
	
	
	ReturnInfo *r = new ReturnInfo(*temp, s->getReturnType(), s->getId_array_func());
	
	//cout<<"RetType: "<<s->getReturnType()<<" Name: "<<s->getName()<<" IDA: "<<s->getId_array_func()<<"\n"<<endl;
	
	r->setId($1->getName());
	
	string *tempCode = new string("");
	
	tempCode->append("MOV BX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	tempCode->append("ADD BX, BX\n");
	
	
	
	string *varSymbol = new string("");
	varSymbol->append($1->getName());
	varSymbol->append(replaceChar(table.getScopeID(*$1), '.', '_' ));
	varSymbol->append("[BX]");
	
	r->setSymbol(*varSymbol);
	
	//tempCode->append("MOV AX, ");
	//tempCode->append(*varSymbol);
	//tempCode->append("[BX]\n");
	
	r->setCode(*tempCode);
	//r->setId_or_array(2);
	
	$$ = r;
	}
	

	}
	 ;
	 
 expression : logic_expression	{ 
	
	ofsLog<<"At line no: "<<line_count<<" expression : logic_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	
	temp->append($1->getBody());
	
	
	ReturnInfo *r = new ReturnInfo(*temp, $1->getReturnType());
	
	r->setCode(*tempCode);
	r->setSymbol($1->getSymbol());
	
	
	$$ = r;

	}
	   | variable ASSIGNOP logic_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" expression : variable ASSIGNOP logic_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<*$2<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	//SymbolInfo *sinfo = new SymbolInfo($1->get)
	
	string *temp = new string("");
	string *tempCode = new string($3->getCode());
	
	char *tempVar=newTemp();
	dataSegment->append(string(tempVar));
	dataSegment->append(" dw ?\n");
	
	temp->append($1->getBody());
	temp->append(*$2);
	temp->append($3->getBody());
	
	tempCode->append(";");
	tempCode->append($1->getBody());
	tempCode->append(*$2);
	tempCode->append($3->getBody());
	tempCode->append("\n");
	
	if($1->getBody().find("[") == std::string::npos){
		
		tempCode->append("MOV AX, ");
		tempCode->append($3->getSymbol());
		tempCode->append("\n");
		
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
		
		
		tempCode->append("MOV ");
		tempCode->append($1->getSymbol());
		tempCode->append(", AX\n");
		tempCode->append("\n");
	
	}
	else{	
		//tempCode->append($1->getCode());
		tempCode->append("MOV AX, ");
		tempCode->append($3->getSymbol());
		tempCode->append("\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
		tempCode->append($1->getCode());
		tempCode->append("\n");
		tempCode->append("MOV AX, ");
		tempCode->append(string(tempVar));
		tempCode->append("\n");
		tempCode->append("MOV ");
		tempCode->append($1->getSymbol());
		tempCode->append(", AX\n");
	}
	
	
	
	
	

	
	SymbolInfo sinfo($1->getId(), "ID");
	
	SymbolInfo *tempInfo = table.LookUp(sinfo);
	
	if(tempInfo==NULL)
	{
		
		
	}
	
	else{
	
	
	if($3->getReturnType().compare("void")==0)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	else{
	
	
	
	if(($1->getId_or_array()==1 && $1->getBody().find("[") == std::string::npos) || ($1->getId_or_array()==2 && $1->getBody().find("[") != std::string::npos  ) )
	{
		if($1->getReturnType().compare( $3->getReturnType() ) !=0 )
		{
			error_count++;
			
			ofsLog<<"Error at line no: "<<line_count<<" Type Mismatch \n"<<endl;
			ofsLog<<endl;
			
			
			ofsError<<"Error at line no: "<<line_count<<" Type Mismatch \n"<<endl;
			ofsError<<endl;
		}
	
	}
	
	else if($1->getId_or_array()==2 && ($1->getBody().find("[") == std::string::npos))
	{
		error_count++;
		
		ofsLog<<"Error at line no: "<<line_count<<" Type Mismatch, "<<$1->getId()<<" is an array. \n"<<endl;
		ofsLog<<endl;
			
		ofsError<<"Error at line no: "<<line_count<<" Type Mismatch, "<<$1->getId()<<" is an array. \n"<<endl;
		ofsError<<endl;
	
	}
	
	else if($1->getId_or_array()==1  && $1->getBody().find("[") != std::string::npos)
	{
		error_count++;
		
		ofsLog<<"Error at line no: "<<line_count<<" Type Mismatch, "<<$1->getId()<<" is not an array. \n"<<endl;
		ofsLog<<endl;
			
		ofsError<<"Error at line no: "<<line_count<<" Type Mismatch, "<<$1->getId()<<" is not an array. \n"<<endl;
		ofsError<<endl;
	}
	
	}
	}
	
	
	
	
	ReturnInfo *r = new ReturnInfo(*temp, $1->getReturnType());
	
	r->setCode(*tempCode);
	
	
	$$ = r;

	}	
	   ;
			
logic_expression : rel_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" logic_expression : rel_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	$$ = $1;

	}	
		 | rel_expression LOGICOP rel_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" logic_expression  : rel_expression LOGICOP rel_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<$2->getName()<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	if($1->getReturnType().compare("void")==0 || $3->getReturnType().compare("void")==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	
	
	
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	tempCode->append($3->getCode());
	
	temp->append($1->getBody());
	temp->append($2->getName());
	temp->append($3->getBody());
	
	
	tempCode->append("MOV AX, ");
	tempCode->append($1->getSymbol());
	
	//cout<<$1->getSymbol()<<endl;
	//cout<<$3->getSymbol()<<endl;
	
	tempCode->append("\n");
	tempCode->append("MOV BX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	
	char *tempVar=newTemp();
	
	if($2->getName().compare("&&")==0){
	
	//cout<<"getyourboastees!"<<endl;
		tempCode->append("AND AX, BX\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
	}
	else if($2->getName().compare("||")==0){
	
	//cout<<"getyourboastees!"<<endl;
		tempCode->append("OR AX, BX\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
	}
	
	dataSegment->append(string(tempVar));
	dataSegment->append(" dw ?\n");
	
	
	ReturnInfo *r = new ReturnInfo(*temp, "int");
	
	r->setCode(*tempCode);
	
	r->setSymbol(string(tempVar));
	
	
	$$ = r;
	

	}	
		 ;
			
rel_expression	: simple_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" rel_expression	: simple_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	$$ = $1;
	

	}
		| simple_expression RELOP simple_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" rel_expression	: simple_expression RELOP simple_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<$2->getName()<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	
	if($1->getReturnType().compare("void")==0 || $3->getReturnType().compare("void")==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	
	
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	tempCode->append($3->getCode());
	
	char *tempVar=newTemp();
	char *label1=newLabel();
	char *label2=newLabel();
	
	
	temp->append($1->getBody());
	temp->append($2->getName());
	temp->append($3->getBody());
	
	tempCode->append(";");
	tempCode->append($1->getBody());
	tempCode->append($2->getName());
	tempCode->append($3->getBody());
	tempCode->append("\n");
	
	tempCode->append("MOV AX, ");
	tempCode->append($1->getSymbol());
	tempCode->append("\n");
	tempCode->append("CMP AX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	
	if($2->getName().compare("<")==0)
	{
		tempCode->append("JL ");
		tempCode->append(string(label1));
		tempCode->append("\n");
		
		//cout<<"hello"<<endl;
	}
	else if($2->getName().compare("<=")==0)
	{
		tempCode->append("JLE ");
		tempCode->append(string(label1));
		tempCode->append("\n");
	}
	else if($2->getName().compare(">")==0)
	{
		tempCode->append("JG ");
		tempCode->append(string(label1));
		tempCode->append("\n");
	}
	else if($2->getName().compare(">=")==0)
	{
		tempCode->append("JGE ");
		tempCode->append(string(label1));
		tempCode->append("\n");
	}
	else if($2->getName().compare("==")==0)
	{
		tempCode->append("JE ");
		tempCode->append(string(label1));
		tempCode->append("\n");
	}
	else if($2->getName().compare("!=")==0)
	{
		tempCode->append("JNE ");
		tempCode->append(string(label1));
		tempCode->append("\n");
	}
	
	tempCode->append("MOV ");
	tempCode->append(string(tempVar));
	tempCode->append(", 0\n");
	tempCode->append("JMP ");
	tempCode->append(string(label2));
	tempCode->append("\n");
	tempCode->append(string(label1));
	tempCode->append(": \n");
	tempCode->append("MOV ");
	tempCode->append(string(tempVar));
	tempCode->append(", 1\n");
	tempCode->append(string(label2));
	tempCode->append(": \n");
	//tempCode->append("MOV ");
	
	dataSegment->append(string(tempVar));
	dataSegment->append(" dw ?\n");
	
	
	ReturnInfo *r = new ReturnInfo(*temp, "int");
	
	r->setCode(*tempCode);
	r->setSymbol(string(tempVar));
	
	$$ = r;

	}	
		;
				
simple_expression : term { 
	
	ofsLog<<"At line no: "<<line_count<<" simple_expression : term \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	$$ = $1;
	

	}
		  | simple_expression ADDOP term { 
	
	ofsLog<<"At line no: "<<line_count<<" simple_expression : simple_expression ADDOP term \n"<<endl;
	
	ofsLog<<$1->getBody()<<$2->getName()<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	if($1->getReturnType().compare("void")==0 || $3->getReturnType().compare("void")==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	tempCode->append($3->getCode());
	char *tempVar = newTemp();
	
	temp->append($1->getBody());
	temp->append($2->getName());
	temp->append($3->getBody());
	
	tempCode->append(";");
	tempCode->append($1->getBody());
	tempCode->append($2->getName());
	tempCode->append($3->getBody());
	tempCode->append("\n");
	
	tempCode->append("MOV AX, ");
	tempCode->append($1->getSymbol());
	tempCode->append("\n");
	tempCode->append("MOV BX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	//tempCode->append("\n");
	
	if($2->getName().compare("+")==0)
	{
		tempCode->append("ADD AX, BX\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
		tempCode->append("\n");
		
		dataSegment->append(string(tempVar));
		dataSegment->append(" dw ?\n");
	}
	
	else if($2->getName().compare("-")==0)
	{
		tempCode->append("SUB AX, BX\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
		tempCode->append("\n");
		
		dataSegment->append(string(tempVar));
		dataSegment->append(" dw ?\n");
	
	}
	
	
	
	string str="";
	
	if($1->getReturnType().compare("float")==0 || $3->getReturnType().compare("float")==0)
	{
		str="float";
	}
	else
	{
		str=$1->getReturnType();
	}
	
	ReturnInfo *r = new ReturnInfo(*temp, str);
	
	r->setCode(*tempCode);
	
	r->setSymbol(string(tempVar));
	
	
	$$ = r;
	

	}
		  ;
					
term :	unary_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" term :	unary_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	$$ = $1;
	

	}
     |  term MULOP unary_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" term :	term MULOP unary_expression \n"<<endl;
	
	if($2->getName().compare("%")==0 && $3->getBody().compare("0")==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Modulus by zero \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Modulus by zero \n"<<endl;
		ofsError<<endl;
	}
	
	if($2->getName().compare("%")==0)
	{
		if(!($1->getReturnType().compare("int")==0 && $3->getReturnType().compare("int")==0))
		{
			error_count++;
			ofsLog<<"Error at line no: "<<line_count<<" Non integer operand on modulus operator \n"<<endl;
			ofsLog<<endl;
			
			ofsError<<"Error at line no: "<<line_count<<" Non integer operand on modulus operator \n"<<endl;
			ofsError<<endl;
		}
	}
	
	
	
	
	
	ofsLog<<$1->getBody()<<$2->getName()<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	if($3->getReturnType().compare("void")==0 || $1->getReturnType().compare("void")==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	tempCode->append($3->getCode());
	
	char *tempVar=newTemp();
	
	temp->append($1->getBody());
	temp->append($2->getName());
	temp->append($3->getBody());
	
	tempCode->append(";");
	tempCode->append($1->getBody());
	tempCode->append($2->getName());
	tempCode->append($3->getBody());
	tempCode->append("\n");
	
	
	tempCode->append("MOV AX, ");
	tempCode->append($1->getSymbol());
	tempCode->append("\n");
	tempCode->append("MOV BX, ");
	tempCode->append($3->getSymbol());
	tempCode->append("\n");
	//tempCode->append("IMUL BX");
	
	
	if($2->getName().compare("%")==0)
	{
		// clear dx, perform 'div bx' and mov dx to temp
		tempCode->append("XOR DX, DX\n");
		tempCode->append("DIV BX\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", DX\n");
		tempCode->append("\n");
	}
	else if($2->getName().compare("*")==0)
	{
		tempCode->append("IMUL BX\n");
		tempCode->append("\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
		tempCode->append("\n");
		
	}
	else if($2->getName().compare("/")==0)
	{
		// clear dx, perform 'div bx' and mov ax to temp
		tempCode->append("XOR DX, DX\n");
		tempCode->append("DIV BX\n");
		tempCode->append("MOV ");
		tempCode->append(string(tempVar));
		tempCode->append(", AX\n");
		tempCode->append("\n");
	}
	
	
	dataSegment->append(string(tempVar));
	dataSegment->append(" dw ?\n");
	
	
	
	
	
	
	
	
	
	string str="";
	
	if($2->getName().compare("%")==0)
	{
		str = "int";
	}
	
	else if($1->getReturnType().compare("float")==0 || $3->getReturnType().compare("float")==0)
	{
		str="float";
	}
	else
	{
		str=$1->getReturnType();
	}
	
	ReturnInfo *r = new ReturnInfo(*temp, str);
	
	r->setCode(*tempCode);
	
	r->setSymbol(string(tempVar));
	
	$$ = r;
	

	}
     ;

unary_expression : ADDOP unary_expression  { 
	
	ofsLog<<"At line no: "<<line_count<<" unary_expression : ADDOP unary_expression \n"<<endl;
	
	ofsLog<<$1->getName()<<$2->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getName());
	temp->append($2->getBody());
	
	//$$ = temp;
	
	if($2->getReturnType().compare("void")==0)
	{	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	
	ReturnInfo *r = new ReturnInfo(*temp, $2->getReturnType());
	
	r->setCode(*tempCode);
	
	$$ = r;
	

	}
		 | NOT unary_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" unary_expression : NOT unary_expression \n"<<endl;
	
	ofsLog<<*$1<<$2->getBody()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append(*$1);
	temp->append($2->getBody());
	
	
	if($2->getReturnType().compare("void")==0)
	{
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Void function cannot be part of an expression. \n"<<endl;
		ofsError<<endl;
	}
	
	
	ReturnInfo *r = new ReturnInfo(*temp, $2->getReturnType());
	
	r->setCode(*tempCode);
	
	
	$$ = r;
	

	}
		 | factor { 
	
	ofsLog<<"At line no: "<<line_count<<" unary_expression : factor \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	$$ = $1;
	

	}
		 ;
	
factor	: variable { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: variable \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	
	ReturnInfo *r = new ReturnInfo($1->getBody(), $1->getReturnType(), $1->getId_or_array());
	
	r->setCode($1->getCode());
	
	r->setSymbol($1->getSymbol());
	
	
	$$ = r;
	
	
	

	}
	| ID LPAREN argument_list RPAREN { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: ID LPAREN argument_list RPAREN \n"<<endl;
	
	SymbolInfo *t = table.LookUp(*$1);
	
	if(t==NULL)
	{	error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Undeclared Function "<<$1->getName()<<" \n"<<endl;
		ofsLog<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Undeclared Function "<<$1->getName()<<" \n"<<endl;
		ofsError<<endl;
	}
	
	
	if(t!=NULL && t->getNumberOfParameters() != $3->size())
	{	
	//cout<<"ONE!\n"<<endl;
	
		error_count++;
		ofsLog<<"Error at line no: "<<line_count<<" Total number of arguments mismatch with declaration in function "<<$1->getName()<<" \n"<<endl;
		
		ofsError<<"Error at line no: "<<line_count<<" Total number of arguments mismatch with declaration in function "<<$1->getName()<<" \n"<<endl;
	}
	
	else if(t!=NULL && t->getNumberOfParameters() == $3->size())
	{	
		//cout<<"At line :"<<line_count;
		
		vector<string> strVector;
		
		for(int i=0;i<$3->size();i++)
		{
			strVector.push_back( $3->at(i)->getReturnType() );
		}
		
		
		
		if(t->getParameterTypes() != strVector)
		{
			ofsLog<<"Error at line no: "<<line_count<<" Argument type mismatch \n"<<endl;
			ofsLog<<endl;
			
			ofsError<<"Error at line no: "<<line_count<<" Argument type mismatch \n"<<endl;
			ofsError<<endl;
		}
	}
	
	
	
	
	
	
	ofsLog<<$1->getName()<<*$2;
	//ofsLog<<endl;
	
	int i=0;
	
	while(i<$3->size())
	{
		ofsLog<<$3->at(i)->getBody();
		
		i++;
		
		if(i<$3->size())
		{
			ofsLog<<",";
		}
	
	}
	
	ofsLog<<*$4<<endl;
	ofsLog<<endl;
	
	i=0;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getName());
	temp->append(*$2);
	//temp->append(*$3);
	
	while(i<$3->size())
	{
		temp->append($3->at(i)->getBody());
		
		i++;
		
		if(i<$3->size())
		{
			temp->append(",");
		}
	
	}
	
	
	
	temp->append(*$4);
	
	//$$ = temp;
	
	string tempStr = "";
	
	SymbolInfo *y = table.LookUp(*$1);
	
	if(y!=NULL)
	{
		tempStr = y->getReturnType();
	}
	
	ReturnInfo *r = new ReturnInfo(*temp, tempStr);
	
	r->setCode(*tempCode);
	
	
	$$ = r;
	

	}
	| LPAREN expression RPAREN { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: LPAREN expression RPAREN \n"<<endl;
	
	ofsLog<<*$1<<$2->getBody()<<*$3<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($2->getCode());
	
	temp->append(*$1);
	temp->append($2->getBody());
	temp->append(*$3);
	
	//$$ = temp;
	
	ReturnInfo *r = new ReturnInfo(*temp, $2->getReturnType());
	
	r->setCode(*tempCode);
	r->setSymbol($2->getSymbol());

	
	$$ = r;
	

	}
	| CONST_INT  { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: CONST_INT \n"<<endl;
	
	ofsLog<<$1->getName()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getName());
	
	//$$ = temp;
	
	ReturnInfo *r = new ReturnInfo(*temp, "int");
	
	r->setCode(*tempCode);
	r->setSymbol($1->getName());
	
	//r->setId_or_array(2);
	
	$$ = r;
	

	}
	| CONST_FLOAT { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: CONST_FLOAT \n"<<endl;
	
	ofsLog<<$1->getName()<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string("");
	
	temp->append($1->getName());
	
	//$$ = temp;
	
	ReturnInfo *r = new ReturnInfo(*temp, "float");
	
	r->setCode(*tempCode);
	
	//r->setId_or_array(2);
	
	$$ = r;
	

	}
	| variable INCOP { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: variable INCOP \n"<<endl;
	
	ofsLog<<$1->getBody()<<*$2<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	
	tempCode->append(";");
	tempCode->append($1->getBody());
	tempCode->append(*$2);
	tempCode->append("\n");
	
	tempCode->append("MOV AX, ");
	tempCode->append($1->getSymbol());
	tempCode->append("\n");
	tempCode->append("INC AX\n");
	tempCode->append("MOV ");
	tempCode->append($1->getSymbol());
	tempCode->append(", AX\n");
	tempCode->append("\n");
	
	temp->append($1->getBody());
	temp->append(*$2);
	
	//$$ = temp;
	
	ReturnInfo *r = new ReturnInfo(*temp, $1->getReturnType());
	
	r->setCode(*tempCode);
	
	r->setSymbol($1->getSymbol());
	
	//r->setId_or_array(2);
	
	$$ = r;
	
	

	}
	| variable DECOP { 
	
	ofsLog<<"At line no: "<<line_count<<" factor	: variable DECOP \n"<<endl;
	
	ofsLog<<$1->getBody()<<*$2<<endl;
	ofsLog<<endl;
	
	string *temp = new string("");
	string *tempCode = new string($1->getCode());
	
	tempCode->append(";");
	tempCode->append($1->getBody());
	tempCode->append(*$2);
	tempCode->append("\n");
	
	tempCode->append("MOV AX, ");
	tempCode->append($1->getSymbol());
	tempCode->append("\n");
	tempCode->append("DEC AX\n");
	tempCode->append("MOV ");
	tempCode->append($1->getSymbol());
	tempCode->append(", AX\n");
	tempCode->append("\n");
	
	temp->append($1->getBody());
	temp->append(*$2);
	
	//$$ = temp;
	
	ReturnInfo *r = new ReturnInfo(*temp, $1->getReturnType());
	
	r->setCode(*tempCode);
	r->setSymbol($1->getSymbol());
	
	//r->setId_or_array(2);
	
	$$ = r;
	

	}
	;
	
argument_list : arguments { 
	
	ofsLog<<"At line no: "<<line_count<<" argument_list : arguments \n"<<endl;
	
	
	int i=0;
	
	
	while(i<$1->size())
	{
		ofsLog<<$1->at(i)->getBody();
		
		i++;
		
		if(i<$1->size())
		{
			ofsLog<<",";
		}
	
	}
	
	ofsLog<<endl;
	ofsLog<<endl;
		
	
	$$ = $1;
	

	}
			  |  { ofsLog<<"At line no: "<<line_count<<" argument_list : arguments \n"<<endl;
			  
			  vector<ReturnInfo*>* argVector = new vector<ReturnInfo*>();
			  
			  $$ = argVector;
			  		  
			  }
			  ;
	
arguments : arguments COMMA logic_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" arguments : arguments COMMA logic_expression \n"<<endl;
	
	int i = 0;
	
	
	while(i<$1->size())
	{
		ofsLog<<$1->at(i)->getBody();
		
		ofsLog<<",";
		i++;
	
	
	}
	
		
	
	ofsLog<<$3->getBody()<<endl;
	ofsLog<<endl;
	
	string *tempCode = new string("");
	
	vector<ReturnInfo*>* tempVect = $1;
	
	ReturnInfo* r = new ReturnInfo($3->getBody(), $3->getReturnType());
	
	r->setCode(*tempCode);
	
	tempVect->push_back(r);
	
	$$ = tempVect;
	

	}
	      | logic_expression { 
	
	ofsLog<<"At line no: "<<line_count<<" parameter_list  : logic_expression \n"<<endl;
	
	ofsLog<<$1->getBody()<<endl;
	ofsLog<<endl;
	
	string *tempCode = new string("");
	
	vector<ReturnInfo*>* argVect = new vector<ReturnInfo*>();
	ReturnInfo* r = new ReturnInfo($1->getBody(), $1->getReturnType());
	
	r->setCode(*tempCode);
	
	argVect->push_back(r);
	
	
	$$ = argVect;
	

	}
	      ;
 

%%
int main(int argc,char *argv[])
{	
	ofsLog.open("log.txt", ios::out | ios::trunc);
	ofsError.open("error.txt", ios::out | ios::trunc);
	ofsCode.open("code.asm", ios::out | ios::trunc);

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	yyin=fin;
	yyparse();
	
	fclose(yyin);
	
	return 0;
}


