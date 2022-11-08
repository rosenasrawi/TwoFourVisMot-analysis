%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1;

for this_subject = subjects
    
    %% Parameters
    
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% Load epoched data

    load([param.path, 'Processed/Locked resp/epoched resp/' 'epoched_resp_s' num2str(this_subject)], 'data');

    %% Run fast ICA and check eog component detectability (+ topography check)

    cfg = [];
    cfg.keeptrials = 'yes';
    cfg.channel = {'EEG'};
    
    d_eeg = ft_timelockanalysis(cfg, data);
    
    %% ICA

    cfg = [];
    cfg.method = 'fastica';
    ica = ft_componentanalysis(cfg, d_eeg);

    %% Correlate ica timecourses with measured eog

    cfg = [];
    cfg.keeptrials = 'yes';
    d_ica = ft_timelockanalysis(cfg, ica);
    
    cfg.channel = {'eog'};
    d_eog = ft_timelockanalysis(cfg, data);

    y = [];
    x = d_eog.trial(:,1,:); % eog

    for c = 1:size(d_ica.trial,2)
        y = d_ica.trial(:,c,:); % components
        correlations(c) = corr(y(:), x(:));
    end

    %% Look at components & correlations

    % topography
    cfg           = [];
    cfg.component = 1:length(ica.label);
    cfg.layout    = 'biosemi64.lay';
    cfg.comment   = 'no';
    figure; ft_topoplotIC(cfg, ica)
    colormap('jet')

    % correlations
    figure; 
    bar(1:c, abs(correlations),'r'); title('correlations with component timecourses');   
    xlabel('comp #');

    drawnow;

    %% Find the max abs cor

    ica = rmfield(ica, 'trial');
    find(abs(correlations) == max(abs(correlations))) % show which has highest cor

    ica2rem = input('bad components are [x,x]: ');
    
    %% Save

    save([param.path, 'Processed/Locked resp/ICA resp/' 'ICA_resp_s' num2str(this_subject)], 'ica2rem','ica');
    
    close all;
end