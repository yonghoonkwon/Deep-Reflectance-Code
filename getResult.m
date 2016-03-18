function res =  getResult(dataset, method, bit)

reflectanceDir = 'data\exp01\reflectance-seed-01\';
fmdDir = 'data\exp01\fmd-seed-01\';
dtdDir = 'data\exp01\dtd-seed-01\';
kthDir = 'data\exp01\kth-seed-01\';
mitDir = 'data\exp01\mit-seed-01\';

switch dataset
    case 'fmd'
        dataDir = fmdDir;
    case 'dtd'
        dataDir = dtdDir;
    case 'mit'
        dataDir = mitDir;
    case 'reflectance'
        dataDir = reflectanceDir;
    case 'kth'
        dataDir = kthDir;
    otherwise
        serror('Unknown dataset %s', dataset) ;
end

%global imdb Wtrue gtX_test Xtraining Xtest

imdb = load([dataDir 'imdb\imdb-seed-1.mat']);
gtX = imdb.images.label;

switch method
    case 'dsift-LSH'
        dsift = load([dataDir 'dsift-codes']);
        X = dsift.code';
        hashCodes = 'LSH';
    case 'rcnn-ITQ'
        rcnn = load([dataDir 'rcnn-codes']);
        X = rcnn.code';
        hashCodes = 'ITQ';
    case 'vlad-KBE'
        dcnnvlad = load([dataDir 'dcnnvlad-codes']);
        X = dcnnvlad.code';
        hashCodes = 'KBE-rand-2';
    case 'vlad-KBE-orth'
        dcnnvlad = load([dataDir 'dcnnvlad-codes']);
        X = dcnnvlad.code';
        hashCodes = 'KBE-rand-orth-2';
    case 'dcnn-LSH'
        dcnnfv = load([dataDir 'dcnnfv-codes']);
        X = dcnnfv.code';
        hashCodes = 'LSH';
    case 'dcnn-ITQ'
        dcnnfv = load([dataDir 'dcnnfv-codes']);
        X = dcnnfv.code';
        hashCodes = 'ITQ';
    case 'dcnn-KBE-orth'
        dcnnfv = load([dataDir 'dcnnfv-codes']);
        X = dcnnfv.code';
        hashCodes = 'KBE-rand-orth-2';
    case 'dcnn-ITQ-rand'
        dcnnfv = load([dataDir 'dcnnfv-codes']);
        X = dcnnfv.code';
        hashCodes ='ITQ-no-PCA';
    otherwise
        serror('Unknown method %s', method) ;
end

if strcmp(dataset, 'reflectance')
    numClass = 21;
    rng('shuffle')
    ins_num = [6 5 10 6 8 10 6 5 6 5 6 6 10 6 8 6 6 6 5 5 6];
    sum_i = 0;
    test_class = [];
    for i=1:numClass
        test_class = [test_class sum_i+randi([1 ins_num(i)])];
        sum_i = sum_i + ins_num(i);
    end
    
    train_class = setdiff(1:sum(ins_num), test_class);
    
    total_index = 1:size(X,1);
    index_m = reshape(total_index, 84, uint8(size(total_index,2)/84));
    train_m = index_m(:,train_class);
    test_m = index_m(:,test_class);
    
    train_index = reshape(train_m, 1, size(train_m(:),1));
    test_index = reshape(test_m, 1, size(test_m(:),1));
    
    Xtraining = X(train_index,:);
    gtX_train = gtX(train_index);
    Xtest = X(test_index,:);
    gtX_test = gtX(test_index);
elseif strcmp(dataset, 'kth')
    numClass = 11;
    rng('shuffle')
    ins_num = 4 * ones(1,numClass);
    sum_i = 0;
    test_class = [];
    for i=1:numClass
        test_class = [test_class sum_i+randi([1 ins_num(i)])];
        sum_i = sum_i + ins_num(i);
    end
    
    train_class = setdiff(1:sum(ins_num), test_class);
    
    total_index = 1:size(X,1);
    index_m = reshape(total_index, 108, uint8(size(total_index,2)/108));
    train_m = index_m(:,train_class);
    test_m = index_m(:,test_class);
    
    train_index = reshape(train_m, 1, size(train_m(:),1));
    test_index = reshape(test_m, 1, size(test_m(:),1));
    
    Xtraining = X(train_index,:);
    gtX_train = gtX(train_index);
    Xtest = X(test_index,:);
    gtX_test = gtX(test_index);
else
    rng('shuffle') 
    index = randperm(size(X,1));
    X = X(index,:);
    gtX = gtX(1,index);
    
    train_size = floor(0.8*size(gtX,2));
    Xtraining = X(1:train_size,:);
    gtX_train = gtX(1:train_size);
    Xtest = X(train_size+1:end,:);
    gtX_test = gtX(train_size+1:end);
    
end

Wtrue = zeros(size(Xtest,1), size(Xtraining,1));
for i=1:1:size(Xtest,1)
    for j=1:1:size(Xtraining,1)
        Wtrue(i,j)=gtX_train(j);
    end
end

res = [];

if (strcmp(method,'PQ')||strcmp(method,'KPQ'))% All the quantization methods
        res = test_quantization_method(Xtraining', Xtraining', Xtest', Wtrue, para{i}, method);
else
    res = test_all_methods(Xtraining, Xtest, Wtrue, gtX_test, ...
    hashCodes, bit);
end
end

