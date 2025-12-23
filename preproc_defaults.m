function s = preproc_defaults
% DAST defaults for preproc
% version for entire test Jan 2026
% taken from hlcm1.m

% $File: //depot/common/dsp/component/tool/PrefSet/main/test/hlcm1.m $
% $Revision: #8 $  $Author: erh_lab $  $Date: 2025/12/11 $

% TODO: 

s.room = 'PITCH'; %'ANECHOIC' 'DESK' 'HOME, 'PITCH', '' detect automatically
s.targetpath =        '\\demant.com\data\ERH\Media\Media\HLCM\HLCM.2\DAST';
%s.corpus = 'DAST';        % preprocessed corpus, DAST or CONT
s.backgroundpath =    '\\demant.com\data\ERH\Media\Media\HLCM\HLCM.2\CONT\input';   % TODO remove later
s.SNRs = [5 0];     % SNRs in current test
s.talkers = {'F1' 'M1'};
s.condition = 0;    % conditions 3-7 used in HLCM.1
s.fs = 16000;       % samplerate in HLCM
s.peakSPL = 120;    % full scale acoustic level

