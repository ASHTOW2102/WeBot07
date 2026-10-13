function build_nao_timeline_model
% Build a small Simulink model that visualizes the striker state timeline.
model = 'nao_striker_timeline';
if bdIsLoaded(model), close_system(model, 0); end
new_system(model);

add_block('simulink/Sources/Clock', [model '/Simulation time'], ...
  'Position', [40 80 80 110]);
add_block('simulink/User-Defined Functions/Interpreted MATLAB Fcn', ...
  [model '/Action selector'], 'MATLABFcn', 'nao_action_code(u)', ...
  'Position', [140 70 280 120]);
add_block('simulink/Sinks/Display', [model '/Action code'], ...
  'Position', [350 70 440 120]);
add_block('simulink/Sinks/To Workspace', [model '/Log action'], ...
  'VariableName', 'naoAction', 'SaveFormat', 'Structure With Time', ...
  'Position', [340 155 450 195]);

add_line(model, 'Simulation time/1', 'Action selector/1');
add_line(model, 'Action selector/1', 'Action code/1');
add_line(model, 'Action selector/1', 'Log action/1');
set_param(model, 'StopTime', '30');
save_system(model, fullfile(fileparts(mfilename('fullpath')), [model '.slx']));
open_system(model);
disp('Action codes: 1=wave, 2=walk, 3=kick, 4=turn, 5=celebrate');
end
