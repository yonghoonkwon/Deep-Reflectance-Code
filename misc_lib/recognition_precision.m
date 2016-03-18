function [recognition, s1] = recognition_precision( Wtrue, Dhat, gtX_test)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
kkk=10;
for i=1:size(Dhat,1)
    [a,b] = sort(Dhat(i,:),'ascend');
    Wtrue(i,:) = Wtrue(i,b);
end

s1=mode(Wtrue(:,1:kkk)');
r = (s1 == gtX_test);
recognition=sum(r)/length(s1);

end

