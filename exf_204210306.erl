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
-export([setVar/3,reduceBool/1,getVars/1]).

%----------------------------------------------------------------------------------------------```-----------------------------------------------------
%---- setVar: sets a value to an Argument,  for example: setVar(x1,true,{and,x1,x2}) -> {and,1,x2}
setVar(Var,Value,BooleanExp) when (Value ==  1) or (Value == true) -> setA(Var,1,BooleanExp) ;
setVar(Var,Value,BooleanExp) when (Value ==  0) or (Value == false) -> setA(Var,0,BooleanExp);
setVar(_,_,_)  -> notACorrectValue.

setA(Var,V,BooleanExp) when is_tuple(BooleanExp)  -> if % V is 0/1
                                                      element(1, BooleanExp) == 'not'->
                                                                  if element(2,BooleanExp) == Var -> {'not',V};
                                                                   true -> {'not',setA(Var,V,setA(Var,V,element(2,BooleanExp)))}
                                                                  end;
                                                      element(1, BooleanExp) == 'and' ->
                                                                  if element(2,BooleanExp) == Var -> {'and',V,setA(Var,V,element(3,BooleanExp))};
                                                                  element(3,BooleanExp) == Var -> {'and',setA(Var,V,element(2,BooleanExp)),V};
                                                                  true -> {'and',setA(Var,V,setA(Var,V,element(2,BooleanExp))),setA(Var,V,setA(Var,V,element(3,BooleanExp)))}
                                                                  end;
                                                      element(1, BooleanExp) == 'or' ->
                                                                  if element(2,BooleanExp) == Var -> {'or',V,setA(Var,V,element(3,BooleanExp))};
                                                                    element(3,BooleanExp) == Var -> {'or',setA(Var,V,element(2,BooleanExp)),V};
                                                                    true -> {'or',setA(Var,V,setA(Var,V,element(2,BooleanExp))),setA(Var,V,setA(Var,V,element(3,BooleanExp)))}
                                                                  %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ check this ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                                                  end;
                                                     true -> errorNotATuple
                                                    end;
setA(_,_,BooleanExp) -> BooleanExp. % in case its not a tuple its a Var.
%---------------------------------------------------------------------------------------------------------------------------------------------------
%---- reduce the BooleanExp: for exp: reduceBool({and,0,x2}) -> 0; reduceBool({and,1,x2}) -> x2
reduceBool(BooleanExp) when not is_tuple(BooleanExp)-> BooleanExp;
reduceBool(BooleanExp) when element(1, BooleanExp) == 'not'-> if  is_tuple(element(2,BooleanExp)) -> reduceBool({'not',reduceBool(element(2,BooleanExp))});
                                                                element(2,BooleanExp) == 1 -> 0;
                                                                element(2,BooleanExp) == 0 -> 1;
                                                                %element 2 is a Variable so
                                                                true -> BooleanExp
                                                              end;
reduceBool(BooleanExp) when element(1, BooleanExp) == 'and'-> if (element(2,BooleanExp) == 0) or (element(3,BooleanExp) == 0)  -> 0;
                                                                (element(2,BooleanExp) == 1) and (element(3,BooleanExp) == 1) -> 1;
                                                                (element(2,BooleanExp) == 1) -> reduceBool(element(3,BooleanExp));
                                                                (element(3,BooleanExp) == 1) -> reduceBool(element(2,BooleanExp));
                                                                is_tuple(element(2,BooleanExp)) or is_tuple(element(3,BooleanExp)) -> reduceBool({'and',reduceBool(element(2,BooleanExp)),reduceBool(element(3,BooleanExp))});
                                                                true -> BooleanExp
                                                              end;
reduceBool(BooleanExp) when element(1, BooleanExp) == 'or'-> if (element(2,BooleanExp) == 1) or (element(3,BooleanExp) == 1)  -> 1;
                                                                (element(2,BooleanExp) == 0) and (element(3,BooleanExp) == 0)  -> 0;
                                                                (element(2,BooleanExp) == 0) -> reduceBool(element(3,BooleanExp));
                                                                (element(3,BooleanExp) == 0) -> reduceBool(element(2,BooleanExp));
                                                                is_tuple(element(2,BooleanExp)) or is_tuple(element(3,BooleanExp)) -> reduceBool({'or',reduceBool(element(2,BooleanExp)),reduceBool(element(3,BooleanExp))});
                                                                true -> BooleanExp
                                                              end;
reduceBool(_)-> error.
%---------------------------------------------------------------------------------------------------------------------------------------------------
%------------ returns List of the unique Variables
getVars(BooleanExp) ->  Set = sets:from_list(getVarsA (BooleanExp,[])), sets:to_list(Set). %removes duplications

%gets all the Variables with duplicates
getVarsA(BooleanExp,List) when not is_tuple(BooleanExp) -> List; %recursion base
getVarsA(BooleanExp,List) when element(1, BooleanExp) == 'not' ->
                    %-----check: if what come after not is tuple
                    case {is_tuple(element(2,BooleanExp))} of
                      {true}-> getVarsA(element(2,BooleanExp),List);
                      {_} ->  [element(2,BooleanExp)] ++ List
                    end;
getVarsA(BooleanExp,List) when (element(1, BooleanExp) == 'or') or (element(1, BooleanExp) == 'and') ->
                %-----check: if what come after or/and is tuple , if its alreadt in List
                %------------2-------------------------------3---------------------------------2-----------------------------------------3------------
                    case {is_tuple(element(2,BooleanExp)),is_tuple(element(3,BooleanExp))} of
                      %------------one or two of the elements are tuples:------------------------------
                      %both elements are tuples
                      {true,true}-> getVarsA(element(2,BooleanExp),List) ++ getVarsA(element(3,BooleanExp),List);
                      %element 3 adds to list
                      {true,false}-> getVarsA(element(2,BooleanExp), [element(3,BooleanExp)] ++ List);
                      %element 2 adds to list
                      {false,true}-> getVarsA(element(3,BooleanExp),[element(2,BooleanExp)] ++ List);
                      %--------------------------both elements are Variables:------------------------------
                      {_,_} -> [element(2,BooleanExp)] ++ [element(3,BooleanExp)] ++ List
                    end;
getVarsA(_,_)->error.
%---------------------------------------------------------------------------------------------------------------------------------------------------





