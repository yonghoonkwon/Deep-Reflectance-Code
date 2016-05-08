function  imdb = reflectance_get_database(datasetDir, varargin)
opts.seed = 1 ;
opts = vl_argparse(opts, varargin) ;

rng(opts.seed) ;

imdb.imageDir = fullfile(datasetDir, 'images') ;

cats = dir(imdb.imageDir) ;
cats = cats([cats.isdir] & ~ismember({cats.name}, {'.','..'})) ;
imdb.classes.name = {cats.name} ;
imdb.images.id = [] ;
imdb.sets = {'train', 'val', 'test'} ;
ins_num=[];
for c=1:numel(cats)
  dirinfo = dir(fullfile(imdb.imageDir, imdb.classes.name{c}));
  dirinfo(~[dirinfo.isdir]) = [];
  dirinfo = dirinfo(3:end)';
  ims = cell(1);
  ins_num = [ins_num length(dirinfo)];
  for K = 1 : length(dirinfo)
    imsi{K} = dir(fullfile(imdb.imageDir, imdb.classes.name{c}, dirinfo(K).name,'*.bmp'));
    if size(imsi{K})>84
        imsi{K} = imsi{K}(1:84);
    end
    for M = 1:size(imsi{K})
        imsi{K}(M).name = [dirinfo(K).name '\' imsi{K}(M).name];
    end
    if K==1
        ims = imsi{1};
    else
        ims = cat(1,ims, imsi{K});
    end
  end
  
  imdb.images.name{c} = cellfun(@(S) fullfile(imdb.classes.name{c}, S), ...
    {ims.name}, 'Uniform', 0);
  imdb.images.label{c} = c * ones(1,numel(ims)) ;
  
end

imdb.images.name = horzcat(imdb.images.name{:}) ;
imdb.images.label = horzcat(imdb.images.label{:}) ;
%imdb.images.set = horzcat(imdb.images.set{:}) ;
imdb.images.id = 1:numel(imdb.images.name) ;

imdb.images.set = zeros(1,size(imdb.images.name,2));
imdb.segments = imdb.images ;
imdb.segments.imageId = imdb.images.id ;

% make this compatible with the OS imdb
imdb.meta.classes = imdb.classes.name ;
imdb.meta.inUse = true(1,numel(imdb.meta.classes)) ;
imdb.segments.difficult = false(1, numel(imdb.segments.id)) ;

numClass = 21;
sum_i = 0;
test_class = [];
for i=1:numClass
    test_class = [test_class sum_i+randi([1 ins_num(i)])];
    sum_i = sum_i + ins_num(i);
end

train_class = setdiff(1:sum(ins_num), test_class);

total_index = 1:size(imdb.images.name,2);
index_m = reshape(total_index, 84, uint8(size(total_index,2)/84));
train_m = index_m(:,train_class);
test_m = index_m(:,test_class);

train_index = reshape(train_m, 1, size(train_m(:),1));
test_index = reshape(test_m, 1, size(test_m(:),1));

imdb.images.set(1, test_index) = 3;
imdb.images.set(1, train_index) = 1;

sel_train = find(imdb.images.set == 3);
imdb.images.set(sel_train(1 : 2 : end)) = 2;
imdb.segments.set = imdb.images.set;

