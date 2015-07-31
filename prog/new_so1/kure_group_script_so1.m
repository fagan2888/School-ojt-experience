function kure_group_script_so1(fnStr, gNoV, setNoV)
% Write a unix shell script that submits all batch jobs
%{
IN
   fnStr
      file name, such as run_g3_alphahsg.sh
%}
% ------------------------------------------------------

cS = const_so1(gNoV(1), setNoV(1));
saveHistory = cS.alwaysSaveHistories;

% Expand inputs to vectors
n = max(length(gNoV), length(setNoV));
gNoV = gNoV(:) .* ones([n,1]);
setNoV = setNoV(:) .* ones([n,1]);


fid = fopen(fnStr, 'w');

for i1 = 1 : n
   cmdStr = kure_command_so1(saveHistory, gNoV(i1), setNoV(i1), []);
   fprintf(fid, cmdStr);
   fprintf(fid, '\n');
   
   if i1 < n
      % This gives the shell time to get each job started
   	fprintf(fid, 'sleep 5 \n');
   end
end

fclose(fid);

disp(['Created group script    ', fnStr]);

end