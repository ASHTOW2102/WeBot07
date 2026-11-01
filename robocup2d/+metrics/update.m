function S = update(S, W, P, kickedIds)
%METRICS.UPDATE  Accumulate statistics after each step. Owner: Stream C (Xu Lu).
%   S = metrics.update(S, W, P, kickedIds)
%   kickedIds: ids of robots whose kick took effect this step ([] if none).
%   Add new metrics here; runner.runMatch does not need to change.

% possession: nearest robot within 0.5 m of the ball
best = inf; bestTeam = 0;
for i = 1:numel(W.robots)
    d = hypot(W.robots(i).x - W.ball.x, W.robots(i).y - W.ball.y);
    if d < best, best = d; bestTeam = W.robots(i).team; end
end
if best < 0.5
    S.possessionTime(bestTeam) = S.possessionTime(bestTeam) + P.dt;
end

% kicks and shots on target (straight-line path, ignores friction and blockers)
for id = kickedIds
    t = W.robots(id).team;
    S.kicks(t) = S.kicks(t) + 1;
    side = P.team.attackDir(t);              % opponent goal line at x = side * length/2
    gx = side * P.field.length / 2;
    if W.ball.vx * side > 0
        tHit = (gx - W.ball.x) / W.ball.vx;
        yHit = W.ball.y + W.ball.vy * tHit;
        if abs(yHit) < P.field.goalWidth / 2
            S.shotsOnTarget(t) = S.shotsOnTarget(t) + 1;
        end
    end
end

% outs from new events
ev = W.game.events;
for k = S.lastEventCount + 1 : numel(ev)
    if strncmp(ev(k).type, 'out', 3), S.outs = S.outs + 1; end
end
S.lastEventCount = numel(ev);
end
