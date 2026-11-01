function [ball, kicked] = applyKick(ball, R, cmd, P)
%BALLMODEL.APPLYKICK  Execute a kick request if the ball is in reach. Owner: Stream B (Sharique).
%   [ball, kicked] = ballmodel.applyKick(ball, R, cmd, P)
%   R    robot struct (global frame); cmd its command this step.
%   A kick happens only if cmd.kick is true, the gap between robot edge and
%   ball edge is <= P.ball.kickRange, and the ball is within +-P.ball.kickAngle
%   of the robot's heading. The ball then gets speed cmd.kickSpeed (capped)
%   in direction R.th + cmd.kickDir, with Gaussian noise on speed and angle.
%   STAND-IN kick model. Stream B tunes it against NAO6 kick data.
kicked = false;
if ~cmd.kick || R.fallen || R.penalised
    return
end
dx = ball.x - R.x; dy = ball.y - R.y;
gap = hypot(dx, dy) - R.r - P.ball.radius;
bearing = util.wrapToPi(atan2(dy, dx) - R.th);
if gap > P.ball.kickRange || abs(bearing) > P.ball.kickAngle
    return
end
spd = min(max(cmd.kickSpeed, 0), P.ball.kickSpeedMax);
spd = spd * (1 + P.ball.kickNoiseSpeed * randn());
dir = R.th + cmd.kickDir + P.ball.kickNoiseDir * randn();
ball.vx = spd * cos(dir);
ball.vy = spd * sin(dir);
kicked = true;
end
