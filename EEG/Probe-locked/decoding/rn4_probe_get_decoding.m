%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:25;

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

    wrong_dir = sub_log.wrongDir;
    good_dir = contains(wrong_dir, 'FALSE');
    
    %% Check if trials missing
    
    while length(good_RT) ~= length(trl2keep)
        
        for i = 1:length(trl2keep)
            if data.trialinfo(i) ~= sub_log.probeTrig(i)
                good_RT(i) = [];
                good_dir(i) = [];
                break
            end
        end

    end

    %% Keep good trials
    
    cfg = [];
    cfg.trials = trl2keep & good_RT & good_dir;

    data = ft_selectdata(cfg, data);

    %% Equal number of congruent/incongruent trials

    trials_congr     = ismember(data.trialinfo(:,1), param.triggers_resp_left) & ismember(data.trialinfo(:,1), param.triggers_item_left) | ismember(data.trialinfo(:,1), param.triggers_resp_right) & ismember(data.trialinfo(:,1), param.triggers_item_right);
    trials_incongr   = ismember(data.trialinfo(:,1), param.triggers_resp_left) & ismember(data.trialinfo(:,1), param.triggers_item_right) | ismember(data.trialinfo(:,1), param.triggers_resp_right) & ismember(data.trialinfo(:,1), param.triggers_item_left);
    
    i_congr = find(trials_congr); i_incongr = find(trials_incongr); % indices
    n_congr = sum(trials_congr); n_incongr = sum(trials_incongr); % sum
    diff    = abs(n_congr - n_incongr);

    %% Restore congr/incongr balance

    if diff > 0

        congr2keep = logical(1:length(trials_congr));
    
        if n_congr > n_incongr % more congruent
            t_rem = i_congr(randperm(length(i_congr))); % shuffle trials
        elseif n_congr < n_incongr % more incongruent
            t_rem = i_incongr(randperm(length(i_incongr))); % shuffle trials
        end
        
        t_rem = t_rem(1:diff); % select first n
        congr2keep(t_rem) = false; % mark them as false

        % Restore balance
        cfg = [];
        cfg.trials = congr2keep;
        
        data = ft_selectdata(cfg, data);

    end

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);

    %% Surface laplacian

    cfg = [];
    cfg.elec = ft_read_sens('standard_1020.elc');

    data = ft_scalpcurrentdensity(cfg, data);

    %% Baseline correction

    cfg = []; 
    cfg.demean = 'yes';
    cfg.baselinewindow = [-.25 0];

    data = ft_preprocessing(cfg, data);

    % %% Resample

    % cfg = [];
    % cfg.resamplefs = 100; 
    
    % data        = ft_resampledata(cfg, data);

    %% Select data 
    
    cfg = [];
    cfg.latency = [-.1 2]; % encoding window
    cfg.channel = 'EEG'; % only keep EEG electrodes
    
    data        = ft_selectdata(cfg, data);

    %% Separate trial types
    
    % Left & right required response 
    trials_resp_left     = ismember(data.trialinfo(:,1), param.triggers_resp_left);
    trials_resp_right    = ismember(data.trialinfo(:,1), param.triggers_resp_right);

    % Target location
    trials_item_left     = ismember(data.trialinfo(:,1), param.triggers_item_left);
    trials_item_right    = ismember(data.trialinfo(:,1), param.triggers_item_right);

    % Target tilt
    trials_tilt_left     = ismember(data.trialinfo(:,1), param.triggers_tilt_left);
    trials_tilt_right    = ismember(data.trialinfo(:,1), param.triggers_tilt_right);
    
    % Load
    trials_load_two      = ismember(data.trialinfo(:,1), param.triggers_load_two);
    trials_load_four     = ismember(data.trialinfo(:,1), param.triggers_load_four);   

    %% Data into single matrix, split by condition
    
    cfg = [];
    cfg.keeptrials = 'yes';

    % Load one - T1
    cfg.trials = trials_load_two;
    data_two   = ft_timelockanalysis(cfg, data);

    % Load one - T2
    cfg.trials = trials_load_four;
    data_four  = ft_timelockanalysis(cfg, data);

    %% Decoding 

    dtime       = data.time;

    %% Load two    
    
    % Data-sets
    d           = data_two.trial;    
    allTrials   = 1:size(data_two.trial, 1);
    
    % Classes
    motorClass  = trials_load_two & trials_resp_right; motorClass  = motorClass(trials_load_two);  % (1 for right)
    visualClass = trials_load_two & trials_item_right; visualClass = visualClass(trials_load_two); % (1 for right)
    tiltClass   = trials_load_two & trials_tilt_right; tiltClass   = tiltClass(trials_load_two);   % (1 for right)

    % Run decoding
    [decoding.motor_correct_two, decoding.motor_distance_two]      = eeg_decoding(d, allTrials, motorClass, dtime);
    [decoding.visual_correct_two, decoding.visual_distance_two]    = eeg_decoding(d, allTrials, visualClass, dtime);
    [decoding.tilt_correct_two, decoding.tilt_distance_two]        = eeg_decoding(d, allTrials, tiltClass, dtime);

    %% Load four    
    
    % Data-sets
    d           = data_four.trial;
    allTrials   = 1:size(data_four.trial, 1);
    
    % Classes
    motorClass  = trials_load_four & trials_resp_right; motorClass  = motorClass(trials_load_four);  % (1 for right)
    visualClass = trials_load_four & trials_item_right; visualClass = visualClass(trials_load_four); % (1 for right)
    tiltClass   = trials_load_four & trials_tilt_right; tiltClass   = tiltClass(trials_load_four);   % (1 for right)

    % Run decoding
    [decoding.motor_correct_four, decoding.motor_distance_four]     = eeg_decoding(d, allTrials, motorClass, dtime);
    [decoding.visual_correct_four, decoding.visual_distance_four]   = eeg_decoding(d, allTrials, visualClass, dtime);
    [decoding.tilt_correct_four, decoding.tilt_distance_four]       = eeg_decoding(d, allTrials, tiltClass, dtime);

    %% Add time variable

    decoding.time = data.time{1}*1000;

    %% Save 
    
    save([param.path, 'Processed/Locked probe/decoding/' 'decoding_s' num2str(this_subject)], 'decoding');
    
end

%% Decoding general function

function [accuracy, distance] = eeg_decoding(d, allTrials, class, dtime)
    
    % pre-allocate accuracy & distance
    accuracy = zeros(length(allTrials),length(dtime{1}));
    distance = zeros(length(allTrials),length(dtime{1}));

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

        % euclidean & linear method (baiwei script line 96-103)

    end

end