%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:5;

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

%% Motor

fn_motor = fn(contains(fn, 'motor') & (contains(fn, 'fast') | contains(fn, 'slow')));

figure; 
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.zlim      = [-25 15];
cfg.colorbar  = 'yes';

for f = 1:length(fn_motor)

    subplot(2,2, f);

    cfg.parameter = fn_motor{f};

    ft_singleplotTFR(cfg, mean_cvsi_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));

    xline(0)  
    xlim([-0.1 1.5]); 
    xlabel('Time after probe (s)'); ylabel('Frequency (Hz)')
    title(fn_motor{f})

end

%% Visual

fn_visual = fn(contains(fn, 'visual') & (contains(fn, 'fast') | contains(fn, 'slow')));

figure; 
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'yes';

for f = 1:length(fn_visual)

    subplot(2,2, f);

    cfg.parameter = fn_visual{f};

    ft_singleplotTFR(cfg, mean_cvsi_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));

    xline(0)  
    xlim([-0.1 1.5]); 
    xlabel('Time after probe (s)'); ylabel('Frequency (Hz)')
    title(fn_visual{f})

end

