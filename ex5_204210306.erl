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
% creates N processes thats point to one another.
ring_parallel(N,M)->ring_parallel(N,N,M).
ring_parallel(N,I,M)->spawn(ring_parallel_spawn(N,I,M,self(),self())).

%creating te next chain and going into a recieve loop
ring_parallel_spawn(N,1,M,To,First)->First ! {to,self()} ,ring_parallel_sendMessages(M,To); %end of recursion. close the circle
ring_parallel_spawn(N,I,M,To,First)-> ring_parallel_spawn(N,I-1,M,self(),First), spawn(ring_parallel_loop(To)).

%sends M messages trow First node
ring_parallel_sendMessages(0,To)->time;
ring_parallel_sendMessages(M,To)->
  To ! {M},
  ring_parallel_sendMesssages(M-1,To).


ring_parallel_loop(To)->
  receive
    {to,NewTo}->ring_parallel_loop(NewTo);
    {Message}-> To ! Message;
    _-> ring_parallel_loop(To)
  end.