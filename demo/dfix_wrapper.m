% initializations - per "rig"

% mac
% cfg.screen_rect = [1280 750 1680 1050];

% ===== linux desktop =======================
cfg.screen_number = 0;
cfg.screen_rect = [1520 900 1920 1200];
cfg.screen_visible_mm = [120, 90]; % physical size of stim display screen
cfg.screen_distance_mm = 300;
cfg.background_color=[127 127 127];
cfg.eyelink_dummymode = 1;
cfg.output_folder='/Users/dan/Documents/MATLAB';
cfg.SkipSyncTests = 0;

% ===== EEG booth =======================
% cfg.screen_number = 1;
% cfg.screen_rect = [];
% cfg.screen_visible_mm = [600, 338]; % physical size of stim display screen
% cfg.screen_distance_mm = 700;
% cfg.eyelink_dummymode = 0;
% cfg.output_folder='/Users/dan/Documents/MATLAB';
% cfg.SkipSyncTests = 0;


% dio
cfg.dio = 'n';
cfg.dio_reward_size = 500;
cfg.dio_reward_number = 1;
cfg.dio_reward_gap = 250;


% Psychtoolbox/stim stuff
cfg.fixpt_window_deg = [0, 0];
cfg.fixpt_color = [.7, .5, .2];
cfg.fixpt_rect = [0 0 20 20];

% initializations - experimental parameters
% colors  [0,1] not [0 255]

% other
cfg.verbose = 1;

% computed after initializations


% used for unit conversions between pixels & degrees
%cfg.ppdX = cfg.screen_resolution(1)/atan(0.5*cfg.screen_visible_mm(1)/cfg.screen_distance_mm)*pi/180;
%cfg.ppdY = cfg.screen_resolution(2)/atan(0.5*cfg.screen_visible_mm(2)/cfg.screen_distance_mm)*pi/180;

dfix(cfg);
%bfix(cfg);
%times = cfix(cfg);