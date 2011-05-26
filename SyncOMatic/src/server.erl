-module(server).
-export([start/0]).
-import(crawl).
-import(md5).
-import(serialize). 
-import(lists,[map/2,flatten/1]).
-import(utilmisc).
-import(fileset).
-import(changeset).
-import(confServer).
-import(io_lib).

start()->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
					{reuseaddr, true},
					 {active, true}]),
    io:format("server ready...~n"),
    seq_loop(Listen,confServer:getServerRootPath(),confServer:getArchiveDir()).

seq_loop(Listen,RootDir,ArchiveDir)->
    {ok, Socket} = gen_tcp:accept(Listen),
    FS = fileset:mkFS(RootDir),
    TS = fileutil:addRootPath(mkTimeStamp(),ArchiveDir),
    io:format("updated file set~n"),
    fileset:display_FS(FS),
    loop(Socket,FS,RootDir,TS),
    seq_loop(Listen,RootDir,ArchiveDir).

%not close here	gen_tcp:close(Listen),
loop(Socket,FS,RootDir,TS) ->
    receive
	{tcp, Socket, Bin} ->
	    Cmd = binary_to_term(Bin),
	    {RetValue,FSnew} = process(Cmd,FS,RootDir,TS),
	    %io:format("Server replying  [~p]~n" ,[RetValue]),
	    gen_tcp:send(Socket, term_to_binary(RetValue)),
	    loop(Socket,FSnew,RootDir,TS);
	{tcp_closed, Socket} ->
	    io:format("Server socket closed~n" )
	end.
prepare(Path,MD,FS,RootDir,TS)->
    {In,FS2}= cleanFS({Path,MD},FS),
    io:format("new FS~n"),
    fileset:display_FS(FS2),
    io:format("~p**~n",[In]),
    case In of
	true -> 
	    io:format("need to move stuff"),
	    moveToArchive(Path,RootDir,TS);
	_  -> 
	    io:format("Nothing to move")
    end,
    {In,FS2}.

%shou-could be optimize for tail recursion
% cleaner

%process(Cmd,FS,RootDir,TS) ->
%    case Cmd of 
%	{push,Path,MD,Bin} ->
%	    processPush(Path,MD,Bin,FS,RootDir,TS);
%	{trash,Path,MD} ->
%	    processTrash(Path,MD,FS,RootDir,TS);
%	_ ->
%	    io:format("unknow command can't process !!!")
 %   end;
%process(_,FS,_,_) ->
 %   FS;

process({getFS},FS,_,_)->
    io:format("got FS~n"),
    {FS,FS};

process({get,Path},FS,RootDir,TS)->
    R = fileutil:addRootPath(Path,RootDir),
    D =  file:read_file(R),
    {D,FS};

process({push,Path,MD,Bin},FS,RootDir,TS) ->
    {_,FS2} = prepare(Path,MD,FS,RootDir,TS),
    case doSaveFile(Path,RootDir,Bin) of
	MD ->
	    {ok,[ {Path,MD}|FS2]};
	_ ->
	    doCleanUp(Path,RootDir),
	    {badMd5,FS2}
    end;

process({trash,Path,MD},FS,RootDir,TS) ->
    case prepare(Path,MD,FS,RootDir,TS) of
	{true,FS2} ->
	    {ok,FS2};
	{false,FS2} ->
	    io:format("file [~p] cant be move continue happily annyway",[Path]),
	    {ok,FS2}
    end.
    
    

%	   
% if fileisin move it to timestamp/path
cleanFS(E,FS)->
   case changeset:isIn(E,FS) of
       true ->
	   {true,utilmisc:filterThree(fun(X,Y) ->not changeset:isIn(X,Y) end,FS,[E])};
       false ->
	   {false,FS}
   end. 

moveToArchive(Path,Root,ArchiveTimeStamp)->
    %io:format("~p~n",[{Path,Root,ArchiveTimeStamp}]),
    fileutil:move(Path,Root,ArchiveTimeStamp).
    
doSaveFile(Path,Root,Content)->
    fileutil:save(Path,Root,Content).

mkTimeStamp()->
    {A,B,C}=now(),
    lists:flatten(io_lib:format("~p.~p.~p",[A,B,C])).
    
doCleanUp(Path,Root)->
    io:format("bad MD5 rolling back [~p] ~n",[Path]),
    fileutil:delete(Path,Root).
