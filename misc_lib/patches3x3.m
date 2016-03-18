function [ dst ] = patches3x3( src )

dst = zeros(size(src,1),size(src,2),size(src,3),9);
dst(:,:,:,1) = src;
dst(:,:,:,2) = src([2:end,1],:,:);
dst(:,:,:,3) = src([end,1:end-1],:,:);
dst(:,:,:,4) = src(:,[2:end,1],:);
dst(:,:,:,5) = src(:,[end,1:end-1],:);
dst(:,:,:,6) = src([2:end,1],[2:end,1],:);
dst(:,:,:,7) = src([2:end,1],[end,1:end-1],:);
dst(:,:,:,8) = src([end,1:end-1],[2:end,1],:);
dst(:,:,:,9) = src([end,1:end-1],[end,1:end-1],:,:);

end

