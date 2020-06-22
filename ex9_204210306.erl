%%%-------------------------------------------------------------------
%%% @author amit
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ex9_204210306).
-author("amit").

%% API
-export([etsBot/0]).
%---------------------------------------------------------------
%%startChat()->Pid
%---------------------------------------------------------------
etsBot()->   {_, File} = file:open("etsCommands.txt",[read]),
  [Type|Actions]= readFile(File),
  makeEts(Type),
  doActions(Actions),
  printEts().

makeEts(Type)-> try ets:new(botEts, [list_to_atom(Type -- "\n"), named_table]) catch _-> errorWrongType end.

 % printEts().
%%printEts()-> file:open("etsRes_204210306.ets",[write, append]),
%%  file:write_file("etsRes_204210306.ets", io_lib:format("~p ~p~n", [Key, Value]), [append]).

%---------- readlines, open file and return the String inside
readFile(File) ->
  case file:read_line(File) of
    % Data
    {ok, Data} -> [Data | readFile(File)];
    % End of file
    eof -> []
  end.