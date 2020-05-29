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
% steady(F):
% takes a function F() and trys to run it.
% in either way, success or failue, it will be written to myLog_204210306.elog with a time stamp
%---------------------------------------------------------------
steady(F) ->
  file:open("myLog_204210306.elog",[write, append]),
  try F() of
    %case of success: {time, success, ReturnValue}
    RetVal -> file:write_file("myLog_204210306.elog", io_lib:format("{~p,success,~p} ~n", [os:system_time(second), RetVal]), [append]),RetVal
  catch
    % case of error: {time, error, Error}
    error:Error -> file:write_file("myLog_204210306.elog",io_lib:format("{~p,error,~p} ~n", [os:system_time(second), Error]), [append]),Error;
    % case of exit: {time, exit, Exit}
    exit:Exit -> file:write_file("myLog_204210306.elog",io_lib:format("{~p,exit,~p} ~n", [os:system_time(second), Exit]), [append]),Exit;
    % case of trow: {time, throw, Throw}
    throw:Throw -> file:write_file("myLog_204210306.elog",io_lib:format("{~p,throw,~p} ~n", [os:system_time(second), Throw]), [append]),Throw
  end.

%---------------------------------------------------------------
% calc(division,A,B):
% trys to do A/B
% it will fail when B=0, but we will catch the Error with the catch
%---------------------------------------------------------------
calc(division,A,B)->try A/B of
                      Val-> Val %case of success
                    catch
                      %case of failure {time,Exceptione, divisionByZero,E}
                      Exception:E -> {os:system_time(second),Exception, divisionByZero,E} % case of exaption
                    end;
calc(_,_,_)-> badArgs.