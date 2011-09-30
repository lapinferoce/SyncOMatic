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
% old slow ways
%diff(FS1,FS2)->
%     Added = utilmisc:filterThree(fun(X,Y) ->not isIn(X,Y) end,FS1,FS2),
%     Changed = utilmisc:filterThree(fun(X,Y) ->hasChangeIn(X,Y) end,FS1,FS2),
%     Removed = utilmisc:filterThree(fun(X,Y) ->not isIn(X,Y) end,FS2,FS1),
%     {Added,Changed,Removed}.


%return a change set
% using the new way avoiding lookup again and again
 diff(FS1,FS2)->
     sorted_FS1 = sort(fun({PA,HA}, {PB,HB}) -> PA >= PB end,FS1),
     sorted_FS2 = sort(fun({PA,HA}, {PB,HB}) -> PA >= PB end,FS2),
     P = dodiff(FS1,FS2)
 %    Added = utilmisc:filterThree(fun(X,Y) ->not isIn(X,Y) end,FS1,FS2),
 %    Changed = utilmisc:filterThree(fun(X,Y) ->hasChangeIn(X,Y) end,FS1,FS2),
 %    Removed = utilmisc:filterThree(fun(X,Y) ->not isIn(X,Y) end,FS2,FS1),
     {Added,Changed,Removed}.

dofiff(FS1,FS2)->
	dodiff(FS1,FS2,[],[],[]).
	
dodiff(FS1,FS2,Added,Changed,Removed)->
	[EFS1|TFS1] = FS1,
	[EFS2|TFS2] = FS2,
	{PEFS1,HEFS1} = EFS1,
	{PEFS2,HEFS2} = EFS2,
	case {PEFS1,PEFS2} of
		PEFS1 < PEFS2 -> 
			dodiff(TFS1,FS2,Added++EFS1,Changed,Removed);
		PEFS1 > PEFS2 ->
			dodiff(FS1,TFS2,Added,Changed,Removed++ESF2);
		PEFS1 == PEFS2 ->
			case {HEFS1==HEFS2} ->
				dodiff(TFS1,TFS2,Added,Changed,Removed);
			_ -> 
				dodiff(TFS1,TFS2,Added,Changed++EFS1,Removed)
			end
	end;
				
	
dodiff([],[HFS2|TFS2],Added,Changed,Removed)->
	dodiff([],TFS2,Added,Changed,Removed++HFS2);

dodiff([HFS1|TFS1],[],Added,Changed,Removed)->
	dodiff(TFS1,[],Added++HFS1,Changed,Removed);

dodiff([],[],Added,Changed,Removed)->
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
