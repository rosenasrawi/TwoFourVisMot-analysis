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

%% Save these

save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_perf_all'], 'cvsi_perf_all');
save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_perf_all'], 'mean_cvsi_perf_all');

