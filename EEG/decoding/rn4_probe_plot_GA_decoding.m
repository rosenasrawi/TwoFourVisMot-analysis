%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:5;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn4_gen_param(this_subject);
    
    %% Load decoding struct

    load([param.path, 'Processed/Locked probe/decoding/' 'decoding_s' num2str(this_subject)], 'decoding');

    fn = fieldnames(decoding);
    fn = fn(~contains(fn, 'time'));
    
    for f = 1:length(fn)
        decoding_all.(fn{f})(this_subject,:) = squeeze(mean(decoding.(fn{f})));
    end

    decoding_all.time = decoding.time;

end

%% Plot variables

decoding_titles = {'Load two', 'Load four'};

fn = fieldnames(decoding_all);

motor_correct = fn(contains(fn, 'motor_correct'));
motor_distance = fn(contains(fn, 'motor_distance'));

visual_correct = fn(contains(fn, 'visual_correct'));
visual_distance = fn(contains(fn, 'visual_distance'));

tilt_correct = fn(contains(fn, 'tilt_correct'));
tilt_distance = fn(contains(fn, 'tilt_distance'));

%% Accuracy 

%% Plot motor & visual

figure;
sgtitle('Visual & motor selection')

for i = 1:length(decoding_titles)

    subplot(1,2,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(motor_correct{i}), param.cols_RGB{1}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(visual_correct{i}), param.cols_RGB{2}, 'se');
    
    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); yline(0.5, '--k')
    ylim([.45 .6]); xlim([-100 1500]); 
    legend('motor','','visual','','','')

end


%% Distance 

%% Plot motor & visual

figure;
sgtitle('Visual & motor selection')

for i = 1:length(decoding_titles)

    subplot(1,2,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(motor_distance{i}), param.cols_RGB{1}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(visual_distance{i}), param.cols_RGB{2}, 'se');
    
    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding distance');   

    xline(0, '--k'); yline(0, '--k')
    ylim([-0.005 .02]); xlim([-100 1500]); 
    legend('motor','','visual','','','')

end
