%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn4_gen_param(this_subject);
        
    %% Preprocessing and epoch settings

    cfg = [];
    
    cfg.reref = 'yes';
    cfg.refchannel = {'EXG1','EXG2'}; % L and R mastiod
    cfg.demean = 'yes'; 
    
    cfg.trialdef.eventtype  = 'STATUS';
    cfg.trialdef.eventvalue = param.triggers_probe; 
    cfg.trialdef.prestim    = param.T_probe_window(1); 
    cfg.trialdef.poststim   = param.T_probe_window(2); 
    
    %% Process for separate sessions

    cfg.dataset = [param.EEGpath, eegfiles{1}]; % process session 1
    cfg_s1 = ft_definetrial(cfg);
    
    data_s1 = ft_preprocessing(cfg_s1);

    cfg.dataset = [param.EEGpath, eegfiles{2}]; % process session 2
    cfg_s2 = ft_definetrial(cfg);

    data_s2 = ft_preprocessing(cfg_s2);
    
    %% Merge sessions

    cfg = [];
    data = ft_appenddata(cfg, data_s1, data_s2); % merge

    %% Bipolar EMGs and EOG

    eog1 = ismember(data.label, 'EXG3');   eog2 = ismember(data.label, 'EXG4'); % bipolar EOG chan 
    emgL1 = ismember(data.label, 'EXG5');  emgL2 = ismember(data.label, 'EXG6'); % EMG left   
    emgR1 = ismember(data.label, 'EXG7');  emgR2 = ismember(data.label, 'EXG8'); % EMG right

    data.label(end+1:end+3) = {'eog','emgL','emgR'}; % new labels for difference

    for trl = 1:size(data.trial,2) % calc difference between two
        data.trial{trl}(end+1,:) = data.trial{trl}(eog1,:) - data.trial{trl}(eog2,:);
        data.trial{trl}(end+1,:) = data.trial{trl}(emgL1,:) - data.trial{trl}(emgL2,:);
        data.trial{trl}(end+1,:) = data.trial{trl}(emgR1,:) - data.trial{trl}(emgR2,:);
    end
    
    %% Rectified high-pass filtered EMG

    cfg = [];
    cfg.channel = {'emgL','emgR'};
    cfg.hpfilter = 'yes';
    cfg.hpfreq = 60;
    cfg.rectify = 'yes'; % all negative become positive

    emg = ft_preprocessing(cfg, data);
    emg.label = {'emgLrect','emgRrect'};

    data = ft_appenddata(cfg, data, emg); % append
    
    %% Keep channels of interest

    cfg = [];
    cfg.channel = {'A*','B*','eog','emgL','emgR','emgLrect','emgRrect'};

    data = ft_selectdata(cfg, data);    

    %% Plot channels
    
    figure; 
    for ch = 1:64
        subplot(8,8,ch); hold on;
        plot(data.time{300}, data.trial{300}(ch,:), 'b');
        plot(data.time{700}, data.trial{700}(ch,:), 'r');
        title(data.label(ch));
        xlim([-1 4]); ylim([-100 100]);
    end

    %% Interpolate bad channels
    
    sub_chan = ismember(param.chanrepsubs, num2str(this_subject));

    if sum(sub_chan) >= 1  % Subject need chan replacements?

        this_badchan = ismember(data.label, param.badchan{sub_chan});
    
        if sum(this_badchan) == 1
            this_replacechan = ismember(data.label, param.replacechan{sub_chan});   
    
            for trl = 1:size(data.trial,2)
                data.trial{trl}(this_badchan,:) = mean(data.trial{trl}(this_replacechan,:));
            end
            
        end
     
        if sum(this_badchan) > 1
            badchan = data.label(this_badchan);
            
            for chan = 1:sum(this_badchan)
                this_badchan2 = ismember(data.label, badchan{chan});
                this_replacechan = ismember(data.label, param.replacechan{sub_chan}{chan});
                
                for trl = 1:size(data.trial,2)
                    data.trial{trl}(this_badchan2,:) = mean(data.trial{trl}(this_replacechan,:));
                end
                
            end
            
        end
    
        % Plot channels again
        
        figure; 
        for ch = 1:64
            subplot(8,8,ch); hold on;
            plot(data.time{300}, data.trial{300}(ch,:), 'b');
            plot(data.time{700}, data.trial{700}(ch,:), 'r');
            title(data.label(ch));
            xlim([-1 4]); ylim([-100 100]);
        end

    end

    %% Convert to 10-10 Biosemi system labels

    cfg = [];
    cfg.layout = 'biosemi64.lay'; % assumes this is standard

    layout = ft_prepare_layout(cfg);
    data.label(1:64) = layout.label(1:64);
    
    %% Resample

    cfg = [];
    cfg.resamplefs = 200;

    data = ft_resampledata(cfg, data);

    %% Save epoched data

    save([param.path, 'Processed/Locked probe/epoched probe/' 'epoched_probe_s' num2str(this_subject)], 'data');

end

