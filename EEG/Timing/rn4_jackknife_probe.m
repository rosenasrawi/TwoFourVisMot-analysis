%% Clear workspace

clear; close all; clc

%% Load data files

param = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_probe_all'], 'mean_cvsi_probe_all');
load([param.path, 'Processed/Locked probe/decoding/' 'decoding_all'], 'decoding_all');

%% General variables

probe_titles = {'Motor - load two', 'Motor - load four', 'Visual - load two', 'Visual - load four'};
subs = 1:25;
peakperc = {'10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'};

%% Get timecourses

time_index     = cvsi_probe_all.time >= -0.1 & cvsi_probe_all.time <= 1.5;

timecourses.time = cvsi_probe_all.time(time_index);

timecourses.motor_load_two = cvsi_probe_all.motor_beta_load_two(:,time_index);
timecourses.motor_load_four = cvsi_probe_all.motor_beta_load_four(:,time_index);

timecourses.visual_load_two = cvsi_probe_all.visual_alpha_load_two(:,time_index);
timecourses.visual_load_four = cvsi_probe_all.visual_alpha_load_four(:,time_index);

fn = fieldnames(timecourses);
fn = fn(contains(fn, 'load'));

%% Jackknife, leave one out

peaks = 0.10:0.10:0.90; peak = length(peaks)+1;

tpeak = zeros(4,peak,25);

for s = 1:25
    
    jsubs = subs;
    jsubs(s) = [];
    
    i = 1;

    for f = 1:length(fn)
    
        tc = mean(timecourses.(fn{f})(jsubs,:),1);
        tpeak(i,peak,s) = timecourses.time(find(tc == min(tc)));

        ipeak = find(timecourses.time == tpeak(i,peak,s));

        for p = 1:length(peaks)

            for t = find(timecourses.time >= 0 & timecourses.time <= tpeak(i,peak,s))

                if tc(t) <= tc(ipeak)*peaks(p)
                    tpeak(i,p,s) = timecourses.time(t);
                    break
                end
        
            end 

        end

        i = i+1;

    end

end

mean_tpeak = mean(tpeak,3); % before leave-one-out

nsub = length(subs);
se_tpeak = sqrt((nsub-1)/nsub .* sum((tpeak - mean_tpeak).^2, 3));


%% Plot

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc)/2,2,i)

    bar(mean_tpeak(:,i));
    hold on;
    scatter(1:4, squeeze(tpeak(:,i,:)), "filled", 'jitter', 'on')
    errorbar(mean_tpeak(:,i),se_tpeak(:,i), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');
    
    
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);

end

%% Latency shift with load

motor_4v2 = squeeze(tpeak(2,:,:) - tpeak(1,:,:));
mean_motor_4v2 = mean(motor_4v2,2);

visual_4v2 = squeeze(tpeak(4,:,:) - tpeak(3,:,:));
mean_visual_4v2 = mean(visual_4v2,2);

% motor diff - visual difference

se_motor_4v2 = sqrt((nsub-1)/nsub .* sum((motor_4v2 - mean_motor_4v2).^2, 2));
se_visual_4v2 = sqrt((nsub-1)/nsub .* sum((visual_4v2 - mean_visual_4v2).^2, 2));


%% 50% plot Motor

figure;

bar(mean_tpeak(1:2,5), 'FaceColor', param.cols_RGB{1});
hold on;
scatter(1:2, squeeze(tpeak(1:2,5,:)),"filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_tpeak(1:2,5), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_tpeak(1:2,5),se_tpeak(1:2,5), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylim([0 0.7])
ylabel('Peak time (s)'); xlabel('Condition'); title('50% peak')
set(gca,'XtickLabel', probe_titles(1:2));

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 500 300]);


%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-motor-50'], 'epsc');

%% Latency shift

figure;

