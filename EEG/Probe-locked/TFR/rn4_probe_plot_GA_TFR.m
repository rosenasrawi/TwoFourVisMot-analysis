%% Clean workspace

clc; clear; close all

%% Load contrasts

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_probe_all'], 'mean_cvsi_probe_all');

load([param.path, 'Processed/Locked probe/stats/' 'stat_cvsi'], 'stat_cvsi');

%% Plot variables

fn = fieldnames(cvsi_probe_all);
fn = fn(contains(fn, 'load'));

probe_titles = {'Motor - load two', 'Motor - load four', 'Visual - load two', 'Visual - load four'};
load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual'};

fn_TFR = {'motor_load_two', 'motor_load_four', 'visual_load_two', 'visual_load_four'};

motor_cvsi = {'motor_beta_load_two', 'motor_beta_load_four'};
visual_cvsi = {'visual_alpha_load_two', 'visual_alpha_load_four'};

two_cvsi = {'motor_beta_load_two', 'visual_alpha_load_two'};
four_cvsi = {'motor_beta_load_four', 'visual_alpha_load_four'};

%% Add stat to datastruct

mean_cvsi_probe_all.mask_motor_load_two = stat_cvsi.motor_load_two.mask;
mean_cvsi_probe_all.mask_motor_load_four = stat_cvsi.motor_load_four.mask;
mean_cvsi_probe_all.mask_visual_load_two = stat_cvsi.visual_load_two.mask;
mean_cvsi_probe_all.mask_visual_load_four = stat_cvsi.visual_load_four.mask;

fn_mask = fieldnames(mean_cvsi_probe_all);
fn_mask = fn_mask(contains(fn_mask, 'mask'));

%% Plot TFR 

figure; 
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.zlim      = 'maxabs';
cfg.maskstyle = 'outline';

for f = 1:length(fn_TFR)

    subplot(2,2, f);

    cfg.parameter = fn_TFR{f};
    cfg.maskparameter = fn_mask{f};

    ft_singleplotTFR(cfg, mean_cvsi_probe_all);
    colormap(flipud(brewermap(100,'RdBu')));

    xline(0)  
    xlim([-0.1 1.5]); 
    xlabel('Time after probe (s)'); ylabel('Frequency (Hz)')
    title(probe_titles{f})

end    

%% Time-courses 

%% Plot motor & visual (panel = load)

figure;
sgtitle('Visual & motor selection')

time = cvsi_probe_all.time;

for i = 1:length(load_titles)

    subplot(1,2,i)

    mot = cvsi_probe_all.(motor_cvsi{i}); mot_stat = stat_cvsi.(motor_cvsi{i}).mask * -0.3;
    vis = cvsi_probe_all.(visual_cvsi{i}); vis_stat = stat_cvsi.(visual_cvsi{i}).mask * -0.5;

    frevede_errorbarplot(time, mot, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, vis, param.cols_RGB{2}, 'se');

    plot(time, mot_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{1});
    plot(time, vis_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{2});

    title(load_titles{i}); 
    xlabel('Time after probe (s)'); ylabel('CvsI power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); 
    legend('motor','','visual','','','')

end

%% Plot motor & visual (panel = class)

figure;
sgtitle('Visual & motor selection')

time = cvsi_probe_all.time;

for i = 1:length(class_titles)

    subplot(1,2,i)

    two = cvsi_probe_all.(two_cvsi{i}); two_stat = stat_cvsi.(two_cvsi{i}).mask * -0.3;
    four = cvsi_probe_all.(four_cvsi{i}); four_stat = stat_cvsi.(four_cvsi{i}).mask * -0.5;

    frevede_errorbarplot(time, two, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, four, param.cols_RGB{2}, 'se');

    plot(time, two_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{1});
    plot(time, four_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{2});

    title(class_titles{i}); 
    xlabel('time (s)'); ylabel('cvsi power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); 
    legend('two','','four','','','')

end

