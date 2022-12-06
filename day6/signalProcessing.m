
clear
close all

data = importdata("input.txt");
data = char( data );
data = double( data );
nData = length( data );

kernelLengths = [ 4, 14];
nKernels = length( kernelLengths );

for ii = 1:nKernels
    
    kernelLength = kernelLengths(ii);

    for jj = kernelLength:nData
        
        startIndex = jj - (kernelLength - 1);
        stopIndex = jj;
        inds = startIndex:stopIndex;
    
        subset = data( inds );
        uniques = unique( subset );
        nUniques = length( uniques );
    
        if( nUniques == kernelLength )
            jj
            break;
        end
    end
end
