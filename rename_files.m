% script to rename files from Szymon back to DAST sentence nrs.

clear all;
directory = 'C:\Temp\larsnoise_m1_5dB\condition_1';
prefix = 'reference';
output_directory = '\\demant.com\data\ERH\Media\Media\HLCM\HLCM.2\DAST\TP_1000\SNR_5\M1\condition_1';
csvfile = 'Corpus_DAST\metadata\List_F1A.csv';


if ~exist(output_directory, 'dir')
    mkdir(output_directory);
end
fileList = dir(fullfile(directory, strcat(prefix, '*.wav')));
data = readtable(csvfile);
for i = 1:length(fileList)
    inputFile = fullfile(directory, fileList(i).name);

    [~, name, ~] = fileparts(fileList(i).name);
    parts = split(name, '_');
    prefix = parts{1};
    listnum = str2double(parts{2});
    itemnum = str2double(parts{3});

    sentencenum = data(itemnum+1, "Sentence");
    listnum_ver = data(itemnum+1, "List");
    xxxx = sprintf('%04d', sentencenum.Variables);
    outputFile = fullfile(output_directory, [xxxx, '.wav']);
    disp(inputFile);
    disp(outputFile);

    copyfile(inputFile, outputFile);
end
