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
  printEts(),
  ets:delete(botEts).

makeEts(Type)-> try ets:new(botEts, [list_to_atom(Type -- "\n"), named_table]) catch _-> errorWrongType end.

%--------------------------------------------------------------------------printEts().
printEts()-> file:open("etsRes_204210306.ets",[write]), printEts(ets:first(botEts)).
printEts('$end_of_table')->ok;
printEts(Res)-> Next = ets:next(botEts,Res), [{Key,Value}|_] = ets:lookup(botEts,Res),
  file:write_file("etsRes_204210306.ets", io_lib:format("~p ~p~n", [Key,Value]), [append]),
  printEts(Next).



%---------- readlines, open file and return the String inside
readFile(File) ->
  case file:read_line(File) of
    % Data
    {ok, Data} -> [Data | readFile(File)];
    % End of file
    eof -> []
  end.

doActions([])->ok;
doActions([H|T])-> [Command|Data] = string:tokens(H -- "\n"," "), %io:format("~p~n",[Data]),
                    case Command of
                      "update" -> update(Data);
                      "insert" -> insert(Data);
                      "delete" -> delete(Data);
                      "lookup" -> lookup(Data);
                      _-> errorWrongCommand
                    end,
                    doActions(T).

insert([])-> ok;
insert([Key,Value|T])->  LookUp = ets:lookup(botEts,Key),
                              if
                                LookUp ==[]-> ets:insert(botEts,{Key,Value}); %key is not in the ETS
                                true-> keyAlreadyIn %key is in the ETS already
                              end,insert(T);
insert(_)-> errorValue.

update([])-> ok;
update([Key,Value|T])->  LookUp = ets:lookup(botEts,Key),
  if
    LookUp ==[]-> notInEts; %key is not in the ETS
    true-> ets:insert(botEts,{Key,Value}) %key is in the ETS already
  end,
  update(T);
update(_)-> errorValue.

delete([])-> ok;
delete([Key|T])->  ets:delete(botEts,Key) , delete(T); % if its not there -> ignore
delete(_)-> error.

lookup([])-> ok;
lookup([Key|T])->  LookUp = ets:lookup(botEts,Key) , % if its not there -> ignore
printLookUp(LookUp),  lookup(T);
lookup(_)-> error.

printLookUp([])->ok;
printLookUp([{Key,Value}|T]) -> io:format("key: ~p val: ~p ~n",[Key,Value]), printLookUp(T).