% script to collect DAST results from HLCM.1
% LABW, 24feb2026


% anonymous TPnr
% make word scores
anonym = 1;         % Eriksholm use 0, external use 1

% actual TP's in design
TPtest= [2002        2016        2020        2019        1681        1514        2004        1917        1585        1983        1275];  % LABW updated 11feb2026
TPtest= [2002        2016        2020        2019        1681        1514        2004        1917        1585        1983];  % LABW updated 24feb2026

TPanon= [13          2           14          4           5           6           15          8           9           10 ];

% base path for results
bpath = 'results\hlcm1\';   % local
bpath = '\\demant.com\data\ERH\Data\Data\HLCM\HLCM.1\DAST\';   % server


%table for all tp
Tresult = [];

for tpnr = TPtest

    dout = [];

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
            itp = find(TPtest == tpnr);
            tpnra = TPanon(itp);
            fprintf('Complete: Data found for TP%d anonym %d in %s\n', tpnr, tpnra, matfiles(imat).name);

            % add tp column
            if anonym
                data.BlockResults.TPnr(:) = tpnra;          % anonymous for external sharing
            else
                data.BlockResults.TPnr(:) = tpnr;
            end

            % add talker column
            talker = data.SentenceInfo.Target{1};   % all the same
            data.BlockResults.Talker(:) = string(talker);

            % convert List nr from string to int
            data.BlockResults.List = double(data.BlockResults.List);

            % save full data for anonym mode (Szymon)
            if anonym
                dout.BlockResults = data.BlockResults;
                dout.KeywordScore = data.KeywordScore;
                dout.SentenceInfo = data.SentenceInfo;
                fprintf('Saving anonym tpnr %d\n', tpnra);
                save(num2str(tpnra), "dout");
            end

            % do rau tranformation on % scores
            data.BlockResults.Score = rau(data.BlockResults.Score/100, 20);

            if isempty(Tresult)
                Tresult = data.BlockResults;
            else
                Tresult = [Tresult; data.BlockResults];
            end

        end

    end

end
writetable(Tresult, 'HLCM1_DAST.xlsx');