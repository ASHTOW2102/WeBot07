function W = init(P, kickoffTeam)
%WORLD.INIT  Build the world struct W at kick-off. Owner: Stream C (Xu Lu).
%   W = world.init(P)               Blue kicks off
%   W = world.init(P, kickoffTeam)  kickoffTeam = 1 (Blue) or 2 (Red)
%
%   W is the single source of truth for the simulator (global frame):
%     W.t, W.step                      time (s) and step counter
%     W.robots(1:2*teamSize)           struct array, see INTERFACE.md
%     W.ball                           x, y, vx, vy (+ z, vz reserved for 3D)
%     W.game                           state, half, score, kickoff, last touch, events
if nargin < 2, kickoffTeam = 1; end

W.t = 0;
W.step = 0;

n = 0;
for team = 1:2
    for num = 1:P.teamSize
        n = n + 1;
        R.id        = n;
        R.team      = team;
        R.number    = num;
        R.role      = P.team.defaultRoles{num};
        R.x = 0; R.y = 0; R.th = 0;     % pose, global frame (m, m, rad)
        R.vx = 0; R.vy = 0; R.w = 0;    % current velocity, BODY frame (m/s, m/s, rad/s)
        R.fallen    = false;
        R.penalised = false;
        R.r         = P.robot.radius;
        W.robots(n) = R;
    end
end

W.ball = struct('x', 0, 'y', 0, 'vx', 0, 'vy', 0, 'z', 0, 'vz', 0);

W.game.state         = 'PLAYING';   % INITIAL | READY | SET | PLAYING | FINISHED
W.game.half          = 1;
W.game.timeInHalf    = 0;
W.game.score         = [0 0];       % [Blue Red]
W.game.kickoffTeam   = kickoffTeam;
W.game.firstKickoffTeam = kickoffTeam;
W.game.lastTouchTeam = 0;           % 0 = nobody yet
W.game.lastTouchId   = 0;
W.game.events        = struct('t', {}, 'type', {}, 'team', {}, 'id', {});

W = world.resetKickoff(W, P, kickoffTeam);
end
