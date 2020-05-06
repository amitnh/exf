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
-export([setAndReduce/3,reduceBool/1,getVars/1]).

%----------------------------------------------------------------------------------------------```-----------------------------------------------------
%---- setVar: sets a value to an Argument,  for example: setVar(x1,true,{and,x1,x2}) -> {and,1,x2}
setAndReduce(Var,Value,BooleanExp) when (Value ==  1) or (Value == true) -> setA(Var,true,BooleanExp) ;
setAndReduce(Var,Value,BooleanExp) when (Value ==  0) or (Value == false) -> setA(Var,false,BooleanExp);
setAndReduce(_,_,_)  -> notACorrectValue.

setA(Var,V,BooleanExp) when (is_tuple(BooleanExp)) and (element(1, BooleanExp) == 'not') ->
                            if element(2, BooleanExp) == Var  -> not V;
                                  element(2, BooleanExp) == Var -> not V;
                                  element(2, BooleanExp) == true -> false;
                                  element(2, BooleanExp) == false -> true;
                                  is_tuple(element(2, BooleanExp)) ->setA(Var,V,{'not',setA(Var,V,element(2, BooleanExp))});
                                  true->BooleanExp
                                end;
setA(Var,V,BooleanExp) when (is_tuple(BooleanExp)) and (element(1, BooleanExp) == 'and') -> _Tuple = erlang:element(2, BooleanExp),
                                              if
                                                element(1, _Tuple) == Var -> if V==false -> false;
                                                                                true-> setA(Var,V,element(2, _Tuple))
                                                                                end;
                                                element(2, _Tuple) == Var -> if V==false -> false;
                                                                                 true-> setA(Var,V,element(1, _Tuple))
                                                                               end;
                                                element(1, _Tuple) == false -> false;
                                                element(2, _Tuple) == false -> false;
                                                element(1, _Tuple) == true -> setA(Var,V,element(2, _Tuple));
                                                element(2, _Tuple) == true -> setA(Var,V,element(1, _Tuple));

                                              true->setA(Var,V,{'and',{setA(Var,V,element(1, _Tuple)),setA(Var,V,element(2, _Tuple))}})
                                            end;
setA(Var,V,BooleanExp) when (is_tuple(BooleanExp)) and (element(1, BooleanExp) == 'or') -> _Tuple = erlang:element(2, BooleanExp),
                    if
                      element(1, _Tuple) == true -> true;
                      element(2, _Tuple) == true -> true;
                      element(1, _Tuple) == false ->setA(Var,V,element(2, _Tuple));
                      element(2, _Tuple) == false ->setA(Var,V,element(1, _Tuple));
                      element(1, _Tuple) == Var -> if V==true -> true;
                                                     true-> setA(Var,V,element(2, _Tuple)) %V=false
                                                   end;
                      element(2, _Tuple) == Var -> if V==true -> true;
                                                     true-> setA(Var,V,element(1, _Tuple)) %V=false
                                                   end;


                      true->setA(Var,V,{'or',{setA(Var,V,element(1, _Tuple)),setA(Var,V,element(2, _Tuple))}})
                    end;

setA(_,_,BooleanExp) ->  BooleanExp.  % in case its not a tuple its a Var.
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
%------------ returns List of the Variables
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





