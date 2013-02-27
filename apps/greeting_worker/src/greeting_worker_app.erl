-module(greeting_worker_app).

-behaviour(application).

%% ===================================================================
%% Application callbacks
%% ===================================================================
-export([start/0, start/2, stop/1]).

start() -> application:start(greeting_worker).

start(_StartType, _StartArgs) ->
    error_logger:info_msg("Starting dummy_app application...~n"),
    greeting_worker_sup:start_link().

stop(_State) ->
    ok.
