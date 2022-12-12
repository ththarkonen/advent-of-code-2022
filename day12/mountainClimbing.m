
clear
close all

data = importdata("input.txt")
data = char( data )
data = double( data )

[ n, m] = size( data );
startPosition = find( data == 83 );
destPosition = find( data == 69 );

% [startII, startJJ] = ind2sub( [ n, m], startingInd );
% [destII, destJJ] = ind2sub( [ n, m], destInd );

data( data == 83 ) = double('a');
data( data == 69 ) = double('z');
data = data - 97;

pathTree = {};
pathTree.path_1 = destPosition;

pathLength = 0;
atStart = false;

while( ~atStart )
    
    paths = fieldnames( pathTree );
    nPaths = length( pathTree );

    for ii = 1:nPaths


    
        neighbourInds = getNeighbours( startPosition, n, m);
        validInds = getValidPaths( startPosition, neighbourInds, data)

        includesStart = ismember( neighbourInds, startPosition);
        includesStart = any( includesStart );

        if( includesStart )
            
            atStart = true;
            break;
        end

        nValids = sum( validInds )
    end

    pathLength = pathLength + 1;
end

function [neighbours] = getNeighbours( pos, n, m)

    [ii, jj] = ind2sub( [ n, m], pos);

    kernel = ones( 3, 3);
    kernel( ii, jj) = 0;

    data = zeros( n, m);
    data( ii, jj) = 1;

    neighbours = conv2( data, kernel, 'same') > 0;
    neighbours = find( neighbours );
end

function [validPaths] = getValidPaths( startPosition, neighbours, data)
        
    d = data( neighbours ) - data( startPosition );

    validInds = d >= -1 & d <= 0;
    validPaths = neighbours( validInds );
end