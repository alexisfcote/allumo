classdef ZeroedTime
    % Data class that holds information about a zeroed time (calibration time)
    
    properties
        start_index
        stop_index
        Qpelvis
        Qcuissegauche
    end
    
    methods
        function obj = ZeroedTime(start_index, stop_index, Qpelvis, Qcuissegauche)
        obj.start_index = start_index;
        obj.stop_index  = stop_index;
        obj.Qpelvis = Qpelvis;
        obj.Qcuissegauche = Qcuissegauche;
        end
    end
    
end

