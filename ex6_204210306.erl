%%%-------------------------------------------------------------------
%%% @author amit
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ex6_204210306).
-author("amit").

%% API
-export([songList/1,songGen/3,getFirst/1,getLast/1,getLabels/2]).
%---------------------------------------------------------------

songList(L) when is_list(L)-> songList(L,digraph:new([cyclic]));
songList(_)-> notAList.
% List of songs, Graph
songList([],G)->  io:format("number of edges: ~p.~n", [length(digraph:edges(G))]),G;
songList([H|T],G)  when is_list(H) -> V1=digraph:add_vertex(G,getFirst(H)),
                        V2=digraph:add_vertex(G,getLast(H)),
                        digraph:add_edge(G,V1,V2,H),
                        songList(T,G);
songList(_,_) -> notAString.

%gets the labels from the Vertecies.
getLabels(_,[])-> [];
getLabels(G,[V1,V2|T])-> getEdgeLabel(G,[digraph:edge(G,E)||E <- digraph:out_edges(G,V1)],V2) ++ getLabels(G,[V2|T]);
getLabels(_,_)-> [].

% gets list of out edges from V1 and return Label of an edge (V1,V2)
getEdgeLabel(_,[{_,_,V2,Label}|_],V2) -> [Label]; % case (V1,V2)
getEdgeLabel(G,[{_,_,_,_}|T],V2) -> getEdgeLabel(G,T,V2). %  case (V1,no V2)



%checks if V1 is in vertex in G
isAVertex(G,V1)->isAVertex(G,V1,[digraph:edge(G,E)||E<-digraph:edges(G)]).%make edges list of all the graph
isAVertex(_,_,[])-> false;
isAVertex(_,V1,[{_,_,_,V1}|_])-> true;
isAVertex(G,V1,[{_,_,_,_}|T])-> isAVertex(G,V1,T).




% for exp: Start="ABC", End="BAC" ---> so we search path from C to B (and we add Start and End)
songGen(G,Start,End) -> case {isAVertex(G,Start),isAVertex(G,End)} of
                          {false,_} -> startIsNotAVertex; %start is not in G
                          {_,false} -> endIsNotAVertex; %end is not in G
                          {_,_}->   A=getLast(Start),B=getFirst(End),songGen(G,Start,End,A,B) % Start and End in G
                        end.


songGen(_,Start,Start,A,A)-> [Start]; % "palindrome" case, for example: Start= "ABCCA"
songGen(_,Start,End,A,A)-> [Start] ++ [End]; % case "ABC" "CBA"
songGen(G,Start,End,A,B)->MiddleLabels=getLabels(G,digraph:get_short_path(G,A,B)),
  if length(MiddleLabels)==0 -> false; %there isn't a path
  true-> [Start] ++ MiddleLabels ++ [End] end.


getFirst(String)-> lists:sublist(String,1,1). %gets the first character of a string
getLast(String)-> Length=length(String), lists:sublist(String,Length,Length). %gets the last character of a string

