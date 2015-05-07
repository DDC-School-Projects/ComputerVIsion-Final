classdef sift_descriptor
    properties
        name
        class
        d
        f       
    end
    
    methods
        function obj = sift_descriptor(name,class,d,f)
            obj.name = name;
            obj.class = class;
            obj.d=d;
            obj.f=f;
        end;
    end
    
end

