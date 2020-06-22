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
-export([]).
%---------------------------------------------------------------
%%startChat()->Pid
%---------------------------------------------------------------
file:open("myLog_204210306.elog",[write, append]),
try F() of
%case of success: {time, success, ReturnValue}
RetVal -> file:write_file("myLog_204210306.elog", io_lib:format("{~p,success,~p} ~n", [os:system_time(second), RetVal]), [append]),RetVal
catch