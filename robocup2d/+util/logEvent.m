function W = logEvent(W, type, team, id)
%UTIL.LOGEVENT  Append an event to W.game.events.
%   type: 'kick' | 'goal' | 'out_side' | 'out_goalline' | 'half_time' | 'full_time'
%   team: 1 or 2 (0 if none), id: robot id (0 if none)
W.game.events(end+1) = struct('t', W.t, 'type', type, 'team', team, 'id', id);
end
