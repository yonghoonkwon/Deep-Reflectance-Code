function runExperiments()
% Run Hashing for Material Recognition Experiments
% Copyright (C) 2016 Hang Zhang, Rutgers University

setup;
global index;
index = 1;

path_model_vgg_m = 'data/models/imagenet-vgg-m.mat';

%% encodings

% RCNN (FC-CNN) flavors
rcnn.name = 'rcnn' ;
rcnn.opts = {...
    'type', 'rcnn', ...
    'model', path_model_vgg_m, ...
    'layer', 19} ;


dcnn.name = 'dcnnfv' ;
dcnn.opts = {...
    'type', 'dcnn', ...
    'model', path_model_vgg_m, ...
    'layer', 13, ...
    'numWords', 64, ...
    'encoderType', 'fv'};


dcnnvlad.name = 'dcnnvlad' ;
dcnnvlad.opts = {...
    'type', 'dcnn', ...
    'model', path_model_vgg_m, ...
    'layer', 13, ...
    'numWords', 64, ...
    'encoderType', 'vlad'} ;

dsift.name = 'dsift' ;
dsift.opts = {...
    'type', 'dsift', ...
    'numWords', 256, ...
    'numPcaDimensions', 80} ;

% Set of experiments to run
setupNameList = {'rcnn', 'dcnn', 'dsift', 'dcnnvlad'}; % ,'rdcnn'
encoderList = {{rcnn}, {dcnn}, {dsift}, {dcnnvlad}}; % ,{rcnn dcnn}
datasetList = {{'reflectance',1}, {'fmd',14},{'dtd',10},{'kth', 4}} ;%
%, ,, {'voc07',1}, {'os',1}


for ii = 1 : numel(datasetList)
    dataset = datasetList{ii} ;
    
    if iscell(dataset)
        numSplits = dataset{2} ;
        dataset = dataset{1} ;
    else
        numSplits = 1 ;
    end
    
    for jj = 1 : numSplits
        for ee = 1: numel(encoderList)
            os_train(...
                'dataset', dataset, ...
                'seed', jj, ...
                'encoders', encoderList{ee}, ...
                'prefix', 'exp01', ...
                'suffix', setupNameList{ee}, ...
                'printDatasetInfo', ee == 1, ...
                'writeResults', true, ...
                'vocDir', 'data/VOC2007', ...
                'useGpu', true, ...
                'gpuId', 1);
        end
    end
end

clear all;
%% Hashing 

datasetList = {'reflectance','fmd','dtd', 'kth'};%'mit'
method = { 'dsift-LSH', 'rcnn-ITQ','vlad-KBE-orth', 'dcnn-KBE-orth'... % ,,'vlad-KBE'
    'dcnn-LSH', 'dcnn-ITQ'};% ,'dcnn-ITQ-rand', ,, 'dcnn-ITQ'
bits = 2.^([ 8 9 10 11 12]);%;

for k = bits
    iters = 10;
    for l = 1:iters
        for i=1:length(datasetList)
            for j = length(method)
                res(i,j,bits==k,l) = getResult(datasetList{i}, method{j}, k);
            end
        end
    end
end
aver_res = mean(res,4);

for i=1:size(res,1)
    for j=1:size(res,2)
        array = reshape(res(i,j,1,:),1,iters);
        sigma(i,j) = std(array);
    end
end


method2 = { 'FV-SIFT-H', 'CNN-ITQ','vlad-CNN-KBE', 'FV-CNN-KBE'...
    'FV-CNNH-rand', 'FV-CNNH-opt'};

r2 = reshape(aver_res(2,:,:),5,5);
drawFigure2016(2.^([ 8 9 10 11 12]),method,r2)
r3 = reshape(aver_res(3,:,:),5,5);
drawFigure2016(2.^([ 8 9 10 11 12]),method,r3)

end
