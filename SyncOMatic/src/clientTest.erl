-module(clientTest).
-export([start/0]).
-import(crawl).
-import(md5).
-import(serialize). 
-import(lists,[map/2]).
-import(utilmisc).
-import(fileset).
-import(changeset).
	
start() ->
    PathRoot = "./AA",
    PathRoot2 = "./BB",
    io:format("Start processing  ~n"),
    FS=fileset:mkFS(PathRoot),
    FS2=fileset:mkFS(PathRoot2),
 %   io:format("Done~n"),
    serialize:store("/tmp/FS",FS),
						 %    display_FS(FS),
    CS=changeset:diff(FS,FS2),
    changeset:display_CS(CS).

 
