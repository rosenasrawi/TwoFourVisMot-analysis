%% Clean workspace

clc; clear; close all

%% Load data

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_perf_all'], 'cvsi_perf_all');

%% Select fields

fn_TFR    = {'motor_load_two_fast', 'motor_load_four_fast', 'motor_load_two_slow', 'motor_load_four_slow', 'visual_load_two_fast', 'visual_load_four_fast', 'visual_load_two_slow', 'visual_load_four_slow'};
fn_time   = {'motor_beta_load_two_fast', 'motor_beta_load_four_fast', 'motor_beta_load_two_slow', 'motor_beta_load_four_slow', 'visual_alpha_load_two_fast', 'visual_alpha_load_four_fast', 'visual_alpha_load_two_slow', 'visual_alpha_load_four_slow'};

%% Time-course stat

%% Settings

cfg = [];

cfg.xax = cvsi_perf_all.time;
cfg.npermutations = 10000;
cfg.clusterStatEvalaluationAlpha = 0.05;
cfg.nsub = size(cvsi_perf_all.motor_load_two_fast, 1);
cfg.statMethod = 'montecarlo'; 

data_zero = zeros(size(cvsi_perf_all.motor_beta_load_two_fast));

%% Run

for f = 1:length(fn_time)
    stat_perf.(fn_time{f}) = frevede_ftclusterstat1D(cfg, cvsi_perf_all.(fn_time{f}), data_zero);
end

%% Zeros to NaNs in mask

for f = 1:length(fn_time)
    m = double(stat_perf.(fn_time{f}).mask);
    m(m==0) = nan;
    stat_perf.(fn_time{f}).mask = m;
end

%% TFR stat

%% Settings

cfg = [];

cfg.xax = cvsi_perf_all.time;
cfg.yax = cvsi_perf_all.freq;
cfg.npermutations = 10000; % usually use 10.000 (but less for testing)
cfg.clusterStatEvalaluationAlpha = 0.025;
cfg.statMethod = 'montecarlo';  % statcfg.statMethod = 'analytic';

data_zero = zeros(size(cvsi_perf_all.motor_load_two_fast));

%% Run

for f = 1:length(fn_TFR)
    stat_perf.(fn_TFR{f}) = frevede_ftclusterstat2D(cfg, squeeze(cvsi_perf_all.(fn_TFR{f})), squeeze(data_zero));
end

%% Save it

save([param.path, 'Processed/Locked probe/stats/' 'stat_perf'], 'stat_perf');

%% Difference stat

motor_dif_two = cvsi_perf_all.motor_beta_load_two_slow - cvsi_perf_all.motor_beta_load_two_fast;
motor_dif_four = cvsi_perf_all.motor_beta_load_four_slow - cvsi_perf_all.motor_beta_load_four_fast;
visual_dif_two = cvsi_perf_all.visual_alpha_load_two_slow - cvsi_perf_all.visual_alpha_load_two_fast;
visual_dif_four = cvsi_perf_all.visual_alpha_load_four_slow - cvsi_perf_all.visual_alpha_load_four_fast;

%% Settings

cfg = [];

cfg.xax = cvsi_perf_all.time;
cfg.npermutations = 10000;
cfg.clusterStatEvalaluationAlpha = 0.05;
cfg.nsub = size(cvsi_perf_all.motor_beta_load_two_slow, 1);
cfg.statMethod = 'montecarlo'; 

data_zero = zeros(size(cvsi_perf_all.motor_beta_load_two_slow));

%% Get

motor_stat_two = frevede_ftclusterstat1D(cfg, motor_dif_two, data_zero);
motor_stat_four = frevede_ftclusterstat1D(cfg, motor_dif_four, data_zero);

visual_stat_two = frevede_ftclusterstat1D(cfg, visual_dif_two, data_zero);
visual_stat_four = frevede_ftclusterstat1D(cfg, visual_dif_four, data_zero);

%% Mask

motor_stat_two = double(motor_stat_two.mask);
motor_stat_two(motor_stat_two==0) = nan;

motor_stat_four = double(motor_stat_four.mask);
motor_stat_four(motor_stat_four==0) = nan;

visual_stat_two = double(visual_stat_two.mask);
visual_stat_two(visual_stat_two==0) = nan;

visual_stat_four = double(visual_stat_four.mask);
visual_stat_four(visual_stat_four==0) = nan;

dif_stat_perf = {visual_stat_two, visual_stat_four, motor_stat_two, motor_stat_four};

%% Save

save([param.path, 'Processed/Locked probe/stats/' 'dif_stat_perf'], 'dif_stat_perf');

