%% Clear workspace

clear; close all; clc

%% Load data files

param = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'cvsi_probe_all'], 'cvsi_probe_all');
load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_cvsi_probe_all'], 'mean_cvsi_probe_all');
load([param.path, 'Processed/Locked probe/decoding/' 'decoding_all'], 'decoding_all');

%% TFR to timecourses

fn = fieldnames(cvsi_probe_all);
fn = fn(contains(fn, 'load'));

beta_index     = cvsi_probe_all.freq >= param.betaband(1) & cvsi_probe_all.freq <= param.betaband(2);
alpha_index    = cvsi_probe_all.freq >= param.alphaband(1) & cvsi_probe_all.freq <= param.alphaband(2);
time_index     = cvsi_probe_all.time >= -0.1 & cvsi_probe_all.time <= 1.5;

timecourses = cvsi_probe_all;

for f = 1:length(fn)
    if contains(fn{f},'motor')
        timecourses.(fn{f}) = squeeze(mean(squeeze(cvsi_probe_all.(fn{f})(:,:,beta_index,time_index)),2));
    elseif contains(fn{f},'visual')
        timecourses.(fn{f}) = squeeze(mean(squeeze(cvsi_probe_all.(fn{f})(:,:,alpha_index,time_index)),2));
    end
end

timecourses.time = timecourses.time(time_index);

probe_titles = {'Motor - load two', 'Motor - load four', 'Visual - load two', 'Visual - load four'};
subs = 1:25;
peakperc = {'100% peak', '50% peak'};

%% Jackknife, leave one out

tpeak = zeros(4,2,25);

for s = 1:25
    
    jsubs = subs;
    jsubs(s) = [];
    
    i = 1;

    for f = 1:length(fn)
        tc = mean(timecourses.(fn{f})(jsubs,:),1);
        tpeak(i,1,s) = timecourses.time(find(tc == min(tc)));

        ipeak = find(timecourses.time == tpeak(i,1,s));


        for t = find(timecourses.time >= 0 & timecourses.time <= tpeak(i,1,s))
            tc(t)
            if tc(t) <= tc(ipeak)*0.50
                tpeak(i,2,s) = timecourses.time(t);
                break
            end
    
        end 
        i = i+1;
    end

end

mean_tpeak = mean(tpeak,3);
se_tpeak = std(tpeak,[],3)/sqrt(size(tpeak,3));

%% Plot

ylims = {[0.55 .95], [0.3 .65]};

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(mean_tpeak(:,i));
    hold on;
    scatter(1:4, squeeze(tpeak(:,i,:)), "filled", 'jitter', 'on')
    errorbar(mean_tpeak(:,i),se_tpeak(:,i), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');
    
    
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);
    ylim(ylims{i})

end

%% Peak moment (on grand average)

tpeak = zeros(4,2); i = 1;

for f = 1:length(fn)
    tc = mean(timecourses.(fn{f}),1);
    tpeak(i,1) = timecourses.time(find(tc == min(tc)));

    ipeak = find(timecourses.time == tpeak(i,1));
  
    for t = find(timecourses.time >= 0 & timecourses.time <= tpeak(i))

        if tc(t) <= tc(ipeak)*0.50
            tpeak(i,2) = timecourses.time(t);
            break
        end

    end    
    i = i+1;
end

%% Plot

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(tpeak(:,i));
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);
    ylim(ylims{i})

end

%% Decoding

fn = fieldnames(decoding_all);
fn = fn(contains(fn, 'correct'));
fn = fn(~contains(fn, 'tilt'));

time_index     = decoding_all.time >= -100 & decoding_all.time <= 1500;

for f = 1:length(fn)
    decoding_all.(fn{f}) = decoding_all.(fn{f})(:,time_index);
end


%% Jackknife, leave one out

tpeak = zeros(4,2,25);

for s = 1:25
    
    jsubs = subs;
    jsubs(s) = [];
    
    i = 1;

    for f = [1,3,2,4]
        tc = mean(decoding_all.(fn{f})(jsubs,:),1);
        tpeak(i,1,s) = decoding_all.time(find(tc == max(tc)));
        ipeak = find(decoding_all.time == tpeak(i,1,s));

        for t = find(decoding_all.time >= 0 & decoding_all.time <= tpeak(i,1,s))

            if tc(t) >= 0.5 + (tc(ipeak)-0.5) * 0.50
                tpeak(i,2,s) = decoding_all.time(t);
                break
            end
    
        end 
        i = i+1;
    end

end

mean_tpeak = mean(tpeak,3);
se_tpeak = std(tpeak,[],3)/sqrt(size(tpeak,3));

%% Plot

ylims = {[0 1500], [0 650]};

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(mean_tpeak(:,i));
    hold on;
    scatter(1:4, squeeze(tpeak(:,i,:)), "filled", 'jitter', 'on')
    errorbar(mean_tpeak(:,i),se_tpeak(:,i), 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', 'none');
    
    
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);
    ylim(ylims{i})

end

%% Plot peak moment (grand average)

tpeak = zeros(4,2); i = 1;

for f = [1,3,2,4] % ordered differently here...

    tc = mean(decoding_all.(fn{f}),1);
    tpeak(i,1) = decoding_all.time(find(tc == max(tc)));
    ipeak = find(decoding_all.time == tpeak(i,1));
    
    for t = find(decoding_all.time >= 0 & decoding_all.time <= tpeak(i,1))

        if tc(t) >= 0.5 + (tc(ipeak)-0.5) * 0.50
            tpeak(i,2) = decoding_all.time(t);
            break
        end

    end    

    i = i+1;

end

%% Plot

figure;

for i = 1:length(peakperc)

    subplot(length(peakperc),1,i)

    bar(tpeak(:,i));
    ylabel('Peak time (s)'); xlabel('Condition'); title(peakperc{i})
    set(gca,'XtickLabel', probe_titles);
    ylim(ylims{i})

end





