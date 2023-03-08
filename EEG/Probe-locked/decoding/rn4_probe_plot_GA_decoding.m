%% Clean workspace

clc; clear; close all

%% Define parameters

subjects = 1:25;

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

%% Smooth pp timecourses

for f = 1:length(fn)
    decoding_all.(fn{f}) = smoothdata(decoding_all.(fn{f}), 2, 'gaussian', 30);
end

%% Save decoding

save([param.path, 'Processed/Locked probe/decoding/' 'decoding_all'], 'decoding_all');

%% Load stats

load([param.path, 'Processed/Locked probe/stats/' 'stat_decoding'], 'stat_decoding');

%% Plot variables

load_titles = {'Load two', 'Load four'};
class_titles = {'Motor', 'Visual', 'Tilt'};

fn = fieldnames(decoding_all);

motor_correct = fn(contains(fn, 'motor_correct'));
motor_distance = fn(contains(fn, 'motor_distance'));

visual_correct = fn(contains(fn, 'visual_correct'));
visual_distance = fn(contains(fn, 'visual_distance'));

tilt_correct = fn(contains(fn, 'tilt_correct'));
tilt_distance = fn(contains(fn, 'tilt_distance'));

two_correct = fn(contains(fn, 'correct_two'));
two_distance = fn(contains(fn, 'distance_two'));

four_correct = fn(contains(fn, 'correct_four'));
four_distance = fn(contains(fn, 'distance_four'));

%% Accuracy 

%% Plot motor & visual (panel = load)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(load_titles)

    subplot(1,2,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(motor_correct{i}), param.cols_RGB{1}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(visual_correct{i}), param.cols_RGB{2}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(tilt_correct{i}), param.cols_RGB{3}, 'se');

%     plot(decoding_all.time, stat_decoding.(motor_correct{i}).mask * 0.495, 'color', param.cols_RGB{1}, 'LineWidth', 2);
%     plot(decoding_all.time, stat_decoding.(visual_correct{i}).mask * 0.49, 'color', param.cols_RGB{2}, 'LineWidth', 2);
%     plot(decoding_all.time, stat_decoding.(tilt_correct{i}).mask * 0.485, 'color', param.cols_RGB{3}, 'LineWidth', 2);

    title(load_titles{i}); 
    xlabel('Time after probe (s)'); ylabel('Decoding accuracy');   

    xline(0, '--k'); yline(0.5, '--k')
    ylim([.48 .56]); xlim([-100 1500]); 

    legend('motor','','visual','','tilt','','','')

end

%% Plot motor & visual (panel = class)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(class_titles)

    subplot(1,3,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(two_correct{i}), param.cols_RGB{1}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(four_correct{i}), param.cols_RGB{2}, 'se');

%     plot(decoding_all.time, stat_decoding.(two_correct{i}).mask * 0.495, 'color', param.cols_RGB{1}, 'LineWidth', 2);
%     plot(decoding_all.time, stat_decoding.(four_correct{i}).mask * 0.49, 'color', param.cols_RGB{2}, 'LineWidth', 2);

    title(class_titles{i}); 
    xlabel('Time after probe (s)'); ylabel('Decoding accuracy');   

    xline(0, '--k'); yline(0.5, '--k')
    ylim([.48 .56]); xlim([-100 1500]); 
    legend('two','','four','','','')

end

%% Distance 

%% Plot motor & visual (panel = load)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(load_titles)

    subplot(1,2,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(motor_distance{i}), param.cols_RGB{1}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(visual_distance{i}), param.cols_RGB{2}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(tilt_distance{i}), param.cols_RGB{3}, 'se');

    title(load_titles{i}); 
    xlabel('time (s)'); ylabel('decoding distance');   

    xline(0, '--k'); yline(0, '--k')
    ylim([-0.005 .02]); xlim([-100 1500]); 
    legend('motor','','visual','','tilt','','','')

end

%% Plot motor & visual (panel = class)

figure;
sgtitle('Visual & motor selection')

for i = 1:length(class_titles)

    subplot(1,3,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(two_distance{i}), param.cols_RGB{1}, 'se');
    frevede_errorbarplot(decoding_all.time, decoding_all.(four_distance{i}), param.cols_RGB{2}, 'se');

    title(class_titles{i}); 
    xlabel('time (s)'); ylabel('decoding distance');   

    xline(0, '--k'); yline(0, '--k')
    ylim([-0.005 .02]); xlim([-100 1500]); 
    legend('two','','four','','','')

end
