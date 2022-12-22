
clc
clear
close all

data = readlines("test.txt");
[ map, moves, rotations] = constructMap( data );
character = makeCharacter( map, 1)

imagesc( map )
hold on
h = plot( character.position(2), character.position(1), '.')
h.MarkerSize = 30;
h.Color = "red";
axis equal
axis tight

function [character] = makeCharacter( map, rowIndex)

    row = map( rowIndex, :)
    startJJ = find( row == 1, 1);

    character = {};
    character.position = [1, startJJ];
    character.direction = [0; 1];
end

function [ map, moves, rotations] = constructMap( data )

    mapLines = data(1:end-2);
    moveLine = data(end);

    mapHeigth = length( mapLines );
    mapWidths = strlength( mapLines );
    mapWidth = max( mapWidths );

    map = zeros( mapHeigth, mapWidth) - 1;

    for ii = 1:mapHeigth
        
        line_ii = mapLines(ii);
        line_ii = char( line_ii );

        width_ii = mapWidths(ii);

        for jj = 1:width_ii
            
            marker_ii = line_ii(jj);

            switch marker_ii
                case " "
                    map(ii,jj) = -1;
                case "#"
                    map(ii,jj) = 0;
                case "."
                    map(ii,jj) = 1;
            end
        end
    end

    delimiters = ["R", "L"];
    [ moveLengths, rotations] = split( moveLine, delimiters);

    moves = double( moveLengths );
    rotations = [rotations; "0"];
end