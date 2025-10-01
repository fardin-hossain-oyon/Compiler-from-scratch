#include<iostream>
#include<stdio.h>
#include<cstring>
#include <bits/stdc++.h>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>


#define PRIME 7
#define LIST_SIZE 100
#define C1 5
#define C2 7
#define defaultSize 100

using namespace std;

class StrCode{
    string body;
    string code;
    string symbol;
public:

    StrCode()
    {
        body = "";
        code = "";
    }


    StrCode(string body, string code)
    {
        this->body = body;
        this->code = code;
    }


    void setBody(string body)
    {
        this->body = body;
    }

    void setCode(string code)
    {
        this->code = code;
    }

    string getBody()
    {
        return body;
    }

    string getCode()
    {
        return code;
    }

    void setSymbol(string symbol)
    {
        this->symbol = symbol;
    }

    string getSymbol()
    {
        return symbol;
    }


};

class IDInfo{
    string ID;
    string body;
    int id_arr;
    string code;
    string symbol;
public:

    //string code;

    IDInfo()
    {
        ID = "";
        body = "";
        id_arr = 1;
        symbol = "";
    }

    IDInfo(string ID, string body)
    {
        this->ID = ID;
        this->body = body;
    }

    void setID(string ID)
    {
        this->ID = ID;
    }

    void setBody(string body)
    {
        this->body = body;
    }

    void setId_arr(int n)
    {
        id_arr = n;
    }

    string getID()
    {
        return ID;
    }

    string getBody()
    {
        return body;
    }

    int getId_arr()
    {
        return id_arr;
    }

    void setCode(string code)
    {
        this->code = code;
    }

    string getCode()
    {
        return code;
    }

    void setSymbol(string symbol)
    {
        this->symbol = symbol;
    }

    string getSymbol()
    {
        return symbol;
    }

};

class ReturnInfo{
    string body;
    string returnType;
    int id_or_array;
    string id;
    string code;
    string symbol;
public:
    ReturnInfo()
    {
        body = "";
        returnType = "";
        id_or_array = 1;
        id = "";
        symbol="";
    }

    ReturnInfo(string body)
    {
        this->body = body;
    }

    ReturnInfo(string body, string returnType)
    {
        this->body = body;
        this->returnType = returnType;
    }

    ReturnInfo(string body, string returnType, int id_or_array)
    {
        this->body = body;
        this->returnType = returnType;
        this->id_or_array = id_or_array;
    }

    void setBody(string body)
    {
        this->body = body;
    }

    void setReturnType(string returnType)
    {
        this->returnType = returnType;
    }

    void setId_or_array(int id_or_array)
    {
        this->id_or_array = id_or_array;
    }

    void setId(string str)
    {
        id = str;
    }

    string getBody()
    {
        return body;
    }

    string getReturnType()
    {
        return returnType;
    }

    int getId_or_array()
    {
        return id_or_array;
    }

    string getId()
    {
        return id;
    }

    void setCode(string code)
    {
        this->code = code;
    }

    string getCode()
    {
        return code;
    }

    void setSymbol(string symbol)
    {
        this->symbol = symbol;
    }

    string getSymbol()
    {
        return symbol;
    }

};


class SymbolInfo{
    string name;
    string type;
    string returnType;
    int id_array_func;
    int numberOfParameters;
    vector<string> parameterTypes;
    string code;
    string symbol;
public:
    SymbolInfo()
    {
        name = "";
        type = "";
        returnType = "";
        id_array_func = 0;
        numberOfParameters = 0;
    }

    SymbolInfo(string str1, string str2)
    {
        name = str1;
        type = str2;
    }

    void setName(string name)
    {
        this->name = name;
    }

    void setType(string type)
    {
        this->type = type;
    }

    void setReturnType(string returnType)
    {
        this->returnType = returnType;
    }

    void setId_array_func(int id_array_func)
    {
        this->id_array_func = id_array_func;
    }

    void setNumberOfParameters(int numberOfParameters)
    {
        this->numberOfParameters = numberOfParameters;
    }

