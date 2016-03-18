function res = test_all_methods(Xtraining, Xtest, Wtrue, gtX_test, method, bit)

train_size = min(size(Xtraining,1), 10000);
d= size(Xtraining, 2);
rand_bit = randperm(d);

switch method
    case 'LSH'
        R = randn(size(Xtraining,2), bit);
        B1 = sign(Xtraining(1:train_size,:)*R);
        B2 = sign(Xtest*R);
        B1 = compactbit(B1>0);
        B2 = compactbit(B2>0);
        
    case 'ITQ'
        % PCA
        if (bit < size(Xtraining,2))
            [~,pc] = mixData6(Xtraining(1:train_size,:), bit);
            Xtraining = Xtraining * pc;
            Xtest = Xtest * pc;
        end
        % ITQ
        [~, R] = ITQ(Xtraining(1:train_size,:),5);
        B1 = Xtraining*R;
        B2 = Xtest*R;
        B1 = compactbit(B1>0);
        B2 = compactbit(B2>0);
        
    case 'ITQ-no-PCA'
        % Random projection
        P = randn(size(Xtraining,2), bit);
        Xtraining = Xtraining* P; 
        Xtest = Xtest* P;
        
        % itq
        [~, R] = ITQ(Xtraining(1:train_size,:),5);
        B1 = Xtraining*R;
        B2 = Xtest*R;
        B1 = compactbit(B1>0);
        B2 = compactbit(B2>0);
        
    case 'BBE-rand-orth' % BITQLOW
        % determine b1 and b2 for bit
        d = bit;
        n = 1: d;
        m = d./n;
        idx = find(abs(m - round(m)) > 0.000001);
        m(idx) = [];
        n(idx) = [];
        [~, idx] = min(abs(m-n));
        b2 = m(idx);
        b1 = n(idx);
        
        XX_train = TensorFV(Xtraining);
        XX_test = TensorFV(Xtest);
        [R1,R2] = BilinearITQ_low_rand(XX_train(:,:,1:train_size),b1,b2,5);
        
        BB = zeros(b1,b2,size(XX_train,3),'single');
        for j=1:size(XX_train,3)
            BB(:,:,j) = sign(R1'*XX_train(:,:,j)*R2);
        end
        B1 = zeros(size(XX_train,3),b1*b2,'single');
        for i=1:size(XX_train,3)
            t = BB(:,:,i);
            B1(i,:) = t(:)';
        end
        
        BB = zeros(b1,b2,size(XX_test,3),'single');
        for j=1:size(XX_test,3)
            BB(:,:,j) = sign(R1'*XX_test(:,:,j)*R2);
        end
        B2 = zeros(size(XX_test,3),b1*b2,'single');
        for i=1:size(XX_test,3)
            t = BB(:,:,i);
            B2(i,:) = t(:)';
        end
        B1 = compactbit(B1 > 0);
        B2 = compactbit(B2 > 0);
        
    case 'KBE-rand-2'      
        model = Kronecker_rand(d,bit,2,0);
        tic;
        B1 = KBE_prediction(model, Xtraining);
        B2 = KBE_prediction(model, Xtest);
        toc;
        
        B1 = compactbit(B1>0);
        B2 = compactbit(B2>0);
        
    case 'KBE-rand-orth-2'
        model = Kronecker_rand(d,bit,2,1);
        tic;
        B1 = KBE_prediction(model, Xtraining);
        B2 = KBE_prediction(model, Xtest);
        toc;
        
        B1 = compactbit(B1>0);
        B2 = compactbit(B2>0);
    
    
        
    otherwise
        serror('Unknown hashing method %s', method) ;
        
end

Dhat = hammingDist(B2, B1);

[res, label] = recognition_precision(Wtrue, Dhat, gtX_test);

end