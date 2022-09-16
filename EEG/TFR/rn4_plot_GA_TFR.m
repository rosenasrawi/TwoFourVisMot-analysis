%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:5;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% load 
    load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_' param.subjectIDs{this_subject}], 'cvsi_probe');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_probe_all = selectfields(cvsi_probe,{'label', 'time', 'freq', 'dimord'});
    end
    
    %% add to all sub structure
    cvsi_probe_all.motor_load_two(this_subject,:,:,:)    = cvsi_probe.motor_load_two;
    cvsi_probe_all.motor_load_four(this_subject,:,:,:)   = cvsi_probe.motor_load_four;
    cvsi_probe_all.visual_load_two(this_subject,:,:,:)   = cvsi_probe.visual_load_two;
    cvsi_probe_all.visual_load_four(this_subject,:,:,:)  = cvsi_probe.visual_load_four;

end    

%% Average

mean_cvsi_probe_all = selectfields(cvsi_probe_all,{'label', 'time', 'freq', 'dimord'});

mean_cvsi_probe_all.motor_load_two    = squeeze(mean(cvsi_probe_all.motor_load_two));
mean_cvsi_probe_all.motor_load_four   = squeeze(mean(cvsi_probe_all.motor_load_four));
mean_cvsi_probe_all.visual_load_two   = squeeze(mean(cvsi_probe_all.visual_load_two));
mean_cvsi_probe_all.visual_load_four  = squeeze(mean(cvsi_probe_all.visual_load_four));

%% Plot TFR 

titles_probe_contrasts = {'motor load two', 'motor load four', 'visual load two', 'visual load four'};

probe_contrasts = {mean_cvsi_probe_all.motor_load_two, mean_cvsi_probe_all.motor_load_four, mean_cvsi_probe_all.visual_load_two, mean_cvsi_probe_all.visual_load_four};

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-10,10];

figure;

for contrast = 1:length(probe_contrasts)
    subplot(2,2, contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(probe_contrasts{contrast}); % select data
    contourf(mean_cvsi_probe_all.time, mean_cvsi_probe_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)

    title(titles_probe_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Plot timecourse
timecourse_titles = {'load two', 'load four'};

%% General params
beta_index              = cvsi_probe_all.freq >= param.betaband(1) & cvsi_probe_all.freq <= param.betaband(2);
alpha_index             = cvsi_probe_all.freq >= param.alphaband(1) & cvsi_probe_all.freq <= param.alphaband(2);

%% Vis mot, load two vs four

cvsi_motor_beta         = {squeeze(mean(squeeze(cvsi_probe_all.motor_load_two(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_probe_all.motor_load_four(:,:,beta_index,:)),2))};
cvsi_motor_alpha        = {squeeze(mean(squeeze(cvsi_probe_all.motor_load_two(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_probe_all.motor_load_four(:,:,alpha_index,:)),2))};
cvsi_visual_alpha       = {squeeze(mean(squeeze(cvsi_probe_all.visual_load_two(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_probe_all.visual_load_four(:,:,alpha_index,:)),2))};

linecolors = {'blue','red'};

figure; sgtitle("Visual (8-12Hz) and motor (13-30Hz) selection")

for i = 1:length(timecourse_titles)
    
    subplot(1,2,i)
    frevede_errorbarplot(cvsi_probe_all.time, cvsi_motor_beta{i}, linecolors{1}, 'se');
    hold on
    frevede_errorbarplot(cvsi_probe_all.time, cvsi_visual_alpha{i}, linecolors{2}, 'se');

    xline(0); yline(0); ylim([-30,10])
    title(timecourse_titles{i})

end

figure; sgtitle("Visual (8-12Hz) and motor (8-12Hz) selection")

for i = 1:length(timecourse_titles)
    
    subplot(1,2,i)
    frevede_errorbarplot(cvsi_probe_all.time, cvsi_motor_alpha{i}, linecolors{1}, 'se');
    hold on
    frevede_errorbarplot(cvsi_probe_all.time, cvsi_visual_alpha{i}, linecolors{2}, 'se');

    xline(0); yline(0); ylim([-30,10])
    title(timecourse_titles{i})

end
