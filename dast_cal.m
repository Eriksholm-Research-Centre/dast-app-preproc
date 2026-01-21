function y_cal = dast_cal(tpnr, listnr, talker)
% function to play unprocessed DAST files and measure levels and play for calibration
%   input: listnr(s) as vector in range 1-11
%   output: table with rms and peak levels

% defaults shared with DAST app
sopt = preproc_defaults;
basepath = sopt.targetpath;
fs = sopt.fs;
silgap = 0.5 * fs;  % nr samples to remove = 0.5 sec
fs_out = 44100;

csvfile = 'Corpus_DAST\metadata\List_F1A.csv';
fprintf('Reading list definitions %s\n', csvfile);
dast_lists = readtable(csvfile);

% make a row filter and select the list
rf = rowfilter(dast_lists);
sel_lists = dast_lists(rf.List == listnr, :);
nrsent = height(sel_lists);
%header = {'SNR', 'Talker', 'Condition', 'Peak level', 'RMS level', 'Acoustic level'};
%Tout = table;
irow = 1;

sumcond = 0;
peakcond = 0;
icond = 1;      % processing conditions: unaided
snr = 0;        % use the SNR 0 folder
rmslist = zeros(1,nrsent);
peaklist = zeros(1,nrsent);
y_cal = zeros(10,1);     % calibration signal is a column vcector
i_end = 0;
for isent = 1:nrsent
    filepath = fullfile(basepath, ['TP_' num2str(tpnr)], ['SNR_' num2str(snr)], talker, ['condition_' num2str(icond)]);
    if ~exist(filepath, "dir")
        % skip missing dirs
        continue;
    end
    filenr = sel_lists(isent, "Sentence").Sentence;
    filename = fullfile(filepath, sprintf('%04d.wav', filenr));

    if exist(filename, "file")
        fprintf('Reading list %d: %s\n', listnr, filename);
        info = audioinfo(filename);
        [y, fs_file] = audioread(filename);
        assert(fs_file == fs);
        % remove 0.5s beginning and end
        y(1:silgap) = [];
        y(end-silgap+1:end) = [];
        len_sent = length(y);
        y_cal((i_end+1:i_end+len_sent)') = y;        % append
        i_end = i_end + len_sent;

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
    snr, talker, icond, 20*log10(peakcond(icond)), 20*log10(sumcond(icond)), 20*log10(sumcond(icond)) + sopt.peakSPL);

% resample for 44100

% resample and write
if fs_file ~= fs_out
    % resample on the fly
    G = gcd(fs_file,fs_out);
    n_up = fs_out/G;
    n_down = fs_file/G;

    %do it
    y_cal = resample(y_cal, n_up, n_down);
end

% loop it in soundmexpro
clear soundmexpro;

% get drivers
[ok, drivers] = soundmexpro('getdrivers');
assert(ok);

soundmexpro('init', ...
    'driver', drivers{1}, ...
    'samplerate', fs_out, ...
    'numbufs', 10, ... % software buffering to avoid drops (see SoundMexPro documentation for more info)
    'output', [14 15], ... % zero base
    'track', 2, ... % uses default 'circular' mapping
    'autocleardata',1, ... % all audio data segments that were already played completely are freed from memory on every 'loadfile' or 'loadmem' command
    'quiet', 1 ...
    );


% listOfChannels = unique([app.data.Settings.PlaybackChannelsTarget app.data.Settings.PlaybackChannelsMasker]);
% [~,idxFilter] = ismember(app.data.Settings.PlaybackChannelsTarget,listOfChannels);
%fprintf('loadMixAndPlaySentence(): SMP playing %s\n', app.iter.targetFullfile );  % LABW
soundmexpro('loadmem', ...
    'data', y_cal, ...
    'track', [0 1], ...
    'loopcount', 0 ...          % loop
    );

soundmexpro('start','length',0);

