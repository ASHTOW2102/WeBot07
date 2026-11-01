# RoboCup 2D Simulator: Shared Interface

ENG5325 Robotics TDP · agreed interface for the MATLAB 2D simulation · v1.0 (proposed 1 Nov 2026)

This file is the contract between the four streams. If your code follows it, it plugs into everyone else's code without changes. Any change to a name, unit or signature below is an **interface change**: agree it with the team first, update this file and `tests/run_tests.m` in the same commit, and add a line to the changelog at the bottom.

## 1. Golden rules

1. **SI units everywhere:** metres, seconds, radians, m/s, rad/s. No degrees, no centimetres.
2. **One source of truth:** the world struct `W` holds the state. Only the main loop writes to it.
3. **Behaviours never touch `W`.** They read an observation `obs` and return a command `cmd`.
4. **Behaviours always think "attack +x".** The simulator converts each team's view so both teams run identical code.
5. **No hard-coded numbers in stream code.** Every constant lives in `config.defaultParams` (`P`).
6. **Same signature for every behaviour:** `[cmd, mem] = behaviours.<role>(obs, mem, P)`.
7. **Run `tests/run_tests.m` before every Friday merge.** All tests must pass.

## 2. Coordinate frames

**Global frame** (used in `W`, by the referee, viewer and metrics):

- Origin at the centre spot. x runs along the pitch (-4.5 to +4.5 m), y across it (-3 to +3 m).
- Heading `th` is measured from +x, anticlockwise positive, wrapped to (-pi, pi].
- Blue (team 1) attacks +x, Red (team 2) attacks -x (`P.team.attackDir = [+1 -1]`).

**Team frame** (used in `obs`, by all behaviours and `motion.goToPoint`):

- Own goal at x = -4.5, opponent goal at x = +4.5, for both teams.
- For Red this is the global frame rotated by 180 degrees (`util.toTeamFrame`). It is a rotation, not a mirror, so left, right and turning direction stay correct.

**Robot body frame** (used in `cmd` and robot velocities):

- vx forward, vy to the robot's left, w anticlockwise.
- Body-frame commands are the same in every frame, so no conversion is needed.

## 3. Timing

- Fixed timestep `P.dt = 0.05` s (20 Hz). Every function that integrates takes `dt` from `P`.
- Halves of `P.halfDuration` seconds, `P.numHalves` halves. Check the values against the current RoboCup KidSize rules.

## 4. Data types

### 4.1 Parameters `P` (owner: Stream C; each stream owns its own sub-struct)

| Field | Contents | Owner |
|---|---|---|
| `P.dt`, `P.halfDuration`, `P.numHalves`, `P.teamSize`, `P.roleUpdateEvery`, `P.seed` | Simulation settings | C |
| `P.field.*` | Pitch dimensions from Table 1 of the brief | C |
| `P.robot.*` | NAO6 footprint, speed, acceleration and lag limits | A |
| `P.ball.*` | Ball radius, rolling deceleration, kick reach, kick speed and noise | B |
| `P.team.*` | Team names, attack directions, default roles by shirt number | D |

Values marked `PLACEHOLDER` in `config/defaultParams.m` are guesses. The owning stream replaces them with validated data and notes the source in a comment.

### 4.2 World `W` (global frame, owner: Stream C)

| Field | Type | Meaning |
|---|---|---|
| `W.t`, `W.step` | double, int | Simulated time (s) and step counter |
| `W.robots(i)` | struct array, 8 entries | One per robot, ids 1 to 4 Blue, 5 to 8 Red |
| `W.ball` | struct | `x, y, vx, vy` (+ `z, vz` reserved for the 3D stretch goal, kept at 0) |
| `W.game` | struct | Game state, see below |

**Robot** `W.robots(i)`:

| Field | Unit | Meaning |
|---|---|---|
| `id` | | 1 to 8, unique |
| `team` | | 1 = Blue, 2 = Red |
| `number` | | Shirt number 1 to 4 within the team |
| `role` | char | `'goalkeeper'`, `'defender'` or `'striker'` |
| `x, y, th` | m, m, rad | Pose, global frame |
| `vx, vy, w` | m/s, m/s, rad/s | Current velocity, **body frame** |
| `fallen`, `penalised` | logical | Robot cannot move while true |
| `r` | m | Footprint radius |

