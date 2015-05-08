classdef sift_descriptor
    properties
        name
        classname
        class
        d
        f  
        
    end
    
    methods
        function obj = sift_descriptor(name,class,i,f,d)
            obj.name = name;
            obj.classname = class;
            obj.class=i;
            obj.d=d;
            obj.f=f;
        end;
    end
    
end

