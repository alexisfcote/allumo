classdef AllumoData < handle
    %AllumoData DataClass for Allumo GUI
    
    properties (SetObservable)
        pelvis_path;
        cuisse_path;
        humanModel;
        hour=0;
    end
    
    properties
        p = {}% plot points objects
        l = {}% plot link objects
        a = {} % plot axes objects
        tete % plot object
        
        videoReader
        mainAxes
        videoAxes
        
        pelvisplot = {}
        cuisseplot = {}
        lineplot
    end
    
    methods
    end
    
end