**Game** `W.game`:

| Field | Meaning |
|---|---|
| `state` | `'INITIAL' \| 'READY' \| 'SET' \| 'PLAYING' \| 'FINISHED'` (stand-in uses PLAYING and FINISHED) |
| `half`, `timeInHalf` | Current half and seconds into it |
| `score` | `[Blue Red]` |
| `kickoffTeam`, `firstKickoffTeam` | Team taking the current and first kick-off |
| `lastTouchTeam`, `lastTouchId` | Who touched the ball last (0 = nobody) |
| `events` | Struct array: `t, type, team, id`. Types: `kick, goal, out_side, out_goalline, half_time, full_time` |

### 4.3 Observation `obs` (team frame, built by `perception.observe`)

| Field | Contents |
|---|---|
| `obs.self` | `id, number, role, x, y, th, vx, vy, w` |
| `obs.ball` | `x, y, vx, vy, visible` |
| `obs.mates` | Struct array of team-mates: `id, number, role, x, y, th, fallen` |
| `obs.opps` | Struct array of opponents: `id, number, x, y, th, fallen` |
| `obs.game` | `state, score [own opp], timeLeft, ownKickoff, t` |

The stand-in gives perfect information. Sensor noise or a limited field of view can be added later inside `perception.observe` without changing any behaviour.

### 4.4 Command `cmd` (body frame, created with `util.emptyCmd`)

| Field | Unit | Meaning |
|---|---|---|
| `vx` | m/s | Desired forward speed |
| `vy` | m/s | Desired side speed, + = left |
| `w` | rad/s | Desired turn rate, + = anticlockwise |
| `kick` | logical | Request a kick this step |
| `kickSpeed` | m/s | Requested ball speed |
| `kickDir` | rad | Kick direction relative to the robot's heading |

Commands are **requests**. `motion.update` enforces the robot's limits, and `ballmodel.applyKick` only kicks if the ball is in reach.

### 4.5 Memory `mem`

Each robot's private memory: a struct the behaviour owns completely (state machine state, timers, targets). It starts as `[]` and is reset to `[]` when the robot's role changes.

## 5. Folder layout and ownership

```
robocup2d/
  main.m                    run one watched match + a small batch
  INTERFACE.md              this file
  +config/defaultParams.m   C (sub-structs owned per table 4.1)
  +util/                    shared helpers: wrapToPi, toTeamFrame, emptyCmd, logEvent
  +world/                   C   init, resetKickoff, resolveCollisions
  +perception/observe.m     C   (B may add ball-detection noise later)
  +motion/                  A   update, goToPoint
  +ballmodel/               B   update, applyKick
  +behaviours/              B   striker   |   D   defender, goalkeeper
  +strategy/assignRoles.m   D
  +referee/update.m         C
  +metrics/                 C   init, update, summary
  +runner/                  C   runMatch (main loop), runBatch, callBehaviour
  +viz/draw.m               C
  tests/run_tests.m         all
```

Folders starting with `+` are MATLAB packages: call functions as `motion.update(...)`. Edit only the files your stream owns. Shared files (`+util`, `tests`) change only by team agreement.

## 6. Function contracts

| Function | Signature | Owner | Contract |
|---|---|---|---|
| Parameters | `P = config.defaultParams()` | C | Returns every constant |
| World set-up | `W = world.init(P, kickoffTeam)` | C | Robots and ball at kick-off |
| Kick-off reset | `W = world.resetKickoff(W, P, team)` | C | Used after goals and at half time |
| Collisions | `W = world.resolveCollisions(W, P)` | C | Robot-robot, robot-ball, boundary |
| Observation | `obs = perception.observe(W, i, P)` | C | Robot i's view, team frame |
| Robot motion | `R = motion.update(R, cmd, P, dt)` | A | Clamp, lag, integrate one robot |
| Go to point | `cmd = motion.goToPoint(self, target, P)` | A | `target = [x y]` or `[x y th]`, team frame |
| Ball motion | `ball = ballmodel.update(ball, P, dt)` | B | Rolling with friction |
| Kick | `[ball, kicked] = ballmodel.applyKick(ball, R, cmd, P)` | B | Kicks only if in reach |
| Behaviours | `[cmd, mem] = behaviours.<role>(obs, mem, P)` | B, D | Standard signature |
| Roles | `roles = strategy.assignRoles(W, team, P)` | D | Cell array by shirt number |
| Rules | `W = referee.update(W, P, dt)` | C | Goals, outs, clock |
| Metrics | `S = metrics.update(S, W, P, kickedIds)` | C | Accumulate stats |
| Match | `result = runner.runMatch(P, opts)` | C | One match, see `opts` in file |
| Batch | `results = runner.runBatch(P, n, opts)` | C | Many headless matches |
| Viewer | `viz.draw(W, P)` | C | Read-only drawing |

