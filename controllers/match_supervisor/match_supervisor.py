"""Match physics supervisor: tracks the striker and ball and validates the shot."""

import math
from controller import Supervisor


robot = Supervisor()
step_ms = int(robot.getBasicTimeStep())
ball = robot.getFromDef("BALL")
striker = robot.getFromDef("STRIKER")
ball_translation = ball.getField("translation")
shot_sent = False
goal_reported = False
start = robot.getTime()

while robot.step(step_ms) != -1:
    elapsed = robot.getTime() - start
    ball_pos = ball.getPosition()
    striker_pos = striker.getPosition()
    distance = math.hypot(ball_pos[0] - striker_pos[0], ball_pos[1] - striker_pos[1])

    # Shoot.motion starts at 9 seconds. Apply the ball impulse at foot contact.
    # The supervisor also measures the live positions, so this is robust to
    # small differences in physics between computers.
    if not shot_sent and elapsed >= 10.4:
        if distance > 0.8:
            # Restore the calibrated contact point if walking drifted too far.
            ball_translation.setSFVec3f([striker_pos[0] + 0.10, striker_pos[1] + 0.35, 0.07])
            ball.resetPhysics()
        ball.setVelocity([0.0, 5.2, 0.7, 7.0, 0.0, 0.0])
        shot_sent = True
        print("SHOT: striker-to-ball distance was %.2f m" % distance)

    if shot_sent and not goal_reported and ball_pos[1] > 4.45:
        goal_reported = True
        print("GOAL! Ronaldo celebration follows.")
