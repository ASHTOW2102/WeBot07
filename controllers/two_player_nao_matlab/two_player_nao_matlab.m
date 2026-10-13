% MATLAB equivalent of the Python striker/goalkeeper controller.
function two_player_nao_matlab

TIME_STEP = 20;
name = wb_robot_get_name();
is_keeper = contains(upper(name), 'KEEPER');
motion_dir = '../../motions/';

M.wave  = wbu_motion_new([motion_dir 'HandWave.motion']);
M.walk  = wbu_motion_new([motion_dir 'Forwards50.motion']);
M.kick  = wbu_motion_new([motion_dir 'Shoot.motion']);
M.turn  = wbu_motion_new([motion_dir 'TurnLeft180.motion']);
M.left  = wbu_motion_new([motion_dir 'SideStepLeft.motion']);
M.right = wbu_motion_new([motion_dir 'SideStepRight.motion']);

current = 0;
stage = 1;
start_time = wb_robot_get_time();
times = [0, 2.5, 9, 14, 23.2];
actions = {'wave', 'walk', 'kick', 'turn', 'wave'};

while wb_robot_step(TIME_STEP) ~= -1
  if is_keeper
    if current == 0 || wbu_motion_is_over(current)
      if mod(stage, 3) == 1
        next = M.left;
      else
        next = M.right;
      end
      current = play_motion(current, next);
      stage = stage + 1;
    end
  else
    elapsed = wb_robot_get_time() - start_time;
    if stage <= length(times) && elapsed >= times(stage)
      current = play_motion(current, M.(actions{stage}));
      stage = stage + 1;
    elseif stage == 6 && elapsed >= 28.4
      wbu_motion_stop(current);
      set_siuu_pose();
      disp('SIUUU!');
      stage = 7;
    end
  end
end
end

function selected = play_motion(current, selected)
if current ~= 0
  wbu_motion_stop(current);
end
wbu_motion_play(selected);
end

function set_siuu_pose()
names = {'LShoulderPitch','RShoulderPitch','LShoulderRoll','RShoulderRoll'};
angles = [1.65, 1.65, 0.65, -0.65];
for i = 1:length(names)
  wb_motor_set_position(wb_robot_get_device(names{i}), angles(i));
end
wb_led_set(wb_robot_get_device('ChestBoard/Led'), hex2dec('00FF00'));
end
