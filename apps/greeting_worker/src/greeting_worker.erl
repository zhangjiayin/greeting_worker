-module(greeting_worker).
-include_lib("amqp_client/include/amqp_client.hrl").

-export([start_link/0,init/0]).
%% API
start_link() ->
    {ok,spawn_link( ?MODULE, init , [] )}.

init() ->
    erlydb:start(mysql, [{hostname, "localhost"}, {username, "root"}, {password, "123456"}, {database, "t1"}, {logfun, fun (_Module, _Line, _Level, _FormatFun) -> ok end} ]),
    mysql:fetch(erlydb_mysql,<<"set names utf8;">>),
    {ok, Connection} = amqp_connection:start(#amqp_params_network{host = "localhost"}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),
    error_logger:info_msg(" [*] Waiting for messages.~n"),

    amqp_channel:subscribe(Channel, #'basic.consume'{queue = <<"hello">>,
            no_ack = true}, self()),
    receive
        #'basic.consume_ok'{} -> ok
    end,
    error_logger:info_msg(" [*] start looping.~n"),
    loop(Channel).


loop(Channel) ->
    receive
        {#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
            {[user, User],[blog,Blog],[createdAt, CreatedAt]} = binary_to_term(Body),
            %%           CreatedAt = calendar:datetime_to_gregorian_seconds(calendar:now_to_universal_time( now()))-719528*24*3600,
            mysql:prepare(update_developer_country, <<"INSERT INTO `t1`.`t1` (`id`, `uid`, `data`, `created_at`, `updated_at`) VALUES (NULL, ?, ?, ?, ?)">>),
            mysql:execute(erlydb_mysql, update_developer_country, [User,Blog, CreatedAt, CreatedAt]),
            mysql:fetch(erlydb_mysql,<<"select * from t1">>),
            loop(Channel)
            %%  after  1000 ->
            %%         error_logger:info_msg(" [*] looping.~n"),
            %%          loop(Channel)
    end.

