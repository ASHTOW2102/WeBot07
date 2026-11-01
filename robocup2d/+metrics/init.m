function S = init(P)
%METRICS.INIT  Empty match statistics. Owner: Stream C (Xu Lu).
%   All per-team arrays are [Blue Red].
S.possessionTime = [0 0];   % s, team of the robot nearest the ball (within 0.5 m)
S.kicks          = [0 0];
S.shotsOnTarget  = [0 0];   % kicks whose path would cross the opponent goal mouth
S.outs           = 0;
S.lastEventCount = 0;
end
