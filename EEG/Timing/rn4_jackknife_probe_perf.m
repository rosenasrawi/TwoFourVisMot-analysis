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

mean_tpeak_motor = mean(tpeak_motor); % before leave-one-out
mean_tpeak_visual = mean(tpeak_visual); % before leave-one-out

nsub = length(subs);
se_tpeak_motor = sqrt((nsub-1)/nsub .* sum((tpeak_motor - mean_tpeak_motor).^2));
se_tpeak_visual = sqrt((nsub-1)/nsub .* sum((tpeak_visual - mean_tpeak_visual).^2));

%% Plot motor

figure;

subplot(1,2,1); % Load two

bar(mean_tpeak_motor(1:2), 'FaceColor', param.cols_RGB{1});
hold on;
scatter(1:2, squeeze(tpeak_motor(:,1:2)),"filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_tpeak_motor(1:2), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_tpeak_motor(1:2), se_tpeak_motor(1:2), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylim([0 0.7])
ylabel('Peak time (s)'); xlabel('Performance'); title('Load two')
set(gca,'XtickLabel', perf_titles);


subplot(1,2,2); % Load four

bar(mean_tpeak_motor(3:4), 'FaceColor', param.cols_RGB{1});
hold on;
scatter(1:2, squeeze(tpeak_motor(:,3:4)),"filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_tpeak_motor(3:4), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_tpeak_motor(3:4), se_tpeak_motor(3:4), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylim([0 0.7])
ylabel('Peak time (s)'); xlabel('Performance'); title('Load four')
set(gca,'XtickLabel', perf_titles);


set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 300]);


%% Plot visual

figure;

subplot(1,2,1); % Load two

bar(mean_tpeak_visual(1:2), 'FaceColor', param.cols_RGB{1});
hold on;
scatter(1:2, squeeze(tpeak_visual(:,1:2)),"filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_tpeak_visual(1:2), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_tpeak_visual(1:2), se_tpeak_visual(1:2), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylim([0 0.7])
ylabel('Peak time (s)'); xlabel('Performance'); title('Load two')
set(gca,'XtickLabel', perf_titles);


subplot(1,2,2); % Load four

bar(mean_tpeak_visual(3:4), 'FaceColor', param.cols_RGB{1});
hold on;
scatter(1:2, squeeze(tpeak_visual(:,3:4)),"filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_tpeak_visual(3:4), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_tpeak_visual(3:4), se_tpeak_visual(3:4), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylim([0 0.7])
ylabel('Peak time (s)'); xlabel('Performance'); title('Load four')
set(gca,'XtickLabel', perf_titles);


set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 300]);


