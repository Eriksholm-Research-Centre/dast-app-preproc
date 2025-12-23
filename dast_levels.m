function slevels = dast_levels(tpnr, listnr)
% function to check DAST files and measure levels
%   input: listnr(s) as vector in range 1-11

% defaults shared with DAST app
sopt = preproc_defaults;
basepath = sopt.targetpath;


csvfile = 'Corpus_DAST\metadata\List_F1A.csv';
fprintf('Reading list definitions %s\n', csvfile);
dast_lists = readtable(csvfile);

% make a row filter and select the list
rf = rowfilter(dast_lists);
sel_lists = dast_lists(rf.List == listnr, :);

slevels = [];
ix = 1;
for snr = sopt.SNRs
    for talker = sopt.talkers
        for icond = 1:7     % processing conditions
            for isent = 1:height(sel_lists)
                filepath = fullfile(basepath, ['TP_' num2str(tpnr)], ['SNR_' num2str(snr)], talker{1}, ['condition_' num2str(icond)]);

                filenr = sel_lists(isent, "Sentence").Sentence;
                filename = fullfile(filepath, sprintf('%04d.wav', filenr));

                if exist(filename, "file")
                    fprintf('%s\n', filename);
                    info = audioinfo(filename);
                    y = audioread(filename);
                    peak = max(abs(y(:)));
                    rms = std(y(:));
                    fprintf('\tOutput peak level %2.1f dBFS, rms level %2.1f dBFS, acoustic level %2.1f dB SPL \n', ...
                        20*log10(peak), 20*log10(rms), 20*log10(rms) + sopt.peakSPL);
                    if peak >= 1
                        warning('File %s is clipped.',filename);
                    end
                else
                    warning('File %s not found, skipping it\n', filename);
                end
              
            end
                % average across sentences in lists


        end
    end
end