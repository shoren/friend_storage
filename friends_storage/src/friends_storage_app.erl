%%%-------------------------------------------------------------------
%% @doc friends_storage public API
%% @end
%%%-------------------------------------------------------------------

-module(friends_storage_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    friends_storage_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
