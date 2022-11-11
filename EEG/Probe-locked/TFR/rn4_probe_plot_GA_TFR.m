%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% load 
    load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_s' num2str(this_subject)], 'cvsi_probe');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_probe_all = selectfields(cvsi_probe, {'label', 'time', 'freq', 'dimord'});
        cvsi_probe_all.label = {'C3'}; % CVSI, so only one channel per contrast
    end
    
    fn = fieldnames(cvsi_probe);
    fn = fn(contains(fn, 'load'));

    for f = 1:length(fn)
        cvsi_probe_all.(fn{f})(this_subject,:,:,:) = cvsi_probe.(fn{f});
    end

end    

%% Average

mean_cvsi_probe_all = selectfields(cvsi_probe_all, {'label', 'time', 'freq', 'dimord'});

for f = 1:length(fn)
    c = squeeze(mean(cvsi_probe_all.(fn{f})));
    s = size(cvsi_probe.(fn{f}));
    mean_cvsi_probe_all.(fn{f}) = reshape(c,s); % Reshape average to give it single-channel dimension
end

%% Plot variables

probe_titles = {'Motor - load two', 'Motor - load four', 'Visual - load two', 'Visual - load four'};
load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual'};

beta_index     = cvsi_probe_all.freq >= param.betaband(1) & cvsi_probe_all.freq <= param.betaband(2);
alpha_index    = cvsi_probe_all.freq >= param.alphaband(1) & cvsi_probe_all.freq <= param.alphaband(2);

freq_index = {beta_index, alpha_index};

motor_cvsi = fn(contains(fn, 'motor'));
visual_cvsi = fn(contains(fn, 'visual'));

two_cvsi = fn(contains(fn, 'two'));
four_cvsi = fn(contains(fn, 'four'));

%% Plot TFR 

figure; 
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.zlim      = 'maxabs';

for f = 1:length(fn)

    subplot(2,2, f);

    cfg.parameter = fn{f};
    
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

for i = 1:length(load_titles)

    subplot(1,2,i)

    mot = squeeze(mean(squeeze(cvsi_probe_all.(motor_cvsi{i})(:,:,beta_index,:)),2));
    vis = squeeze(mean(squeeze(cvsi_probe_all.(visual_cvsi{i})(:,:,alpha_index,:)),2));

    frevede_errorbarplot(cvsi_probe_all.time, mot, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(cvsi_probe_all.time, vis, param.cols_RGB{2}, 'se');

    title(load_titles{i}); 
    xlabel('Time after probe (s)'); ylabel('CvsI power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); 
    legend('motor','','visual','','','')

end

%% Plot motor & visual (panel = class)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(class_titles)

    subplot(1,2,i)

    two = squeeze(mean(squeeze(cvsi_probe_all.(two_cvsi{i})(:,:,freq_index{i},:)),2));
    four = squeeze(mean(squeeze(cvsi_probe_all.(four_cvsi{i})(:,:,freq_index{i},:)),2));

    frevede_errorbarplot(cvsi_probe_all.time, two, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(cvsi_probe_all.time, four, param.cols_RGB{2}, 'se');

    title(class_titles{i}); 
    xlabel('time (s)'); ylabel('cvsi power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.1 1.5]); 
    legend('two','','four','','','')

end

