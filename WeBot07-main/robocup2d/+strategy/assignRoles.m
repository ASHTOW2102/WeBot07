function roles = assignRoles(W, team, P)
%STRATEGY.ASSIGNROLES  Decide each robot's role. Owner: Stream D (Ashish).
%   roles = strategy.assignRoles(W, team, P)
%   Returns a 1 x teamSize cell array of role names, indexed by shirt number.
%   Allowed role names: 'goalkeeper', 'defender', 'striker' (add new ones
%   only together with a matching behaviours.<role> function).
%   Called every P.roleUpdateEvery steps by runner.runMatch.
%   STAND-IN: fixed roles from P.team.defaultRoles (a set formation).
%   Stream D can switch to dynamic allocation here without touching the loop.
roles = P.team.defaultRoles;
end
