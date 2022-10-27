%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 17:25;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% Load epoched data, ica, usable trials

    load([param.path, 'Processed/Locked probe/epoched probe/' 'epoched_probe_s' num2str(this_subject)], 'data');
    load([param.path, 'Processed/Locked probe/ICA probe/' 'ICA_probe_s' num2str(this_subject)], 'ica2rem','ica');
    load([param.path, 'Processed/Locked probe/usable trials probe/' 'usable_trials_probe_s' num2str(this_subject)], 'trl2keep');
    
    %% Load logfile
    
    log = readtable(param.logfile);
    
    sub_logindex = log.subjectID == this_subject;
    sub_log = log(sub_logindex,:);

    remove_RT = log.goodBadTrials(sub_logindex);
    good_RT = contains(remove_RT, 'TRUE');

    %% Check if trials missing
    
    while length(good_RT) ~= length(trl2keep)
        
        for i = 1:length(trl2keep)
            if data.trialinfo(i) ~= sub_log.probeTrig(i)
                good_RT(i) = [];
                break
            end
        end

    end

    %% Remove bad trials
    
    cfg = [];
    cfg.trials = trl2keep & good_RT;

    data = ft_selectdata(cfg, data);
    
    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);

    %% Baseline correction

    cfg = []; 
    cfg.demean = 'yes';
    cfg.baselinewindow = [-.25 0];

    data = ft_preprocessing(cfg, data);
    
    %% Band selection

    % Band selection
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'yes';

    % Beta
    cfg.bpfreq  = [13 30];
    data_beta   = ft_preprocessing(cfg, data);

    % Alpha
    cfg.bpfreq  = [8 12];
    data_alpha  = ft_preprocessing(cfg, data);

    %% Resample

    cfg = [];
    cfg.resamplefs = 50; 
    
    data        = ft_resampledata(cfg, data);
    data_beta   = ft_resampledata(cfg, data_beta);
    data_alpha  = ft_resampledata(cfg, data_alpha);

    %% Temporal smoothing (removing the higher frequencies)

    cfg = [];
    cfg.boxcar = 0.05; % smooth with 50 ms boxcar window
    
    data        = ft_preprocessing(cfg, data);
    data_beta   = ft_preprocessing(cfg, data_beta);
    data_alpha  = ft_preprocessing(cfg, data_alpha);

    %% Select data 
    
    cfg = [];
    cfg.latency = [-.1 4]; % encoding window
    cfg.channel = 'EEG'; % only keep EEG electrodes
    
    data        = ft_selectdata(cfg, data);
    data_beta   = ft_selectdata(cfg, data_beta);
    data_alpha  = ft_selectdata(cfg, data_alpha);

    %% Separate trial types
    
    % Left & right required response 
    trials_resp_left     = ismember(data.trialinfo(:,1), param.triggers_resp_left);
    trials_resp_right    = ismember(data.trialinfo(:,1), param.triggers_resp_right);

    % Target location
    trials_item_left     = ismember(data.trialinfo(:,1), param.triggers_item_left);
    trials_item_right    = ismember(data.trialinfo(:,1), param.triggers_item_right);
    
    % Load
    trials_load_two      = ismember(data.trialinfo(:,1), param.triggers_load_two);
    trials_load_four     = ismember(data.trialinfo(:,1), param.triggers_load_four);   

    %% Data into single matrix, split by condition
    
    cfg = [];
    cfg.keeptrials = 'yes';

    % Load one - T1
    cfg.trials = trials_load_two;

    data_two         = ft_timelockanalysis(cfg, data);                     % put all trials into a single matrix
    data_two_beta    = ft_timelockanalysis(cfg, data_beta);
    data_two_alpha   = ft_timelockanalysis(cfg, data_alpha);

    % Load one - T2
    cfg.trials = trials_load_four;
    
    data_four         = ft_timelockanalysis(cfg, data);
    data_four_beta    = ft_timelockanalysis(cfg, data_beta);
    data_four_alpha   = ft_timelockanalysis(cfg, data_alpha);

    %% Decoding 

    dtime = data.time;                                                        % Time variable

    %% Load two    
    
    % Data-sets
    d = data_two.trial; d_beta = data_two_beta.trial; d_alpha = data_two_alpha.trial;   % data, and for beta, alpha
    allTrials   = 1:size(data_two.trial, 1);                                            % Trials 
    
    % Classes
    motorClass  = trials_load_two & trials_resp_right; motorClass  = motorClass(trials_load_two);  % (1 for right)
    visualClass = trials_load_two & trials_item_right; visualClass = visualClass(trials_load_two); % (1 for right)

    % Run decoding
    [decoding.motor_correct_two, decoding.motor_distance_two]                 = eeg_decoding(d, allTrials, motorClass, dtime);
    [decoding.visual_correct_two, decoding.visual_distance_two]               = eeg_decoding(d, allTrials, visualClass, dtime);
    [decoding.motor_beta_correct_two, decoding.motor_beta_distance_two]       = eeg_decoding(d_beta, allTrials, motorClass, dtime);
    [decoding.motor_alpha_correct_two, decoding.motor_alpha_distance_two]     = eeg_decoding(d_alpha, allTrials, motorClass, dtime);    
    [decoding.visual_alpha_correct_two, decoding.visual_alpha_distance_two]   = eeg_decoding(d_alpha, allTrials, visualClass, dtime);

    %% Load four    
    
    % Data-sets
    d = data_four.trial; d_beta = data_four_beta.trial; d_alpha = data_four_alpha.trial;   % data, and for beta, alpha
    allTrials   = 1:size(data_four.trial, 1);                                              % Trials 
    
    % Classes
    motorClass  = trials_load_four & trials_resp_right; motorClass  = motorClass(trials_load_four);  % (1 for right)
    visualClass = trials_load_four & trials_item_right; visualClass = visualClass(trials_load_four); % (1 for right)

    % Run decoding
    [decoding.motor_correct_four, decoding.motor_distance_four]               = eeg_decoding(d, allTrials, motorClass, dtime);
    [decoding.visual_correct_four, decoding.visual_distance_four]             = eeg_decoding(d, allTrials, visualClass, dtime);
    [decoding.motor_beta_correct_four, decoding.motor_beta_distance_four]     = eeg_decoding(d_beta, allTrials, motorClass, dtime);
    [decoding.motor_alpha_correct_four, decoding.motor_alpha_distance_four]   = eeg_decoding(d_alpha, allTrials, motorClass, dtime);       
    [decoding.visual_alpha_correct_four, decoding.visual_alpha_distance_four] = eeg_decoding(d_alpha, allTrials, visualClass, dtime);

    %% Add time variable

    decoding.time = data.time{1}*1000;

    %% Save 
    
    save([param.path, 'Processed/Locked probe/decoding/' 'decoding_s' num2str(this_subject)], 'decoding');
    
end


%% Decoding general function

function [accuracy, distance] = eeg_decoding(d, allTrials, class, dtime)

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisClass   = class(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (class == thisClass);
        otherNonMatch   = otherTrials' & (class ~= thisClass);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(dtime{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            accuracy(thisTrial, time)      = distMatch < distNonMatch;
            distance(thisTrial, time)      = distNonMatch - distMatch;
        end

    end

end