%% Clean workspace

clc; clear; close all

%% Load contrasts

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_probe_all'], 'mean_cvsi_probe_all');

load([param.path, 'Processed/Locked probe/stats/' 'stat_cvsi'], 'stat_cvsi');
load([param.path, 'Processed/Locked probe/jackknife/' 'jk_cvsi'], 'jk_cvsi');

load([param.path, 'Processed/Locked probe/stats/' 'dif_stat'], 'dif_stat');

%% Plot variables

load_titles = {'Load two', 'Load four'};
class_titles = {'Visual', 'Motor'};
probe_titles = {'Visual (two)', 'Motor (two)', 'Visual (four)', 'Motor (four)'};

fn_TFR = {'visual_load_two', 'motor_load_two', 'visual_load_four', 'motor_load_four'};
fn_time = {'motor_beta_load_two', 'motor_beta_load_four', 'visual_alpha_load_two', 'visual_alpha_load_four'};

time = cvsi_probe_all.time;

LOAD = {'two', 'four'};
i_load = {3:4, 1:2};

%% Add TFR mask

for f = fn_TFR
    mean_cvsi_probe_all.(append('mask_', f{1})) = stat_cvsi.(f{1}).mask;
end

%% Plot TFR 

figure; 
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'yes';
cfg.zlim      = 'maxabs';
cfg.maskstyle = 'outline';

for f = 1:length(fn_TFR)

    subplot(2,2, f);

    cfg.parameter = fn_TFR{f};
    cfg.maskparameter = append('mask_', fn_TFR{f});

    ft_singleplotTFR(cfg, mean_cvsi_probe_all);
    colormap(flipud(brewermap(100,'RdBu')));

    xline(0)  
    xlim([-0.1 1.5]); 
    xlabel('Time after probe (s)'); ylabel('Frequency (Hz)')
    title(probe_titles{f})

end    

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 500]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/cvsi/TFR-visual-motor'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/TFR-visual-motor'], 'png');

%% Time-courses 

%% Plot motor & visual (panel = class)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(class_titles)

    subplot(1,2,i)

    two = fn_time{i_load{i}(1)}; four = fn_time{i_load{i}(2)};

    two_dat = cvsi_probe_all.(two); two_stat = stat_cvsi.(two).mask * 2;
    four_dat = cvsi_probe_all.(four); four_stat = stat_cvsi.(four).mask * 2.5;

    frevede_errorbarplot(time, two_dat, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, four_dat, param.cols_RGB{2}, 'se');

    plot(time, two_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{1});
    plot(time, four_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{2});
    plot(time, dif_stat{i}*3, 'k', 'LineWidth', 2, 'Color', '#999999');

    title(class_titles{i}); 
    xlabel('time (s)'); ylabel('cvsi power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-12 8])
    legend('Two','','Four','','','')

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 250]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/cvsi/TC-visual-motor'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/TC-visual-motor'], 'png');

%% Jackknife

figure; 

for i = 1:2

    subplot(1,2,i); 

    errorbar(jk_cvsi.mean_load(i_load{i}(1)), 2, jk_cvsi.se_load(i_load{i}(1)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{1})
    hold on
    errorbar(jk_cvsi.mean_load(i_load{i}(2)), 1, jk_cvsi.se_load(i_load{i}(2)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{2})

    xlim([-0.1 1.5]); ylim([0 3]);
    xline(0, '--k')
     
    yticks([1,2]); yticklabels({'Four','Two'})
    xlabel('Peak time (s)');
end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 80]);

%% Save fig

saveas(gcf, [param.figpath '/TFR/cvsi/JK-visual-motor'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/JK-visual-motor'], 'png');



%% Plot motor & visual load difference

figure;
sgtitle('Visual & motor selection')

for i = 1:length(class_titles)

    subplot(1,2,i)

    two = fn_time{i_load{i}(1)}; four = fn_time{i_load{i}(2)};

    two_dat = cvsi_probe_all.(two); two_stat = stat_cvsi.(two).mask * 2;
    four_dat = cvsi_probe_all.(four); four_stat = stat_cvsi.(four).mask * 2.5;

    frevede_errorbarplot(time, two_dat-four_dat, param.cols_RGB{3}, 'se');

    title(class_titles{i}); 
    xlabel('time (s)'); ylabel('cvsi power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-12 8])

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 250]);

