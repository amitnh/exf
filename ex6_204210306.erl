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

% [lists:nth(1,[element(4,E) || E <- digraph:edges(G,V1),element(3,E)==V2])].

% for exp: Start="ABC", End="BAC" ---> so we search path from C to B (and we add Start and End)
songGen(G,Start,End)-> [Start] ++ getLabels(G,digraph:get_short_path(G,getLast(Start),getFirst(End))) ++ [End].



getFirst(String)-> lists:sublist(String,1,1). %gets the first character of a string
getLast(String)-> Length=length(String), lists:sublist(String,Length,Length). %gets the last character of a string

