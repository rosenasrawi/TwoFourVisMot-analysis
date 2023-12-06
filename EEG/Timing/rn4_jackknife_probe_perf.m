%% Clear workspace

clear; close all; clc

%% Load data files

param = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_perf_all'], 'cvsi_perf_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_perf_all'], 'mean_cvsi_perf_all');

%% Get timecourses

time_index = cvsi_perf_all.time >= -0.1 & cvsi_perf_all.time <= 1.5;

motor_tc = {'motor_beta_load_two_fast', 'motor_beta_load_two_slow', 'motor_beta_load_four_fast', 'motor_beta_load_four_slow'};
visual_tc = {'visual_alpha_load_two_fast', 'visual_alpha_load_two_slow', 'visual_alpha_load_four_fast', 'visual_alpha_load_four_slow'};

perf_titles = {'Fast', 'Slow'};

%% Jackknife

subs = 1:25;
tpeak_motor = zeros(25,4);
tpeak_visual = zeros(25,4);

for s = subs
    
    jsub = subs; jsub(s) = []; % leave one sub out

    for m = 1:length(motor_tc) % MOTOR

        tc = mean(cvsi_perf_all.(motor_tc{m})(jsub,:),1);
        
        tpeak = cvsi_perf_all.time(find(tc == min(tc)));
        ipeak = find(cvsi_perf_all.time == tpeak);

        for t = find(cvsi_perf_all.time >= 0 & cvsi_perf_all.time <= tpeak)
            if tc(t) <= tc(ipeak) * 0.5
                tpeak_motor(s,m) = cvsi_perf_all.time(t);
                break
            end
    
        end

    end

    for v = 1:length(visual_tc) % VISUAL

        tc = mean(cvsi_perf_all.(visual_tc{v})(jsub,:),1);
        
        tpeak = cvsi_perf_all.time(find(tc == min(tc)));
        ipeak = find(cvsi_perf_all.time == tpeak);

        for t = find(cvsi_perf_all.time >= 0 & cvsi_perf_all.time <= tpeak)
            if tc(t) <= tc(ipeak) * 0.5
                tpeak_visual(s,v) = cvsi_perf_all.time(t);
                break
            end
    
        end

    end

end

%% Stats

nsub = length(subs);

mot_two_slow = tpeak_motor(:,1); mot_two_fast = tpeak_motor(:,2); 
mot_four_slow = tpeak_motor(:,3); mot_four_fast = tpeak_motor(:,4);


vis_two_slow = tpeak_visual(:,1); vis_two_fast = tpeak_visual(:,2); 
vis_four_slow = tpeak_visual(:,3); vis_four_fast = tpeak_visual(:,4);

mot_two = ttest_jk(mot_two_slow, mot_two_fast, nsub)
mot_four = ttest_jk(mot_four_slow, mot_four_fast, nsub)

vis_two = ttest_jk(vis_two_slow, vis_two_fast, nsub)
vis_four = ttest_jk(vis_four_slow, vis_four_fast, nsub)

mot_dif = ttest_jk(squeeze(mot_two_fast-mot_two_slow), squeeze(mot_four_fast-mot_four_slow), nsub)

vis_dif = ttest_jk(squeeze(vis_two_fast-vis_two_slow), squeeze(vis_four_fast-vis_four_slow), nsub)


%% Data structure

jk_perf.motor         = tpeak_motor;
jk_perf.visual        = tpeak_visual;

jk_perf.mean_motor    = mean(tpeak_motor);
jk_perf.mean_visual   = mean(tpeak_visual);
jk_perf.se_motor      = sqrt((nsub-1)/nsub .* sum((tpeak_motor - mean(tpeak_motor)).^2)); 
jk_perf.se_visual     = sqrt((nsub-1)/nsub .* sum((tpeak_visual - mean(tpeak_visual)).^2)); 

jk_perf.p_two_mot     = p_two_mot;
jk_perf.p_four_mot    = p_four_mot;
jk_perf.p_two_vis     = p_two_vis;
jk_perf.p_four_vis    = p_four_vis;

%% Save

save([param.path, 'Processed/Locked probe/jackknife/' 'jk_perf'], 'jk_perf');

%% Jackknife ttest function

function stat = ttest_jk(cond1, cond2, nsub)

    df = nsub-1;
    
    diff = squeeze(cond2 - cond1);
    avg = mean(diff);
    se = sqrt((nsub-1)/nsub .* sum((diff - avg).^2));

    stat.t = avg ./ se;
    stat.p = (1-tcdf(abs(stat.t),df))*2;
    stat.m = avg;
    stat.se = se;
    stat.dz = stat.t /nsub;

end

