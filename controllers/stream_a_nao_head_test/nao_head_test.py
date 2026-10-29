"""nao_head_test controller."""

# You may need to import some classes of the controller module. Ex:
#  from controller import Robot, Motor, DistanceSensor
from controller import Robot
import math

# create the Robot instance.
robot = Robot()

# get the time step of the current world.
timestep = int(robot.getBasicTimeStep())

# You should insert a getDevice-like function in order to get the
# instance of a device of the robot. Something like:
#  motor = robot.getDevice('motorname')
#  ds = robot.getDevice('dsname')
#  ds.enable(timestep)
head_yaw = robot.getDevice('HeadYaw')
head_sensor = head_yaw.getPositionSensor()
head_sensor.enable(timestep)

# Main loop:
# - perform simulation steps until Webots is stopping the controller
while robot.step(timestep) != -1:
    # Read the sensors:
    # Enter here functions to read sensor data, like:
    #  val = ds.getValue()

    # Process sensor data here.

    # Enter here functions to send actuator commands, like:
    #  motor.setPosition(10.0)
    t = robot.getTime()
    target = 1.0 * math.sin(t)
    head_yaw.setPosition(target)
    if int(t * 1000) % 500 < timestep:
        print(f't={t:.2f}s cmd={target:+.2f} actual={head_sensor.getValue():+.2f}')
# Enter here exit cleanup code.
