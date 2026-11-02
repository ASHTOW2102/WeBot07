function draw(W, P)
%VIZ.DRAW  Top-down view of the match. Owner: Stream C (Xu Lu).
%   viz.draw(W, P)  draws into the current figure. Read-only: never changes W.
F = P.field; hx = F.length / 2; hy = F.width / 2;
cla; hold on; axis equal;
xlim([-hx - F.borderWidth, hx + F.borderWidth]);
ylim([-hy - F.borderWidth, hy + F.borderWidth]);
set(gca, 'Color', [0.18 0.55 0.24]);
white = [1 1 1];
% outline, halfway line, centre circle
plot([-hx hx hx -hx -hx], [-hy -hy hy hy -hy], 'Color', white);
plot([0 0], [-hy hy], 'Color', white);
a = linspace(0, 2*pi, 60); rc = F.centreCircleDiameter / 2;
plot(rc * cos(a), rc * sin(a), 'Color', white);
for s = [-1 1]
    gx = s * hx;
    % goal area and penalty area
    plot(gx - s * [0 F.goalAreaLength F.goalAreaLength 0], F.goalAreaWidth / 2 * [-1 -1 1 1], 'Color', white);
    plot(gx - s * [0 F.penaltyAreaLength F.penaltyAreaLength 0], F.penaltyAreaWidth / 2 * [-1 -1 1 1], 'Color', white);
    % goal
    plot(gx + s * [0 F.goalDepth F.goalDepth 0], F.goalWidth / 2 * [-1 -1 1 1], 'Color', [0.9 0.9 0.9], 'LineWidth', 2);
    % penalty mark
    plot(gx - s * F.penaltyMarkDist, 0, '+', 'Color', white);
end
cols = {[0.15 0.35 0.9], [0.85 0.15 0.15]};
for i = 1:numel(W.robots)
    R = W.robots(i);
    plot(R.x + R.r * cos(a), R.y + R.r * sin(a), 'Color', cols{R.team}, 'LineWidth', 1.5);
    plot([R.x, R.x + R.r * cos(R.th)], [R.y, R.y + R.r * sin(R.th)], 'Color', cols{R.team}, 'LineWidth', 2);
    text(R.x, R.y, num2str(R.number), 'HorizontalAlignment', 'center', 'Color', white, 'FontSize', 8);
end
br = P.ball.radius;
fill(W.ball.x + br * cos(a), W.ball.y + br * sin(a), [1 0.55 0], 'EdgeColor', 'none');
title(sprintf('Blue %d - %d Red   half %d   %.0f s', W.game.score(1), W.game.score(2), ...
      W.game.half, W.game.timeInHalf));
hold off;
end
