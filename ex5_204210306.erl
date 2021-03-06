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
-export([ring_parallel/2,ring_serial/2,mesh_parallel/3,mesh_serial/3]).

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

ring_parallel(1,_) -> notAcircle;
ring_parallel(N,M) when is_integer(N) and is_integer(M)-> Self= self(), register(node1,spawn(fun()->ring_parallel(N,N,M,node1,Self) end)),answer_loop();
ring_parallel(_,_)-> badArguments.

ring_parallel(_,1,M,_,TopPid) ->  TopPid ! node_loop_master([node2],[],M,0,0,os:timestamp()); %close the loop : node1---->node2
ring_parallel(N,I,M,Last,TopPid) -> register(Node=numToAtom(I),spawn(fun()->node_loop([Last],I,[]) end)),ring_parallel(N,I-1,M,Node,TopPid). % makes N processes node1,node2,...,nodeN.

answer_loop()->   receive Msg-> flush(),Msg end.
flush() -> receive _ ->flush() after 0 -> ok end.

%sends M msgs
node_loop_master(ToList,_,M,M,M,StartTime)-> sendMes(ToList,close), %recieved all msgs
      receive
        {_,_,close} -> flush(),
          io:format("Total Time of Function: ~f miliseconds~n", [Time=timer:now_diff(os:timestamp(), StartTime) / 1000]), {Time,M,M}%waits for the {close} message back
      end;
node_loop_master(ToList,History,M,M,Recieved,StartTime)->
      receive
         {_,_,close} -> io:format("[node1] and All other processes are closed ~n"),
           io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(os:timestamp(), StartTime) / 1000]), {timer:now_diff(os:timestamp(), StartTime),M,Recieved};
         {_,_,{_,Msg}} when is_integer(Msg) -> node_loop_master(ToList,History,M,M,Recieved+1,StartTime); % 1st time i receieved this msg
         _-> node_loop_master(ToList,History,M,M,Recieved,StartTime)
       end;
node_loop_master(ToList,History,M,Sent,Recieved,StartTime)-> sendMes(ToList, {pidToRegName(self()),Sent}),node_loop_master(ToList,History,M,Sent+1,Recieved,StartTime).

%node_loop- each process is a node
% ToList - list of nodes to send to
% C- unique number
%History- list of messages history: [{C,Message1},{C,Message2},...]
node_loop(ToList,C,History)->
  receive %prioritize close
    {_,_,close} -> sendMes(ToList,close),flush(); %for the ring use
    {_,_,{master,close}}->flush()
  after 0 ->
    receive
      %{addToList,Pid} -> node_loop(ToList ++ [Pid],C,History);
      {_,_,close} -> sendMes(ToList,close); %for the ring close use
      {_,_,{master,close}}->io:format(""); % for mesh grid close use
      {_,_, {Atom,Message}}-> IsMember= lists:member({Atom, Message},History), %check if ive send that msg in the past
        if
          not IsMember->% 1st time i receieved this msg
             if Atom =:= master -> sendMes(ToList, {master,Message}),% if its from the master %passing the masters msg
                                   sendMes(ToList, {pidToRegName(self()),Message}), %passing a unique response
                                   node_loop(ToList,C,History++[{master, Message}]++[{pidToRegName(self()),Message}]); %adding to history msgs
                true ->
                         sendMes(ToList, {Atom,Message}),%case atom is not master just pass it
                         node_loop(ToList,C,History++[{Atom,Message}]) %adding to history msgs
                end;
          true-> node_loop(ToList,C,History) %iv'e already received this msg
        end;
      _-> node_loop(ToList,C,History)
    end
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
ring_serial(V,M) when is_integer(V) and is_integer(M)->Self=self(), spawn(fun() -> ring_serial(1,V+1,0,M,os:timestamp(),Self) end),answer_loop();
ring_serial(_,_)-> badArguments.

