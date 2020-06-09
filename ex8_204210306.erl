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
-export([startChat/1,call/1,send/1,steadyLink/1,steadyMon/1]).
%---------------------------------------------------------------
%%startChat()->Pid
%---------------------------------------------------------------
startChat(RemoteName@IP)->
  case whereis(localPID) of
    undefined ->
      register(localPID, Pid_Local_Sender = spawn(fun() -> loop(RemoteName@IP, 0, 0) end)),
      rpc:call(RemoteName@IP, ex8_204210306, addToChat, [node()]),
      put(remoteName@IP, RemoteName@IP),   % Saves RemoteName@IP
      Pid_Local_Sender; %returns the pid
    _ -> io:format("chat already works")
  end.


addToChat(LocalName@IP) ->
  % check if we already put it
  case whereis(remotePID) of
    undefined ->
      register(remotePID, spawn(fun() -> remoteLoop(LocalName@IP, 0, 0) end));
    _ -> io:format("chat already works")
  end.

send(Message) -> remotePID ! Message.

call(Message)-> rpc:call(get(remoteName@IP), ex8_204210306, send, [Message]).


loop(RemoteName@IP, Sent, Received)->
  receive
    stats ->
      io:format("Local stats: sent: ~p received: ~p~n", [Sent, Received]),
      loop(RemoteName@IP, Sent, Received);

    quit ->
      {remotePID, RemoteName@IP} ! quit,
      io:format("~p - Successfully closed.~n",[self()]),
      exit(requested);

    {fromRemote, Message} ->
      Message,
      loop(RemoteName@IP, Sent, Received + 1);

    Message ->
      {remotePID, RemoteName@IP} ! {fromLocal, Message},
      loop(RemoteName@IP, Sent + 1, Received)
  end.


remoteLoop(LocalName@IP, SentIndex, ReceivedIndex) ->
  receive
    stats ->
      io:format("remote stats: sent: ~p received: ~p~n", [SentIndex, ReceivedIndex]),
      remoteLoop(LocalName@IP, SentIndex, ReceivedIndex);

    quit->
      io:format("~p - Successfully closed.~n",[self()]),
      exit(requested);

    {fromLocal, _}->
      remoteLoop(LocalName@IP, SentIndex, ReceivedIndex + 1);

    Message ->
      {localPID, LocalName@IP} ! {fromRemote, Message},
      remoteLoop(LocalName@IP, SentIndex + 1, ReceivedIndex)
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
  spawn_monitor(ex8_204210306, steadyEval, [F]),
  % Wait for termination message from the above process
  receive
  % Normal termination
    {_,_,_, PID, normal} ->
      "Normal termination of process " ++ getPID(PID) ++ " was detected";

  % Termination with an a exception
    {_,_,_, PID, Info} ->
      "An exception in process " ++ getPID(PID) ++ " was detected: " ++ atom_to_list(Info)
  after 5000 -> ok
  end.

%% getPID(PID)
%  Extract the x.y.z PID number from termination message PID component
getPID(PID)->
  string:sub_string(pid_to_list(PID), 2, (string:len(pid_to_list(PID))-1)).

%% steadyEval(F)
% aid function, evalute the function F on the new process that have had been monitored
% <ExceptionType> is one of the following: error, exit or throw
steadyEval(F) ->
  try F() of
    _	-> normalTermination
  catch
    error:_Error 	-> exit(error);
    exit:_Exit	-> exit(exit);
    throw:_Throw	-> exit(throw)
  end.