function w = batchlms(x,y,mu,p,epoch)	
w = zeros(epoch,p);
for k=1:epoch
    e = y-x*w(k,:)';
    w(k+1,:) = w(k,:) + mu/k*e'*x; 
end