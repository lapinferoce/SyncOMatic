%crawl module
-module(serialize).
-export([store/2,load/1]).

load(File) ->
    case file:open(File, read) of
	{ok, S} ->
	    Val = load1(S),
	    file:close(S),
	    {ok, Val};
	{error, Why} ->
	    {error, Why}
    end.

load1(S) ->
    case io:read(S, '') of
	{ok, Term} -> [Term|load1(S)];
	eof-> [];
	Error -> Error
    end.

store(File, L) ->
    {ok, S} = file:open(File, write),
    lists:foreach(fun(X) -> io:format(S, "~p.~n" ,[X]) end, L),
    file:close(S).


