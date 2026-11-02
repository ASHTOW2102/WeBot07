function cmd = goToPoint(self, target, P)
%MOTION.GOTOPOINT  Command that drives a robot towards a target pose. Owner: Stream A (Muqeem).
%   cmd = motion.goToPoint(self, target, P)
%   self    obs.self (team frame)
%   target  [x y] or [x y th] in the SAME frame as self (team frame).
%           Without th the robot faces the direction of travel.
%   Returns a command struct (body frame). Behaviours call this for every move.
%   STAND-IN proportional controller. Stream A replaces with proper speed /
%   heading controllers, path following and obstacle avoidance.
cmd = util.emptyCmd();
dx = target(1) - self.x;
dy = target(2) - self.y;
dist = hypot(dx, dy);

% error in body frame
c = cos(self.th); s = sin(self.th);
ex =  c * dx + s * dy;
ey = -s * dx + c * dy;

kp = 1.5;
cmd.vx = kp * ex;
cmd.vy = kp * ey;

if numel(target) >= 3 && dist < 0.3
    headingErr = util.wrapToPi(target(3) - self.th);   % final heading when close
else
    headingErr = util.wrapToPi(atan2(dy, dx) - self.th); % face travel direction
    if dist < 0.05, headingErr = 0; end
end
cmd.w = 2.0 * headingErr;

% walk forward mainly once roughly facing the target
if abs(headingErr) > pi/3 && dist >= 0.3
    cmd.vx = 0.2 * cmd.vx;
end
end
