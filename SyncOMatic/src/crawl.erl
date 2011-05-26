%crawl module
-module(crawl).
-export([crawl/1,crawl/3,file_type/1,print_list/1]).

-include_lib("kernel/include/file.hrl").

% crawl:print_list(crawl:crawl(".")).
% crawl:print_list(crawl:crawl("/media/7faf9644-2189-4d8b-a4a0-4a7ba3de3076/home/ebooks")).

%symply recursive path crawling
listFiles(Dir) -> case file:list_dir(Dir) of
		      {ok,Files} -> Files;
		      {error,_}  -> {error,Dir}
		  end.

crawl(Dir) -> crawl(listFiles(Dir),Dir,[]).

crawl([H|T],Dir,A)	-> 
    FullPath = filename:join([Dir,H]),
    case file_type(FullPath)of
	regular ->
	    crawl(T,Dir,[FullPath|A]);
	directory ->
	    R=crawl(listFiles(FullPath),FullPath,[]),R ++ crawl(T,Dir,A);
	error -> {error,A}
    end;

crawl([],_,A) -> A.

file_type(File) ->
    case file:read_file_info(File) of
	{ok, Facts} ->
	    case Facts#file_info.type of
		regular   -> regular;
		directory -> directory;
		_ 	  -> error
	    end;
	_  -> error
    end.

% printlist stuff
print_list(L)->print_list(L,0).

print_list([H|T],N) ->
    io:format("~p~n",[H]),
    print_list(T,N+1);
print_list([],N) ->
    {ok,N}.
