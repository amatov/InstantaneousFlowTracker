counter=1
for i=1:length(a)
    row=find(c==b(i));
    for j=1:length(row)
        F1(counter)=a(i);
        F2(counter)=b(i);
        F3(counter)=d(row(j));
        counter=counter+1;
    end
end