    void setParameterTypes(vector<string> parameterTypes)
    {
        this->parameterTypes = parameterTypes;
    }

    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }

    string getReturnType()
    {
        return returnType;
    }

    int getId_array_func()
    {
        return id_array_func;
    }

    int getNumberOfParameters()
    {
        return numberOfParameters;
    }

    vector<string> getParameterTypes()
    {
        return parameterTypes;
    }

    void setCode(string code)
    {
        this->code = code;
    }

    string getCode()
    {
        return code;
    }

    void setSymbol(string symbol)
    {
        this->symbol = symbol;
    }

    string getSymbol()
    {
        return symbol;
    }

};



class seperateChainingHashing{
    vector<vector<SymbolInfo> > table;
    int collisions;
    int probes;
public:

    seperateChainingHashing()
    {
        collisions = 0;
        probes = 0;
        table.resize(1);
    }

    seperateChainingHashing(int n)
    {
        collisions = 0;
        probes = 0;
        table.resize(n);
    }

    int getCollisions()
    {
        return collisions;
    }

    int hashFunction1(string str)
    {
        int hashValue = 0;

        for(int i=0;i<str.size();i++)
        {
            hashValue = hashValue + str[i];
        }

        hashValue = hashValue % table.size();

        return hashValue;
    }

    bool insertItem(SymbolInfo s)
    {
        int hashValue = hashFunction1(s.getName());

        bool inserted = false;

        if(!table[hashValue].empty())
        {
            collisions++;
        }


        bool keyExists = false;
        int idx=0;

        for(int i=0 ; i<table[hashValue].size() ; i++)
        {
            if(s.getName().compare(table[hashValue][i].getName() )==0)
            {
                keyExists = true;
                idx=i;
                break;
            }
        }

        if(!keyExists)
        {

            table[hashValue].push_back(s);

            //cout<<"Inserted in "<<hashValue<<", "<<table[hashValue].size() - 1<<" position ";
            //ofs<<"Inserted in "<<hashValue<<", "<<table[hashValue].size() - 1<<" position ";

            inserted = true;
        }

        if(inserted==false)
        {
            //cout<<"Key already exists."<<endl;
            //ofs<<"Key already exists."<<endl;
        }

        return inserted;
    }

    bool removeItem(SymbolInfo s)
    {
        int hashValue = hashFunction1(s.getName());

        bool keyExists = false;
        bool deleted = false;

        if(table[hashValue].empty())
            return false;

        if(s.getName().compare(table[hashValue][0].getName())==0)
        {
            probes++;
            table[hashValue].erase(table[hashValue].begin());
            deleted = true;

        }

        else{

        for(int i=0; i<table[hashValue].size();i++)
        {
            if(s.getName().compare(table[hashValue][i].getName())==0)
            {
                keyExists = true;
                deleted = true;
                table[hashValue].erase(table[hashValue].begin()+i);
                break;
            }
        }

        }

        return deleted;

    }

    SymbolInfo* searchTable(SymbolInfo s)
    {
        int hashValue = hashFunction1(s.getName());

        //string r="EMPTY_STRING";

        SymbolInfo *s1 = NULL;

        if(table[hashValue].empty())
            return s1;

        if(s.getName().compare(table[hashValue][0].getName())==0)
        {
            probes++;
            return &table[hashValue][0];
        }
        else
        {

            for(int i=0 ; i<table[hashValue].size() ; i++)
            {
               probes++;
               if(s.getName().compare(table[hashValue][i].getName())==0)
               {
                   s1 = &table[hashValue][i];
                   //r = table[hashValue][i].getType();
                   break;
               }
            }
        }

        return s1;
    }








    void SearchAndReplace(SymbolInfo s)
    {
        int hashValue = hashFunction1(s.getName());

        string r="EMPTY_STRING";

        if(table[hashValue].empty())
            return;

        if(s.getName().compare(table[hashValue][0].getName())==0)
        {
            probes++;

            table[hashValue][0] = s;

            //return table[hashValue][0].getType();
        }
        else
        {

            for(int i=0 ; i<table[hashValue].size() ; i++)
            {
               probes++;
               if(s.getName().compare(table[hashValue][i].getName())==0)
               {
                   //r = table[hashValue][i].getType();

                   table[hashValue][i] = s;

                   break;
               }
            }
        }

        //return r;
    }














    int getProbes(){ return probes; }

