function W = resetKickoff(W, P, kickoffTeam)
%WORLD.RESETKICKOFF  Put robots and ball in kick-off positions. Owner: Stream C.
%   Positions are written in the TEAM frame (own goal at x = -4.5) and
%   converted to global with util.toTeamFrame (a 180 degree rotation is its
%   own inverse). Stream D may replace these with formation positions.
%   STAND-IN: simple fixed spots by shirt number.
spots = [ -4.00  0.00 ;    % #1
          -2.50  0.00 ;    % #2
          -1.00  0.00 ;    % #3 (moves to -0.4 for the kicking team)
          -1.50  1.20 ];   % #4
for i = 1:numel(W.robots)
    R = W.robots(i);
    s = spots(R.number, :);
    if R.team == kickoffTeam && R.number == 3
        s(1) = -0.4;
    end
    [gx, gy, gth] = util.toTeamFrame(s(1), s(2), 0, [], [], P.team.attackDir(R.team));
    R.x = gx; R.y = gy; R.th = gth;
    R.vx = 0; R.vy = 0; R.w = 0;
    R.fallen = false;
    W.robots(i) = R;
end
W.ball.x = 0; W.ball.y = 0; W.ball.vx = 0; W.ball.vy = 0; W.ball.z = 0; W.ball.vz = 0;
W.game.kickoffTeam = kickoffTeam;
end