**Higher-level skills** (Stream B, used by the striker and defenders) go in a `+skills` package with the pattern `cmd = skills.<name>(obs, ..., P)`, for example `skills.approachBall`, `skills.dribble`, `skills.passTo(obs, mateId, P)`, `skills.intercept`. They return a command, like `motion.goToPoint`.

## 7. Main loop (inside `runner.runMatch`)

One step, in this order:

1. **Roles:** `strategy.assignRoles` every `P.roleUpdateEvery` steps.
2. **Decide:** for each robot, `perception.observe`, then its behaviour.
3. **Move:** `motion.update` for each robot.
4. **Kick:** `ballmodel.applyKick` in random robot order; the first valid kick wins.
5. **Roll:** `ballmodel.update`.
6. **Collide:** `world.resolveCollisions`.
7. **Clock:** advance `W.t` and `W.step`.
8. **Rules:** `referee.update`.
9. **Measure:** `metrics.update`, and `viz.draw` if watching.

All robots decide from the same snapshot (step 2 completes before step 3), so no robot sees another's move from the same step.

## 8. Stateflow

Behaviours are designed as Stateflow charts. To keep the fast MATLAB loop (no Simulink needed), build each one as a **standalone Stateflow chart** (`.sfx`), which can be called from MATLAB code. Check that everyone's MATLAB version supports standalone charts.

The wrapper keeps the standard signature, for example:

```matlab
function [cmd, mem] = striker(obs, mem, P)
if isempty(mem), mem.chart = strikerChart(); end   % create the chart once per robot
% feed obs into the chart, step it, read the decision, then build cmd with
% motion.goToPoint / skills.* and the chart's outputs
end
```

The rest of the simulator never knows whether a behaviour is a chart or plain code.

## 9. Stand-ins and how to replace them

Every function above already exists as a simple working version, so a full match runs from day one. To replace your part:

1. Keep the file name and signature exactly.
2. Swap the body for your real version.
3. Run `tests/run_tests.m` and one watched match (`main.m`).
4. Merge on Friday.

| Stand-in | Replaced by | Owner |
|---|---|---|
| Fixed speed limits and P-controller | NAO6-validated model, proper controllers, avoidance | A |
| Constant-deceleration ball, simple kick | Validated ball and kick model, skills, Stateflow striker | B |
| Simple restarts, no fouls | Full restart rules, fouls, READY/SET, penalties | C |
| Fixed roles and kick-off spots | Dynamic roles, formations, Stateflow goalkeeper and defender | D |

## 10. Placeholders to replace first

| Value | Owner | Needed by |
|---|---|---|
| `P.robot.vxMax, vxMin, vyMax, wMax` and acceleration limits | A | Model validation, late Nov |
| `P.robot.radius`, `P.robot.tau` | A | Late Nov |
| `P.ball.rollDecel` | B | Late Nov |
| `P.ball.kickSpeedMax`, kick noise, `kickRange`, `kickAngle` | B | Late Nov |
| `P.halfDuration` (check rules) | C | Before batch experiments |
| `P.team.defaultRoles` and kick-off spots | D | Before M2 (27 Nov) |

## 11. Running it

```matlab
cd robocup2d                         % repo root
run('tests/run_tests.m')             % all tests must print PASS
main                                 % watch a 2-minute match, then a 10-match batch
P = config.defaultParams();
results = runner.runBatch(P, 100);   % 100 full matches, headless
T = struct2table(results);           % analyse and plot
```

## Changelog

| Date | Version | Change | Agreed by |
|---|---|---|---|
| 1 Nov 2026 | 1.0 | First proposal | To agree in week 1 |
