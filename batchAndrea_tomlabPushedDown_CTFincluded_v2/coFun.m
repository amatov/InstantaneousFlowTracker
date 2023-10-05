function [costV,angV,deltaDv] = coFun(I,J,K,F1,F2,F3,costFunction,w1,w2,w3)

len = length(F1);
for i=1:len
    x1=I(F1(i),2);
    x2=J(F2(i),2);
    x3=K(F3(i),2);
    y1=I(F1(i),1);
    y2=J(F2(i),1);
    y3=K(F3(i),1);
    % I changed this part so the compiler can determine we are using costaa
    % function
    %%aux= feval(costFunction,x1,x2,x3,y1,y2,y3,w1,w2,w3);
    if strcmp(costFunction, 'costaa')
        aux = costaa(x1,x2,x3,y1,y2,y3,w1,w2,w3);
    else
        disp('Some problem in function coFun because changing it!');
        disp('Check the functin coFun.m');
    end
    costV(1,i) = aux(1);
    angV(i) = aux(2);
    deltaDv(i) = aux(3);
end
