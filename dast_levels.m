function Tout = dast_levels(tpnr, listnr)
% function to check DAST files and measure levels
%   input: listnr(s) as vector in range 1-11
%   output: table with rms and peak levels

% TODO: remove .5s beginning and end

% defaults shared with DAST app
sopt = preproc_defaults;
basepath = sopt.targetpath;
fs = sopt.fs;

csvfile = 'Corpus_DAST\metadata\List_F1A.csv';
fprintf('Reading list definitions %s\n', csvfile);
dast_lists = readtable(csvfile);

% make a row filter and select the list
rf = rowfilter(dast_lists);
sel_lists = dast_lists(rf.List == listnr, :);
nrsent = height(sel_lists);
header = {'SNR', 'Talker', 'Condition', 'Peak level', 'RMS level', 'Acoustic level'};
%Tout = table;
irow = 1;
nrcond = 7;
silgap = 0.5 * fs;  % nr samples to remove = 0.5 sec
for snr = sopt.SNRs
    for talker = sopt.talkers
        sumcond = zeros(1,nrcond);
        peakcond = zeros(1,nrcond);
        for icond = 1:nrcond     % processing conditions
            rmslist = zeros(1,nrsent);
            peaklist = zeros(1,nrsent);
            for isent = 1:nrsent
                filepath = fullfile(basepath, ['TP_' num2str(tpnr)], ['SNR_' num2str(snr)], talker{1}, ['condition_' num2str(icond)]);
                if ~exist(filepath, "dir")
                    % skip missing dirs
                    continue;
                end
                filenr = sel_lists(isent, "Sentence").Sentence;
                filename = fullfile(filepath, sprintf('%04d.wav', filenr));

                if exist(filename, "file")
                    %fprintf('%s\n', filename);
                    info = audioinfo(filename);
                    y = audioread(filename);
                    
                    % remove 0.5s beginning and end
                    y(1:silgap) = [];
                    y(end-silgap+1:end) = [];

                    peak = max(abs(y(:)));
                    peaklist(isent) = peak;
                    rms = std(y(:));
                    rmslist(isent) = rms;
                    if peak >= 1
                        warning('File %s is clipped.',filename);
                    end
                else
                    warning('\tFile %s not found.', filename);
                end

            end
            % average across sentences in lists
            peakcond(icond) = max(peaklist);
            sumcond(icond) = sqrt((sum(rmslist.^2))/nrsent);
            fprintf('SNR %d dB, Talker %s, Cond %d: Peak level %2.1f dBFS, rms level %2.1f dBFS, acoustic level %2.1f dB SPL \n', ...
                snr, talker{1}, icond, 20*log10(peakcond(icond)), 20*log10(sumcond(icond)), 20*log10(sumcond(icond)) + sopt.peakSPL);
            % build the vectors
            SNR(irow) = snr; %#ok<*AGROW>
            Talker(irow) = talker;
            Condition(irow) = icond;
            PeakLevel(irow) = 20*log10(peakcond(icond));
            RMSLevel(irow) = 20*log10(sumcond(icond));
            AcousticLevel(irow) = RMSLevel(irow) + sopt.peakSPL;
            irow = irow+1;
        end
    end
end
% use columns here
Tout = table(SNR', Talker', Condition', PeakLevel', RMSLevel', AcousticLevel', 'VariableNames',header);
writetable(Tout, ['TP' num2str(tpnr) '_L' num2str(listnr) '_levels.csv']);