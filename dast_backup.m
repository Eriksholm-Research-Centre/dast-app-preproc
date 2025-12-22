function status = dast_backup(tpnr)
% function to backup data to server:
% only vald files are copied
% status = 1 is success

serverpath = '\\demant.com\data\ERH\Data\Data\HLCM\HLCM.1\DAST';


tpstring = num2str(tpnr);
allfiles = dir(['results\' tpstring '*.mat']);
% Copy mat files one by one
nrfiles = length(allfiles);
if nrfiles == 0
   fprintf('dast_backup: No DAST files found for TP %d\n', tpnr); 
end
for ifile = 1:nrfiles
    current_mat =  ['results\' allfiles(ifile).name];
    
    fprintf('dast_backup: Copying file %d of %d: %s\n', ifile, nrfiles, current_mat);
    
    if exist(fullfile(serverpath, current_mat), 'file')
        fprintf('...exists already, skipped\n');
        status = 1;
    else
        [status, message] = copyfile(current_mat, serverpath);
    end
    
    if ~status
        fprintf('%s\n', message);
    end
end