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
-export([setVariable/3,reduceBool/1,getVars/1]).

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
%---- reduceBool: sets a value to an Argument and Reduce the function,  for example: setVar(x1,false,{and,x1,x2}) -> {and,false,x2}
%can only be used after all the Vars got Values !!!!!!!
reduceBool(A) when (A=:=false) or (A=:=true) -> A;
reduceBool({'not',B}) ->  not reduceBool(B);
reduceBool({'and',{A,B}}) -> (reduceBool(A) and reduceBool(B));
reduceBool({'or',{A,B}}) ->  (reduceBool(A) or reduceBool(B));
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





