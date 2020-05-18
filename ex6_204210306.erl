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
-export([songList/1,songGen/3,getFirst/1,getLast/1]).
%---------------------------------------------------------------
songList(L) when is_list(L)-> songList(L,digraph:new([cyclic]));
songList(_)-> notAList.
% List of songs, Graph
songList([],G)->  io:format("number of edges: ~p.~n", [length(digraph:edges(G))]),G;
songList([H|T],G)  when is_list(H) -> V1=digraph:add_vertex(G,getFirst(H)),V2=digraph:add_vertex(G,getLast(H)),
                        digraph:add_edge(G,V1,V2,H), %adds te edge to the graph with Label: "name of edge"
                        songList(T,G);
songList(_,_) -> notAString.



songGen(G,S,E)-> digraph:get_short_path(G,S,E).



getFirst(String)-> lists:sublist(String,1,1). %gets the first character of a string
getLast(String)-> Length=length(String), lists:sublist(String,Length,Length). %gets the last character of a string

