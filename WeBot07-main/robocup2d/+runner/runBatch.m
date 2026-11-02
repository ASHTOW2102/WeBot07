function results = runBatch(P, nMatches, opts)
%RUNNER.RUNBATCH  Play many headless matches with different seeds. Owner: Stream C.
%   results = runner.runBatch(P, nMatches)
%   results = runner.runBatch(P, nMatches, opts)   opts as runner.runMatch (viz forced off)
%   Returns a struct array of metrics.summary rows, one per match, with a
%   .seed field. In MATLAB: T = struct2table(results) for analysis and plots.
if nargin < 3, opts = struct(); end
opts.viz = false;
for k = 1:nMatches
    opts.seed = k;
    r = runner.runMatch(P, opts);
    row = r.summary;
    row.seed = k;
    results(k) = row; %#ok<AGROW>
    fprintf('match %3d  Blue %d - %d Red\n', k, row.scoreBlue, row.scoreRed);
end
fprintf('mean goals: Blue %.2f, Red %.2f over %d matches\n', ...
    mean([results.scoreBlue]), mean([results.scoreRed]), nMatches);
end
