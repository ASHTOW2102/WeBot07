function ball = update(ball, P, dt)
%BALLMODEL.UPDATE  Roll the ball for one timestep. Owner: Stream B (Sharique).
%   ball = ballmodel.update(ball, P, dt)
%   Constant rolling deceleration until the ball stops. Global frame.
%   STAND-IN. Stream B validates P.ball.rollDecel and may refine the model.
%   ball.z / ball.vz are reserved for the 3D-ball stretch goal (keep at 0).
v = hypot(ball.vx, ball.vy);
if v > 0
    vNew = max(v - P.ball.rollDecel * dt, 0);
    k = vNew / v;
    ball.vx = ball.vx * k;
    ball.vy = ball.vy * k;
end
ball.x = ball.x + ball.vx * dt;
ball.y = ball.y + ball.vy * dt;
end
