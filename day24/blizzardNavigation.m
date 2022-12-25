
clc
clear
close all

data = readlines("input.txt");

[ map, blizzards] = constructMap( data );
[ maxII, maxJJ] = size( map );

start = [ 1, 2];
target = [ maxII, maxJJ - 1];
visited = zeros( maxII, maxJJ, 300);

tic
[ timePart1, blizzards] = getDistance( start, target, blizzards, map, visited, 1);
[ timeMid,   blizzards] = getDistance( target, start, blizzards, map, visited, timePart1 + 1);
[ timePart2, blizzards] = getDistance( start, target, blizzards, map, visited, timeMid + 1);
toc

part1 = num2str( timePart1 );
part2 = num2str( timePart2 );

disp("Part 1: " + part1);
disp("Part 2: " + part2);

function [time, blizzards] = getDistance( start, target, blizzards, map, visited, time)
    

    period = size( visited, 3);
    [ maxII, maxJJ] = size( map );
    timeIndexNext = mod( time, period) + 1;

    visited_t = visited( :, :, timeIndexNext);
    blizzards = updateBlizzards( blizzards, map);

    possibleLocations = getPossibleLocations( start, map, blizzards, visited_t);
    possibleII = possibleLocations(:,1);
    possibleJJ = possibleLocations(:,2);

    possibleInds = sub2ind( [ maxII, maxJJ], possibleII, possibleJJ);

    visitedNext = visited( :, :, timeIndexNext);
    visitedNext( possibleInds ) = 1;
    visited( :, :, timeIndexNext) = visitedNext;

    includesTarget = ismember( target, possibleLocations, "rows");
    includesTarget = any( includesTarget );

    pathsNext = possibleLocations;
    
    while( ~includesTarget )

        timeIndexNext = mod( time + 1, period) + 1;
        blizzards = updateBlizzards( blizzards, map);

        time = time + 1;
        disp("Current time: " + num2str(time));
        
        paths = pathsNext;
        pathsNext = [];

        nPaths = size( paths, 1);
        
        for ii = 1:nPaths

            visited_t = visited( :, :, timeIndexNext);
            
            path_ii = paths( ii, :);
            paths_ii = getPossibleLocations( path_ii, map, blizzards, visited_t);
            
            includesTarget = ismember( target, paths_ii, "rows");
            includesTarget = any( includesTarget );        
            
            if( ~includesTarget )
                
                visitedII = paths_ii(:,1);
                visitedJJ = paths_ii(:,2);
            
                newVisitedInds = sub2ind( [ maxII, maxJJ], visitedII, visitedJJ);
            
                visitedNext = visited( :, :, timeIndexNext);
                visitedNext( newVisitedInds ) = 1;
                visited( :, :, timeIndexNext) = visitedNext;

                pathsNext = [ pathsNext; paths_ii];
            else
                break;
            end
        end
    end
end

function [possibleLocations] = getPossibleLocations( p, map, blizzards, visited)

    [ maxII, maxJJ] = size( map );

    kernel = [ 0, 1;
               1, 0;
               0, 0;
              -1, 0;
               0,-1];

    wallInds = find( map == 1 );
    visitedInds = find( visited == 1 );

    [ wallII, wallJJ] = ind2sub( [ maxII, maxJJ], wallInds);
    [ visitedII, visitedJJ] = ind2sub( [ maxII, maxJJ], visitedInds);

    north = blizzards.north;
    east = blizzards.east;
    south = blizzards.south;
    west = blizzards.west;

    possibleLocations = p + kernel;
    outOfBoundsII = possibleLocations(:,1) < 1 | possibleLocations(:,1) > maxII;
    outOfBoundsJJ =  possibleLocations(:,2) < 1 | possibleLocations(:,2) > maxJJ;
    outOfBounds = outOfBoundsII | outOfBoundsJJ;

    wallLocations = [ wallII, wallJJ];
    visitedLocations = [ visitedII, visitedJJ];
    blizzardLocations = [north; east; south; west];
    
    inds = ~outOfBounds;
    inds = inds & ~ismember( possibleLocations, blizzardLocations, "rows");
    inds = inds & ~ismember( possibleLocations, wallLocations, "rows");
    inds = inds & ~ismember( possibleLocations, visitedLocations, "rows");

    possibleLocations = possibleLocations( inds, :);
end

function [blizzards] = updateBlizzards( blizzards, map)

    [ maxII, maxJJ] = size( map );

    north = blizzards.north;
    east = blizzards.east;
    south = blizzards.south;
    west = blizzards.west;

    north = north + [-1, 0];
    east = east + [ 0 1];
    south = south + [1 0];
    west = west + [ 0 -1];

    northBounds = north(:,1) == 1;
    eastBounds = east(:,2) == maxJJ;
    southBounds = south(:,1) == maxII;
    westBounds = west(:,2) == 1;

    north( northBounds, 1) = maxII - 1;
    east( eastBounds, 2) = 2;
    south( southBounds, 1) = 2;
    west( westBounds, 2) = maxJJ - 1;

    blizzards.north = north;
    blizzards.east = east;
    blizzards.south = south;
    blizzards.west = west;
end

function [ map, blizzards] = constructMap( lines )

    mapHeight = length( lines );
    mapWidth = strlength( lines );
    mapWidth = max( mapWidth );
    
    map = zeros( mapHeight, mapWidth);
    
    blizzards = {};
    blizzards.north = [];
    blizzards.east = [];
    
    blizzards.south = [];
    blizzards.west = [];
    
    for ii = 1:mapHeight
        
        line_ii = lines(ii);
        line_ii = char( line_ii );
        
        wallInds = line_ii == '#';
        map( ii, wallInds) = 1;
        
        northInds = find( line_ii == '^' );
        eastInds = find( line_ii == '>' );
        southInds = find( line_ii == 'v' );
        westInds = find( line_ii == '<' );
        
        northInds = northInds(:);
        eastInds = eastInds(:);
        southInds = southInds(:);
        westInds = westInds(:);
        
        nNorth = length( northInds );
        nEast = length( eastInds );
        nSouth = length( southInds );
        nWest = length( westInds );
        
        northII = ii * ones( nNorth, 1);
        eastII = ii * ones( nEast, 1);
        southII = ii * ones( nSouth, 1);
        westII = ii * ones( nWest, 1);
        
        blizzardsNorth = [ northII, northInds];
        blizzardsEast = [ eastII, eastInds];
        blizzardsSouth = [ southII, southInds];
        blizzardsWest = [ westII, westInds];
        
        blizzards.north = [ blizzards.north; blizzardsNorth];
        blizzards.east = [ blizzards.east; blizzardsEast];
        blizzards.south = [ blizzards.south; blizzardsSouth];
        blizzards.west = [ blizzards.west; blizzardsWest];    
    end
end
