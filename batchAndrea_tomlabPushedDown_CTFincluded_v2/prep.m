% for i=1:10
%     diffx{i}=newtrack{i+1}(:,1)-newtrack{i}(:,1)
%     diffy{i}=newtrack{i+1}(:,2)-newtrack{i}(:,2)
%     angleindeg{i}=atan2(diffy{i},diffx{i})*180/pi
% end

    diffx=newtrack{8}(:,1)-newtrack{1}(:,1)
    diffy=newtrack{8}(:,2)-newtrack{1}(:,2)
    angleindeg=mod(atan2(diffy,diffx),2*pi)
    angleindeg=angleindeg*180/pi
%     angleindeg=atan2(diffy,diffx)
%     angleindeg=angleindeg*180/pi
%     if (angleindeg(:)<0)
%         angleindeg=angleindeg+360
%     end
    