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
-export([ring_parallel/2,ring_serial/2,mesh_parallel/3,getNeighborsMesh/2]).

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

ring_parallel(1,_) -> notAcircle;
ring_parallel(N,M) when is_integer(N) and is_integer(M)-> register(node1,spawn(fun()->ring_parallel(N,N,M,node1) end));
ring_parallel(_,_)-> badArguments.

ring_parallel(_,1,M,_) -> node_loop_master([node2],[],M,0,0,os:timestamp()); %close the loop : node1---->node2
ring_parallel(N,I,M,Last) -> register(Node=numToAtom(I),spawn(fun()->node_loop([Last],I,[]) end)),ring_parallel(N,I-1,M,Node). % makes N processes node1,node2,...,nodeN.



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
    {From,_,Message}-> IsMember= lists:member({From, Message},History), %check if ive send that msg in the past
      if
        not IsMember-> sendMes(ToList, Message),node_loop(ToList,C,History++[{From, Message}]); % 1st time i receieved this msg
        true-> node_loop(ToList,C,History) %iv'e already recieved this msg
      end;
    _-> node_loop(ToList,C,History)
  end.
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%send the message to all the members in lists
sendMes([],_)-> void; %io:format("Message: ~p sent from: ~p to all ~n", [Message,pidToRegName(self())]);
sendMes([H|ToList],Message)->IsRegName = lists:member(H,registered()), MyName= pidToRegName(self()),
  if IsRegName and (H /= MyName) -> H ! {self(),H,Message},  sendMes(ToList,Message); %check if H not closed yet
  %,io:format("Message: ~p sent from: ~p to: ~p ~n", [Message,pidToRegName(self()),[H]])
    true -> sendMes(ToList,Message)
end.


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
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

mesh_parallel(1,M,C)-> chooseNBiggerThen1;
mesh_parallel(N,M,C) when is_integer(N) and is_integer(M) and is_integer(C) and (C>0) and (C<N*N +1) ->register(numToAtom(C),spawn(fun()->mesh_parallel(N,N*N,M,C) end));
mesh_parallel(_,_,_)-> badArguments.

mesh_parallel(N,0,M,C) -> node_loop_master_mesh(getNeighborsMesh(C,N),[],M,0,0,N*M,os:timestamp()); %mesh master does that- number C
mesh_parallel(N,C,M,C) -> mesh_parallel(N,C-1,M,C); % skip building C %io:format("skipped node~p ~n",[C]),
mesh_parallel(N,I,M,C) -> register(numToAtom(I),spawn(fun()->node_loop(getNeighborsMesh(I,N),I,[]) end)),mesh_parallel(N,I-1,M,C). % makes N processes node1,node2,...,nodeN. %,io:format("build node~p ~n",[I])

%get the neighbors list, gets the N and the index I,
% return list of neighbors nodes for example: getneighborsMesh(2,10)-> [node1,node3,node12]
getNeighborsMesh(I,N)-> Col= I rem N, Line = I div N,
  Neighbors= [Line*N + Col-1,Line*N + Col+1,(Line+1)*N + Col,(Line-1)*N + Col], % left, right,down, up
  [numToAtom(X)||X<-Neighbors,X>0,X<(N*N)+1]. %taking only the neighbors that exists between 1-N^2

getAllNodes(N)-> [numToAtom(X)||X<-lists:seq(1, N*N)].

%sends M msgs
node_loop_master_mesh(ToList,_,M,M,ToRecieve,ToRecieve,StartTime)-> sendMes(getAllNodes(ToRecieve div M),close), %recieved all msgs
  receive
    {_,_,close} -> io:format("C and All other processes are closed ~n"),
      io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]), {timer:now_diff(os:timestamp(), StartTime),M,M};%waits for the {close} message back
    _ -> node_loop_master_mesh(ToList,ToList,M,M,ToRecieve,ToRecieve,StartTime)
  end;
node_loop_master_mesh(ToList,History,M,M,Recieved,ToRecieve,StartTime)-> %wating to recieve all the msgs back
  receive
    {_,_,close} -> io:format("C and All other processes are closed ~n"),
      io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]), {timer:now_diff(os:timestamp(), StartTime),M,Recieved};
    {_,_,Msg} when is_integer(Msg) -> node_loop_master_mesh(ToList,History,M,M,Recieved+1,ToRecieve,StartTime); % 1st time i receieved this msg
    _ -> node_loop_master_mesh(ToList,History,M,M,Recieved,ToRecieve,StartTime)
  end;
node_loop_master_mesh(ToList,History,M,Sent,Recieved,ToRecieve,StartTime)-> sendMes(ToList, Sent),node_loop_master_mesh(ToList,History,M,Sent+1,Recieved,ToRecieve,StartTime).


