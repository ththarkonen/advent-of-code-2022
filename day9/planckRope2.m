clear
close all

data = readlines("input.txt");

moves = split(data);
nMoves = length( data );

directions = moves(:,1);

distances = moves(:,2);
distances = double( distances );
totalDistance = sum( distances );

nKnots = 10;
knotPositions = zeros( 2, totalDistance + 1, nKnots);

counter = 2;
for ii = 1:nMoves
    
    direction_ii = directions(ii);
    distance_ii = distances(ii);

    for jj = 1:distance_ii

        knot_ii_jj_1 = knotPositions( :, counter - 1, 1);
        knot_ii_jj_1 = moveHead( knot_ii_jj_1, direction_ii);
        knotPositions( :, counter, 1) = knot_ii_jj_1;

        for kk = 2:nKnots
            
            knotPrev_ii_jj_kk = knotPositions( :, counter, kk - 1);
            knot_ii_jj_kk = knotPositions( :, counter - 1, kk);

            knot_ii_jj_kk = moveKnot( knot_ii_jj_kk, knotPrev_ii_jj_kk);
            knotPositions( :, counter, kk) = knot_ii_jj_kk;
        end   

        counter = counter + 1;
    end
end

lastKnotPositions = knotPositions(:,:,end);
totalTailPositions = unique( lastKnotPositions', 'rows');
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

    headKnotDirection( headKnotDirection == 2 ) = 1;
    headKnotDirection( headKnotDirection == -2 ) = -1;

    if( ~isClose )
        p = p + headKnotDirection;
    end
end