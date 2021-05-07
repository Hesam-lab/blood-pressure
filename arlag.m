function x = arlag(ts,N,p)
x=zeros(N-p,p);
for i=1:p
    x(:,i)=ts(p-i+1:end-i);
end
