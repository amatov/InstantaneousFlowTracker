function saveTrajectoriesToFile(MPM)

% saveTrajectoriesToFile open text files and writes 
% in them trajectories extracted from the "magic" matrix
%
% SYNOPSIS      saveTrajectoriesToFile(MPM)
%
% 
% INPUT         fsmParam    : MPM matrix
%
% OUTPUT        none        : writes to disk text files
%
% DEPENDENCES   fsmMain uses {  }
%               fsmMain is used by {  }
%
% Alexandre Matov, January 7th, 2003

% Open text file for output
fid=fopen('trajectories.txt','wt+');
fid2=fopen('trajectories_noghosts.txt','wt+');
fid3=fopen('trajectories_ghost.txt','wt+');

for i=1:size(MPM,1)
    row=MPM(i,:);
    indx=find(row~=0);
    if length(indx)==length(row) % If no zeros, write the whole line
        fprintf(fid,'%d ',row);
        fprintf(fid,'\n');
        if length(row)>2 % Only write in file 2 if no ghost
            fprintf(fid2,'%d ',row);
            fprintf(fid2,'\n');   
        end
    else
        c=0; counter=0; traj=[]; % Reset counters
        while c<length(row)
            c=c+1;
            if row(c)~=0 % Forget if 0
                counter=counter+1;
                traj(counter)=row(c);
            end
            if row(c)==0 | c==length(row) % Write if next 0 or end of line reached
                if ~isempty(traj)
                    fprintf(fid,'%d ',traj);
                    fprintf(fid,'\n');   
                    if length(traj)>2 % Only write in file 2 if no ghost
                        fprintf(fid2,'%d ',traj);
                        fprintf(fid2,'\n');   
                    end
                    if length(traj)==2 % Only write in file 3 if there are ghost
                        fprintf(fid3,'%d ',traj);
                        fprintf(fid3,'\n');   
                    end
                    traj=[]; % Reset trajectory
                    counter=0; % Reset counter
                end
            end
        end
    end
end

% Close files
fclose(fid);
fclose(fid2);