    string printTable()
    {
        string str="";

        for(int i=0; i<table.size(); i++)
        {
            //cout<<i<<" --> ";
            //ofs<<i<<" --> ";

            if(table[i].size() == 0)
            {
                //cout<<endl;
                //ofs<<endl;
                continue;
            }

            //cout<<i<<" --> ";

            stringstream ss;

            ss<<i;

            string str1 = ss.str();

            str = str + str1 + " --> ";

            for(int j=0 ; j<table[i].size() ; j++)
            {
                //cout<<"< "<<table[i][j].first<<" : "<<table[i][j].second<<" >  ";

                str = str + "<" + table[i][j].getName() + " : " + table[i][j].getType() + " > ";

                //ofs<<"< "<<table[i][j].first<<" : "<<table[i][j].second<<" >  ";
            }

            //cout<<endl;
            //ofs<<endl;

            str = str + "\n";
        }

        return str;

    }



    string printTableV2()
    {
        string str="";

        for(int i=0; i<table.size(); i++)
        {
            //cout<<i<<" --> ";
            //ofs<<i<<" --> ";

            if(table[i].size() == 0)
            {
                //cout<<endl;
                //ofs<<endl;
                continue;
            }

            //cout<<i<<" --> ";

            stringstream ss;

            ss<<i;

            string str1 = ss.str();

            str = str + str1 + " --> ";

            for(int j=0 ; j<table[i].size() ; j++)
            {
                //cout<<"< "<<table[i][j].first<<" : "<<table[i][j].second<<" >  ";

                str = str + "<" + table[i][j].getName() + " : " + table[i][j].getType() + " : " + table[i][j].getReturnType() + " : " + to_string(table[i][j].getId_array_func()) + " : " + to_string(table[i][j].getNumberOfParameters()) + " > ";

                //ofs<<"< "<<table[i][j].first<<" : "<<table[i][j].second<<" >  ";
            }

            //cout<<endl;
            //ofs<<endl;

            str = str + "\n";
        }

        return str;

    }





};



class ScopeTable{
    vector<SymbolInfo> symbolInfoArray;
    seperateChainingHashing *SCH;
    ScopeTable *parentScope;
    string id;
    int numberOfChild;
public:
    ScopeTable()
    {
        parentScope = NULL;
        id = "1";
        numberOfChild = 0;
        SCH = new seperateChainingHashing(1);
    }

    ~ScopeTable()
    {
        delete SCH;
        delete parentScope;
    }

    ScopeTable(int n)
    {
        id = "1";
        numberOfChild = 0;
        parentScope = NULL;
        SCH = new seperateChainingHashing(n);
    }

    void setId(string str)
    {
        id = str;
    }

    string getId()
    {
        return id;
    }

    void setNumberOfChild(int n)
    {
        numberOfChild = n;
    }

    int getNumberOfChild()
    {
        return numberOfChild;
    }

    void setParentScope(ScopeTable *scope)
    {
        parentScope = scope;
    }

    ScopeTable *getParentScope()
    {
        return parentScope;
    }

    bool Insert(SymbolInfo s)
    {
        bool inserted = false;

        inserted = SCH->insertItem(s);

        return inserted;
    }

    SymbolInfo *LookUp(SymbolInfo s)
    {
        SymbolInfo *temp = new SymbolInfo();

        temp = SCH->searchTable(s);

        /*if(str.compare("EMPTY_STRING")==0)
        {
            temp = NULL;
        }

        else{
        temp->setName(s.getName());
        temp->setType( str );
        }
*/
        return temp;
    }






    void LookUpAndReplace(SymbolInfo s)
    {
        SCH->SearchAndReplace(s);
    }






    bool Delete(SymbolInfo s)
    {
        bool deleted = false;

        deleted = SCH->removeItem(s);

        return deleted;
    }

    string Print()
    {
        string str = SCH->printTable();
        str = str + "\n";

        return str;
        //ofs<<endl;
    }

    string PrintV2()
    {
        string str = SCH->printTableV2();
        str = str + "\n";

        return str;
        //ofs<<endl;
    }

};


class SymbolTable{
    ScopeTable *currentScopeTable;
public:
    SymbolTable()
    {
        currentScopeTable = new ScopeTable(1);
    }

    ~SymbolTable()
    {
        delete currentScopeTable;
    }

