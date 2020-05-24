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
-export([ring_parallel/2,ring_serial/2]).

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

ring_parallel(1,_) -> notAcircle;
ring_parallel(N,M) when is_integer(N) and is_integer(M)-> register(node1,spawn(fun()->ring_parallel(N,N,M,node1) end));
ring_parallel(_,_)-> badArguments.

ring_parallel(_,1,M,_) -> node_loop_master([node2],[],M,0,0,os:timestamp()); %close the loop : node1---->node2
ring_parallel(N,I,M,Last) -> register(Node=numToAtom(I),spawn(fun()->node_loop([Last],1,[]) end)),ring_parallel(N,I-1,M,Node). % makes N processes node1,node2,...,nodeN.



%sends M msgs
node_loop_master(ToList,_,M,M,M,StartTime)-> sendMes(ToList,close),io:format("node1 recieved back all of the messages ~n"), %recieved all msgs
      receive
        {_,_,close} -> io:format("[node1] and All other processes are closed ~n"),
          io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]), {timer:now_diff(os:timestamp(), StartTime),M,M}%waits for the {close} message back
      end;
node_loop_master(ToList,History,M,M,Recieved,StartTime)->
      receive
         {_,_,close} -> io:format("[node1] and All other processes are closed ~n"),
           io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]), {timer:now_diff(os:timestamp(), StartTime),M,Recieved};
         {_,_,Msg} when is_integer(Msg) -> node_loop_master(ToList,History,M,M,Recieved+1,StartTime); % 1st time i receieved this msg
         _-> node_loop_master(ToList,History,M,M,Recieved,StartTime)
       end;
node_loop_master(ToList,History,M,Sent,Recieved,StartTime)-> sendMes(ToList, Sent),node_loop_master(ToList,History,M,Sent+1,Recieved,StartTime).

%node_loop- each process is a node
% ToList - list of nodes to send to
% C- unique number
%History- list of messages history: [{C,Message1},{C,Message2},...]
node_loop(ToList,C,History)->
  receive
    %{addToList,Pid} -> node_loop(ToList ++ [Pid],C,History);
    {_,_,close} -> sendMes(ToList,close),io:format("~p is closed ~n",[pidToRegName(self())]);
    {_,_,Message}-> IsMember= lists:member({C, Message},History),
      if
        not IsMember-> sendMes(ToList, Message),node_loop(ToList,C,History++[{C, Message}]); % 1st time i receieved this msg
        true-> node_loop(ToList,C,History) %iv'e already recieved this msg
      end;
    _-> node_loop(ToList,C,History)
  end.
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%send the message to all the members in lists
sendMes([],_)-> io:format(""); %io:format("Message: ~p sent from: ~p to all ~n", [Message,pidToRegName(self())]);
sendMes([H|ToList],Message)-> H ! {self(),H,Message},io:format("Message: ~p sent from: ~p to: ~p ~n", [Message,pidToRegName(self()),[H]]),  sendMes(ToList,Message).

%gets the RegName from the Pid, for example:      <0.78.0> ---> [node4]
pidToRegName(Pid)-> [Y ||{registered_name,Y}<-process_info(Pid)].
%----------------------------------------------------------------------------
%takes Number and makes it an atom node, for the register func. numToAtom(7)-> node7.
numToAtom(N) -> list_to_atom(lists:flatten(io_lib:format("node~B", [N]))).
atomToNum(Atom)->list_to_integer(string:substr(atom_to_list(Atom),5)).



%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
ring_serial(1,_) -> notAcircle;
ring_serial(V,M) when is_integer(V) and is_integer(M)-> spawn(fun() -> ring_serial(1,V+1,0,M,os:timestamp()) end);
ring_serial(_,_)-> badArguments.

% i similate the circle
% Vertex1 and vertexN is the sameone
ring_serial(_,V,M,M,StartTime)->
                      receive
                         {_,V,M}->  io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]), {timer:now_diff(os:timestamp(), StartTime),M,M}; % if im the last msg
                         {_,Me,M}-> ring_serial(Me,V,1,M,StartTime);% if im the last msg for this vertex
                         {_,Me,_}-> ring_serial(Me,V,M,M,StartTime); %middle of recieving msgs
                         _ -> error
                       end;
ring_serial(Me,V,Sent,M,StartTime) -> self() ! {Me,Me+1,Sent+1}
  ,io:format("Message: ~p sent from: vertex~p to: vertex~p ~n", [Sent,Me,Me+1])
  ,ring_serial(Me,V,Sent+1,M,StartTime).
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------