# Webots NAO: Striker vs Goalkeeper

A small RoboCup-style Webots simulation containing two SoftBank NAO robots:

- a red striker that waves, approaches the ball, shoots, turns, and celebrates;
- a blue goalkeeper that patrols left and right across the goalmouth;
- a match supervisor that tracks the live ball and makes the shot repeatable.

The repository includes equivalent Python and MATLAB NAO controllers plus a
Simulink timeline model that visualizes the striker's decisions.

## Requirements

- Webots R2025a
- Python 3 (Webots can use its configured Python installation)
- Internet access the first time the world loads its official Webots PROTO assets
- MATLAB with Simulink (optional, only for the MATLAB/Simulink examples)

## Run the simulation

1. Clone this repository.
2. Open `worlds/two_player_goal.wbt` in Webots.
3. Allow Webots to download the referenced NAO, field, and ball assets if prompted.
4. Press the **Run** button.
5. Use **Simulation > Reset** to replay the demonstration.

For MATLAB, open `worlds/two_player_goal_matlab.wbt`. For Simulink setup and
the complete system explanation, see [`docs/MATLAB_SIMULINK.md`](docs/MATLAB_SIMULINK.md).

The shot occurs after roughly 10 seconds. The celebration begins after the
striker turns around.

## Project structure

```text
webot07/
├── controllers/
│   ├── two_player_nao/
│   │   └── two_player_nao.py      # striker and goalkeeper behavior
│   ├── two_player_nao_matlab/
│   │   └── two_player_nao_matlab.m # MATLAB equivalent
│   └── match_supervisor/
│       └── match_supervisor.py    # ball tracking, shot, and goal detection
├── motions/                       # standard NAO motion files
├── matlab/                         # Simulink model builder and action function
├── docs/                           # MATLAB/Simulink explanation
└── worlds/
    └── two_player_goal.wbt        # field, robots, ball, and camera
```

## How the controller works

Both NAO robots execute `two_player_nao.py`. The robot name determines its role:

```python
role = "keeper" if "KEEPER" in robot.getName().upper() else "striker"
```

The striker follows a short timed plan:

```text
0.0 s   wave
2.5 s   walk
9.0 s   kick
14.0 s  turn around
23.2 s  victory wave
28.4 s  SIUU-inspired finishing pose
```

The goalkeeper repeats the standard left and right sidestep motions. The match
supervisor measures the real striker-to-ball distance, applies the shot impulse
at foot-contact time, and reports when the ball crosses the goal line.

## Main source files

- `controllers/two_player_nao/two_player_nao.py`
- `controllers/match_supervisor/match_supervisor.py`
- `controllers/two_player_nao_matlab/two_player_nao_matlab.m`
- `matlab/build_nao_timeline_model.m`
- `worlds/two_player_goal.wbt`

This project is intended as a concise educational example. The behavior uses a
timed motion plan rather than full camera-based autonomous ball perception.
