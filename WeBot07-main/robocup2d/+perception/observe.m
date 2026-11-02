function obs = observe(W, i, P)
%PERCEPTION.OBSERVE  What robot i knows, in ITS TEAM's frame. Interface type.
%   obs = perception.observe(W, i, P)
%   Owner: Stream C for the stand-in (perfect information).
%   Later: Stream B can add ball-detection noise / field of view here without
%   changing any behaviour code, because behaviours only ever see obs.
%
%   Team frame: own goal at x = -length/2, attacking +x (see util.toTeamFrame).
%   obs.self   id, number, role, x, y, th, vx, vy, w   (vx, vy, w = body frame)
%   obs.ball   x, y, vx, vy, visible
%   obs.mates  struct array of team-mates: id, number, role, x, y, th, fallen
%   obs.opps   struct array of opponents:  id, number, x, y, th, fallen
%   obs.game   state, score [own opp], timeLeft, ownKickoff, t
R = W.robots(i);
ad = P.team.attackDir(R.team);

[x, y, th] = util.toTeamFrame(R.x, R.y, R.th, [], [], ad);
obs.self = struct('id', R.id, 'number', R.number, 'role', R.role, ...
                  'x', x, 'y', y, 'th', th, 'vx', R.vx, 'vy', R.vy, 'w', R.w);

[bx, by, ~, bvx, bvy] = util.toTeamFrame(W.ball.x, W.ball.y, [], W.ball.vx, W.ball.vy, ad);
obs.ball = struct('x', bx, 'y', by, 'vx', bvx, 'vy', bvy, 'visible', true);

mates = struct('id', {}, 'number', {}, 'role', {}, 'x', {}, 'y', {}, 'th', {}, 'fallen', {});
opps  = struct('id', {}, 'number', {}, 'x', {}, 'y', {}, 'th', {}, 'fallen', {});
for k = 1:numel(W.robots)
    if k == i, continue; end
    O = W.robots(k);
    [ox, oy, oth] = util.toTeamFrame(O.x, O.y, O.th, [], [], ad);
    if O.team == R.team
        mates(end+1) = struct('id', O.id, 'number', O.number, 'role', O.role, ...
                              'x', ox, 'y', oy, 'th', oth, 'fallen', O.fallen); %#ok<AGROW>
    else
        opps(end+1) = struct('id', O.id, 'number', O.number, ...
                             'x', ox, 'y', oy, 'th', oth, 'fallen', O.fallen); %#ok<AGROW>
    end
end
obs.mates = mates;
obs.opps  = opps;

other = 3 - R.team;
obs.game = struct('state', W.game.state, 'score', [W.game.score(R.team) W.game.score(other)], ...
                  'timeLeft', P.halfDuration - W.game.timeInHalf, ...
                  'ownKickoff', W.game.kickoffTeam == R.team, 't', W.t);
end
