%% Clean workspace

clc; clear; close all

%% Load contrasts

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_perf_all'], 'cvsi_perf_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_perf_all'], 'mean_cvsi_perf_all');
load([param.path, 'Processed/Locked probe/jackknife/' 'jk_perf'], 'jk_perf');

%% Plot variables

load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual'};

time = cvsi_perf_all.time;

DT = {'fast', 'slow'};
ERR = {'prec', 'imprec'};
LOAD = {'two', 'four'};
i_load = {1:2, 3:4};

%% Plot time-courses

%% Motor: fast vs slow

figure;
sgtitle('Motor selection: fast vs slow')

for i = 1:length(load_titles)

    subplot(1,2,i)

    fast = cvsi_perf_all.(append('motor_beta_load_', LOAD{i}, '_fast'));
    slow = cvsi_perf_all.(append('motor_beta_load_', LOAD{i}, '_slow'));

    frevede_errorbarplot(time, fast, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow, param.cols_RGB{2}, 'se');
    
    xline(jk_perf.mean_motor(i_load{i}(1)), 'Color', param.cols_RGB{1}, 'LineWidth', 1)
    xline(jk_perf.mean_motor(i_load{i}(2)), 'Color', param.cols_RGB{2}, 'LineWidth', 1)

    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-14 8])
    legend('Fast','','Slow','','','')

end

set(gcf, "Position", [500 500 800 250]);

%% Jackknife motor

figure; 

i_load = {1:2, 3:4};

for i = 1:2

    subplot(1,2,i); 

    errorbar(jk_perf.mean_motor(i_load{i}(1)), 2, jk_perf.se_motor(i_load{i}(1)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{1})
    hold on
    errorbar(jk_perf.mean_motor(i_load{i}(2)), 1, jk_perf.se_motor(i_load{i}(2)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{2})

    xlim([-0.1 1.5]); ylim([0 3]);
    xline(0, '--k')
     
    yticks([1,2]); yticklabels({'Slow','Fast'})
    xlabel('Peak time (s)');
end

set(gcf, "Position", [500 500 800 80]);

%% Visual: fast vs slow

figure;
sgtitle('Visual selection: fast vs slow')

for i = 1:length(load_titles)

    subplot(1,2,i)

    fast = cvsi_perf_all.(append('visual_alpha_load_', LOAD{i}, '_fast'));
    slow = cvsi_perf_all.(append('visual_alpha_load_', LOAD{i}, '_slow'));

    frevede_errorbarplot(time, fast, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow, param.cols_RGB{2}, 'se');
    
    xline(jk_perf.mean_visual(i_load{i}(1)), 'Color', param.cols_RGB{1}, 'LineWidth', 1)
    xline(jk_perf.mean_visual(i_load{i}(2)), 'Color', param.cols_RGB{2}, 'LineWidth', 1)

    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-14 8])
    legend('Fast','','Slow','','','')

end

set(gcf, "Position", [500 500 800 250]);

%% Jackknife visual

figure; 

i_load = {1:2, 3:4};

for i = 1:2

    subplot(1,2,i); 

    errorbar(jk_perf.mean_visual(i_load{i}(1)), 1, jk_perf.se_visual(i_load{i}(1)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{1})
    hold on
    errorbar(jk_perf.mean_visual(i_load{i}(2)), 2, jk_perf.se_visual(i_load{i}(2)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{2})

    xlim([-0.1 1.5]); ylim([0 3]);
    xline(0, '--k')
     
    yticks([1,2]); yticklabels({'Fast','Slow'})
    xlabel('Peak time (s)');
end

set(gcf, "Position", [500 500 800 100]);

%% Motor: prec vs imprec

figure;
sgtitle('Motor selection: precision')

for i = 1:length(load_titles)

    subplot(1,2,i)

    fast = cvsi_perf_all.(append('motor_beta_load_', LOAD{i}, '_prec'));
    slow = cvsi_perf_all.(append('motor_beta_load_', LOAD{i}, '_imprec'));

    frevede_errorbarplot(time, fast, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow, param.cols_RGB{2}, 'se');
    
    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-14 8])
    legend('Precise','','Imprecise','','','')

end

set(gcf, "Position", [500 500 800 250]);

%% Visual: prec vs imprec

figure;
sgtitle('Visual selection: precision')

for i = 1:length(load_titles)

    subplot(1,2,i)

    fast = cvsi_perf_all.(append('visual_alpha_load_', LOAD{i}, '_prec'));
    slow = cvsi_perf_all.(append('visual_alpha_load_', LOAD{i}, '_imprec'));

    frevede_errorbarplot(time, fast, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow, param.cols_RGB{2}, 'se');
    
    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-14 8])
    legend('Fast','','Slow','','','')

end

set(gcf, "Position", [500 500 800 250]);

%% Quick plot TFR

%% Fast vs slow

titles = {'Load two - fast', 'Load four - fast', 'Load two - slow', 'Load four - slow'};

% Motor

plot_TFR_perf(fn, mean_cvsi_perf_all, ...
              'motor', 'fast', 'slow', ...
              'maxabs', titles)

% Visual

plot_TFR_perf(fn, mean_cvsi_perf_all, ...
              'visual', 'fast', 'slow', ...
              'maxabs', titles)

%% Prec vs imprec

titles = {'Load two - prec', 'Load four - prec', 'Load two - imprec', 'Load four - imprec'};

% Motor

plot_TFR_perf(fn, mean_cvsi_perf_all, ...
              'motor', 'prec', 'imprec', ...
              'maxabs', titles)

% Visual

plot_TFR_perf(fn, mean_cvsi_perf_all, ...
              'visual', 'prec', 'imprec', ...
              'maxabs', titles)


%% TFR plot

function plot_TFR_perf(fn, cvsi, mod, perf1, perf2, zlim, titles)
    
    fn_mod = fn(contains(fn, mod) & (contains(fn, perf1) | contains(fn, perf2)));

    figure; 
    cfg = [];
    
    cfg.figure    = "gcf";
    cfg.channel   = 'C3';
    cfg.colorbar  = 'yes';
    cfg.zlim      = zlim;
    
    for f = 1:length(fn_mod)
    
        subplot(2,2, f);
    
        cfg.parameter = fn_mod{f};
    
        ft_singleplotTFR(cfg, cvsi);
        colormap(flipud(brewermap(100,'RdBu')));
    
        xline(0)  
        xlim([-0.1 1.5]); 
        xlabel('Time after probe (s)'); ylabel('Frequency (Hz)')
        title(titles{f})

    end

end