    SymbolTable(int n)
    {
        currentScopeTable = new ScopeTable(n);
    }

    void setCurrentScopeTable(ScopeTable *scope)
    {
        currentScopeTable = scope;
    }

    void EnterScope(int n)
    {
        ScopeTable *temp = new ScopeTable(n);
        temp->setParentScope(currentScopeTable);
        temp->getParentScope()->setNumberOfChild( temp->getParentScope()->getNumberOfChild() + 1 );

        stringstream ss;
        ss<<temp->getParentScope()->getNumberOfChild();
        string idString;
        ss>>idString;


        temp->setId( temp->getParentScope()->getId() + "." + idString);

        currentScopeTable = temp;

        //cout<<"Created Scopetable with ID #"<<currentScopeTable->getId()<<endl;
        //ofs<<"Created Scopetable with ID #"<<currentScopeTable->getId()<<endl;

    }

    void ExitScope(int n)
    {

        //cout<<"Scopetable with ID #"<<currentScopeTable->getId()<<" removed."<<endl;
        //ofs<<"Scopetable with ID #"<<currentScopeTable->getId()<<" removed."<<endl;

        ScopeTable *temp =  currentScopeTable;

        currentScopeTable = temp->getParentScope();
    }

    bool Insert(SymbolInfo s)
    {
        bool inserted = false;

        inserted = currentScopeTable->Insert(s);

        if(inserted==true)
        {
            //cout<<"in scopetable #"<<currentScopeTable->getId()<<endl;
            //ofs<<"in scopetable #"<<currentScopeTable->getId()<<endl;
        }

        return inserted;
    }

    bool Remove(SymbolInfo s)
    {
        bool deleted = false;

        deleted = currentScopeTable->Delete(s);

        return deleted;
    }

    SymbolInfo *LookUp(SymbolInfo s)
    {
        ScopeTable *temp = currentScopeTable;


        bool found = false;

        SymbolInfo *s1 = NULL;

        do{
            s1 = temp->LookUp(s);

            if(s1!=NULL)
            {
                break;
            }

            temp = temp->getParentScope();


        }while(temp!=NULL);

        if(s1!=NULL)
        {
            //cout<<"Found at Scopetable #"<<temp->getId()<<endl;
            //ofs<<"Found at Scopetable #"<<temp->getId()<<endl;
        }

        return s1;
    }


    string getScopeID(SymbolInfo s)
    {
        ScopeTable *temp = currentScopeTable;

        string scopeID = "";


        bool found = false;

        SymbolInfo *s1 = NULL;

        do{
            s1 = temp->LookUp(s);

            if(s1!=NULL)
            {
                break;
            }

            temp = temp->getParentScope();


        }while(temp!=NULL);

        if(s1!=NULL)
        {
            //cout<<"Found at Scopetable #"<<temp->getId()<<endl;
            //ofs<<"Found at Scopetable #"<<temp->getId()<<endl;

            scopeID = temp->getId();
        }

        return scopeID;
    }




    SymbolInfo* LookUpInCurrentScopeTable(SymbolInfo s)
    {
        ScopeTable *temp = currentScopeTable;


        bool found = false;

        SymbolInfo *s1 = NULL;


        s1 = temp->LookUp(s);

        if(s1!=NULL)
        {
            //cout<<"Found at Scopetable #"<<temp->getId()<<endl;
            //ofs<<"Found at Scopetable #"<<temp->getId()<<endl;
        }

        return s1;
    }





    void LookUpAndReplace(SymbolInfo s)
    {
        ScopeTable *temp = currentScopeTable;


        //bool found = false;

        SymbolInfo *s1 = NULL;

        do{
            s1 = temp->LookUp(s);

            //temp->LookUpAndReplace(s);

            if(s1!=NULL)
            {
                temp->LookUpAndReplace(s);
                break;
            }

            temp = temp->getParentScope();


        }while(temp!=NULL);

        if(s1!=NULL)
        {
            //cout<<"Found at Scopetable #"<<temp->getId()<<endl;
            //ofs<<"Found at Scopetable #"<<temp->getId()<<endl;
        }

        //return s1;
    }


    string getCurrentTableID()
    {
        return currentScopeTable->getId();
    }





