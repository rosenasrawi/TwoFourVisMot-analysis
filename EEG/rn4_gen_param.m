function [param, eegfiles] = rn4_gen_param(this_subject)

    %% General info

    % Paths
    param.EEGpath           = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn4 - Vis-mot four items/Data/Lab data/eegdata/';
    param.path              = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn4 - Vis-mot four items/Data/';
    param.logfile           = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn4 - Vis-mot four items/Data/Lab data/logfiles/combined_logfile.csv';
    
    % Subjects and sessions
    param.subjectIDs    = 1:25;

    eegfiles = {strcat('rn4_s', num2str(this_subject), 'a', '.bdf'); 
                strcat('rn4_s', num2str(this_subject), 'b', '.bdf')};

    % Frequency bands
    param.betaband           = [13 30];
    param.alphaband          = [ 8 12];

    % Electrodes
    param.C3                 = 'C3';
    param.C4                 = 'C4';
    param.PO7                = 'PO7';
    param.PO8                = 'PO8';

    % Plot colors
    param.cols_cond          = {'motor',            'visual',           'tilt'};
    param.cols_names         = {'licac',            'turquoise',        'orange'};
    param.cols_RGB           = {[0.78, 0.63, 0.78], [0.11, 0.71, 0.65], [1, 0.49, 0.31]};

    % Times
    param.T_probe_window     = [1 3];
    param.T_resp_window      = [3 1];

    % Trials
    trials                   = 1:16;

    item_left                = [1,3,5,7,9,11,13,15];
    item_right               = [2,4,6,8,10,12,14,16];
    tilt_left                = [2,4,5,6,9,11,15,16];
    tilt_right               = [1,3,7,8,10,12,13,14];

    %% Triggers

    param.triggers_probe        = trig_define(trials, [16,66,116,166]);
    param.triggers_resp         = param.triggers_probe + 16;

    param.triggers_load_two     = trig_define(trials, [0,16,32,100,116,132]);
    param.triggers_load_four    = param.triggers_load_two + 50;

    param.triggers_dial_up      = trig_define(trials, [0,16,32,50,66,82]);
    param.triggers_dial_right   = param.triggers_dial_up + 100;

    param.triggers_item_left    = trig_define(item_left, [0,16,32,50,66,82,100,116,132,150,166,182]);
    param.triggers_item_right   = trig_define(item_right, [0,16,32,50,66,82,100,116,132,150,166,182]);

    param.triggers_tilt_left    = trig_define(tilt_left, [0,16,32,50,66,82,100,116,132,150,166,182]);
    param.triggers_tilt_right   = trig_define(tilt_right, [0,16,32,50,66,82,100,116,132,150,166,182]);

    param.triggers_resp_left    = [trig_define(tilt_left, [0,16,32,50,66,82]), trig_define(tilt_right, [100,116,132,150,166,182])];
    param.triggers_resp_right   = [trig_define(tilt_right, [0,16,32,50,66,82]), trig_define(tilt_left, [100,116,132,150,166,182])];

    %% Bad channels

    param.chanrepsubs       = {     '6',                   '7',                  '10',                  '12',                          '14',                  '15',                  '17',                                    '21'};
    param.badchan           = {    'B25',             {'B25','B31'},             'B25',             {'A30','B25'},                 {'A30','B25'},             'B25',             {'B25','B31'},                     {'B10','B11','B12'}};
    param.replacechan       = {{'A31','B26'}, {{'A31','B26'},{'A30','B30'}}, {'A31','B26'}, {{'A29','A31'},{'A31','B26'}}, {{'A29','A31'},{'A31','B26'}}, {'A31','B26'}, {{'A31','B26'},{'A30','B30'}}, {{'B3','B9'},{'B9','B20'},{'B9','B13','B19'}}};

    %% General function of adding condition codes to trial triggers
    
    function trig = trig_define(trials, factor)
        
        trig = [];
        
        for f = factor
            trig = [trig, trials + f]; 
        end

    end

end 



    