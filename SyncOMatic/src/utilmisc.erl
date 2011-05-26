-module(utilmisc).
-export([pmap/2,filterThree/3]).
-import(lists,[map/2]).



% self ! id du processus courrant
pmap(F, L) ->
    S = self(),
    Pids = lists:map(fun(I) ->
			     spawn(fun() -> do_f(S, F, I) end)
                     end, L),
    gather(Pids).

gather([H|T]) ->
    receive
        {H, Ret} -> [Ret|gather(T)]
    end;
gather([]) ->
    [].

do_f(Parent, F, I) ->
    Parent ! {self(), (catch F(I))}.



%special filter
%using accumlulator for better tail recursion
 filterThree(P, U,A) -> filterThree(P, U,A,[]).
 filterThree(P, [H|T],A,R)->
     case P(H,A) of
	 true -> filterThree(P, T,A,[H|R]);
	 false ->filterThree(P, T,A,R);
	 _ -> io:format("error, unexepect predicate return  ~n")
     end;

 filterThree(_, [],_,R) ->	

     R.