    void PrintCurrentScopeTable()
    {
        //cout<<"Scopetable #"<< currentScopeTable->getId() <<endl;
        //ofs<<"Scopetable #"<< currentScopeTable->getId() <<endl;

        currentScopeTable->Print();
    }

    string PrintAllScopeTables()
    {

        string str = "";

        ScopeTable *temp = currentScopeTable;

        do
        {   //cout<<"Scopetable #"<<temp->getId()<<endl;
            str = str + "Scopetable #" + temp->getId() + "\n";
            //ofs<<"Scopetable #"<<temp->getId()<<endl;\n
            str = str + temp->Print();
            temp = temp->getParentScope();

        }while(temp!=NULL);

        return str;

    }

    string PrintAllScopeTablesV2()
    {

        string str = "";

        ScopeTable *temp = currentScopeTable;

        do
        {   //cout<<"Scopetable #"<<temp->getId()<<endl;
            str = str + "Scopetable #" + temp->getId() + "\n";
            //ofs<<"Scopetable #"<<temp->getId()<<endl;\n
            str = str + temp->PrintV2();
            temp = temp->getParentScope();

        }while(temp!=NULL);

        return str;

    }



};

/*
int main()
{
    int hashTableSize = 0;

    std::ifstream infile("input.txt");
    std::string line;

    char choice;

    std::getline(infile, line);
    std::istringstream iss(line);

    iss>>hashTableSize;

    SymbolTable *st = new SymbolTable(hashTableSize);

    ofs.open("output.txt", ios::out | ios::trunc);


    while(1)
    {
        std::getline(infile, line);
        std::istringstream iss(line);

        iss>>choice;

        if(choice == 'I')
        {
            string str1;
            string str2;

            iss>>str1>>str2;

            cout<<endl;
            ofs<<endl;

            cout<<choice<<" "<<str1<<" "<<str2<<endl;
            ofs<<choice<<" "<<str1<<" "<<str2<<endl;

            cout<<endl;
            ofs<<endl;

            SymbolInfo s;

            s.setName(str1);
            s.setType(str2);

            st->Insert(s);

        }

        else if(choice == 'L')
        {
            string str;
            iss>>str;

            cout<<endl;
            ofs<<endl;

            cout<<choice<<" "<<str<<endl;
            ofs<<choice<<" "<<str<<endl;

            cout<<endl;
            ofs<<endl;

            SymbolInfo s1;

            s1.setName(str);
            s1.setType("");

            SymbolInfo *s = st->LookUp(s1);

            if(s!=NULL)
            {
                //cout<<"Found"<<endl;
            }
            else
            {
                cout<<"Not Found"<<endl;
                ofs<<"Not Found"<<endl;
            }

        }

        else if(choice == 'D')
        {
            string str;
            iss>>str;

            cout<<endl;
            ofs<<endl;

            cout<<choice<<" "<<str<<endl;
            ofs<<choice<<" "<<str<<endl;

            cout<<endl;
            ofs<<endl;

            SymbolInfo s1;

            s1.setName(str);

            bool d = st->Remove(s1);

            if(d==true)
            {
                cout<<"Successfully deleted."<<endl;
                ofs<<"Successfully deleted."<<endl;
            }

            else{
                cout<<str<<" not found."<<endl;
                ofs<<str<<" not found."<<endl;
            }
        }
        else if(choice == 'P')
        {
            string str;
            iss>>str;

            cout<<endl;
            ofs<<endl;

            cout<<choice<<" "<<str<<endl;
            ofs<<choice<<" "<<str<<endl;

            cout<<endl;
            ofs<<endl;

            if(str.compare("A")==0)
            {
                st->PrintAllScopeTables();
            }
            else
            {
                st->PrintCurrentScopeTable();
            }
        }
        else if(choice == 'S')
        {
            cout<<endl;
            ofs<<endl;

            cout<<choice<<endl;
            ofs<<choice<<endl;

            cout<<endl;
            ofs<<endl;

            st->EnterScope(hashTableSize);
        }
        else if(choice == 'E')
        {
            cout<<endl;
            ofs<<endl;

            cout<<choice<<endl;
            ofs<<choice<<endl;

            cout<<endl;
            ofs<<endl;

            st->ExitScope(hashTableSize);
        }

        if(infile.eof()){
            break;
        }

    }

    ofs.close();


}
*/





























