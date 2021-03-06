classdef matchFeaturesApproxNN < coder.ExternalDependency %#codegen
    
    % Copyright 2012 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'matchFeatures';
        end
        
        function b = isSupportedContext(~)
            b = true; % supports non-host target
        end

        function updateBuildInfo(buildInfo, context)
            buildInfo.addIncludePaths({fullfile(matlabroot,'toolbox', ...
                'vision','builtins','src','ocv','include'), ...
                fullfile(matlabroot,'toolbox', ...
                'vision','builtins','src','ocvcg', 'opencv', 'include')} );

            buildInfo.addSourcePaths({fullfile(matlabroot,'toolbox', ...
                'vision','builtins','src','ocv')});
            buildInfo.addSourceFiles({'matchFeaturesApproxNNCore.cpp', ...
                'mwflann.cpp', ...  
                'mwminiflann.cpp'});

            buildInfo.addIncludeFiles({'vision_defines.h', ...
                                       'precomp_flann.hpp'});
            
            % add flann directory with all header files (using hack)
            fileLists = coder.internal.const('../../../../builtins/src/ocv/include/flann/*');
            buildInfo.addNonBuildFiles(fileLists, '','BlockModules');
                                 
            vision.internal.buildable.portableOpenCVBuildInfo(buildInfo, context, ...
                'matchFeatures');            
        end
        
        %------------------------------------------------------------------
        % write all supported data-type specific function calls
        function [indexPairs, matchMetric] = ...
                findApproximateNearestNeighbors(features1, features2, metric)                             
            
            coder.inline('always');
            coder.cinclude('matchFeaturesCore_api.hpp');              
            
            M  = cast(size(features1,2),'int32');
            N1 = cast(size(features1,1),'int32');
            N2 = cast(size(features2,1),'int32');                
                                         
            % When there is only 1 feature vector in features2 we cannot
            % find 2 nearest neighbors.
            if N2 > 1
                knn = int32(2);
            else
                knn = int32(1);
            end
            
            if coder.isColumnMajor
                indexPairs  = coder.nullcopy(zeros(knn, N1, 'int32'));
            else
                indexPairs  = coder.nullcopy(zeros(N1, knn, 'int32'));
            end                
            
            if strcmpi(metric, 'hamming')
                if coder.isColumnMajor
                    matchMetric = coder.nullcopy(zeros(knn, N1, 'int32'));
                    coder.ceval('-col','findApproximateNearestNeighbors_uint8',...
                        features1', ...
                        features2', ...
                        metric,...
                        N1, N2, M, knn, ...
                        coder.ref(indexPairs),...
                        coder.ref(matchMetric));
                else
                    matchMetric = coder.nullcopy(zeros(N1, knn, 'int32'));
                    coder.ceval('-row','findApproximateNearestNeighbors_uint8',...
                        coder.ref(features1), ...
                        coder.ref(features2), ...
                        metric,...
                        N1, N2, M, knn, ...
                        coder.ref(indexPairs),...
                        coder.ref(matchMetric));
                end
            else
                if coder.isColumnMajor
                    matchMetric = coder.nullcopy(zeros(knn, N1, 'single'));
                    coder.ceval('-col','findApproximateNearestNeighbors_real32',...
                        features1', ...
                        features2', ...
                        metric,...
                        N1, N2, M, knn, ...
                        coder.ref(indexPairs),...
                        coder.ref(matchMetric));
                else
                    matchMetric = coder.nullcopy(zeros(N1, knn, 'single'));
                    coder.ceval('-row','findApproximateNearestNeighbors_real32',...
                        coder.ref(features1), ...
                        coder.ref(features2), ...
                        metric,...
                        N1, N2, M, knn, ...
                        coder.ref(indexPairs),...
                        coder.ref(matchMetric));
                end
            end
        end
    end
end
