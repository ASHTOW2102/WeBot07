function [cmd, mem] = striker(obs, mem, P)
%BEHAVIOURS.STRIKER  Striker behaviour. Owner: Stream B (Sharique).
%   [cmd, mem] = behaviours.striker(obs, mem, P)
%   Every behaviour has this exact signature:
%     obs  perception.observe output, TEAM frame (attack +x)
%     mem  this robot's private memory (state machine state etc.), [] at start
%     cmd  util.emptyCmd struct, robot BODY frame
%   STAND-IN: get behind the ball on the line to the opponent goal, then kick.
%   Stream B replaces this with the Stateflow striker (see INTERFACE.md).
if isempty(mem), mem.state = 'approach'; end

goal = [P.field.length / 2, 0];
b = [obs.ball.x, obs.ball.y];
toGoal = goal - b;
u = toGoal / max(norm(toGoal), 1e-9);
behind = b - (P.robot.radius + P.ball.radius + 0.05) * u;   % spot just behind the ball
faceGoal = atan2(u(2), u(1));

me = [obs.self.x, obs.self.y];
distBehind = norm(behind - me);
aligned = abs(util.wrapToPi(faceGoal - obs.self.th)) < 0.3;

switch mem.state
    case 'approach'
        cmd = motion.goToPoint(obs.self, [behind faceGoal], P);
        if distBehind < 0.12 && aligned
            mem.state = 'kick';
        end
    case 'kick'
        cmd = util.emptyCmd();
        cmd.kick = true;
        cmd.kickSpeed = 2.0;
        cmd.kickDir = 0;
        mem.state = 'approach';
    otherwise
        cmd = util.emptyCmd();
        mem.state = 'approach';
end
end
