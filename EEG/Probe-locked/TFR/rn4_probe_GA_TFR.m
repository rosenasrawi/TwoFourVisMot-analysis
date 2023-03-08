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
        cvsi_probe_all.(fn{f})(this_subject,:,:,end) = 0; % remove NaN
    end

end    

%% Average

mean_cvsi_probe_all = selectfields(cvsi_probe_all, {'label', 'time', 'freq', 'dimord'});

for f = 1:length(fn)
    c = squeeze(mean(cvsi_probe_all.(fn{f})));
    s = size(cvsi_probe.(fn{f}));
    mean_cvsi_probe_all.(fn{f}) = reshape(c,s); % Reshape average to give it single-channel dimension
end

%% Time-courses

beta_index     = cvsi_probe_all.freq >= param.betaband(1) & cvsi_probe_all.freq <= param.betaband(2);
alpha_index    = cvsi_probe_all.freq >= param.alphaband(1) & cvsi_probe_all.freq <= param.alphaband(2);

cvsi_probe_all.motor_beta_load_two = squeeze(mean(squeeze(cvsi_probe_all.motor_load_two(:,:,beta_index,:)),2));
cvsi_probe_all.motor_beta_load_four = squeeze(mean(squeeze(cvsi_probe_all.motor_load_four(:,:,beta_index,:)),2));
cvsi_probe_all.visual_alpha_load_two = squeeze(mean(squeeze(cvsi_probe_all.visual_load_two(:,:,alpha_index,:)),2));
cvsi_probe_all.visual_alpha_load_four = squeeze(mean(squeeze(cvsi_probe_all.visual_load_four(:,:,alpha_index,:)),2));

%% Save these

save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');
save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_probe_all'], 'mean_cvsi_probe_all');
