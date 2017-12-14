function Varma_simpleconfig

% Config file for generating Varma stimulus with long range correlations.
% This config generates a video of duration 20 mins. The second half of the
% video is a repetition of the first half.

control = stimulus.getControl;
control.clearAll()   % clear trial queue and cached conditions.

cond.fps = 60;
cond.pre_blank_period   = 0;
cond.noise_seed         = randi(10000); % random noise seed
cond.pattern_upscale    = 3;
cond.pattern_width      = 32;
cond.duration           = 600;          % 10 mins
cond.pattern_aspect     = 1.7;
cond.gaborpatchsize     = 0.28; 
cond.gabor_wlscale      = 4;
cond.gabor_envscale     = 6;
cond.gabor_ell          = 1;
cond.gaussfilt_scale    = 1.5;          % scale of 1.5 corresponds to long range correlation
cond.gaussfilt_istd     = 0.5;
cond.gaussfiltext_scale = 1;
cond.gaussfiltext_istd  = 1;
cond.filt_noise_bw      = 0.5;
cond.filt_ori_bw        = 0.5;
cond.filt_cont_bw       = 0.5;
cond.filt_gammshape     = 0.35;
cond.filt_gammscale     = 2;

params = stimulus.utils.factorize(cond);

fprintf('Total duration of video = %3.2f s\n', 2*params.duration);

% generate conditions
hashesVarma = control.makeConditions(stimulus.Varma, params);

hashes = [hashesVarma; hashesVarma]; % repeating the same clip twice

control.pushTrials(hashes);
