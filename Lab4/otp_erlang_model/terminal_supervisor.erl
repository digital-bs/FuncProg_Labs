-module(terminal_supervisor).
-author("Semen").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%% @doc Starts the supervisor
-spec(start_link() -> {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%% @private
%% @doc Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]}}
  | ignore | {error, Reason :: term()}).
init([]) ->
  MaxRestarts = 1000,
  MaxSecondsBetweenRestarts = 3600,
  SupFlags = #{strategy => one_for_one,
    intensity => MaxRestarts,
    period => MaxSecondsBetweenRestarts},

  AChild = #{id => terminal_server,
    start => {terminal_server, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [terminal_server]},

  BChild = #{id => terminal_event,
    start => {terminal_event, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [terminal_event]},

  {ok, {SupFlags, [AChild,BChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
