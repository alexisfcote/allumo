classdef AllumoData < handle
    %AllumoData DataClass for Allumo GUI
    
    properties (SetObservable)
        pelvis_path;
        cuisse_path;
        humanModel;
        view_start_index=1;
        view_stop_index=3600*30;
    end
    
    properties
        p = {}% plot points objects
        l = {}% plot link objects
        a = {} % plot axes objects
        tete % plot object
        
        videoReader
        mainAxes
        videoAxes
        playing = false
        
        pelvisplot = {}
        cuisseplot = {}
        misscalibrationplot
        lineplot
    end
    
    methods
    end
    
end

