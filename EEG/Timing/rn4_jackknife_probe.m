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

nsub = length(subs); df = nsub - 1;

mot_fourtwo = squeeze(tpeak_cvsi(:,2) - tpeak_cvsi(:,1));
mean_mot_fourtwo = mean(mot_fourtwo);
se_mot_fourtwo = sqrt((nsub-1)/nsub .* sum((mot_fourtwo - mean_mot_fourtwo).^2));

vis_fourtwo = squeeze(tpeak_cvsi(:,4) - tpeak_cvsi(:,3));
mean_vis_fourtwo = mean(vis_fourtwo);
se_vis_fourtwo = sqrt((nsub-1)/nsub .* sum((vis_fourtwo - mean_vis_fourtwo).^2));

t_mot = mean_mot_fourtwo ./ se_mot_fourtwo;
p_mot = (1-tcdf(abs(t_mot),df))*2;

t_vis = mean_vis_fourtwo ./ se_vis_fourtwo;
p_vis = (1-tcdf(abs(t_vis),df))*2;

%% Data structure

jk_cvsi.load        = tpeak_cvsi;

jk_cvsi.mean_load   = mean(tpeak_cvsi);
jk_cvsi.se_load     = sqrt((nsub-1)/nsub .* sum((tpeak_cvsi - mean(tpeak_cvsi)).^2)); 

jk_cvsi.p_mot       = p_mot;
jk_cvsi.p_vis       = p_vis;

%% Save

save([param.path, 'Processed/Locked probe/jackknife/' 'jk_cvsi'], 'jk_cvsi');


