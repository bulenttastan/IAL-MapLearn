classdef UserData
    %USERDATA Creates and stores user data on the Map
    %   
    
    properties
        Trace   % The created trace data
    end
    
    methods(Static=true)
        function generate_trace(m)
            %Calculate all node shortest path graph for later processing
            num_states = length(m.S);
            aF = [];
            aT = [];
            aW = [];
            for i=1:num_states
                for ni=m.S(i).connection
                    if m.S(i).is_obstacle || m.S(ni).is_obstacle; continue; end
                    aF = [aF i];
                    aT = [aT ni];
                    dst = sqrt((m.S(i).x - m.S(ni).x)^2 + (m.S(i).y - m.S(ni).y)^2);
                    aW = [aW dst];
                end
            end
            DG = sparse(aF,aT,aW);


            %the node with the max particles
            AllShortestPaths = cell(num_states,num_states);
            for A=1:num_states
                for B=1:num_states
                    if A==B; continue; end
                    if m.S(A).is_obstacle || m.S(B).is_obstacle; continue; end
                    [d,path,pred] = graphshortestpath(DG,A,B);
                    AllShortestPaths{A,B} = struct('path',path,'distance',d);
                end
            end
            save('AllShortestPaths', 'AllShortestPaths');
        end
    end
    
end

