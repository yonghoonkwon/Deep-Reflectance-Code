%% Hashing for friction estimation
function HashForFriction_Demo()
clear all; close all;

addpath baselines;
addpath misc_lib;

numClass = 21;
dataDir = 'reflectance-seed-01\';
load frictionTable2
imdb = load([dataDir 'imdb\imdb-seed-1.mat']);
dcnnfv = load([dataDir 'dcnnfv-codes']);
gtX = imdb.images.label;
X = dcnnfv.code';



%% Train-test set for reflectance disk databse
friction=[];
numIns = 0;
index = [];

for i=1:size(m,1)
    friction=[friction m{i}'];
    ins = double(randi(size(m{i},1)))+numIns;
    index = [index ins];
    numIns = numIns + size(m{i},1); 
end

f=[];
numperIns=84;
for i=1:numperIns
    f = [f;friction];
end

ins_num = [6 5 10 6 8 10 6 5 5 6 10 6 6 8 6 6 6 5 5 6 6];
total_index = 1:size(X,1);
index_m = reshape(total_index, 84, uint8(size(total_index,2)/84));
    
HashFriction = [];
HFrictionPerI = [];

% false means using baseline approach
hash = true;

for iter = 1:137
    % leave one out cross validation
    disp(['Estimating Surface: ' num2str(iter)]);
    test_class = iter;
    train_class = setdiff(1:sum(ins_num), test_class);
    
    % handle the train test index
    train_m = index_m(:,train_class);
    test_m = index_m(:,test_class);
    
    train_index = reshape(train_m, 1, size(train_m(:),1));
    test_index = reshape(test_m, 1, size(test_m(:),1));
    
    % train test friciton
    train_f = f(:,train_class);
    test_f = f(:,test_class);
    
    train_friction = reshape(train_f, 1, size(train_f(:), 1));
    test_friction = reshape(test_f, 1, size(test_f(:), 1));
    
    Xtraining = X(train_index,:);
    gtX_train = gtX(train_index);
    Xtest = X(test_index,:);
    gtX_test = gtX(test_index);
    
    if hash == true
        %% LSH Hash setting
        bit = 1024;
        if iter == 1
            P = randn(size(Xtraining,2), bit);
        end

        Xtraining = Xtraining* P; 
        Xtest = Xtest* P;
        [~, R] = ITQ(Xtraining,10);
        B1 = Xtraining*R;
        B2 = Xtest*R;
        B1 = compactbit(B1>0);
        B2 = compactbit(B2>0);


        %% Evaluate

        Wtrue = zeros(size(Xtest,1), size(Xtraining,1));
        for i=1:1:size(Xtest,1)
            for j=1:1:size(Xtraining,1)
                Wtrue(i,j)=train_friction(j);
            end
        end

        Dtrue = dist_mat(Xtest,Xtraining);
        Dhat = hammingDist(B2, B1);

        kkk=10;
        for i=1:size(Dhat,1)
            [a,b] = sort(Dhat(i,:),'ascend');
            Wtrue(i,:) = Wtrue(i,b);
        end

        estimated = 0;
        % top kkk nearest neighbor
        W = Wtrue(:,1:kkk);
        M=mean(W,2);

        estimated = mean(M);
        HashFriction = [HashFriction estimated];
        HFrictionPerI = [HFrictionPerI M];
    else
        bit = 256;
        R = randn(size(Xtraining,2), bit);
        B1 = sign(Xtraining*R);
        feat = double(compactbit(B1>0));
        
        net{iter} = feedforwardnet(10);
        net{iter} = train(net{iter},feat',train_friction);
        
        B1 = sign(Xtest*R);
        feat = double(compactbit(B1>0));
        M = sim(net{iter},feat');
        HFrictionPerI = [HFrictionPerI M];
    end
end

friction_test = f(:);
prediction = HFrictionPerI(:);
figure;
dscatter(friction_test, prediction);
axis([0.2 0.7 0.2 0.7])
colormap jet
xlabel('True Friction Coefficients')
ylabel('Predicted Friction Coefficients')

background = ones(500, 42*numIns, 3);
lightGray = [189, 189, 189]/255;
lightGray = reshape(lightGray,1,1,3);
s = 0;
sn = [];
for i=1:size(m,1)
    sp = s;
    sn = [sn s];
    s = s + size(m{i},1);
    if mod(i,2)
        col = (42*(sp)+1):42*(s);
        %idx = sub2ind(size(background),1:size(background,1),col,1:3);
        background(:,col,:) = repmat(lightGray,size(background,1),size(col,2));
    end
end
sn = 2 * sn / 137 + 0.04;

FigHandle = figure;
hold on;
imagesc([0.0005 2],[0.1 0.8], background);
x= 2*(1:size(prediction,1))./size(prediction,1);
scatplot(x',prediction, 'voronoi');
axis([0 2 0.1 0.7])
colormap jet
plot(x,friction_test,'r.-');
hold off
ax = gca;
ax.XTick = sn;
ax.XTickLabel = ClassNames';
ax.XTickLabelRotation = 90;
set(gca,'fontsize',14);
set(FigHandle, 'Position', [100, 100, 1500, 450]);


figure;
hold on;
err_p = (prediction - friction_test)./prediction;
bins = -0.8:0.04:0.8;
[H,xb] = hist(err_p, bins);
H=H/sum(H(:),1);
[dummy,idx] = sort(H);

N = numel(H);
colors = jet(41);
for i=1:N
  h = bar(xb(i), H(i));
  col = colors(find(idx==i),:);
  set(h, 'FaceColor', col,'BarWidth', 0.04, 'EdgeColor', 'none') 
end
%set(get(gca,'child'),'FaceColor','b','EdgeColor','r');
axis([-0.8 0.8 0 0.15]);
xlabel('Percentage Error')
ylabel('Frequency')

err_abs = abs(prediction - friction_test);
err_absp = err_abs./friction_test;
disp(mean(err_absp))

end