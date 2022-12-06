
clear
close all

data = importdata("input.txt");
data = char( data );
data = double( data );
nData = length( data );

kernelLengths = [ 4, 14];
nKernels = length( kernelLengths );

for ii = 1:nKernels
    
    kernelLength_ii = kernelLengths(ii);

    for jj = kernelLength_ii:nData
        
        startIndex = jj - (kernelLength_ii - 1);
        stopIndex = jj;
        inds = startIndex:stopIndex;
    
        subset = data( inds );
        uniques = unique( subset );
        nUniques = length( uniques );
    
        if( nUniques == kernelLength_ii )
            jj
            break;
        end
    end
end
