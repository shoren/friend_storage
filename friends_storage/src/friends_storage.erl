




%% @author Lee Barney

%% @copyright 2022 Lee Barney licensed under the <a>

%%        rel="license"

%%        href="http://creativecommons.org/licenses/by/4.0/"

%%        target="_blank">

%%        Creative Commons Attribution 4.0 International License</a>

-module(friends_storage).

%% gen_server

-behaviour(gen_server).

-export([start_link/0]).

%% export gen_server callbacks

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,

     terminate/2, code_change/3]).

%% export client functions

-export([start/0,start/2,stop/1,add/2,list/1,remove/2, remove_all/1]).

 

-define(SERVER,?MODULE).

 

%%%--------

%%% client functions

%%%--------

 

%%These can be used as a template.

 



%%% @doc 

%%% The <kbd>start/0</kbd> function spawns the friends gen_server. The assumption is there will only ever be one friends gen_server in the app.

%%% Parameters: Registration_scope - the atoms _local_ or _global_ are the two valid values

%%%

%%% Value: a 2-tuple consisting of _ok_ followed by the process ID of the running friends gen_server

%%%

-spec start()->ok| ignore | {error, Reason :: term()}.

start() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%% @doc 

%%% The <kbd>start/2</kbd> function spawns the friends gen_server. 

%%% Parameters: Registration_scope - the atoms _local_ or _global_ are the two valid values

%%%

%%% Value: a 2-tuple consisting of _ok_ followed by the process ID of the running friends gen_server

%%%

-spec start(atom(),atom()) ->ok| ignore | {error, Reason :: term()}.

start(Registration_scope,Name_to_register) -> 

  gen_server:start_link({Registration_scope, Name_to_register}, ?MODULE, [], []).

 

%% @doc The <kbd>stop/0</kbd> function causes a graceful stop of the gen_server.

stop(Registered_name)  -> 

  gen_server:call(Registered_name, stop).

 



%%@doc The <kbd>add/1</kbd> function has as its value the sum of all elements of the parameter of type list. The list can be empty.

add(Registered_name,Friend) -> 

  gen_server:call(Registered_name,{add,Friend}).

%%@doc The <kbd>list/1</kbd> function has as its value the entire list of friends. The list can be empty.

list(Registered_name) -> 

  gen_server:call(Registered_name,list).

%%@doc The <kbd>divide/2</kbd> function returns the quotient of the dividend, the first parameter, and the divisor, the second parameter.

remove(Registered_name,Friend) -> 

  gen_server:call(Registered_name,{remove,Friend}).

remove_all(Registered_name) -> 

  gen_server:call(Registered_name,clear).

 



%%%--------

%%% gen_server callbacks

%%% these functions match the interface the <kbd>gen_server</kbd> needs in order to provide the services desired.

%%%--------

%% These can also be used as a template.

 

%% getting things going

start_link() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) -> {ok,[]}.%% setting the state to up

 

%%doc the <kbd>handle_call/3</kbd> function deals with the requests made to <kbd>gen_server</kbd>. The available request types are:

%% <ol>

%%   <li>adding a friend, _O(1)_,</li>

%%   <li>removing a friend, _O(n)_,</li>

%%   <li>retrieving the list of friends, _O(1)_, and</li>

%%   <li>removing all friends _O(1)_</li>

%%     <li>stop, to elegantly stop the <kbd>gen_server</kbd> process _O(1)_.

%% </ol>

%% 

%To stop the server the parameters are:

%% <ol>

%%   <li>stop, an atom,</li>

%%   <li>From, the PID of the <kbd>gen_server</kbd> process, and</li>

%%   <li>State, the current state of the <kbd>gen_server</kbd>.</li>

%% </ol>

 



% handle_cast

handle_cast({add, Friend},Friends) ->

  {noreply, [Friend] ++ Friends};

 

handle_cast({remove, Friend}, Friends) ->

  {noreply, lists:delete(Friend,Friends)};

 

handle_cast(clear, _Friends) ->

  {noreply, []}.

 

%%These are specific to your need.

handle_call(list,_From,Friends) -> 

          {reply,

                {ok,Friends},

           Friends};%% not modifying the server's internal state

 

handle_call(stop, _From, _Friends) -> 

           {stop,normal,

                server_stopped,

          down}. %% setting the server's internal state to down

 

%%%--------

%%% gen_server callbacks

%%% the default behavior here is sufficient for this example.

%%%--------

% handle_cast(_Msg, State) -> {noreply, State}.

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> io:format("code changing",[]),{ok, State}.

 



-ifdef(EUNIT).

  -include_lib("eunit/include/eunit.hrl").

 

handle_cast_test_() ->

  [?_assertEqual({noreply,[sue,joe,sally]},friends_storage:handle_cast({{add,sue},somewhere,[joe,sally]})), %happy path

    ?_assertEqual({noreply,[sue]},friends_storage:handle_cast({{add,sue},somewhere,[]})), %nasty path

    ?_assertEqual({noreply,[sue]},friends_storage:handle_cast({{add,sue},somewhere,nil})), %nasty path

    ?_assertEqual({noreply,[sue,joe]},friends_storage:handle_cast({{remove,sally},somewhere,[sue,joe,sally]})), %happy path

    ?_assertEqual({noreply,[]},friends_storage:handle_cast({{remove,sally},somewhere,[]})), %happy path

  ]

 

handle_call_test_()->

  [?_assertEqual({reply,

                {ok,[joe,sally,grace]},

           [joe,sally,grace]},friends_storage:handle_call(list,somewhere,[joe,sally,grace])),%happy path

   ?_assertEqual({reply,

                ok,

           [joe,grace]},friends_storage:handle_call({remove,sally},somewhere,[joe,sally,grace])),%happy path

   ]

 

%component_level_test_()->{

%  setup,

%  fun()->gen_server:start_link({local, ?SERVER}, ?MODULE, [], []) end,

%  fun()->gen_server:call(?SERVER, stop) end,

%  [?_assertEqual(true,true)]}.


  -endif.


