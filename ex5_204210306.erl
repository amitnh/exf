%%%-------------------------------------------------------------------
%%% @author amit
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ex5_204210306).
-author("amit").

%% API
-export([ring_parallel/2]).
%---------------------------------------------------------------
%%% creates N processes thats point to one another.
%%ring_parallel(N,M)->ring_parallel(N,N,M).
%%ring_parallel(N,I,M)->spawn(ring_parallel_spawn(N,I,M,self(),self(),os:timestamp())).
%%
%%%creating the next chain and going into a recieve loop
%%ring_parallel_spawn(_,1,M,To,First,StartTime)-> First ! {to,self()} ,ring_parallel_First(M,0,To,StartTime); %end of recursion. close the circle
%%ring_parallel_spawn(N,I,M,To,First,StartTime)-> ring_parallel_spawn(N,I-1,M,self(),First,StartTime), spawn(ring_parallel_loop(To)).
%%
%%%sends M messages from First node
%%ring_parallel_First(M,0,_,StartTime)->io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]);
%%ring_parallel_First(M,ToReceive,_,StartTime)->receive
%%                              {M}->ring_parallel_First(M,ToReceive-1,0,StartTime)
%%                            end;
%%ring_parallel_First(M,ToReceive,To,StartTime)->
%%
%%  To ! {M}, ring_parallel_First(M-1,ToReceive,To,StartTime).
%%
%%
%%ring_parallel_loop(To)->
%%  receive
%%    {Message}-> To ! Message
%%  end.
%----------------------------------------------------------------------------
ring_parallel(N,M)->MesMap = makeMesMap(N).

%makes a List with N empty maps.
makeMesMap(N)-> makeMesMap(N,[]).
makeMesMap(0,MesMap)->MesMap;
makeMesMap(N,MesMap)->makeMesMap(N-1,[#{}] ++ MesMap).

%node_loop- each process is a node
% ToList - list of nodes to send to
% C- unique number
%MesMap- List of maps, each node gets a map, thats saves his recieved messages
node_loop(ToList,C,MesMap)->
  receive
    {Message} -> if
                   maps:is_key(Message,lists:nth(C,MesMap)) -> sendMes(ToList,Message);
                   true-> banana
                 end;
    {addToList,Pid} -> node_loop(ToList ++ [Pid],C,MesMap);
    _-> node_loop(ToList,C,MesMap)
  end.

node_loop_master(ToList,C)->aaa.

sendMes([],Message)-> io:format("Message: \"~f\" sent.~n", [Message]);
sendMes([H|ToList],Message)-> H ! Message,  sendMes(ToList,Message).