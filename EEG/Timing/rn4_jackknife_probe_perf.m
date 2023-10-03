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

nsub = length(subs); df = nsub - 1;

two_mot_fastslow = squeeze(tpeak_motor(:,2) - tpeak_motor(:,1));
mean_two_mot_fastslow = mean(two_mot_fastslow);
se_two_mot_fastslow = sqrt((nsub-1)/nsub .* sum((two_mot_fastslow - mean_two_mot_fastslow).^2));

four_mot_fastslow = squeeze(tpeak_motor(:,4) - tpeak_motor(:,3));
mean_four_mot_fastslow = mean(four_mot_fastslow);
se_four_mot_fastslow = sqrt((nsub-1)/nsub .* sum((four_mot_fastslow - mean_four_mot_fastslow).^2));

two_vis_fastslow = squeeze(tpeak_visual(:,2) - tpeak_visual(:,1));
mean_two_vis_fastslow = mean(two_vis_fastslow);
se_two_vis_fastslow = sqrt((nsub-1)/nsub .* sum((two_vis_fastslow - mean_two_vis_fastslow).^2));

four_vis_fastslow = squeeze(tpeak_visual(:,4) - tpeak_visual(:,3));
mean_four_vis_fastslow = mean(four_vis_fastslow);
se_four_vis_fastslow = sqrt((nsub-1)/nsub .* sum((four_vis_fastslow - mean_four_vis_fastslow).^2));

t_two_mot = mean_two_mot_fastslow ./ se_two_mot_fastslow;
p_two_mot = (1-tcdf(abs(t_two_mot),df))*2;

t_four_mot = mean_four_mot_fastslow ./ se_four_mot_fastslow;
p_four_mot = (1-tcdf(abs(t_four_mot),df))*2;

t_two_vis = mean_two_vis_fastslow ./ se_two_vis_fastslow;
p_two_vis = (1-tcdf(abs(t_two_vis),df))*2;

t_four_vis = mean_four_vis_fastslow ./ se_four_vis_fastslow;
p_four_vis = (1-tcdf(abs(t_four_vis),df))*2;

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
