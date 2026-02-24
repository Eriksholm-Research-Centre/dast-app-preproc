% script to collect DAST results from HLCM.1
% LABW, 24feb2026

% actual TP's in design
TPtest= [2002        2016        2020        2019        1681        1514        2004        1917        1585        1983        1275];  % LABW updated 11feb2026
TPtest= [2002        2016        2020        2019        1681        1514        2004        1917        1585        1983];  % LABW updated 24feb2026

% base path for results
bpath = 'results\hlcm1\';   % local
bpath = '\\demant.com\data\ERH\Data\Data\HLCM\HLCM.1\DAST\';   % server


%table for all tp
Tresult = [];

for tpnr = TPtest

    fprintf('Reading data for TP%d from %s\n', tpnr, bpath);
    matfiles = dir([bpath num2str(tpnr) '*.mat']);
    nrfiles = length(matfiles);
    if nrfiles == 0
        warning('TP %d has no data ', tpnr);
    end

    for imat = 1:length(matfiles)

        if isempty(strfind(matfiles(imat).name, 'ELJB')) &&  isempty(strfind(matfiles(imat).name, 'JSJR'))
            warning('mat file %s not by ELJB or JSJR, skipped', matfiles(imat).name)
        else
            % read data
            load([bpath matfiles(imat).name]);    % reads to data variable

            % check if correct
            if ~isfield(data, 'BlockResults')
                warning('mat file %s incomplete data, skipped', matfiles(imat).name);
                continue
            end
            assert(tpnr == data.Settings.Participant);

            % check for missing results and skip
            if  any(any(ismissing(data.BlockResults)))
                warning('mat file %s incomplete data, skipped', matfiles(imat).name);
                continue
            end
            fprintf('Complete: Data found for TP%d in %s\n', tpnr, matfiles(imat).name);

            % add tp column
            data.BlockResults.TPnr(:) = tpnr;
            % convert List nr from string to int
            data.BlockResults.List = double(data.BlockResults.List);

            if isempty(Tresult)
                Tresult = data.BlockResults;
            else
                Tresult = [Tresult; data.BlockResults];
            end

        end

    end

end
writetable(Tresult, 'HLCM1_DAST.xlsx');