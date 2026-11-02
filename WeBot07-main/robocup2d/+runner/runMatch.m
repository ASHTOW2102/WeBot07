function result = runMatch(P, opts)
%RUNNER.RUNMATCH  Play one match. Owner: Stream C (Xu Lu). THE MAIN LOOP.
%   result = runner.runMatch(P)            defaults, headless
%   result = runner.runMatch(P, opts)
%     opts.seed      random seed (default P.seed)
%     opts.viz       true to draw the match (default false)
%     opts.vizEvery  draw every N steps (default 4)
%     opts.maxTime   stop after this many simulated seconds (default inf)
%   result.score, result.summary (metrics.summary), result.events, result.seed
%
%   Order of one step (agreed interface, do not reorder without the team):
%     1. roles      strategy.assignRoles        every P.roleUpdateEvery steps
%     2. decide     perception.observe -> behaviours.<role>   for every robot
%     3. move       motion.update               for every robot
%     4. kick       ballmodel.applyKick         first valid kick wins
%     5. roll       ballmodel.update
%     6. collide    world.resolveCollisions
%     7. clock      W.t, W.step advance
%     8. rules      referee.update
%     9. measure    metrics.update   (+ viz.draw if opts.viz)
if nargin < 2, opts = struct(); end
if ~isfield(opts, 'seed'),     opts.seed = P.seed; end
if ~isfield(opts, 'viz'),      opts.viz = false; end
if ~isfield(opts, 'vizEvery'), opts.vizEvery = 4; end
if ~isfield(opts, 'maxTime'),  opts.maxTime = inf; end

rng(opts.seed);
W = world.init(P, 1);
S = metrics.init(P);
N = numel(W.robots);
mem  = cell(1, N);
cmds = repmat(util.emptyCmd(), 1, N);
dt = P.dt;

while ~strcmp(W.game.state, 'FINISHED') && W.t < opts.maxTime
    % 1. roles
    if mod(W.step, P.roleUpdateEvery) == 0
        for team = 1:2
            roles = strategy.assignRoles(W, team, P);
            for i = 1:N
                if W.robots(i).team == team
                    newRole = roles{W.robots(i).number};
                    if ~strcmp(newRole, W.robots(i).role)
                        W.robots(i).role = newRole;
                        mem{i} = [];             % fresh memory on role change
                    end
                end
            end
        end
    end

    % 2. decide
    for i = 1:N
        obs = perception.observe(W, i, P);
        [cmds(i), mem{i}] = runner.callBehaviour(W.robots(i).role, obs, mem{i}, P);
    end

    % 3. move
    for i = 1:N
        W.robots(i) = motion.update(W.robots(i), cmds(i), P, dt);
    end

    % 4. kick
    kickedIds = [];
    for i = randperm(N)                       % random order: no team gets priority
        [W.ball, k] = ballmodel.applyKick(W.ball, W.robots(i), cmds(i), P);
        if k
            kickedIds = W.robots(i).id;
            W.game.lastTouchTeam = W.robots(i).team;
            W.game.lastTouchId   = W.robots(i).id;
            W = util.logEvent(W, 'kick', W.robots(i).team, W.robots(i).id);
            break
        end
    end

    % 5. roll, 6. collide
    W.ball = ballmodel.update(W.ball, P, dt);
    W = world.resolveCollisions(W, P);

    % 7. clock, 8. rules
    W.t = W.t + dt;
    W.step = W.step + 1;
    W = referee.update(W, P, dt);

    % 9. measure
    S = metrics.update(S, W, P, kickedIds);
    if opts.viz && mod(W.step, opts.vizEvery) == 0
        viz.draw(W, P);
        drawnow;
    end
end

result.score   = W.game.score;
result.summary = metrics.summary(S, W, P);
result.events  = W.game.events;
result.seed    = opts.seed;
end
