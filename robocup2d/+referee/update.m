function W = update(W, P, dt)
%REFEREE.UPDATE  Apply the rules after each physics step. Owner: Stream C (Xu Lu).
%   W = referee.update(W, P, dt)
%   - Goal: the whole ball crosses a goal line between the posts.
%     Blue scores at x = +length/2, Red at x = -length/2. Conceding team kicks off.
%   - Out over a side line or goal line (not a goal): event logged, ball placed
%     back inside and stopped.  STAND-IN restart (no throw-in/corner rules yet).
%   - Clock: halves of P.halfDuration; second half kicked off by the other team.
%   Stream C extends this with restarts, fouls, fallen/penalised robots and
%   the READY/SET states, keeping the signature.
if strcmp(W.game.state, 'FINISHED'), return; end
F = P.field; b = W.ball; r = P.ball.radius;
hx = F.length / 2; hy = F.width / 2;

if abs(b.x) > hx + r
    side = sign(b.x);                       % +1 = right goal line, -1 = left
    if abs(b.y) < F.goalWidth / 2
        scorer = find(P.team.attackDir == side, 1);
        W.game.score(scorer) = W.game.score(scorer) + 1;
        W = util.logEvent(W, 'goal', scorer, W.game.lastTouchId);
        W = world.resetKickoff(W, P, 3 - scorer);
    else
        W = util.logEvent(W, 'out_goalline', W.game.lastTouchTeam, W.game.lastTouchId);
        W.ball.x = side * (hx - 1.0);
        W.ball.y = min(max(b.y, -hy + 0.5), hy - 0.5);
        W.ball.vx = 0; W.ball.vy = 0;
    end
elseif abs(b.y) > hy + r
    W = util.logEvent(W, 'out_side', W.game.lastTouchTeam, W.game.lastTouchId);
    W.ball.y = sign(b.y) * (hy - 0.3);
    W.ball.x = min(max(b.x, -hx + 0.3), hx - 0.3);
    W.ball.vx = 0; W.ball.vy = 0;
end

W.game.timeInHalf = W.game.timeInHalf + dt;
if W.game.timeInHalf >= P.halfDuration
    if W.game.half < P.numHalves
        W = util.logEvent(W, 'half_time', 0, 0);
        W.game.half = W.game.half + 1;
        W.game.timeInHalf = 0;
        W = world.resetKickoff(W, P, 3 - W.game.firstKickoffTeam);
    else
        W = util.logEvent(W, 'full_time', 0, 0);
        W.game.state = 'FINISHED';
    end
end
end
