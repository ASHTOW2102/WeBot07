function P = defaultParams()
%CONFIG.DEFAULTPARAMS  Every shared constant in one struct. Owner: Stream C (Xu Lu).
%   P = config.defaultParams() returns the parameter struct passed to every
%   function in the simulator. Units are SI: metres, seconds, radians.
%   Values marked PLACEHOLDER must be replaced by the owning stream with
%   validated NAO6 / ball data. Changing a field name is an interface change.

% ---- simulation ----
P.dt              = 0.05;     % s, fixed timestep (20 Hz)
P.halfDuration    = 600;      % s per half (check current RoboCup KidSize rules)
P.numHalves       = 2;
P.teamSize        = 4;
P.roleUpdateEvery = 10;       % steps between strategy.assignRoles calls
P.seed            = 1;        % default random seed

% ---- field: Table 1 of the ENG5325 brief ----
P.field.length               = 9.0;
P.field.width                = 6.0;
P.field.goalWidth            = 2.6;
P.field.goalDepth            = 0.6;
P.field.goalHeight           = 1.2;
P.field.goalAreaLength       = 1.0;
P.field.goalAreaWidth        = 3.0;
P.field.penaltyMarkDist      = 1.5;
P.field.centreCircleDiameter = 1.5;
P.field.borderWidth          = 1.0;
P.field.penaltyAreaLength    = 2.0;
P.field.penaltyAreaWidth     = 5.0;

% ---- robot (NAO6). Owner: Stream A (Muqeem) ----
P.robot.radius    = 0.15;   % m      PLACEHOLDER footprint radius
P.robot.vxMax     = 0.25;   % m/s    PLACEHOLDER max forward speed
P.robot.vxMin     = -0.10;  % m/s    PLACEHOLDER max backward speed (negative)
P.robot.vyMax     = 0.15;   % m/s    PLACEHOLDER max side speed
P.robot.wMax      = 1.0;    % rad/s  PLACEHOLDER max turn rate
P.robot.axMax     = 0.5;    % m/s^2  PLACEHOLDER forward acceleration limit
P.robot.ayMax     = 0.5;    % m/s^2  PLACEHOLDER side acceleration limit
P.robot.alphaMax  = 2.0;    % rad/s^2 PLACEHOLDER turn acceleration limit
P.robot.tau       = 0.2;    % s      PLACEHOLDER response lag (first order)

% ---- ball and kick. Owner: Stream B (Sharique) ----
P.ball.radius         = 0.07;  % m, FIFA size 1 (~14 cm diameter, brief)
P.ball.rollDecel      = 0.3;   % m/s^2 PLACEHOLDER rolling deceleration
P.ball.kickRange      = 0.12;  % m   PLACEHOLDER max gap robot edge to ball edge for a kick
P.ball.kickAngle      = pi/6;  % rad PLACEHOLDER ball must be within +-this of robot heading
P.ball.kickSpeedMax   = 3.0;   % m/s PLACEHOLDER
P.ball.kickNoiseSpeed = 0.10;  % fraction, PLACEHOLDER speed noise (1 sigma)
P.ball.kickNoiseDir   = 0.05;  % rad, PLACEHOLDER direction noise (1 sigma)

% ---- teams. Owner: Stream D (Ashish) for roles ----
P.team.names        = {'Blue', 'Red'};
P.team.attackDir    = [+1, -1];   % Blue attacks +x, Red attacks -x (global frame)
P.team.defaultRoles = {'goalkeeper', 'defender', 'striker', 'striker'}; % by shirt number 1..4
end