bar(mean_motor_4v2(5), 'FaceColor',param.cols_RGB{1});
hold on;
scatter(1,motor_4v2(5,:), "filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_motor_4v2(5), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_motor_4v2(5), se_motor_4v2(5), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylabel('Peak time difference (s)'); xlabel('Condition'); title('Motor latency shift')
set(gca,'XtickLabel', peakperc);
ylim([0 0.3])

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 250 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-motor-50-diff'], 'epsc');

%% 50% plot visual

figure;

bar(mean_tpeak(3:4,5), 'FaceColor', param.cols_RGB{2});
hold on;
scatter(1:2, squeeze(tpeak(3:4,5,:)),"filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{2}, 'MarkerEdgeColor', 'black')
plot(mean_tpeak(3:4,5), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_tpeak(3:4,5),se_tpeak(3:4,5), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylim([0 0.7])
ylabel('Peak time (s)'); xlabel('Condition'); title('50% peak')
set(gca,'XtickLabel', probe_titles(3:4));

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 500 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-visual-50'], 'epsc');

%% Latency shift

figure;

bar(mean_visual_4v2(5), 'FaceColor',param.cols_RGB{2});
hold on;
scatter(1,visual_4v2(5,:), "filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{2}, 'MarkerEdgeColor', 'black')
plot(mean_visual_4v2(5), 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_visual_4v2(5), se_visual_4v2(5), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylabel('Peak time difference (s)'); xlabel('Condition'); title('Visual latency shift')
set(gca,'XtickLabel', peakperc);
ylim([0 0.3])

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 250 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-visual-50-diff'], 'epsc');

%% Motor shift

figure;

bar(mean_motor_4v2, 'FaceColor',param.cols_RGB{1});
hold on;
scatter(1:10, motor_4v2, "filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_motor_4v2, 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_motor_4v2, se_motor_4v2, 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylabel('Peak time (s)'); xlabel('Condition'); title('Motor latency shift')
set(gca,'XtickLabel', peakperc);
ylim([-0.1 0.5])

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 500 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-motor-shift'], 'epsc');

%% Visual shift

figure;

bar(mean_visual_4v2, 'FaceColor',param.cols_RGB{2});
hold on;
scatter(1:10, visual_4v2, "filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{2}, 'MarkerEdgeColor', 'black')
plot(mean_visual_4v2, 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_visual_4v2, se_visual_4v2, 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylabel('Peak time (s)'); xlabel('Condition'); title('Visual latency shift')
set(gca,'XtickLabel', peakperc);
ylim([-0.1 0.5])

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 500 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-visual-shift'], 'epsc');

%% Test significance

df = nsub - 1;

t_mot = mean_motor_4v2 ./ se_motor_4v2;
pval_mot = (1-tcdf(abs(t_mot),df))*2;

t_vis = mean_visual_4v2 ./ se_visual_4v2;
pval_vis = (1-tcdf(abs(t_vis),df))*2;


%% Parallel visual/motor

two_vismot = squeeze(tpeak(1,:,:) - tpeak(3,:,:));
mean_two_vismot = mean(two_vismot,2);

four_vismot = squeeze(tpeak(2,:,:) - tpeak(4,:,:));
mean_four_vismot = mean(four_vismot,2);

se_two_vismot = sqrt((nsub-1)/nsub .* sum((two_vismot - mean_two_vismot).^2, 2));
se_four_vismot = sqrt((nsub-1)/nsub .* sum((four_vismot - mean_four_vismot).^2, 2));

%% Load two

figure;

bar(mean_two_vismot, 'FaceColor',param.cols_RGB{1});
hold on;
scatter(1:10, two_vismot, "filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{1}, 'MarkerEdgeColor', 'black')
plot(mean_two_vismot, 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_two_vismot, se_two_vismot, 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylabel('Peak time (s)'); xlabel('Condition'); title('Load two')
set(gca,'XtickLabel', peakperc);
ylim([-0.2 0.6])

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 500 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-two-shift'], 'epsc');

%% Load four

figure;

bar(mean_four_vismot, 'FaceColor',param.cols_RGB{2});
hold on;
scatter(1:10, four_vismot, "filled", 'jitter', 'on', 'MarkerFaceColor', param.cols_RGB{2}, 'MarkerEdgeColor', 'black')
plot(mean_four_vismot, 'linestyle','none','marker','o', 'MarkerFaceColor', 'black', 'MarkerSize',7);
errorbar(mean_four_vismot, se_four_vismot, 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');

ylabel('Peak time (s)'); xlabel('Condition'); title('Load four')
set(gca,'XtickLabel', peakperc);
ylim([-0.2 0.6])

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 500 300]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/jackknife-four-shift'], 'epsc');

%% Test significance

df = nsub - 1;

t_two = mean_two_vismot ./ se_two_vismot;
pval_two = (1-tcdf(abs(t_two),df))*2;

t_four = mean_four_vismot ./ se_four_vismot;
pval_four = (1-tcdf(abs(t_four),df))*2;

%% Decoding

fn = fieldnames(decoding_all);
fn = fn(contains(fn, 'correct'));
fn = fn(~contains(fn, 'tilt'));

time_index     = decoding_all.time >= -100 & decoding_all.time <= 1500;

for f = 1:length(fn)
    decoding_all.(fn{f}) = decoding_all.(fn{f})(:,time_index);
end

%% Jackknife, leave one out

peaks = 0.25:0.25:0.75; peak = length(peaks)+1;
tpeak = zeros(4,peak,25);

for s = 1:25
    
    jsubs = subs;
    jsubs(s) = [];
    
    i = 1;

    for f = [1,3,2,4]
    
        tc = mean(decoding_all.(fn{f})(jsubs,:),1);
        tpeak(i,peak,s) = decoding_all.time(find(tc == max(tc)));
        ipeak = find(decoding_all.time == tpeak(i,peak,s));

        for p = 1:length(peaks)

            for t = find(decoding_all.time >= 0 & decoding_all.time <= tpeak(i,peak,s))

                if tc(t) >= 0.5 + (tc(ipeak)-0.5) * peaks(p)
                    tpeak(i,p,s) = decoding_all.time(t);
                    break
                end
        
            end 

        end

        i = i+1;

    end

end

mean_tpeak = mean(tpeak,3);
se_tpeak = std(tpeak,[],3)/sqrt(size(tpeak,3));

%% Plot

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(mean_tpeak(:,i));
    hold on;
    scatter(1:4, squeeze(tpeak(:,i,:)), "filled", 'jitter', 'on')
    errorbar(mean_tpeak(:,i),se_tpeak(:,i), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');
    
    
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);

end

%% Plot peak moment (grand average)

%% On TFR

tpeak = zeros(4,2); i = 1;

for f = 1:length(fn)
    tc = mean(timecourses.(fn{f}),1);
    tpeak(i,1) = timecourses.time(find(tc == min(tc)));

    ipeak = find(timecourses.time == tpeak(i,1));
  
    for t = find(timecourses.time >= 0 & timecourses.time <= tpeak(i))

        if tc(t) <= tc(ipeak)*0.50
            tpeak(i,2) = timecourses.time(t);
            break
        end

    end    
    i = i+1;
end

%% Plot

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(tpeak(:,i));
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);
    ylim(ylims{i})

end

%% On decoding

tpeak = zeros(4,2); i = 1;

for f = [1,3,2,4] % ordered differently here...

    tc = mean(decoding_all.(fn{f}),1);
    tpeak(i,1) = decoding_all.time(find(tc == max(tc)));
    ipeak = find(decoding_all.time == tpeak(i,1));
    
    for t = find(decoding_all.time >= 0 & decoding_all.time <= tpeak(i,1))

        if tc(t) >= 0.5 + (tc(ipeak)-0.5) * 0.50
            tpeak(i,2) = decoding_all.time(t);
            break
        end

    end    

    i = i+1;

end

%% Plot

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(tpeak(:,i));
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);
    ylim(ylims{i})

end





