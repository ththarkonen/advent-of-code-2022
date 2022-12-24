
clc
clear
close all

data = readlines("test.txt")

[ map, blizzards] = constructMap( data )
character = makeCharacter( map );

time = 0;
while( ~targetReached )
    
    time = getDistance( character, blizzards, time + 1);
end

function [distance] = getDistance( character, blizzards, time)
    
    
end

function [character] = makeCharacter( map )

    [ mapHeight, mapWidth] = size( map );

    character = {};
    character.position = [ 1, 2];
    character.target = [ mapHeight, mapWidth - 1];
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
        
        line_ii = lines(ii)
        line_ii = char( line_ii );
        
        wallInds = line_ii == '#'
        map( ii, wallInds) = 1;
        
        northInds = find( line_ii == '^' )
        eastInds = find( line_ii == '>' )
        southInds = find( line_ii == 'v' )
        westInds = find( line_ii == '<' )
        
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