% i similate the circle
% Vertex1 and vertexN is the sameone
ring_serial(_,V,M,M,StartTime,Self)->
                      receive
                         {_,V,M}->  io:format("Total Time of Function: ~f miliseconds~n", [Time = timer:now_diff(os:timestamp(), StartTime) / 1000]), Self ! {Time,M,M}; % if im the last msg
                         {_,Me,M}-> ring_serial(Me,V,1,M,StartTime,Self);% if im the last msg for this vertex
                         {_,Me,_}-> ring_serial(Me,V,M,M,StartTime,Self); %middle of recieving msgs
                         _ -> error
                       end;
ring_serial(Me,V,Sent,M,StartTime,Self) -> self() ! {Me,Me+1,Sent+1}
  %,io:format("Message: ~p sent from: vertex~p to: vertex~p ~n", [Sent,Me,Me+1])
  ,ring_serial(Me,V,Sent+1,M,StartTime,Self).
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

mesh_parallel(1,_,_)-> chooseNBiggerThen1;
mesh_parallel(N,M,C) when is_integer(N) and is_integer(M) and is_integer(C) and (C>0) and (C<N*N +1) ->Self= self(), register(numToAtom(C),spawn(fun()->mesh_parallel(N,N*N,M,C,Self) end)), answer_loop();
mesh_parallel(_,_,_)-> badArguments.

mesh_parallel(N,0,M,C,Self) -> node_loop_master_mesh(getNeighborsMesh(C,N),[],M,0,0,(((N*N)-1)*M),os:timestamp(),Self); %mesh master does that- number C
mesh_parallel(N,C,M,C,Self) -> mesh_parallel(N,C-1,M,C,Self); % skip building C
mesh_parallel(N,I,M,C,Self) -> register(numToAtom(I),spawn(fun()->node_loop(getNeighborsMesh(I,N),I,[]) end)),mesh_parallel(N,I-1,M,C,Self). % makes N processes node1,node2,...,nodeN. %,io:format("build node~p ~n",[I])

%get the neighbors list, gets the N and the index I,
% return list of neighbors nodes for example: getneighborsMesh(2,10)-> [node1,node3,node12]
getNeighborsMesh(I,N)-> Col= I rem N, Line = I div N,
  Neighbors= [Line*N + Col-1,Line*N + Col+1,(Line+1)*N + Col,(Line-1)*N + Col], % left, right,down, up
  [numToAtom(X)||X<-Neighbors,X>0,X<(N*N)+1]. %taking only the neighbors that exists between 1-N^2

getAllNodes(N)-> [numToAtom(X)||X<-lists:seq(1, N*N)].


%sends M msgs
node_loop_master_mesh(_,_,M,M,ToRecieve,ToRecieve,StartTime,Self)-> sendMes(getAllNodes((ToRecieve div M) +1) -- [pidToRegName(self())], {master,close}), %recieved all msgs getAllNodes((ToRecieve div M) +1) -- [pidToRegName(self())]
     EndTime=os:timestamp(), io:format("Total Time of Function: ~f miliseconds~n", [timer:now_diff(EndTime, StartTime) / 1000]), Self ! {timer:now_diff(EndTime, StartTime),M,M};%waits for the {close} message back  sleep(2000),unregisterAll((ToRecieve div M))

node_loop_master_mesh(ToList,History,M,M,Recieved,ToRecieve,StartTime,Self)-> %wating to recieve all the msgs back
  receive
    {_,_,close} -> io:format("C and All other processes are closed ~n"),
      io:format("Total Time of Function: ~f miliseconds~n", [Time= timer:now_diff(os:timestamp(), StartTime) / 1000]), {Time,M,Recieved};
    {_,_, {master,_}}->node_loop_master_mesh(ToList,History,M,M,Recieved,ToRecieve,StartTime,Self);
      {_,_, {Atom,Message}}-> IsMember= lists:member({Atom, Message},History), %check if ive send that msg in the past
                  if not IsMember ->% 1st time i receieved this msg
                    node_loop_master_mesh(ToList,History++[{Atom, Message}],M,M,Recieved+1,ToRecieve,StartTime,Self);
                    true->node_loop_master_mesh(ToList,History,M,M,Recieved,ToRecieve,StartTime,Self)
                  end;

    _ -> node_loop_master_mesh(ToList,History,M,M,Recieved,ToRecieve,StartTime,Self)
  end;
