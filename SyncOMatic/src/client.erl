-module(client).
-export([start/0]).
-import(crawl).
-import(md5).
-import(serialize). 
-import(lists,[map/2]).
-import(utilmisc).
-import(fileset).
-import(changeset).
-import(confClient).
-import(clock).

start()->
    clock:start(confClient:getTimerValue(),fun()->sync(confClient:getClientRootPath()) end).


getprevFS(Dir)->
    case serialize:load(Dir) of
	{ok,FS}->
	    FS;
	{error,Why}->
	    io:format("error while reading prev FS maybe ok retuning empty set:~n~p~n",[Why]),
	    []
    end.

setNewFS(Dir,Data)->
    serialize:store(Dir,Data).


sync(DIR)->
   {ok,Socket}= gen_tcp:connect("localhost" , 2345,[binary, {packet, 4}]),    
    FS=fileset:mkFS(DIR),
    upSync(DIR,FS,Socket),
    NewFS = downSync(DIR,FS,Socket),
    setNewFS("/tmp/fs",NewFS),
    io:format("saving db~n"),
    gen_tcp:close(Socket).

upSync(DIR,FS,Socket)->
    PrevFS = getprevFS("/tmp/fs"),
    CS = changeset:diff(FS,PrevFS),
    changeset:display_CS(CS),
    {A,C,D} = CS,
    lists:map(fun(I)->
		      pushServer(I,Socket,DIR)
			  end, 
	      A
     ),
    lists:map(fun(I)->
		      pushServer(I,Socket,DIR)
	      end, 
	      C
     ),
    lists:map(fun(I)->
		      trashServer(I,Socket,DIR)
	      end, 
	      D
     ).
%    NewFS = updateFS(FS,AList,CList,DList),
 %   io:format("Up sync ended"),
  %  NewFS.

updateFS(FS,AL,CL,DL)->
    CleanFS = utilmisc:filterThree(fun(X,Y)->not changeset:isIn(X,Y)end,FS,AL++CL++DL),
    CleanFS++AL++CL.

downSync(DIR,FS,Socket)->
    io:format("down sync~n"),
    gen_tcp:send(Socket,term_to_binary({getFS})),
    io:format("waiting for server reply !~n"),
    receive
	{tcp,Socket,RemoteFS}->
	    RFS=binary_to_term(RemoteFS),
	    io:format("gotFS from server: [~p]~n",[RFS])
    end,
    CS = changeset:diff(RFS,FS),
    {A,C,D} = CS,
    io:format("diff from server ~n"),
    changeset:display_CS(CS),
    AList=lists:map(fun(I)->
		      getToLocal(I,Socket,DIR)
			  end, 
	      A
     ),
    CList=lists:map(fun(I)->
		      getToLocal(I,Socket,DIR)
	      end, 
	      C
     ),
    DList=lists:map(fun(I)->
		      trashLocal(I,DIR)
	      end, 
	      D
     ),
    io:format("down sync ended"),
    updateFS(FS,AList,CList,DList).



getToLocal({Path,MD},Socket,DIR)->
    gen_tcp:send(Socket,term_to_binary({get,Path})),
    receive
	{tcp,Socket,Bin}->
	    Cmd = binary_to_term(Bin),
	    {P,M} = process(Cmd,Path,DIR),
	    case M of
		MD ->
		    io:format("md5 ok, nothing todo ~n");
		_ ->
		    getToLocal({Path,MD},Socket,DIR)
	    end;
	{tcp_closed,Socket} ->
	    io:format("connexion ended ??!!")
    end.

process({ok,Bin},Path,DIR)->
    case fileutil:save(Path,DIR,Bin) of
	MD ->
	    {Path,MD}
    end.

trashLocal({P,M},DIR)->
    fileutil:delete(P,DIR),
    {P,M}.

pushServer(I,Socket,DIR)->
    {Path,Md} = I,
    R=fileutil:addRootPath(Path,DIR),
    io:format("pushing  [~p]~n",[R]),
    case file:read_file(R) of
	{ok, Content} ->
	    gen_tcp:send(Socket,term_to_binary({push,Path,Md,Content}));
	_ ->
	    io:format("??")
	end,
    receive
	{tcp,Socket,Bin} ->
	    case binary_to_term(Bin) of
		{badMd5} ->
		    io:format("bad md5 re-sending"),
		    pushServer(I,Socket,DIR);
		_->
		    io:format("recv :[~p]~n",[binary_to_term(Bin)])
		end
    end.
	

trashServer(I,Socket,DIR)->
    {Path,Md} = I,
    R=fileutil:addRootPath(Path,DIR),
    io:format("trashing = ~p~n",[R]),
    gen_tcp:send(Socket,term_to_binary({trash,Path,Md})),
    receive
	{tcp,Socket,Bin}->
	    io:format("[~p] deleted on server ~n",[binary_to_term(Bin)])
    end.

    %ok = gen_tcp:send(Socket,term_to_binary({put,Path,Md,Content})),
    %gen_tcp:close(Socket),                 
    %io:format("~p sent !",Path).    

