function [cmd, mem] = goalkeeper(obs, mem, P)
%BEHAVIOURS.GOALKEEPER  Goalkeeper behaviour. Owner: Stream D (Ashish).
%   [cmd, mem] = behaviours.goalkeeper(obs, mem, P)   (same signature as all behaviours)
%   STAND-IN: track the ball's y on a line just in front of the goal, face the
%   ball, and kick it away if it gets close.
if isempty(mem), mem.state = 'track'; end
lineX = -P.field.length / 2 + 0.3;
yLim  = P.field.goalWidth / 2 - 0.2;
b = [obs.ball.x, obs.ball.y];
me = [obs.self.x, obs.self.y];
faceBall = atan2(b(2) - me(2), b(1) - me(1));
spot = [lineX, min(max(b(2), -yLim), yLim)];
cmd = motion.goToPoint(obs.self, [spot faceBall], P);
if norm(b - me) < P.robot.radius + P.ball.radius + 0.1
    cmd.kick = true; cmd.kickSpeed = 2.5; cmd.kickDir = 0;
end
end
