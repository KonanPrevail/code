I = [150 70 5;
   60 20 3;
   800 140 20;
   30 15 1];

O = [15 225;
    5.4 70;
    56 1300;
    2.1 40];

[m n1]=size(I);
[m n2]=size(O);

% x is [v1;v2,...,vn1;u1;u2...,un2]
f=[zeros(m,n1) -O];
lb=zeros(n1+n2,1);

x=zeros(m,n1+n2);
A=[zeros(m,n1) O] - [I zeros(m,n2)];
b=zeros(m,1);

for i=1:m
    Aeq=[I(i,:) zeros(1,n2)];
    beq=1;
    z = linprog(f(i,:),A,b,Aeq,beq,lb);
    x(i,:)=z';
end
result=x.*[I O];
sum(result(:,1:3),2)
sum(result(:,4:5),2)
