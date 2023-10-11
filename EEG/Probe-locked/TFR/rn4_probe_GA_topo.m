%% Clean workspace

clc; clear; close all

%% Load contrasts

subjects = 1:25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% Load rvsl
    load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'rvsl_probe_s' num2str(this_subject)], 'rvsl_probe');

    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        rvsl_probe_all = selectfields(rvsl_probe, {'label', 'time', 'freq', 'dimord'});
    end

    fn = fieldnames(rvsl_probe);
    fn = fn(contains(fn, 'load'));

    for f = 1:length(fn)
        rvsl_probe_all.(fn{f})(this_subject,:,:,:) = rvsl_probe.(fn{f}); 
    end

end

%% Average 

mean_rvsl_probe_all = selectfields(rvsl_probe_all, {'label', 'time', 'freq', 'dimord'});

for f = 1:length(fn)
    mean_rvsl_probe_all.(fn{f}) = squeeze(mean(rvsl_probe_all.(fn{f}))); 
end

%% Save these

save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'rvsl_probe_all'], 'rvsl_probe_all');
save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_rvsl_probe_all'], 'mean_rvsl_probe_all');
