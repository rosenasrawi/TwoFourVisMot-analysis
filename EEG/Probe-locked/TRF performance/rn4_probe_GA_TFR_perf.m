%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    [param, eegfiles] = rn4_gen_param(this_subject);

    %% Load

    load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_perf_s' num2str(this_subject)], 'cvsi_perf');

    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_perf_all = selectfields(cvsi_perf, {'label', 'time', 'freq', 'dimord'});
        cvsi_perf_all.label = {'C3'}; % CVSI, so only one channel per contrast
    end

    fn = fieldnames(cvsi_perf);
    fn = fn(contains(fn, 'load'));

    for f = 1:length(fn)
        cvsi_perf_all.(fn{f})(this_subject,:,:,:) = cvsi_perf.(fn{f}); 
    end

end

%% Average

mean_cvsi_perf_all = selectfields(cvsi_perf_all, {'label', 'time', 'freq', 'dimord'});

for f = 1:length(fn)
    c = squeeze(mean(cvsi_perf_all.(fn{f})));
    s = size(cvsi_perf.(fn{f}));
    mean_cvsi_perf_all.(fn{f}) = reshape(c,s);
end


%% Time-courses

beta_index     = cvsi_perf_all.freq >= param.betaband(1) & cvsi_perf_all.freq <= param.betaband(2);
alpha_index    = cvsi_perf_all.freq >= param.alphaband(1) & cvsi_perf_all.freq <= param.alphaband(2);

cvsi_perf_all.motor_beta_load_two_fast = squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_fast(:,:,beta_index,:)),2));
cvsi_perf_all.motor_beta_load_two_slow = squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_slow(:,:,beta_index,:)),2));

cvsi_perf_all.motor_beta_load_four_fast = squeeze(mean(squeeze(cvsi_perf_all.motor_load_four_fast(:,:,beta_index,:)),2));
cvsi_perf_all.motor_beta_load_four_slow = squeeze(mean(squeeze(cvsi_perf_all.motor_load_four_slow(:,:,beta_index,:)),2));

cvsi_perf_all.motor_beta_load_two_prec = squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_prec(:,:,beta_index,:)),2));
cvsi_perf_all.motor_beta_load_two_imprec = squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_imprec(:,:,beta_index,:)),2));

cvsi_perf_all.motor_beta_load_four_prec = squeeze(mean(squeeze(cvsi_perf_all.motor_load_four_prec(:,:,beta_index,:)),2));
cvsi_perf_all.motor_beta_load_four_imprec = squeeze(mean(squeeze(cvsi_perf_all.motor_load_four_imprec(:,:,beta_index,:)),2));


cvsi_perf_all.visual_alpha_load_two_fast = squeeze(mean(squeeze(cvsi_perf_all.visual_load_two_fast(:,:,alpha_index,:)),2));
cvsi_perf_all.visual_alpha_load_two_slow = squeeze(mean(squeeze(cvsi_perf_all.visual_load_two_slow(:,:,alpha_index,:)),2));

cvsi_perf_all.visual_alpha_load_four_fast = squeeze(mean(squeeze(cvsi_perf_all.visual_load_four_fast(:,:,alpha_index,:)),2));
cvsi_perf_all.visual_alpha_load_four_slow = squeeze(mean(squeeze(cvsi_perf_all.visual_load_four_slow(:,:,alpha_index,:)),2));

cvsi_perf_all.visual_alpha_load_two_prec = squeeze(mean(squeeze(cvsi_perf_all.visual_load_two_prec(:,:,alpha_index,:)),2));
cvsi_perf_all.visual_alpha_load_two_imprec = squeeze(mean(squeeze(cvsi_perf_all.visual_load_two_imprec(:,:,alpha_index,:)),2));

cvsi_perf_all.visual_alpha_load_four_prec = squeeze(mean(squeeze(cvsi_perf_all.visual_load_four_prec(:,:,alpha_index,:)),2));
cvsi_perf_all.visual_alpha_load_four_imprec = squeeze(mean(squeeze(cvsi_perf_all.visual_load_four_imprec(:,:,alpha_index,:)),2));


%% Plot variables

load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual'};

time = cvsi_perf_all.time;

DT = {'fast', 'slow'};
ERR = {'prec', 'imprec'};
LOAD = {'two', 'four'};

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
    
    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); 
    legend('Fast','','Slow','','','')

end

%% Visual: fast vs slow

figure;
sgtitle('Visual selection: fast vs slow')

for i = 1:length(load_titles)

    subplot(1,2,i)

    fast = cvsi_perf_all.(append('visual_alpha_load_', LOAD{i}, '_fast'));
    slow = cvsi_perf_all.(append('visual_alpha_load_', LOAD{i}, '_slow'));

    frevede_errorbarplot(time, fast, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(time, slow, param.cols_RGB{2}, 'se');
    
    xlabel('time (s)'); ylabel('cvsi power change (%)');  
    title(load_titles{i})
    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); 
    legend('Fast','','Slow','','','')

end

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
    xlim([-0.1 1.5]); 
    legend('Precise','','Imprecise','','','')

end

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
    xlim([-0.1 1.5]); 
    legend('Fast','','Slow','','','')

end


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




%% Plot Timecourses




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


