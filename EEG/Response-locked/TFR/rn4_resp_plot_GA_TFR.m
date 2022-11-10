%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:5;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% load 
    load([param.path, 'Processed/Locked resp/tfr contrasts resp/' 'cvsi_resp_s' num2str(this_subject)], 'cvsi_resp');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_resp_all = selectfields(cvsi_resp, {'label', 'time', 'freq', 'dimord'});
        cvsi_resp_all.label = {'C3'}; % CVSI, so only one channel per contrast
    end
    
    fn = fieldnames(cvsi_resp);
    fn = fn(contains(fn, 'load'));

    for f = 1:length(fn)
        cvsi_resp_all.(fn{f})(this_subject,:,:,:) = cvsi_resp.(fn{f});
    end

end    

%% Average

mean_cvsi_resp_all = selectfields(cvsi_resp_all, {'label', 'time', 'freq', 'dimord'});

for f = 1:length(fn)
    c = squeeze(mean(cvsi_resp_all.(fn{f})));
    s = size(cvsi_resp.(fn{f}));
    mean_cvsi_resp_all.(fn{f}) = reshape(c,s); % Reshape average to give it single-channel dimension
end

%% Plot variables

resp_titles = {'Motor - load two', 'Motor - load four', 'Visual - load two', 'Visual - load four'};
load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual'};

beta_index     = cvsi_resp_all.freq >= param.betaband(1) & cvsi_resp_all.freq <= param.betaband(2);
alpha_index    = cvsi_resp_all.freq >= param.alphaband(1) & cvsi_resp_all.freq <= param.alphaband(2);

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
cfg.colorbar  = 'yes';
cfg.zlim      = [-10,10];

for f = 1:length(fn)

    subplot(2,2, f);

    cfg.parameter = fn{f};
    
    ft_singleplotTFR(cfg, mean_cvsi_resp_all);
    colormap(flipud(brewermap(100,'RdBu')));

    xline(0)  
    xlim([-0.8 0.8]); 
    title(resp_titles{f})

end    

%% Time-courses 

%% Plot motor & visual (panel = load)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(load_titles)

    subplot(1,2,i)

    mot = squeeze(mean(squeeze(cvsi_resp_all.(motor_cvsi{i})(:,:,beta_index,:)),2));
    vis = squeeze(mean(squeeze(cvsi_resp_all.(visual_cvsi{i})(:,:,alpha_index,:)),2));

    frevede_errorbarplot(cvsi_resp_all.time, mot, param.cols_RGB{1}, 'se');
    frevede_errorbarplot(cvsi_resp_all.time, vis, param.cols_RGB{2}, 'se');

    title(load_titles{i}); 
    xlabel('time (s)'); ylabel('cvsi power change (%)');  

    xline(0, '--k'); yline(0, '--k')
    xlim([-0.8 0.8]); 
    legend('motor','','visual','','','')

end
