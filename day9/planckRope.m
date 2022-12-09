
clear
close all

data = readlines("input.txt");

moves = split(data);
nMoves = length( data );

directions = moves(:,1);

distances = moves(:,2);
distances = double( distances );
totalDistance = sum( distances );

tailPosition = [0;0];
headPosition = [0;0];

headPositions = zeros( 2, totalDistance + 1);
tailPositions = zeros( 2, totalDistance + 1);

counter = 2;
for ii = 1:nMoves
    
    direction_ii = directions(ii);
    distance_ii = distances(ii);

    for jj = 1:distance_ii

        headPosition = moveHead( headPosition, direction_ii);
        tailPosition = moveKnot( tailPosition, headPosition);

        headPositions( :, counter) = headPosition;
        tailPositions( :, counter) = tailPosition;

        counter = counter + 1;
    end
end

totalTailPositions = unique( tailPositions', 'rows');
nTotal = size( totalTailPositions, 1)


function [p] = moveHead( p, direction)

    switch direction
        case "U"
            p = p + [0; 1];
        case "D"
            p = p + [0; -1];
        case "L"
            p = p + [-1; 0];
        case "R"
            p = p + [1; 0];
    end
end

function [p] = moveKnot( p, pHead)

    headKnotDirection = pHead - p;
    headTailDistance = abs( headKnotDirection );
    isClose = max( headTailDistance ) <= 1;

    headKnotDirection( headKnotDirection == 2) = 1;
    headKnotDirection( headKnotDirection == -2) = -1;

    if( ~isClose )
        p = p + headKnotDirection;
    end
end
