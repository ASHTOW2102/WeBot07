%MAIN  Run one match with the viewer, then a small headless batch.
%   Run from the repo root (the folder containing this file).
P = config.defaultParams();

% one short match you can watch (2 simulated minutes)
figure('Name', 'RoboCup 2D');
r = runner.runMatch(P, struct('viz', true, 'maxTime', 120));
fprintf('Watched match: Blue %d - %d Red\n', r.score(1), r.score(2));

% batch of short headless matches for metrics
results = runner.runBatch(P, 10, struct('maxTime', 300));
% In MATLAB: T = struct2table(results); summary(T)
