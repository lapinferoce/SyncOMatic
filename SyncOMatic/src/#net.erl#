-module(net).
-export([start_pico/0,client_send/1]).

%
% sequential release
%
start_pico() ->
	{ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
					{reuseaddr, true},
					{active, true}]),
	seq_loop(Listen).

seq_loop(Listen)->
	{ok, Socket} = gen_tcp:accept(Listen),
	loop(Socket),
	seq_loop(Listen).

%not close here	gen_tcp:close(Listen),
loop(Socket) ->
	receive
	{tcp, Socket, Bin} ->
		io:format("Server received binary = ~p~n" ,[Bin]),
		Str = binary_to_term(Bin),
		io:format("Server (unpacked) ~p~n" ,[Str]),
		loop(Socket);
		%Reply = Str,
		%io:format("Server replying = ~p~n" ,[Reply]),
		%gen_tcp:send(Socket, term_to_binary(Reply));
	{tcp_closed, Socket} ->
		io:format("Server socket closed~n" )
end.

client_send(Filepath)->
	{ok, S} = file:read_file(Filepath),
	client_send_file("AAA",S).
	
	

client_send_file(Filename,Content)->
    {ok,Socket}= gen_tcp:connect("localhost" , 2345,
				     [binary, {packet, 4}]),
    ok = gen_tcp:send(Socket,term_to_binary({Filename,Content})),
    gen_tcp:close(Socket),                 
    io:format("sent !").
    %receive
%	{tcp,Socket,Bin} ->
%	    io:format("Client received binary = ~p~n" ,[Bin]),
%	    Val = binary_to_term(Bin),
%	    io:format("Client result = ~p~n" ,[Val]),
%	    gen_tcp:close(Socket)
 %   end.

