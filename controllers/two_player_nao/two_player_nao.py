"""Simple NAO striker and goalkeeper controller."""

import os
from controller import Robot, Motion

robot = Robot()
step = int(robot.getBasicTimeStep())
role = "keeper" if "KEEPER" in robot.getName().upper() else "striker"
start, stage, current = robot.getTime(), 0, None
folder = os.path.join(os.path.dirname(__file__), "..", "..", "motions")


def load(filename):
    return Motion(os.path.abspath(os.path.join(folder, filename)))


motions = {
    "wave": load("HandWave.motion"), "walk": load("Forwards50.motion"),
    "kick": load("Shoot.motion"), "turn": load("TurnLeft180.motion"),
    "left": load("SideStepLeft.motion"), "right": load("SideStepRight.motion")
}


def play(name):
    global current
    if current:
        current.stop()
    current = motions[name]
    current.play()
    print(role, name)


def striker(time):
    global stage, current
    plan = [(0, "wave"), (2.5, "walk"), (9, "kick"),
            (14, "turn"), (23.2, "wave")]
    if stage < len(plan) and time >= plan[stage][0]:
        play(plan[stage][1])
        stage += 1
    elif stage == len(plan) and time >= 28.4:
        current.stop()
        stage += 1
        print("SIUUU!")
    elif stage > len(plan):
        # Simple SIUU finishing pose.
        for joint, angle in {"LShoulderPitch": 1.65, "RShoulderPitch": 1.65,
                             "LShoulderRoll": 0.65, "RShoulderRoll": -0.65}.items():
            robot.getDevice(joint).setPosition(angle)
        robot.getDevice("ChestBoard/Led").set(0x00FF00)


def goalkeeper():
    global stage
    if current is None or current.isOver():
        play("left" if stage % 3 == 0 else "right")
        stage += 1


print("Starting", role)
while robot.step(step) != -1:
    striker(robot.getTime() - start) if role == "striker" else goalkeeper()
