%RUN_TESTS  Interface checks. Run from the repo root before every Friday merge:
%   >> run('tests/run_tests.m')
% Every test must print PASS. If you change an interface, update INTERFACE.md
% and these tests in the same commit.
addpath(fileparts(fileparts(mfilename('fullpath'))));   % repo root, so packages resolve
P = config.defaultParams();
tol = 1e-9;

% 1. team frame is its own inverse
[x, y, th, vx, vy] = util.toTeamFrame(1.2, -0.7, 0.4, 0.3, -0.1, -1);
[x, y, th, vx, vy] = util.toTeamFrame(x, y, th, vx, vy, -1);
assert(abs(x - 1.2) < tol && abs(y + 0.7) < tol && abs(th - 0.4) < tol && abs(vx - 0.3) < tol && abs(vy + 0.1) < tol);
disp('PASS 1 team frame round trip');

% 2. both teams see the same kick-off picture in their own frame
P2 = P;
W = world.init(P2, 1);
W = world.resetKickoff(W, P2, 0);              % 0 = nobody: symmetric spots
oB = perception.observe(W, 1, P);              % Blue #1
oR = perception.observe(W, P.teamSize + 1, P); % Red #1
assert(abs(oB.self.x - oR.self.x) < tol && abs(oB.self.y - oR.self.y) < tol && abs(oB.self.th - oR.self.th) < tol);
assert(oB.self.x < 0, 'own goal must be at negative x in team frame');
disp('PASS 2 symmetric team frames');

% 3. motion respects speed limits
R = W.robots(1); R.x = 0; R.y = 0; R.th = 0;
c = util.emptyCmd(); c.vx = 10; c.vy = 10; c.w = 10;
for k = 1:200, R = motion.update(R, c, P, P.dt); end
assert(R.vx <= P.robot.vxMax + tol && R.vy <= P.robot.vyMax + tol && R.w <= P.robot.wMax + tol);
disp('PASS 3 motion speed limits');

% 4. goToPoint reaches a target within 20 s
R = W.robots(1); R.x = 0; R.y = 0; R.th = 0;
target = [1.0, 0.5, pi/2];
for k = 1:round(20 / P.dt)
    s = struct('x', R.x, 'y', R.y, 'th', R.th);
    R = motion.update(R, motion.goToPoint(s, target, P), P, P.dt);
end
assert(hypot(R.x - 1.0, R.y - 0.5) < 0.05, 'goToPoint did not arrive');
disp('PASS 4 goToPoint arrives');

% 5. ball stops after v / rollDecel seconds
b = struct('x', 0, 'y', 0, 'vx', 1, 'vy', 0, 'z', 0, 'vz', 0);
for k = 1:ceil(1 / P.ball.rollDecel / P.dt) + 1, b = ballmodel.update(b, P, P.dt); end
assert(hypot(b.vx, b.vy) < tol);
disp('PASS 5 ball comes to rest');

% 6. a kick works only with the ball in front and in range
R = W.robots(1); R.x = 0; R.y = 0; R.th = 0;
c = util.emptyCmd(); c.kick = true; c.kickSpeed = 2;
inFront = struct('x', R.r + P.ball.radius + 0.05, 'y', 0, 'vx', 0, 'vy', 0, 'z', 0, 'vz', 0);
behind  = inFront; behind.x = -inFront.x;
[~, k1] = ballmodel.applyKick(inFront, R, c, P);
[~, k2] = ballmodel.applyKick(behind,  R, c, P);
assert(k1 && ~k2);
disp('PASS 6 kick geometry');

% 7. a short match runs end to end and returns the summary fields
r = runner.runMatch(P, struct('maxTime', 30));
need = {'scoreBlue', 'scoreRed', 'possessionBlue', 'kicksBlue', 'kicksRed', 'outs', 'duration'};
assert(all(isfield(r.summary, need)));
disp('PASS 7 match runs');
disp('All interface tests passed.');
