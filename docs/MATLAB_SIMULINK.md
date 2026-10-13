# MATLAB and Simulink

## MATLAB controller

Webots can launch MATLAB directly as a robot controller. Open
`worlds/two_player_goal_matlab.wbt` to run the MATLAB version. It implements
the same role selection and timeline as the short Python controller.

Before running it:

1. Install MATLAB.
2. In Webots, open **Tools > Preferences > General**.
3. Set the MATLAB command/path if Webots did not detect it automatically.
4. Open `worlds/two_player_goal_matlab.wbt` and press **Run**.

The world still uses the small Python match supervisor for repeatable ball
physics and goal detection. The two NAO behavior controllers run in MATLAB.

## Simulink model

The Simulink example visualizes the striker's timed state selection:

1. Start MATLAB in the repository root.
2. Run `addpath('matlab')`.
3. Run `build_nao_timeline_model`.
4. Open/run the generated `matlab/nao_striker_timeline.slx` model.

The displayed action codes are:

| Code | Action |
|---:|---|
| 1 | Wave |
| 2 | Walk |
| 3 | Kick |
| 4 | Turn |
| 5 | Celebrate |

Webots R2025a provides a MATLAB controller API but does not execute `.slx`
files as native robot controllers. The included Simulink model is therefore a
clear visualization/test of the decision timeline. A production closed-loop
co-simulation would require an explicit bridge (for example TCP/UDP) between
Simulink and a Webots controller.

## Data flow

```text
Webots world
  -> starts one controller for each NAO
  -> robot name selects striker or goalkeeper
  -> controller selects a .motion file
  -> Webots applies joint positions and physics
  -> match supervisor tracks striker and ball
  -> supervisor applies the shot impulse and detects the goal
```
