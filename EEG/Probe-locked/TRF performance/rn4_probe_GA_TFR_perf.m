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
