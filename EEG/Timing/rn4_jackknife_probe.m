%% Clear workspace

clear; close all; clc

%% Load data files

param = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_probe_all'], 'mean_cvsi_probe_all');

%% Get time-courses

time_index = cvsi_probe_all.time >= -0.1 & cvsi_probe_all.time <= 1.5;

cvsi_tc = {'motor_beta_load_two', 'motor_beta_load_four', 'visual_alpha_load_two', 'visual_alpha_load_four'};

perf_titles = {'Two', 'Four'};


%% Jackknife

subs = 1:25;
tpeak_cvsi = zeros(25,4);

for s = subs
    
    jsub = subs; jsub(s) = []; % leave one sub out

    for m = 1:length(cvsi_tc) % MOTOR

        tc = mean(cvsi_probe_all.(cvsi_tc{m})(jsub,:),1);
        
        tpeak = cvsi_probe_all.time(find(tc == min(tc)));
        ipeak = find(cvsi_probe_all.time == tpeak);

        for t = find(cvsi_probe_all.time >= 0 & cvsi_probe_all.time <= tpeak)
            if tc(t) <= tc(ipeak) * 0.5
                tpeak_cvsi(s,m) = cvsi_probe_all.time(t);
                break
            end
    
        end

    end

end

%% Stats

nsub = length(subs);
mot_two = tpeak_cvsi(:,1); mot_four = tpeak_cvsi(:,2);
vis_two = tpeak_cvsi(:,3); vis_four = tpeak_cvsi(:,4);

mot_dif = squeeze(mot_four - mot_two);
vis_dif = squeeze(vis_four - vis_two);

mot = ttest_jk(mot_two, mot_four, nsub)

vis = ttest_jk(vis_two, vis_four, nsub)

vis_mot = ttest_jk(vis_dif, mot_dif, nsub)

%% Data structure

jk_cvsi.load        = tpeak_cvsi;

jk_cvsi.mean_load   = mean(tpeak_cvsi);
jk_cvsi.se_load     = sqrt((nsub-1)/nsub .* sum((tpeak_cvsi - mean(tpeak_cvsi)).^2)); 

jk_cvsi.p_mot       = mot.p;
jk_cvsi.p_vis       = vis.p;

%% Save

save([param.path, 'Processed/Locked probe/jackknife/' 'jk_cvsi'], 'jk_cvsi');

writematrix(tpeak_cvsi, [param.path, 'Processed/Locked probe/jackknife/' 'jk_est_vis_mot'])


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



