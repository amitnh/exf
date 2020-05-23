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

%----------------------------------------------------------------------------

ring_parallel(N,M) when is_integer(N) and is_integer(M)-> register(node1,spawn(fun()->ring_parallel(N,N,M,node1) end));
ring_parallel(_,_)-> badArguments.

%if N<2 !@@@@@@@@@@@@@@@@@!@!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ring_parallel(_,1,M,_) -> node_loop_master([node2],[],M,M); %close the loop : node1---->node2
ring_parallel(N,I,M,Last) -> register(Node=numToAtom(I),spawn(fun()->node_loop([Last],1,[]) end)),ring_parallel(N,I-1,M,Node). % makes N processes node1,node2,...,nodeN.



%sends M msgs
node_loop_master(ToList,History,0,0)-> sendMes(ToList,{close}),io:format("node1 recieved back all of the messages ~n");
node_loop_master(ToList,History,0,Recieved)-> receive
                                       {close} -> io:format("All processes are closed ~n");%io:format("node1 recieved this: ~p From: ~p ~n",[Message,From]),
                                       {M} when is_integer(M) -> node_loop_master(ToList,History,0,Recieved-1); % 1st time i receieved this msg
                                       _-> node_loop_master(ToList,History,0,Recieved)
                                     end;
node_loop_master(ToList,History,M,Recieved)-> sendMes(ToList, {M}),node_loop_master(ToList,History,M-1,Recieved).

%node_loop- each process is a node
% ToList - list of nodes to send to
% C- unique number
%History- list of messages history: [{C,Message1},{C,Message2},...]
node_loop(ToList,C,History)->
  receive
    {addToList,Pid} -> node_loop(ToList ++ [Pid],C,History);
    {close} -> sendMes(ToList,{close}),io:format("~p is closed ~n",[self()]);
    {Message} -> IsMember= lists:member({C, {Message}},History),
      if
        not IsMember-> sendMes(ToList, {Message}),node_loop(ToList,C,History++[{C, {Message}}]); % 1st time i receieved this msg
        true-> node_loop(ToList,C,History) %iv'e already recieved this msg
      end;
    _-> node_loop(ToList,C,History)
  end.
%---------------------------------------------------------------------------------------------------
%takes Number and makes it an atom node, for the register func. numToAtom(7)-> node7.
numToAtom(N) -> list_to_atom(lists:flatten(io_lib:format("node~B", [N]))).
atomToNum(Atom)->list_to_integer(string:substr(atom_to_list(Atom),5)).


%---------------------------------------------------------------------------------------------------

%send the message to all the members in lists
sendMes([],Message)-> io:format("Message: ~p sent from: ~p ~n", [Message,self()]);
sendMes([H|ToList],Message)-> H ! Message,  sendMes(ToList,Message).