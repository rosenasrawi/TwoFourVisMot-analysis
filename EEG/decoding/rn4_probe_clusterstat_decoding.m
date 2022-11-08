%% Clean workspace

clc; clear; close all

%% Load data

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/decoding/' 'decoding_all'], 'decoding_all');

%% Clusterstat settings

cfg = [];

cfg.xax = decoding_all.time;
cfg.npermutations = 10000;
cfg.clusterStatEvalaluationAlpha = 0.05;
cfg.nsub = size(decoding_all.motor_correct_two, 1);
cfg.statMethod = 'montecarlo'; 

%% Other parameters

data_zero = zeros(size(decoding_all.motor_correct_two));
data_point5 = data_zero; data_point5(data_zero == 0) = 0.5;

fn = fieldnames(decoding_all);
fn = fn(~contains(fn, 'time'));

fn_corr = fn(contains(fn, 'correct'));
fn_dist = fn(contains(fn, 'distance'));

%% Run stats voor all timecourses

for f = 1:length(fn_corr)

    stat_decoding.(fn_corr{f})    = frevede_ftclusterstat1D(cfg, decoding_all.(fn_corr{f}), data_point5);
    stat_decoding.(fn_dist{f})    = frevede_ftclusterstat1D(cfg, decoding_all.(fn_dist{f}), data_zero);

end

%% Change zeros to nans in mask

for f = 1:length(fn)
    m = double(stat_decoding.(fn{f}).mask);
    m(m==0) = nan;
    stat_decoding.(fn{f}).mask = m;
end

%% Save

save([param.path, 'Processed/Locked probe/stats/' 'stat_decoding'], 'stat_decoding');
