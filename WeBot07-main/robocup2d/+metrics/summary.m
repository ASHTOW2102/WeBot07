function M = summary(S, W, P)
%METRICS.SUMMARY  One flat struct per match, ready for struct2table. Owner: Stream C.
total = max(sum(S.possessionTime), eps);
M.scoreBlue        = W.game.score(1);
M.scoreRed         = W.game.score(2);
M.possessionBlue   = S.possessionTime(1) / total;
M.kicksBlue        = S.kicks(1);
M.kicksRed         = S.kicks(2);
M.shotsOnTargetBlue = S.shotsOnTarget(1);
M.shotsOnTargetRed  = S.shotsOnTarget(2);
M.outs             = S.outs;
M.duration         = W.t;
end
