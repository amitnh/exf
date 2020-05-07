%%%-------------------------------------------------------------------
%%% @author amit
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(exf_204210306).
-author("amit").

%% API
-export([exp_to_bdd/2,setVariable/3,reduceBool/1,getVars/1,makeBdd/2,tree_height/1,num_of_leafs/1,num_of_nodes/1]).

%----------------------------------------------------------------------------------------------```-----------------------------------------------------
%---- setVariable: sets a value to an Argument  the function,  for example: setVar(x1,false,{and,x1,x2}) -> {and,false,x2}
setVariable(Var,1,BooleanExp)-> setVar(Var,true,BooleanExp);
setVariable(Var,true,BooleanExp)-> setVar(Var,true,BooleanExp);
setVariable(Var,0,BooleanExp)-> setVar(Var,false,BooleanExp);
setVariable(Var,false,BooleanExp)-> setVar(Var,false,BooleanExp);
setVariable(_,_,_)-> errorNotACorrectValue.

setVar(Var,Value,Var) -> Value;
setVar(_,_,A) when is_atom(A) or is_integer(A) -> A;
setVar(Var,Value,{Var,Var}) -> {Value,Value};
setVar(Var,Value,{A,Var}) -> {setVar(Var,Value,A),Value};
setVar(Var,Value,{Var,B}) -> {Value,setVar(Var,Value,B)};
setVar(Var,Value,{A,B}) -> {setVar(Var,Value,A),setVar(Var,Value,B)}.

%----------------------------------------------------------------------------------------------```-----------------------------------------------------
%---- reduceBool:  Reduce a Boolean  function,  for example: reduceBool({and,true,x2}) -> x2
%
reduceBool(A) when not is_tuple(A) -> A; %A is true/false/Variable
reduceBool({'not',A}) -> Ar=reduceBool(A),% check if we need to reduce more or not.
  case {is_boolean(Ar)} of
    {false}-> Ar;
    {true}-> not Ar
  end;

reduceBool({'and',{false,_}}) -> false;
reduceBool({'and',{_,false}}) -> false;
reduceBool({'and',{true,B}}) -> reduceBool(B);
reduceBool({'and',{A,true}}) -> reduceBool(A);
reduceBool({'and',{A,B}}) -> Ar=reduceBool(A),Br=reduceBool(B), % check if we need to reduce more or not.
  case {is_boolean(Ar) or is_boolean(Br)} of
    {false}-> {'and',{Ar,Br}};
    {true}-> reduceBool({'and',{Ar,Br}})
  end;

reduceBool({'or',{true,_}}) ->  true;
reduceBool({'or',{_,true}}) ->  true;
reduceBool({'or',{A,false}}) ->  reduceBool(A);
reduceBool({'or',{false,B}}) ->  reduceBool(B);
reduceBool({'or',{A,B}}) ->  Ar=reduceBool(A),Br=reduceBool(B), % check if we need to reduce more or not.
  case {is_boolean(Ar) or is_boolean(Br)} of
    {false}-> {'or',{Ar,Br}};
    {true}-> reduceBool({'or',{Ar,Br}})
  end;

reduceBool(_)-> error.

%---------------------------------------------------------------------------------------------------------------------------------------------------
%------------ returns List of the Variables [x1,x2,x3.....]
getVars(BooleanExp) ->  Set = sets:from_list(getVarsA (BooleanExp)), sets:to_list(Set). %removes duplications

%getVarsA: gets all the Variables with duplicates:
getVarsA(A) when not is_tuple(A) -> [A];
getVarsA({A,B}) when (A == 'not') and (is_tuple(B)) -> getVarsA(B);
getVarsA({A,B}) when A == 'not' -> [B];
getVarsA({_,{B,C}})   -> getVarsA(B) ++ getVarsA(C);

getVarsA(_)->error.
%---------------------------------------------------------------------------------------------------------------------------------------------------
%-------makeBdd- takes Boolean expression and list of Variables and make a Bdd tree by the order of the List
makeBdd(BooleanExp,VarsList)-> makeBddR(BooleanExp,BooleanExp,length(VarsList),1,VarsList).

