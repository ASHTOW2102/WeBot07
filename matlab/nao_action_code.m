function code = nao_action_code(t)
% Numeric action selected by the same timeline used in Webots.
% 0 wait, 1 wave, 2 walk, 3 kick, 4 turn, 5 celebrate
if t < 2.5
  code = 1;
elseif t < 9
  code = 2;
elseif t < 14
  code = 3;
elseif t < 23.2
  code = 4;
else
  code = 5;
end
end
