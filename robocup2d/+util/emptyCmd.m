function cmd = emptyCmd()
%UTIL.EMPTYCMD  The robot command struct, all zero. Interface type.
%   Body frame of the robot: vx forward, vy to the robot's left, w
%   anticlockwise. Behaviours return this; motion.update executes it.
cmd.vx        = 0;      % m/s   desired forward speed
cmd.vy        = 0;      % m/s   desired side speed (+ = left)
cmd.w         = 0;      % rad/s desired turn rate (+ = anticlockwise)
cmd.kick      = false;  % request a kick this step
cmd.kickSpeed = 0;      % m/s   requested ball speed
cmd.kickDir   = 0;      % rad   kick direction relative to robot heading
end
