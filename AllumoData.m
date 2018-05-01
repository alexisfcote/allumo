classdef AllumoData < handle
    %AllumoData DataClass for Allumo GUI
    
    properties (SetObservable)
        pelvis_path;
        cuisse_path;
        humanModel;
    end
    
    properties
        p = {}% plot points objects
        l = {}% plot link objects
        a = {} % plot axes objects
        tete % plot object
        
        pelvisplot = {}
        cuisseplot = {}
        lineplot
    end
    
    methods
    end
    
end

