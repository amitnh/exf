%%%-------------------------------------------------------------------
%%% @author amit
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ex7_204210306).
-author("amit").


%% API
-export([steady/1,calc/3]).
%---------------------------------------------------------------
steady(F) ->
  file:open("myLog_204210306.elog",[read, write, append]),
  try F() of
    %case of success: {time, success, ReturnValue}
    RetVal -> file:write_file("myLog_204210306.elog", io_lib:format("{~p,success,~p} ~n", [erlang:localtime(), RetVal]), [append]),RetVal
  catch
    % case of error: {time, error, Error}
    error:Error -> file:write_file("myLog_204210306.elog",io_lib:format("{~p,error,~p} ~n", [erlang:localtime(), Error]), [append]), Error;
    % case of exit: {time, exit, Exit}
    exit:Exit -> file:write_file("myLog_204210306.elog",io_lib:format("{~p,exit,~p} ~n", [erlang:localtime(), Exit]), [append]), Exit;
    % case of trow: {time, throw, Throw}
    throw:Throw -> file:write_file("myLog_204210306.elog",io_lib:format("{~p,throw,~p} ~n", [erlang:localtime(), Throw]), [append]), Throw
  end.

calc(division,A,B)->try A/B of
                      Val-> Val
                    catch
                      error:Error -> divisionByZero
                    end.