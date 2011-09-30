-module(changeset).
-export([diff/2,display_CS/1,isIn/2]).
-import(fileset).
-import(misc).

%CS display
display_CS({A,C,R})->
     io:format("Added :~n" ),
     fileset:display_FS(A),	
     io:format("Changed :~n" ),
     fileset:display_FS(C),
     io:format("Deleted :~n" ),
     fileset:display_FS(R).

%return a change set
 diff(FS1,FS2)->
     Added = utilmisc:filterThree(fun(X,Y) ->not isIn(X,Y) end,FS1,FS2),
     Changed = utilmisc:filterThree(fun(X,Y) ->hasChangeIn(X,Y) end,FS1,FS2),
     Removed = utilmisc:filterThree(fun(X,Y) ->not isIn(X,Y) end,FS2,FS1),
     {Added,Changed,Removed}.

%check if element has the same car
isIn({P,M},[H|T])->
    {EH,_} = H,
    case P==EH of
	true -> true;
	false ->
	    isIn({P,M},T)
    end;

isIn({},_)->
    false;

isIn(_,[])->
    false.

%check if element has the same car and cdr
isSameIn({P,M},[H|T])->
    {EH,EM} = H,
    case (P==EH) and (M==EM) of
	true -> true;
	false ->
	    isSameIn({P,M},T)
    end;

isSameIn({},_)->
    false;

isSameIn(_,[])->
    false.
%check if element has changed car and cdr
hasChangeIn({P,M},[H|T])->
    {EH,EM} = H,
    case (P==EH) and (not (M==EM)) of
	true -> true;
	false ->
	    hasChangeIn({P,M},T)
    end;

hasChangeIn({},_)->
    false;

hasChangeIn(_,[])->
    false.
