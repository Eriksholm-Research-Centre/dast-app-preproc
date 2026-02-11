% Design for HLCM.1 DAST test
% LABW

% test persons used for test design - taken from Eriksholm Research Centre - Dokumenter\Research Projects\HLCM\Investigations\HLCM.1\Clinic
%hi_tp= [2017        2016        1635        2019        1681        1514        1966        1917        1585        1983        1686        1929 ];  %
hi_tp= [2002        2016        2020        2019        1681        1514        2004        1917        1585        1983        1275];  % LABW updated 11feb2026

special_tp = [1000 1417 99]; % default, JWNI pilot,

nr_tp = length(hi_tp) + length(special_tp);

%% define and balance conditions accross all TPs.
% HLCM1 has 7 conditions which are not repeated

% In test: Proc3-Proc7 -> 5 conditions, all single channel output:

% 1:    unaided clean
% 2:    uniaded noisy
% 3:    NAL-NL2 noisy
% 4:    NAL-NL2 + NR
% 5:    DNNHLC noisy
% 6:    DNNHLC + NR
% 7:    DNNHLCNR


% Coded as: ProcX, where X is processing

%   TODO: The cue is off

% protopype:
%  TP     Block      Corpus       ListType     ListNumber      Talker        Masker      MaskerLevel    SNR    Condition      Var11
% ____    _____    __________    __________    __________    __________    __________    ___________    ___    _________    __________
%
% 1966       1     {'DAST'  }    {'F1A'   }        11        {'F1'    }    {'SSN_F1'}        -40          5         4       {'fixed' }
% 1966       2     {'DAST'  }    {'F1A'   }         1        {'F1'    }    {'SSN_F1'}        -40          0         3       {0×0 char}
% 1966       3     {'DAST'  }    {'F1A'   }         2        {'F1'    }    {'SSN_F1'}        -40          5         4       {0×0 char}
% 1966       4     {'DAST'  }    {'F1A'   }         3        {'F1'    }    {'SSN_F1'}        -40          0         5       {0×0 char}
% 1966       5     {'DAST'  }    {'F1A'   }         4        {'F1'    }    {'SSN_F1'}        -40          5         6       {0×0 char}
% 1966       6     {'DAST'  }    {'F1A'   }         5        {'F1'    }    {'SSN_F1'}        -40          0         7       {0×0 char}
% 1966       7     {'DAST'  }    {'F1A'   }         6        {'M1'    }    {'SSN_F1'}        -40          5         3       {0×0 char}
% 1966       8     {'DAST'  }    {'F1A'   }         7        {'M1'    }    {'SSN_F1'}        -40          0         4       {0×0 char}
% 1966       9     {'DAST'  }    {'F1A'   }         8        {'M1'    }    {'SSN_F1'}        -40          5         5       {0×0 char}
% 1966      10     {'DAST'  }    {'F1A'   }         9        {'M1'    }    {'SSN_F1'}        -40          0         6       {0×0 char}
% 1966      11     {'DAST'  }    {'F1A'   }        10        {'M1'    }    {'SSN_F1'}        -40          5         7       {0×0 char}
%


condNum = 10;       % 2*5 due to two talkers M1 + F1
% cond_pres(1:condNum) = ({'HRTF_nocross'});       % HRTF nocross
% cond_pres2(1:condNum) = ({'SepSingle'});
% cond_angle = zeros(1,condNum);                  % zero degrees azimuth

cond_speechMaterial = cell(1, condNum);

cond_ID = 1:condNum;
cond_train = 4;         % trainign with cond 4

% 7 processing conditions x 2 talkers
cond_nr = repmat(3:7,1,2);

% talker pairs used here
%   Speaker dep. / known voice: M1, M2, F1, F3 (to have 13 lists available)
%   Speaker indep. / unknown voice:  M1, M2, F1, F3 (same as speaker dep.)

% Mx - male talker, Fx - female talker
all_talkers = {'M1' 'F1'};

nr_cond = length(cond_ID);
assert(nr_cond == length(cond_ID));

% 1 visits
nrvisits = 1;

% condition order (counterbalance conditions with the use of balanced Latin Square)
ls1 = ballatsq(condNum);
cond_order_all = ls1;

% list and SNR order
list_order = [11 1:10];
snr_order = repmat([5 0],1,6);

% combinations
% cond_order_all = repmat([1:16],16,1); % used for debug

% header
header = {'TP'    'Block'    'Corpus'    'List type'    'List number'    'Talker'    'Masker'    'Masker level'    'SNR'    'Condition' };


nrrows = (length(hi_tp))*(length(cond_train)+ nr_cond)*nrvisits;
nrcols = length(header);

% cell matrix for everything
c_design = cell(1+nrrows, nrcols);      % 1 row for header

%% Create list pairs and sentence pairs

% count ID's
ID_count = zeros(1,condNum);

% main loop from here
i_row = 1;

% header first
c_design(i_row, :) = header;
i_row = i_row+1;

%%
for i_tp = 1:nr_tp

    % shuffle across tp
    i_lat = i_tp;
    % if nr_tp is larger than the rows produced in the latin square
    % then start over
    if i_lat > length(cond_order_all)%nr_cond
        i_lat = i_lat - length(cond_order_all);%nr_cond;    % wrap around - unbalanced
    end
    cond_order = cond_order_all(i_lat, :);
    trialCount = 1;

    for i_trial = 1:nr_cond+length(cond_train)
        % tp number
        if i_tp > length(hi_tp)
            tp = special_tp(i_tp - length(hi_tp));
        else
            tp = hi_tp(i_tp);
        end
        c_design{i_row, 1} = tp;

        % block nr for DAST
        c_design{i_row, 2} = trialCount;

        % Corpus and listtype and trial fixed
        c_design{i_row, 3} = 'DAST';
        c_design{i_row, 4} = 'F1A' ;

        % list_nr fixed
        c_design{i_row, 5} = list_order(i_trial);

        % talker: 'F1' or 'M1' dependent on TP
        c_design{i_row, 6} = all_talkers{mod(i_tp,2)+1};

        % masker and level fixed (not used)
        c_design{i_row, 7} = 'SSN_F1';
        c_design{i_row, 8} = -40;

        % SNR and condition according to ballatsq
        if i_trial == 1
            % SNR 5 condition 4
            c_design{i_row, 9} =  5;
            c_design{i_row, 10} =  cond_train;
        else
            c_design{i_row, 9} =  snr_order(mod(cond_order(i_trial-1),2)+1);
            c_design{i_row, 10} =  cond_nr(cond_order(i_trial-1));

            % count ID's for test trials
            ID_count(cond_order(i_trial-1)) = ID_count(cond_order(i_trial-1)) + 1;
        end



        % next row
        i_row = i_row+1;
        % counter for 11 trials
        trialCount = trialCount +1;
    end
end



% % count conditions
ID_count

% write it
writecell(c_design, 'hlcm1_all.csv');


