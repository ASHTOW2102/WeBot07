function R = update(R, cmd, P, dt)
%MOTION.UPDATE  Move one robot for one timestep. Owner: Stream A (Muqeem).
%   R = motion.update(R, cmd, P, dt)
%   R    robot struct from W.robots (global pose, body-frame velocity)
%   cmd  command struct (util.emptyCmd), body frame
%   Steps: clamp the command to the robot's speed limits, move the current
%   velocity towards it with a first-order lag and acceleration limits, then
%   integrate the pose in the global frame.
%   STAND-IN kinematic model. Stream A replaces the PLACEHOLDER limits in
%   config.defaultParams with NAO6 data and may refine the model, but must
%   keep this signature.
rp = P.robot;
if R.fallen || R.penalised
    R.vx = 0; R.vy = 0; R.w = 0;
    return
end

% 1. clamp desired command to limits
dvx = min(max(cmd.vx, rp.vxMin), rp.vxMax);
dvy = min(max(cmd.vy, -rp.vyMax), rp.vyMax);
dw  = min(max(cmd.w,  -rp.wMax),  rp.wMax);

% 2. first-order lag, then acceleration limits
a = min(dt / rp.tau, 1);
ax = min(max(a * (dvx - R.vx) / dt, -rp.axMax),    rp.axMax);
ay = min(max(a * (dvy - R.vy) / dt, -rp.ayMax),    rp.ayMax);
al = min(max(a * (dw  - R.w ) / dt, -rp.alphaMax), rp.alphaMax);
R.vx = R.vx + ax * dt;
R.vy = R.vy + ay * dt;
R.w  = R.w  + al * dt;

% 3. integrate pose (body velocity rotated into global frame)
c = cos(R.th); s = sin(R.th);
R.x  = R.x + (R.vx * c - R.vy * s) * dt;
R.y  = R.y + (R.vx * s + R.vy * c) * dt;
R.th = util.wrapToPi(R.th + R.w * dt);
end
