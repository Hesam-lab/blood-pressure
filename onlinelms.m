function w = onlinelms(x,d,mu,p)
L = length(d);	
epoch = L;
w = zeros(epoch,p);
for k=1:epoch
    n = mod(k-1,L)+1;
    e = d(n)-x(n,:)*w(k,:)';
    w(k+1,:) = w(k,:) + mu/k*e*x(n,:); 
end