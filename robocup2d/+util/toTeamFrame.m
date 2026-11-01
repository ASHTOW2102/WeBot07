function [x, y, th, vx, vy] = toTeamFrame(x, y, th, vx, vy, attackDir)
%UTIL.TOTEAMFRAME  Global frame -> team frame (team always attacks +x).
%   For attackDir = +1 nothing changes. For attackDir = -1 the field is
%   rotated by 180 degrees: (x, y) -> (-x, -y), heading -> heading + pi,
%   global velocities negated. A rotation (not a mirror) keeps left/right and
%   turning direction correct, so body-frame commands need no conversion.
%   Pass [] for th, vx or vy when not needed.
if attackDir == 1
    return
end
x = -x;  y = -y;
if ~isempty(th), th = util.wrapToPi(th + pi); end
if ~isempty(vx), vx = -vx; end
if ~isempty(vy), vy = -vy; end
end
