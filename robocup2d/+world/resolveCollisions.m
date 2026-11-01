function W = resolveCollisions(W, P)
%WORLD.RESOLVECOLLISIONS  Circle collisions and boundary limits. Owner: Stream C (Xu Lu).
%   Robot-robot: overlapping circles are pushed apart equally.
%   Robot-ball:  the ball is pushed out of the robot and picks up the robot's
%                speed along the contact normal (a simple "push"); the touch
%                is recorded in W.game.lastTouchTeam / lastTouchId.
%   Robots are kept inside the field plus border strip.
%   STAND-IN physics: Stream C refines, Stream B owns ball behaviour itself.
N = numel(W.robots);

% robot-robot
for i = 1:N-1
    for j = i+1:N
        dx = W.robots(j).x - W.robots(i).x;
        dy = W.robots(j).y - W.robots(i).y;
        d  = hypot(dx, dy);
        minD = W.robots(i).r + W.robots(j).r;
        if d < minD && d > 1e-9
            push = (minD - d) / 2;
            ux = dx / d; uy = dy / d;
            W.robots(i).x = W.robots(i).x - push * ux;  W.robots(i).y = W.robots(i).y - push * uy;
            W.robots(j).x = W.robots(j).x + push * ux;  W.robots(j).y = W.robots(j).y + push * uy;
        end
    end
end

% robot-ball
b = W.ball;
for i = 1:N
    R = W.robots(i);
    dx = b.x - R.x; dy = b.y - R.y; d = hypot(dx, dy);
    minD = R.r + P.ball.radius;
    if d < minD
        if d < 1e-9, dx = cos(R.th); dy = sin(R.th); d = 1; end
        ux = dx / d; uy = dy / d;
        b.x = R.x + minD * ux;  b.y = R.y + minD * uy;
        % robot velocity in global frame
        gvx = R.vx * cos(R.th) - R.vy * sin(R.th);
        gvy = R.vx * sin(R.th) + R.vy * cos(R.th);
        vRobN = gvx * ux + gvy * uy;              % robot speed along normal
        vBallN = b.vx * ux + b.vy * uy;
        if vBallN < vRobN
            b.vx = b.vx + (vRobN - vBallN) * ux;
            b.vy = b.vy + (vRobN - vBallN) * uy;
        end
        W.game.lastTouchTeam = R.team;
        W.game.lastTouchId   = R.id;
    end
end
W.ball = b;

% keep robots inside field + border
xl = P.field.length / 2 + P.field.borderWidth;
yl = P.field.width / 2 + P.field.borderWidth;
for i = 1:N
    W.robots(i).x = min(max(W.robots(i).x, -xl), xl);
    W.robots(i).y = min(max(W.robots(i).y, -yl), yl);
end
end
