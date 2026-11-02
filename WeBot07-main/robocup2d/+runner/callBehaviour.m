function [cmd, mem] = callBehaviour(role, obs, mem, P)
%RUNNER.CALLBEHAVIOUR  Route a robot to the behaviour for its role. Owner: Stream C.
%   Adding a role = add behaviours.<role> with the standard signature and a
%   case here.
switch role
    case 'striker',    [cmd, mem] = behaviours.striker(obs, mem, P);
    case 'defender',   [cmd, mem] = behaviours.defender(obs, mem, P);
    case 'goalkeeper', [cmd, mem] = behaviours.goalkeeper(obs, mem, P);
    otherwise
        error('runner:unknownRole', 'Unknown role "%s"', role);
end
end
