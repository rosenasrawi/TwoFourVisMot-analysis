%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 6;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% Load epoched data & ica

    load([param.path, 'Processed/Locked probe/epoched probe/' 'epoched_probe_s' num2str(this_subject)], 'data');
    load([param.path, 'Processed/Locked probe/ICA probe/' 'ICA_probe_s' num2str(this_subject)], 'ica2rem','ica');

    %% Select EEG

    cfg = [];
    cfg.channel = {'EEG'};

    data = ft_selectdata(cfg, data);

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);
    
    %% Find bad trials

    data.trialinfo(:,end+1) = 1:length(data.trial);
    trials_old = data.trialinfo(:,end);

    %% All channels, all bands

    cfg = [];
    cfg.method = 'summary';
    cfg.channel = {'EEG'};

    data = ft_rejectvisual(cfg, data);

    %% Chan selections

    cfg.keepchannel = 'yes';
    cfg.channel = {'C3','C4','PO7','PO8'};
 
    data = ft_rejectvisual(cfg, data);    

    %% Band selections

    cfg.channel = {'EEG'};
    cfg.preproc.bpfilter = 'yes';
    cfg.preproc.bpfreq = [8 30];

    data = ft_rejectvisual(cfg, data);

    %% Band and chan selections

    cfg.channel = {'C3','C4','PO7','PO8'};

    data = ft_rejectvisual(cfg, data); 

    %% Trials to keep

    trials_new = data.trialinfo(:,end);

    trl2keep = ismember(trials_old, trials_new);

    propkeep(this_subject) = mean(trl2keep)

    %% Save
    
    save([param.path, 'Processed/Locked probe/usable trials probe/' 'usable_trials_probe_s' num2str(this_subject)], 'trl2keep');

end
