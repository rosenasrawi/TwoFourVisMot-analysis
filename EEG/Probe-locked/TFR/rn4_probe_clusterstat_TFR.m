%% Clean workspace

clc; clear; close all

%% Load data

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');

fn_TFR = {'motor_load_two', 'motor_load_four', 'visual_load_two', 'visual_load_four'};
fn_time = {'motor_beta_load_two', 'motor_beta_load_four', 'visual_alpha_load_two', 'visual_alpha_load_four'};

%% Time-course stat

%% Settings

cfg = [];

cfg.xax = cvsi_probe_all.time;
cfg.npermutations = 10000;
cfg.clusterStatEvalaluationAlpha = 0.05;
cfg.nsub = size(cvsi_probe_all.motor_load_two, 1);
cfg.statMethod = 'montecarlo'; 

data_zero = zeros(size(cvsi_probe_all.motor_beta_load_two));

%% Run

for f = 1:length(fn_time)
    stat_cvsi.(fn_time{f}) = frevede_ftclusterstat1D(cfg, cvsi_probe_all.(fn_time{f}), data_zero);
end

%% Zeros to NaNs in mask

for f = 1:length(fn_time)
    m = double(stat_cvsi.(fn_time{f}).mask);
    m(m==0) = nan;
    stat_cvsi.(fn_time{f}).mask = m;
end

%% TFR stat

%% Settings

cfg = [];

cfg.xax = cvsi_probe_all.time;
cfg.yax = cvsi_probe_all.freq;
cfg.npermutations = 10000; % usually use 10.000 (but less for testing)
cfg.clusterStatEvalaluationAlpha = 0.025;
cfg.statMethod = 'montecarlo';  % statcfg.statMethod = 'analytic';

data_zero = zeros(size(cvsi_probe_all.motor_load_two));

%% Run

for f = 1:length(fn_TFR)
    stat_cvsi.(fn_TFR{f}) = frevede_ftclusterstat2D(cfg, squeeze(cvsi_probe_all.(fn_TFR{f})), squeeze(data_zero));
end

%% Save it

save([param.path, 'Processed/Locked probe/stats/' 'stat_cvsi'], 'stat_cvsi');

