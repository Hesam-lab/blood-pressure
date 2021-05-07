function w = batchlms(x,d,mu,p,epoch)	
w = zeros(epoch,p);
for k=1:epoch
    e = d-x*w(k,:)';
    w(k+1,:) = w(k,:) + mu/k*e'*x; 
end