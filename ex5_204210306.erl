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
-export([ring_parallel/2,numToAtom/1,atomToNum/1]).

%----------------------------------------------------------------------------
ring_parallel(N,M)-> register(N,spawn(fun()->node_loop([self()],1,[]) end)).
%%                     end,
%%  receive
%%    Msg-> io:format("Message: \"~f\" recieved.~n", [Msg]);
%%    _->ring_parallel(2,M)



%node_loop- each process is a node
% ToList - list of nodes to send to
% C- unique number
%History- list of messages history: [{C,Message1},{C,Message2},...]
node_loop(ToList,C,History)->
  receive
    {Message} -> IsMember= lists:member({C,Message},History),
                if
                   not IsMember-> sendMes(ToList,Message),node_loop(ToList,C,History++[{C,Message}]); % 1st time i receieved this msg
                   true-> node_loop(ToList,C,History) %iv'e already recieved this msg
                end;
    {addToList,Pid} -> node_loop(ToList ++ [Pid],C,History);
    _-> node_loop(ToList,C,History)
  end.

%takes Number and makes it an Atom node, for the register func. numToAtom(7)-> atom7.
numToAtom(N) -> list_to_atom(lists:flatten(io_lib:format("node~B", [N]))).
atomToNum(Atom)->list_to_integer(string:substr(atom_to_list(Atom),5)).


node_loop_master(ToList,C)->aaa.

%send the message to all the members in lists
sendMes([],Message)-> io:format("Message: \"~f\" sent.~n", [Message]);
sendMes([H|ToList],Message)-> H ! Message,  sendMes(ToList,Message).