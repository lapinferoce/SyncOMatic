-module(fileset).
-export([mkFS/1,display_FS/1]).
-import(utilmisc).
-import(md5).
-import(fileutil).
-import(crawl).
 
mkFS(RootPath)->
     List = crawl:crawl(RootPath),
     utilmisc:pmap(fun(X)->{fileutil:rmRootPath(X,RootPath),md5:md5_hex_file(X)} end ,List).

						 %FS display
display_FS(FS)->display_FS(FS,0).

display_FS([H|T],N) ->
     {Path,Md} = H,
     io:format("~p | ~p~n",[Path,Md]),
     display_FS(T,N+1);
 display_FS([],N) ->
     {ok,N}.
		
