%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1;

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

    %% Keep channels of interest

    cfg = [];
    cfg.channel = {'EEG'};

    data = ft_preprocessing(cfg, data);

    %% Remove bad trials
    
    cfg = [];
    cfg.trials = trl2keep & good_RT;

    data = ft_selectdata(cfg, data);
    
    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);

    %% Surface laplacian

    cfg = [];
    cfg.elec = ft_read_sens('standard_1020.elc');

    data = ft_scalpcurrentdensity(cfg, data);

    %% Get time-frequency response
    
    taperstyle = 'hanning'; 
    windowsize = 0.3;

    cfg = [];

    cfg.method = 'mtmconvol';
    cfg.keeptrials = 'yes';
    cfg.taper = taperstyle;
    cfg.foi = 3:1:40; % frequency's of interest
    cfg.pad = 10; % 
    cfg.toi = data.time{1}(1) + (windowsize / 2) : .05 : data.time{1}(end) - (windowsize / 2); % steps of 50 ms always. 
    cfg.t_ftimwin = ones(1,length(cfg.foi)) * windowsize;

    tfr = ft_freqanalysis(cfg, data);

    %% Separate trial types
    
    % Left & right required response 
    trials_resp_left     = ismember(tfr.trialinfo(:,1), param.triggers_resp_left);
    trials_resp_right    = ismember(tfr.trialinfo(:,1), param.triggers_resp_right);

    % Target location
    trials_item_left     = ismember(tfr.trialinfo(:,1), param.triggers_item_left);
    trials_item_right    = ismember(tfr.trialinfo(:,1), param.triggers_item_right);
    
    % Load
    trials_load_two      = ismember(tfr.trialinfo(:,1), param.triggers_load_two);
    trials_load_four     = ismember(tfr.trialinfo(:,1), param.triggers_load_four);    

    %% Combined trial types
    
    % Load two
    
    trials_resp_left_load_two   = trials_resp_left & trials_load_two;
    trials_resp_right_load_two  = trials_resp_right & trials_load_two;
    
    trials_item_left_load_two   = trials_item_left & trials_load_two;
    trials_item_right_load_two  = trials_item_right & trials_load_two;
    
    % Load four
    
    trials_resp_left_load_four  = trials_resp_left & trials_load_four;
    trials_resp_right_load_four = trials_resp_right & trials_load_four;
    
    trials_item_left_load_four  = trials_item_left & trials_load_four;
    trials_item_right_load_four = trials_item_right & trials_load_four;
    
    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tfr.label, param.C3);
    chan_motor_right    = match_str(tfr.label, param.C4);
    
    % Visual
    chan_visual_left    = match_str(tfr.label, param.PO7);
    chan_visual_right   = match_str(tfr.label, param.PO8);
    
    %% Contra vs ipsi 
    
    %% Motor

    % -- Load two
    motor_load_two(1,:,:) = get_cvsi(tfr, trials_resp_left_load_two, trials_resp_right_load_two, chan_motor_left, chan_motor_right);
    
    % -- Load four
    motor_load_four(1,:,:) = get_cvsi(tfr, trials_resp_left_load_four, trials_resp_right_load_four, chan_motor_left, chan_motor_right);
    
    %% Visual    
 
    % -- Load two
    visual_load_two(1,:,:) = get_cvsi(tfr, trials_item_left_load_two, trials_item_right_load_two, chan_visual_left, chan_visual_right);
    
    % -- Load four
    visual_load_four(1,:,:) = get_cvsi(tfr, trials_resp_left_load_four, trials_resp_right_load_four, chan_motor_left, chan_motor_right);
        
    %% Contrasts in structure
    
    cvsi_probe = [];
    
    cvsi_probe.label = tfr.label;
    cvsi_probe.time = tfr.time;
    cvsi_probe.freq = tfr.freq;
    cvsi_probe.dimord = 'chan_freq_time';    
    
    cvsi_probe.motor_load_two   = motor_load_two;
    cvsi_probe.motor_load_four  = motor_load_four;
    cvsi_probe.visual_load_two  = visual_load_two;
    cvsi_probe.visual_load_four = visual_load_four;

    %% Save 
    
    save([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_s' num2str(this_subject)], 'cvsi_probe');
    
end        
    
%% cvsi general function

function cvsi_dat = get_cvsi(tfr, trials_left, trials_right, chan_left, chan_right)
    
    % Left channels
    a = mean(tfr.powspctrm(trials_right, chan_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_left, chan_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_left, chan_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_right, chan_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_dat = (cvsi_left + cvsi_right) ./ 2;  
        
end