node_loop_master_mesh(ToList,History,M,Sent,Recieved,ToRecieve,StartTime,Self)-> sendMes(ToList, {master,Sent}),node_loop_master_mesh(ToList,History,M,Sent+1,Recieved,ToRecieve,StartTime,Self).

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

mesh_serial(N,M,C) when is_integer(N) and is_integer(M) and (C>0) and (C<N*N+1) -> Self= self(),
  spawn(fun() ->
  mesh_serial(N,C,0,M,
    ((N*N)-1)*M, % ToReceive
    [[]||_<-lists:seq(1,(N*N))], %N*N empty lists in a list. for History
    os:timestamp(),Self)
        end),
answer_loop(); % wait for answer
mesh_serial(_,_,_)->badArguments.


%history is map N*N maps for each vertex
mesh_serial(_,_,M,M,0,_,StartTime,Self)-> Time = timer:now_diff(os:timestamp(), StartTime),io:format("Total Time of Function: ~f miliseconds~n", [Time / 1000]), Self ! {Time,M,M}; % if im the last msg
mesh_serial(N,C,M,M,ToReceive,History,StartTime,Self)->
  receive
    {master,X,Msg}->
      List=[lists:nth(X,History)],
              IsMember = lists:member({master,X,Msg},List), %master msg
                    if not IsMember ->Neighbors=[atomToNum(Y)||Y<-getNeighborsMesh(X,N)]--[C], %first time to receive msg
                                      [self() ! {master,Y,Msg} ||Y<-Neighbors], %pass the master

                                      [self() ! {X,Y,Msg} ||Y<-Neighbors], %new msg

                                      mesh_serial(N,C,M,M,ToReceive,updateHistory(updateHistory(History,X,{master,X,Msg}),X,{X,Msg}),StartTime,Self);
                      true-> mesh_serial(N,C,M,M,ToReceive,History,StartTime,Self)
                    end;
    {Z,C,Msg}->
      List= [lists:nth(C,History)],
                IsMember = lists:member({Z,Msg},List), %normal msg, pass it if u havent yet
                if not IsMember -> mesh_serial(N,C,M,M,ToReceive-1,updateHistory(History,C,{Z,Msg}),StartTime,Self); %recieved a new msg
                true-> mesh_serial(N,C,M,M,ToReceive,History,StartTime,Self) %recieved a old msg
                end;
    {Z,X,Msg}->
      IsMember = lists:member({Z,Msg},[lists:nth(X,History)]), %normal msg, pass it if u havent yet
                  if not IsMember ->Neighbors=[atomToNum(Y)||Y<-getNeighborsMesh(X,N)], [self() ! {Z,Y,Msg} ||Y<-Neighbors], %first time to receive msg
                    [self() ! {Z,Y,Msg} ||Y<-Neighbors],

                    mesh_serial(N,C,M,M,ToReceive,updateHistory(History,X,{Z,Msg}),StartTime,Self);
                    true-> mesh_serial(N,C,M,M,ToReceive,History,StartTime,Self)
                  end;
    _ -> error
  end;



mesh_serial(N,C,I,M,ToReceive,History,StartTime,Self) ->
Neighbors=[atomToNum(X)||X<-getNeighborsMesh(C,N)], %list of numbers of neighbors: [2,5,3,7].
  [self() ! {master,X,I} ||X<-Neighbors],% send a Msg to each Neighbors

            mesh_serial(N,C,I+1,M,ToReceive,History,StartTime,Self). % recursion


%insert Msg to the History Matrix
updateHistory(History,I,ToAdd)->IHis= [lists:nth(I,History)] ++ [ToAdd],
  lists:sublist(History,I) ++ IHis ++ lists:nthtail(I+1,History).
