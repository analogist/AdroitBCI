function [ model, act, gain_A, gain_W, gain_F,...
    vizIP, vizDir, so, m, gainP, gainD ]...
    = setup_adroit(adroitpath, originpos)
%SETUP_ADROIT Based on Vikash's q_controlCviz setup

%% User Inputs

% Model to be loaded
model = 'Adroit_Hand';
act	  = 'joint';

% Actuation gains
gain_A    = 250;     % Arm
gain_W    = 100;     % Wrist
gain_F    = 35;      % Fingers

%vizualizer comp ip
vizIP   = ''; % localhost
vizDir  = adroitpath;

%% Launch Mujoco vizualizer and connect
so = mjcVizualizer(vizIP, vizDir);

%% Load Model in vizualizer and in matlab
mjcLoadModel(so, [adroitpath model '.xml']);
mj('load', [adroitpath model '.xml']);
m = mj('getmodel');
mjcPlot(so);

%% Preparations
gainP	= 1*[gain_W*ones(2,1); gain_F*ones(m.nv-2,1)];
gainD	= -0.4*ones(m.nv, 1);

%% Initialize
mj reset				% Reset the state
% Random initialization of hand
J0  = originpos;
V0  = zeros(m.nv,1);
mj('set','qpos',J0);	% Set data in Mujoco
mj('set','qvel',V0);
mj forward;
mjcPlot(so, J0, V0);

end

