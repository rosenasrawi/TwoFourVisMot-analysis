function [param, eegfiles] = rn4_gen_param(this_subject)

    %% General info

    % Paths
    param.EEGpath           = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn4 - Vis-mot four items/Data/Lab data/eegdata/';
    param.path              = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn4 - Vis-mot four items/Data/';

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

    % Times
    param.T_probe_window     = [1 3];

    % Trials
    trials                   = 1:16;

    item_left                = [1,3,5,7,9,11,13,15];
    item_right               = [2,4,6,8,10,12,14,16];
    tilt_left                = [2,4,5,6,9,11,15,16];
    tilt_right               = [1,3,7,8,10,12,13,14];

    %% Triggers

    param.triggers_probe        = [trials + 16, trials + 16 + 50, trials + 16 + 100, trials + 16 + 150];

    param.triggers_load_two     = [trials, trials + 16, trials + 32, trials + 100, trials + 16 + 100, trials + 32 + 100];    
    param.triggers_load_four    = [trials + 50, trials + 16 + 50, trials + 32 + 50, trials + 150, trials + 16 + 150, trials + 32 + 150];

    param.triggers_dial_up      = [trials, trials + 16, trials + 32, trials + 50, trials + 16 + 50, trials + 32 + 50];
    param.triggers_dial_right   = [trials + 100, trials + 16 + 100, trials + 32 + 100, trials + 150, trials + 16 + 150, trials + 32 + 150];

    param.triggers_item_left    = [item_left, item_left + 16, item_left + 32, item_left + 50, item_left + 50 + 16, item_left + 50 + 32, item_left + 100, item_left + 100 + 16, item_left + 100 + 32, item_left + 150, item_left + 150 + 16, item_left + 150 + 32];
    param.triggers_item_right   = [item_right, item_right + 16, item_right + 32, item_right + 50, item_right + 50 + 16, item_right + 50 + 32, item_right + 100, item_right + 100 + 16, item_right + 100 + 32, item_right + 150, item_right + 150 + 16, item_right + 150 + 32];

    param.triggers_resp_left    = [tilt_left, tilt_left + 16, tilt_left + 32, tilt_left + 50, tilt_left + 50 + 16, tilt_left + 50 + 32, tilt_right + 100, tilt_right + 100 + 16, tilt_right + 100 + 32, tilt_right + 150, tilt_right + 150 + 16, tilt_right + 150 + 32];
    param.triggers_resp_right   = [tilt_right, tilt_right + 16, tilt_right + 32, tilt_right + 50, tilt_right + 50 + 16, tilt_right + 50 + 32, tilt_left + 100, tilt_left + 100 + 16, tilt_left + 100 + 32, tilt_left + 150, tilt_left + 150 + 16, tilt_left + 150 + 32];
    
    %% Bad channels

    param.chanrepsubs       = {     '6',                   '7',                  '10',                  '12',                          '14',                  '15',                  '17',                                    '21'};
    param.badchan           = {    'B25',             {'B25','B31'},             'B25',             {'A30','B25'},                 {'A30','B25'},             'B25',             {'B25','B31'},                     {'B10','B11','B12'}};
    param.replacechan       = {{'A31','B26'}, {{'A31','B26'},{'A30','B30'}}, {'A31','B26'}, {{'A29','A31'},{'A31','B26'}}, {{'A29','A31'},{'A31','B26'}}, {'A31','B26'}, {{'A31','B26'},{'A30','B30'}}, {{'B3','B9'},{'B9','B20'},{'B9','B13','B19'}}};



    