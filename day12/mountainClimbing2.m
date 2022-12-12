
clear
close all

data = importdata("input.txt");
dataChar = char( data );
data = double( dataChar );

[ n, m] = size( data );
startPosition = find( data == 83 );
destPosition = find( data == 69 );

data( data == 83 ) = double('a');
data( data == 69 ) = double('z');
data = data - 97;

visited = destPosition;
paths = destPosition;

pathLength = 0;
atLowestPoint = false;

while( ~atLowestPoint )
    
    cla
    hold on
    
    nPaths = length( paths );
    pathsNext = [];

    for ii = 1:nPaths

        p_ii = paths(ii);
    
        neighbourInds = getNeighbours( p_ii, n, m);
        [ validPaths, visited] = getValidPaths( p_ii, neighbourInds, data, visited);

        pathsNext = [ pathsNext; validPaths];
    end

    elevations = data( pathsNext );
    includesLowestInds = ismember( elevations, 0);
    includesLowest = any( includesLowestInds );

    if( includesLowest )
        atLowestPoint = true;
        pathsNext = pathsNext( includesLowestInds ); 
    end
     
    [ ii, jj] = ind2sub( [n,m], pathsNext);

    h = imagesc( data );
    
    h = plot( jj, ii, '.');
    h.MarkerSize = 20;
    h.Color = "black";
    
    if( includesLowest )
        h.Color = "red";
        h.MarkerSize = 25;
    end
    
    limits = [1 ,m, 1, n];
    axis( limits );
    drawnow();
    
    paths = pathsNext;
    pathLength = pathLength + 1;
end

pathLength = pathLength


function [neighbours] = getNeighbours( pos, n, m)

    [ii, jj] = ind2sub( [ n, m], pos);

    kernel = zeros( 3, 3);
    kernel( :, 2) = 1;
    kernel( 2, :) = 1;
    kernel( 2, 2) = 0;

    data = zeros( n, m);
    data( ii, jj) = 1;

    neighbours = conv2( data, kernel, 'same') > 0;
    neighbours = find( neighbours );
end

function [ validPaths, visited] = getValidPaths( position, neighbours, data, visited)
        
    height = data( position );
    heightNeighbours = data( neighbours );

    d = heightNeighbours - height;
    
    validInds = d >= -1;
    validPaths = neighbours( validInds );
    notVisited = ~ismember( validPaths, visited);
    
    validPaths = validPaths( notVisited );
    visited = [ visited; validPaths];
end