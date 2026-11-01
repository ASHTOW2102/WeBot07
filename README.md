# WeBot07: RoboCup 2D Simulator

A MATLAB 2D simulation of a 4v4 RoboCup KidSize match (NAO6 robots), built for the ENG5325 Robotics TDP.

Every part of the simulator already has a simple working stand-in, so a full match runs from day one. Each stream replaces its own parts with the real version over time.

## Quick start

In MATLAB:

```matlab
cd robocup2d
run('tests/run_tests.m')             % all tests must print PASS
main                                 % watch a 2-minute match, then a 10-match batch
P = config.defaultParams();
results = runner.runBatch(P, 100);   % 100 full matches, headless
T = struct2table(results);           % analyse and plot
```

## Project layout

```
robocup2d/
  main.m                    run one watched match + a small batch
  INTERFACE.md              shared interface: data types, frames, signatures
  +config/defaultParams.m   every constant (P)
  +world/                   world set-up, kick-off reset, collisions
  +perception/observe.m     builds each robot's observation
  +motion/                  robot motion model, goToPoint
  +ballmodel/               ball rolling and kicks
  +behaviours/              striker, defender, goalkeeper
  +strategy/assignRoles.m   role assignment
  +referee/update.m         goals, outs, clock
  +metrics/                 match statistics
  +runner/                  main loop, batch runs
  +viz/draw.m               match viewer
  +util/                    shared helpers
  tests/run_tests.m         interface tests
```

## Streams

| Stream | Owns |
|---|---|
| A | Robot motion model and controllers (`+motion`, `P.robot`) |
| B | Ball model, kicks, skills, striker (`+ballmodel`, `+behaviours/striker.m`, `P.ball`) |
| C | World, perception, referee, metrics, runner, viewer, parameters |
| D | Roles, formations, defender and goalkeeper (`+strategy`, `+behaviours/defender.m`, `+behaviours/goalkeeper.m`, `P.team`) |

## Rules for contributing

- Read [`robocup2d/INTERFACE.md`](robocup2d/INTERFACE.md) first. It is the contract between the streams.
- SI units everywhere (m, s, rad). No hard-coded numbers: constants go in `config.defaultParams`.
- Behaviours keep the signature `[cmd, mem] = behaviours.<role>(obs, mem, P)` and never modify the world `W`.
- Edit only the files your stream owns. Changes to shared files (`+util`, `tests`) or to the interface need team agreement.
- Run `tests/run_tests.m` before every Friday merge. All tests must pass.
