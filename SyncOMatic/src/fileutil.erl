-module(fileutil).
-export([rmRootPath/2,addRootPath/2,move/3,save/3,delete/2]).
-import(md5).

%remove root probleme with /C
rmRootPath(Path,Root)->
    io:format("remove [~p] from [~p]~n",[Root,Path]),
    SP =  filename:split(Path),
    SR =  filename:split(Root),
    T=stuffPath(SP,SR),
    io:format("got ~p~n",[T]),
    T.
    

stuffPath([PH|PT],[RH,RT]) ->
     case (PH==RH) of
	true-> 
	    stuffPath(PT,RT);
	false->
	    filename:join(PT)
    end;
stuffPath([],_) ->
    [].
%add root
addRootPath(Path,Root)->
					       %Root ++ Path.
    RS=filename:split(Root),
    PS=filename:split(Path),
    A=filename:join(RS++PS),
    io:format("join [~p] from [~p] and [~p] ~n",[A,RS,PS]),
    A.
%filename:join([Path,Root]).
make_dir_rec(Path)->
    io:format("creating dir [~p]~n",[Path]),
    Ts = filename:split(Path),
    io:format("ts ~p",[Ts]),
    make_dir_rec1(Ts,"").
    %filelib:ensure_dir(Path).

make_dir_rec1([H|T],Path)->
    io:format("***[~p]~n",[Path]),
    NextPath = addRootPath(H,Path),
    case filelib:is_dir(NextPath) of
	true ->
	    io:format("directory exist");
	false ->
	    io:format("mkding dir"),
	    file:make_dir(NextPath)	    
    end,
    make_dir_rec1(T,NextPath);

make_dir_rec1([],_) ->[].


    

move(Path,RootSrc,RootDest)->
    Src = addRootPath(Path,RootSrc),
    Dest = addRootPath(Path,RootDest),
    make_dir_rec(filename:dirname(Dest)),
    io:format("moving [~p] to [~p]",[Src,Dest]),
    file:rename(Src,Dest).

save(Path,Root,Content)->
    Dest = addRootPath(Path,Root),
    io:format("dir : [~p]~n",[Dest]),
    make_dir_rec(filename:dirname(Dest)),
    io:format("dir created~n"),
    A =file:write_file(Dest,Content),
    io:format("file wrote with status [~p]~n",[A]),
    md5:md5_hex_file(Dest).

delete(Path,Root)->
    Dest = addRootPath(Path,Root),
    file:delete(Dest).
