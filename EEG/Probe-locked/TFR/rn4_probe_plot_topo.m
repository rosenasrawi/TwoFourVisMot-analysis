%% Clean workspace

clc; clear; close all

%% Load contrasts

[param, eegfiles] = rn4_gen_param(1);

load([param.path, 'Processed/Locked probe/tfr contrasts probe/' 'mean_rvsl_probe_all'], 'mean_rvsl_probe_all');

%% Variables

fn = fieldnames(mean_rvsl_probe_all);
fn = fn(contains(fn, 'load'));

time_select = {[0 0.25], [0.25 0.5], [0.5 0.75], [0.75 1], [1 1.25], [1.25 1.5]};

%% Plot topo

%% Visual 

%% Load two

contrast = 'rvsl_item_load_two';

plot_topo(mean_rvsl_probe_all, contrast, time_select, [-6 6], [8 12])

saveas(gcf, [param.figpath '/TFR/cvsi/topo-visual-two'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/topo-visual-two'], 'png');

%% Load four

contrast = 'rvsl_item_load_four';

plot_topo(mean_rvsl_probe_all, contrast, time_select, [-8 8], [8 12])

saveas(gcf, [param.figpath '/TFR/cvsi/topo-visual-four'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/topo-visual-four'], 'png');

%% Motor

%% Load two

contrast = 'rvsl_resp_load_two';

plot_topo(mean_rvsl_probe_all, contrast, time_select, [-6 6], [13 30])

saveas(gcf, [param.figpath '/TFR/cvsi/topo-motor-two'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/topo-motor-two'], 'png');

%% Load four

contrast = 'rvsl_resp_load_four';

plot_topo(mean_rvsl_probe_all, contrast, time_select, [-6 6], [13 30])

saveas(gcf, [param.figpath '/TFR/cvsi/topo-motor-four'], 'epsc');
saveas(gcf, [param.figpath '/TFR/cvsi/topo-motor-four'], 'png');

%% Plot topo general function

function plot_topo(struct, contrast, time_select, zlim, ylim)
    
    figure;
    
    for t = 1:length(time_select)
    
        subplot(1,length(time_select), t)
    
        cfg = [];
    
        cfg.layout    = 'easycapM1.mat';
        cfg.zlim      = zlim;
        cfg.ylim      = ylim;
        cfg.xlim      = time_select{t};
    
        cfg.comment   = 'no';
        cfg.style     = 'straight';
        cfg.colorbar  = 'no'; 
        cfg.parameter = contrast;
    
        ft_topoplotTFR(cfg, struct);
        colormap(flipud(brewermap(100,'RdBu')));
        
    end   

    set(gcf, "renderer", "Painters");
    set(gcf, "Position", [500 500 1200 1200]);
end
