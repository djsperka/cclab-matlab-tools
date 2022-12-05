% initializations - per "rig"
cfg.screen_number = 1;

% mac
% cfg.screen_rect = [1280 750 1680 1050];
% linux, 
%cfg.screen_rect = [1520 900 1920 1200];
% lab
cfg.screen_rect = [];

% this is probably linked to the screen rect, but not now
cfg.screen_visible_mm = [700, 390];
cfg.screen_distance_mm = 800;

% Juicer
cfg.reward_type = 'n';
cfg.reward_size = 500;
cfg.reward_number = 1;
cfg.reward_gap = 250;

% eye tracker config (TODO)
cfg.eyelink_dummymode = 1;
cfg.doBitsPlusPlus = 0;
cfg.SkipSyncTests = 1;

% size of photodiode square, in pixels 
cfg.marker_rect = [0, 0, 200, 200];

% position of photodiode square, see doc for AlignRect
cfg.marker_rect_side1 = 'top';
cfg.marker_rect_side2 = 'right';

% initializations - experimental parameters
% colors  [0,1] not [0 255]
cfg.background_color=[.5, .5, .5];
cfg.output_folder='/Users/dan/Documents/MATLAB';

% other
cfg.verbose = 1;
cfg.doBitsPlusPlus = 0;

% cfix-specific
cfg.dummymode = 1;










% computed after initializations

% screen resolution, in pixels
%cfg.screen_resolution = [cfg.screen_rect(3)-cfg.screen_rect(1), cfg.screen_rect(4)-cfg.screen_rect(2)];
cfg.screen_resolution = [1920, 1080];

% used for unit conversions between pixels & degrees
cfg.ppdX = cfg.screen_resolution(1)/atan(0.5*cfg.screen_visible_mm(1)/cfg.screen_distance_mm)*pi/180;
cfg.ppdY = cfg.screen_resolution(2)/atan(0.5*cfg.screen_visible_mm(2)/cfg.screen_distance_mm)*pi/180;

%afix(cfg);
%bfix(cfg);
cfix(cfg);