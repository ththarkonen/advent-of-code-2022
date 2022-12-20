
clc
clear
close all

signal = readmatrix("input.txt");
signal = signal(:)';

nData = length( signal );
shifted = signal;

inds = 1:nData;

for ii = 1:nData
    
    shift_ii = signal(ii);
    shift_ii = rem( shift_ii, nData - 1);
    ind_ii = find( ii == inds );

    newInd_ii = ind_ii + shift_ii;

    if( shift_ii == 0 )
        continue;
    else
        newInd_ii = ind_ii + shift_ii;

        if( newInd_ii == 1 )
            newInd_ii = nData;
        end

        if( newInd_ii <= 0 )
            newInd_ii = nData + newInd_ii - 1;
        end

        if( newInd_ii > nData )
            newInd_ii = newInd_ii - nData + 1;
        end
    end

    if( newInd_ii > ind_ii )

        leftStart = ind_ii;
        leftStop = newInd_ii - 1;
    
        rightStart = ind_ii + 1;
        rightStop = newInd_ii;

        leftInds = leftStart:leftStop;
        rightInds = rightStart:rightStop;

        inds( leftInds ) = inds( rightInds );
    else

        leftStart = newInd_ii;
        leftStop = ind_ii - 1;
    
        rightStart = newInd_ii + 1;
        rightStop = ind_ii;

        leftInds = leftStart:leftStop;
        rightInds = rightStart:rightStop;

        inds( rightInds ) = inds( leftInds );
    end

    inds( newInd_ii ) = ii;
end

shiftedSignal = signal( inds );
zeroInd = find( shiftedSignal == 0 );
shiftedSignal = circshift( shiftedSignal, -zeroInd);

num1000 = circshift( shiftedSignal, -999);
num1000 = num1000(1)

num2000 = circshift( shiftedSignal, -1999);
num2000 = num2000(1)

num3000 = circshift( shiftedSignal, -2999);
num3000 = num3000(1)

total = num1000 + num2000 + num3000




