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
-export([startChat/1,call/1,send/1]).
%---------------------------------------------------------------
%%startChat()->Pid
%---------------------------------------------------------------
startChat(RemoteName@IP)->
  register(remoteProcessPID, Pid_Local_Sender = spawn(fun() -> loop(RemoteName@IP, 0, 0) end)),
  rpc:call(RemoteName@IP, ex8_204210306, addToChat, [node()]),
  put(remoteName@IP, RemoteName@IP),   % Saves RemoteName@IP
  Pid_Local_Sender. %returns the pid

addToChat(LocalName@IP) ->
  % check if we already put it
  case whereis(remoteProcessPID) of
    undefined ->
      register(remoteProcessPID, spawn(fun() -> remoteLoop(LocalName@IP, 0, 0) end));
    _ -> io:format("chat already works")
  end.

send(Message) ->
  remoteProcessPID ! Message.

call(Message)->
  rpc:call(get(remoteName@IP), ex8_204210306, send, [Message]).


%% Aid function - block receive loop for the local process
loop(RemoteName@IP, Sent, Received)->
  receive
    stats ->
      io:format("Local stats: sent: ~p received: ~p~n", [Sent, Received]),
      loop(RemoteName@IP, Sent, Received);

    quit ->
      % Send exit message to the remote process
      {remoteProcessPID, RemoteName@IP} ! quit,
      io:format("~p - Successfully closed.~n",[self()]),
      exit(requested);

    {fromRemote, Message} ->
      Message,
      %io:format("Local process recieved a message from Remote process : ~p ~n",[Message]),
      loop(RemoteName@IP, Sent, Received + 1);

    Message ->
      {remoteProcessPID, RemoteName@IP} ! {fromLocal, Message},
      %io:format("Local process recieved a message : ~p ~n",[Message]),
      loop(RemoteName@IP, Sent + 1, Received)
  end.


%% Aid function - block receive loop for the remote process
remoteLoop(LocalName@IP, SentIndex, ReceivedIndex) ->
  receive
    stats ->
      io:format("remote stats: sent: ~p received: ~p~n", [SentIndex, ReceivedIndex]),
      remoteLoop(LocalName@IP, SentIndex, ReceivedIndex);

    quit->
      io:format("~p - Successfully closed.~n",[self()]),
      exit(requested);

  % Receive of a message from the local process
    {fromLocal, _}->
      remoteLoop(LocalName@IP, SentIndex, ReceivedIndex + 1);

    Message ->
      {localProcessPID, LocalName@IP} ! {fromRemote, Message},
      remoteLoop(LocalName@IP, SentIndex + 1, ReceivedIndex)
  end.
