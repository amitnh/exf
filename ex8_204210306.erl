%%%-------------------------------------------------------------------
%%% @author amit
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ex8_204210306).
-author("amit").


%% API
-export([remoteStartChat/1,startChat/1,call/1,send/1,steadyLink/1,steadyMon/1]).
%---------------------------------------------------------------
%%startChat()->Pid
%---------------------------------------------------------------
startChat(RemoteName@IP)->
  case whereis(localPID) of
    undefined ->
      register(localPID, Pid_Local_Sender = spawn(fun() -> localLoop(RemoteName@IP, 0, 0) end)), %spawn process for local
      rpc:call(RemoteName@IP, ex8_204210306, remoteStartChat, [node()]), %call a function thats spawn process for remote
      put(remoteName@IP, RemoteName@IP), % Saves RemoteName@IP
      Pid_Local_Sender; %returns the pid
    _ -> io:format("chat already works")
  end.

localLoop(RemoteName@IP, Sent, Received)->
  receive
    stats ->
      io:format("Local stats: sent: ~p received: ~p~n", [Sent, Received]),
      localLoop(RemoteName@IP, Sent, Received);

    quit ->
      {remotePID, RemoteName@IP} ! quit,
      io:format("~p - Successfully closed.~n",[self()]),
      exit(requested);

    {fromRemote, Message} ->
      io:format("~p - local recieved msg from remote .~n",[Message]),
      Message,
      localLoop(RemoteName@IP, Sent, Received + 1);

    Message ->
      {remotePID,RemoteName@IP} ! {fromLocal, Message},
      io:format("~p - local recieved msg .~n",[Message]),
      localLoop(RemoteName@IP, Sent + 1, Received)
  end.

call(Message)-> rpc:call(get(remoteName@IP), ex8_204210306, send, [Message]).%
send(Message)-> remotePID ! Message.

remoteStartChat(LocalName@IP) ->
  % check if we already put it
  case whereis(remotePID) of
    undefined ->
      register(remotePID, spawn(fun() -> remoteLoop(LocalName@IP, 0, 0) end));
    _ -> io:format("chat already works~n")
  end.


remoteLoop(LocalName@IP, Sent, Received) ->
  receive
    stats ->
      io:format("remote stats: sent: ~p received: ~p~n", [Sent, Received]),
      remoteLoop(LocalName@IP, Sent, Received);

    quit->
      {localPID, LocalName@IP} ! quit,
      io:format("~p - Successfully closed.~n",[self()]),
      exit(requested);

    {fromLocal, Message}->
      io:format("~p - remote recieved msg from local.~n",[Message]),
      remoteLoop(LocalName@IP, Sent, Received + 1);

    Message ->
      io:format("~p - remote recieved msg .~n",[Message]),
      {localPID, LocalName@IP} ! {fromRemote, Message},
      remoteLoop(LocalName@IP, Sent + 1, Received)
  end.
%--------------------------------------------------------------------------------------------
% Spawns a process to evaluate function F/0, Links the two processes
% Terminates after 5 seconds if no exception occurs, Returns the PID of spawned process
steadyLink(F) when is_function(F)-> Pid = spawn_link(F),
  receive
    after 5000 -> Pid
  end;
steadyLink(_)-> notAfunction.
%--------------------------------------------------------------------------------------------
steadyMon(F) ->
  spawn_monitor(fun()->F()end),
  % Wait for termination message from the above process
  receive
  % Normal termination
    {_,_,_, PID, normal} ->
      "Normal termination of process " ++ getPID(PID) ++ " was detected";
  % Termination with an a exception
    {_,_,_, PID, Info} ->
      "An exception in process " ++ getPID(PID) ++ " was detected: " ++ Info
  after 5000 -> ok
  end.

%% getPID(PID)
getPID(PID)->
  string:sub_string(pid_to_list(PID), 2, (string:len(pid_to_list(PID))-1)).