makeBddR(_,SubBoolFunc,NumOfVars,Counter,_) when Counter=:= NumOfVars+1 -> reduceBool(SubBoolFunc);
makeBddR(BooleanExp,SubBoolFunc,NumOfVars,Counter,VarsList)->
CurrVar= lists:nth(Counter,VarsList),
  Left = makeBddR(BooleanExp,setVar(CurrVar,false,SubBoolFunc),NumOfVars,Counter+1,VarsList),
  Right = makeBddR(BooleanExp,setVar(CurrVar,true,SubBoolFunc),NumOfVars,Counter+1,VarsList),
  if Right =:= Left -> Right;
    true-> {CurrVar,Left,Right}
  end.
%---------------------------------------------------------------------------------------------------------------------------------------------------
%-------bddHeight- returns the Bdd Height
tree_height(A) when is_boolean(A)-> 0;
tree_height({_,A,B}) -> max(tree_height(A),tree_height(B))+1;
tree_height(_)-> error.
%---------------------------------------------------------------------------------------------------------------------------------------------------
%-------num_of_nodes- returns the Bdd num_of_nodes
num_of_nodes(A) when is_boolean(A)-> 0;
num_of_nodes({_,A,B}) -> num_of_nodes(A) + num_of_nodes(B) + 1; %im a node if im a tuple
num_of_nodes(_)-> error.
%---------------------------------------------------------------------------------------------------------------------------------------------------
%-------num_of_leafs- returns the Bdd num_of_leafs
num_of_leafs(A) when is_boolean(A)-> 0;
num_of_leafs({_,A,B}) when is_boolean(A) -> num_of_leafs(B) + 1; %im a leaf
num_of_leafs({_,A,B}) when is_boolean(B) -> num_of_leafs(A) + 1; %im a leaf
num_of_leafs({_,A,B}) -> num_of_leafs(A)+num_of_leafs(B); %im not a leaf
num_of_leafs(_)-> error.

%---------------------------------------------------------------------------------------------------------------------------------------------------
% makes all permutations of a list
perms([]) -> [[]];
perms(L)  -> [[H|T] || H <- L, T <- perms(L--[H])].
%---------------------------------------------------------------------------------------------------------------------------------------------------
exp_to_bdd(BoolFunc,tree_height)-> Perms = [L||L<-perms(getVars(BoolFunc))], %makes list of all the vars permutations possible.
  getMinTree([{makeBdd(BoolFunc,VarsList),tree_height(makeBdd(BoolFunc,VarsList))}||VarsList<-Perms]); %make list of tuples: {BddTree,height}
exp_to_bdd(BoolFunc,num_of_nodes)-> Perms = [L||L<-perms(getVars(BoolFunc))], %makes list of all the vars permutations possible.
  getMinTree([{makeBdd(BoolFunc,VarsList),num_of_nodes(makeBdd(BoolFunc,VarsList))}||VarsList<-Perms]);%make list of tuples: {BddTree,nodes}
exp_to_bdd(BoolFunc,num_of_leafs)-> Perms = [L||L<-perms(getVars(BoolFunc))], %makes list of all the vars permutations possible.
  getMinTree([{makeBdd(BoolFunc,VarsList),num_of_leafs(makeBdd(BoolFunc,VarsList))}||VarsList<-Perms]);%make list of tuples: {BddTree,leafs}
exp_to_bdd(_, _)-> error.

%---------------------------------------------------------------------------------------------------------------------------------------------------

%gets the min tree from list of trees and Values
getMinTree(List) when is_list(List)->getMinTree(List,first,first);
getMinTree(_)-> error.

getMinTree([H|T],first,_) -> getMinTree(T,element(1,H),element(2,H));%takes the first tree

getMinTree ([],MinTree,_) -> MinTree; %recursion end, when we scanned all the trees
getMinTree ([H|T],MinTree,MinVal) ->
                                    if
                                     element(2,H) < MinVal -> getMinTree (T,element(1,H),element(2,H));
                                      true-> getMinTree (T,MinTree,MinVal)
                                   end.




