%% Clean workspace

clc; clear; close all

%% Load contrasts

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_perf_all'], 'cvsi_perf_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_perf_all'], 'mean_cvsi_perf_all');

load([param.path, 'Processed/Locked probe/stats/' 'stat_perf'], 'stat_perf');
load([param.path, 'Processed/Locked probe/jackknife/' 'jk_perf'], 'jk_perf');

%% Plot variables

load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual'};
fn = fieldnames(mean_cvsi_perf_all);

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

    fast = append('motor_beta_load_', LOAD{i}, '_fast'); slow = append('motor_beta_load_', LOAD{i}, '_slow');
    
    fast_dat = cvsi_perf_all.(fast); fast_stat = stat_perf.(fast).mask * 2;
    slow_dat = cvsi_perf_all.(slow); slow_stat = stat_perf.(slow).mask * 2.5;
    
    frevede_errorbarplot(time, fast_dat, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow_dat, param.cols_RGB{2}, 'se');
    
    plot(time, fast_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{1});
    plot(time, slow_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{2});

    xline(jk_perf.mean_motor(i_load{i}(1)), '--', 'Color', param.cols_RGB{1}, 'LineWidth', 1)
    xline(jk_perf.mean_motor(i_load{i}(2)), '--', 'Color', param.cols_RGB{2}, 'LineWidth', 1)

    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-14 8])
    legend('Fast','','Slow','','','')

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 250]);

%% Save

saveas(gcf, [param.figpath '/TFR/cvsi-perf/TC-motor-fastslow'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi-perf/TC-motor-fastslow'], 'png');

%% Jackknife motor

figure; 

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

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 80]);

%% Save

saveas(gcf, [param.figpath '/TFR/cvsi-perf/JK-motor-fastslow'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi-perf/JK-motor-fastslow'], 'png');

%% Visual: fast vs slow

figure;
sgtitle('Visual selection: fast vs slow')

for i = 1:length(load_titles)

    subplot(1,2,i)

    fast = append('visual_alpha_load_', LOAD{i}, '_fast'); slow = append('visual_alpha_load_', LOAD{i}, '_slow');
    
    fast_dat = cvsi_perf_all.(fast); fast_stat = stat_perf.(fast).mask * 2;
    slow_dat = cvsi_perf_all.(slow); slow_stat = stat_perf.(slow).mask * 2.5;
    
    frevede_errorbarplot(time, fast_dat, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow_dat, param.cols_RGB{2}, 'se');
    
    plot(time, fast_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{1});
    plot(time, slow_stat, 'k', 'LineWidth', 2, 'Color', param.cols_RGB{2});

    xline(jk_perf.mean_visual(i_load{i}(1)), '--', 'Color', param.cols_RGB{1}, 'LineWidth', 1)
    xline(jk_perf.mean_visual(i_load{i}(2)), '--', 'Color', param.cols_RGB{2}, 'LineWidth', 1)

    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); ylim([-14 8])
    legend('Fast','','Slow','','','')

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 250]);

%% Save

saveas(gcf, [param.figpath '/TFR/cvsi-perf/TC-visual-fastslow'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi-perf/TC-visual-fastslow'], 'png');

%% Jackknife visual

figure; 

for i = 1:2

    subplot(1,2,i); 

    errorbar(jk_perf.mean_visual(i_load{i}(1)), 2, jk_perf.se_visual(i_load{i}(1)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{1})
    hold on
    errorbar(jk_perf.mean_visual(i_load{i}(2)), 1, jk_perf.se_visual(i_load{i}(2)), ...
             'horizontal', '.', 'CapSize',8, 'LineWidth', 1.5, 'MarkerSize', 15, 'Color', param.cols_RGB{2})

    xlim([-0.1 1.5]); ylim([0 3]);
    xline(0, '--k')
     
    yticks([1,2]); yticklabels({'Slow','Fast'})
    xlabel('Peak time (s)');
end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 100]);

%% Save

saveas(gcf, [param.figpath '/TFR/cvsi-perf/JK-visual-fastslow'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi-perf/JK-visual-fastslow'], 'png');

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

set(gcf, "renderer", "Painters");
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

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 250]);

%% Quick plot TFR

%% Fast vs slow

titles = {'Load two - fast', 'Load four - fast', 'Load two - slow', 'Load four - slow'};

% Motor

plot_TFR_perf(fn, mean_cvsi_perf_all, stat_perf, ...
              'motor', 'fast', 'slow', ...
              'maxabs', titles)

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 500]);

saveas(gcf, [param.figpath '/TFR/cvsi-perf/TFR-motor-fastslow'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi-perf/TFR-motor-fastslow'], 'png');

% Visual

plot_TFR_perf(fn, mean_cvsi_perf_all, stat_perf, ...
              'visual', 'fast', 'slow', ...
              'maxabs', titles)

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 800 500]);

saveas(gcf, [param.figpath '/TFR/cvsi-perf/TFR-visual-fastslow'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi-perf/TFR-visual-fastslow'], 'png');

%% Prec vs imprec

titles = {'Load two - prec', 'Load four - prec', 'Load two - imprec', 'Load four - imprec'};

% Motor

plot_TFR_perf(fn, mean_cvsi_perf_all, nan, ...
              'motor', 'prec', 'imprec', ...
              'maxabs', titles)

% Visual

plot_TFR_perf(fn, mean_cvsi_perf_all, nan, ...
              'visual', 'prec', 'imprec', ...
              'maxabs', titles)


%% TFR plot

function plot_TFR_perf(fn, cvsi, stat, mod, perf1, perf2, zlim, titles)
    
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

        if class(stat) == 'struct'
            cfg.maskstyle = 'outline';
            f_mask = append('mask_', fn_mod{f});
            cvsi.(f_mask) = stat.(fn_mod{f}).mask;
            cfg.maskparameter = f_mask;
        end

        ft_singleplotTFR(cfg, cvsi);
        colormap(flipud(brewermap(100,'RdBu')));
    
        xline(0)  
        xlim([-0.1 1.5]); 
        xlabel('Time after probe (s)'); ylabel('Frequency (Hz)')
        title(titles{f})

    end

end
