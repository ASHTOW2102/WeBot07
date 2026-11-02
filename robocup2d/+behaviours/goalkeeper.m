function [cmd, mem] = goalkeeper(obs, mem, P)
%BEHAVIOURS.GOALKEEPER  Goalkeeper behaviour. Owner: Stream D (Ashish).
%   [cmd, mem] = behaviours.goalkeeper(obs, mem, P)   (same signature as all behaviours)
%
%   The DECISION (which mode to be in) is made by the Stateflow chart
%   goalkeeperChart.sfx in this folder:
%     GUARD  stay on the guard line, on the line between ball and goal centre
%     BLOCK  ball is shot at our goal: move to where it will cross the guard line
%     CLEAR  ball is within reach: kick it away from our goal
%   This file only (1) turns obs into chart inputs, (2) steps the chart and
%   (3) turns the chosen mode into a command. Settings live in P.team.keeper.
K = P.team.keeper;
GUARD = 1; BLOCK = 2; CLEAR = 3;   % must match the mode values in the chart

if isempty(mem)
    mem.chart = behaviours.goalkeeperChart();   % one chart per robot
    mem.chart.clearDist = P.robot.radius + P.ball.radius + K.clearReach;
    mem.chart.clearExit = K.clearExit;
end

goalX = -P.field.length / 2;
lineX = goalX + K.lineOffset;
yLim  = P.field.goalWidth / 2 - K.postMargin;
me    = [obs.self.x, obs.self.y];

% ---- ball not seen: hold the centre of the goal ----
if ~obs.ball.visible
    mem.chart.ballDist = inf; mem.chart.shotOnGoal = 0;
    step(mem.chart);
    cmd = motion.goToPoint(obs.self, [lineX 0 0], P);
    return
end

% ---- 1. chart inputs from obs ----
b  = [obs.ball.x,  obs.ball.y];
bv = [obs.ball.vx, obs.ball.vy];
[shot, crossY] = predictShot(b, bv, lineX, goalX, P, K);
mem.chart.ballDist   = norm(b - me);
mem.chart.shotOnGoal = double(shot);

% ---- 2. step the chart ----
step(mem.chart);

% ---- 3. mode -> command ----
faceBall = atan2(b(2) - me(2), b(1) - me(1));
switch mem.chart.mode
    case BLOCK
        spot = [lineX, clamp(crossY, yLim)];
        cmd = motion.goToPoint(obs.self, [spot faceBall], P);
    case CLEAR
        cmd = motion.goToPoint(obs.self, [b faceBall], P);
        awayDir = atan2(b(2), b(1) - goalX);           % from goal centre through the ball
        cmd.kick = true;
        cmd.kickSpeed = K.clearSpeed;
        cmd.kickDir = util.wrapToPi(awayDir - obs.self.th);
    otherwise   % GUARD
        % stand where the line from goal centre to the ball meets the guard line
        dx = max(b(1) - goalX, 1e-3);
        spot = [lineX, clamp(b(2) * K.lineOffset / dx, yLim)];
        cmd = motion.goToPoint(obs.self, [spot faceBall], P);
end
end

function [shot, crossY] = predictShot(b, bv, lineX, goalX, P, K)
% Is the ball rolling towards our goal mouth, and where will it cross the guard line?
shot = false; crossY = b(2);
if bv(1) > -K.shotMinSpeed || b(1) < lineX
    return
end
crossY = b(2) + bv(2) * (lineX - b(1)) / bv(1);   % straight-line prediction
goalY  = b(2) + bv(2) * (goalX - b(1)) / bv(1);
shot   = abs(goalY) < P.field.goalWidth / 2 + K.shotMargin;
end

function v = clamp(v, lim)
v = min(max(v, -lim), lim);
end
