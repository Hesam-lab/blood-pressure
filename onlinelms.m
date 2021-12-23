function w = onlinelms(x,y,mu,p)
L = length(y);	
epoch = L;
w = zeros(epoch,p);
for k=1:epoch
    n = mod(k-1,L)+1;
    e = y(n)-x(n,:)*w(k,:)';
    w(k+1,:) = w(k,:) + mu/k*e*x(n,:); 
end