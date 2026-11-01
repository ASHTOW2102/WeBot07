function [cmd, mem] = defender(obs, mem, P)
%BEHAVIOURS.DEFENDER  Defender behaviour. Owner: Stream D (Ashish).
%   [cmd, mem] = behaviours.defender(obs, mem, P)   (same signature as all behaviours)
%   STAND-IN: stand on the line between own goal and ball, 1.8 m out from the
%   goal, facing the ball; clear the ball upfield if it comes close.
if isempty(mem), mem.state = 'guard'; end
ownGoal = [-P.field.length / 2, 0];
b = [obs.ball.x, obs.ball.y];
me = [obs.self.x, obs.self.y];
v = b - ownGoal;
u = v / max(norm(v), 1e-9);
spot = ownGoal + min(1.8, 0.8 * norm(v)) * u;
spot(1) = min(spot(1), -1.0);                  % stay in own half
faceBall = atan2(b(2) - me(2), b(1) - me(1));

if norm(b - me) < P.robot.radius + P.ball.radius + 0.15 && b(1) < 0
    mem.state = 'clear';
end
switch mem.state
    case 'clear'
        cmd = motion.goToPoint(obs.self, [b faceBall], P);
        cmd.kick = true; cmd.kickSpeed = 2.5; cmd.kickDir = 0;
        mem.state = 'guard';
    otherwise
        cmd = motion.goToPoint(obs.self, [spot faceBall], P);
end
end
