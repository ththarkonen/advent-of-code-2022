
clc
clear
close all

data = readlines("input.txt");

[ map, moves, rotations] = constructMap( data );
nMoves = length( moves );

character = makeCharacter( map, 1);
p = character.position;
paths = {p};

animate = true;
saveGif = false;
gifFileName = "monkey-map.gif";

if( animate )

    inputObject = {};
    inputObject.map = map;
    inputObject.character = character;
    inputObject.paths = paths;
    inputObject.faces = [];
    inputObject.faceSize = 0;

    addFrameGIF( inputObject, true, gifFileName, saveGif)
end

for ii = 1:nMoves
    
    moves_ii = moves(ii);
    rotation_ii = rotations(ii);
    
    for jj = 1:moves_ii
    
        [ character, isWall, isVoid] = move( character, map);
        
        if( ~isVoid )
            p = [ p, character.position];
            paths{end} = p;
        else
            paths{ end + 1 } = p;
            p = [character.position];
        end

        if( animate )
        
            inputObject = {};
            inputObject.map = map;
            inputObject.character = character;
            inputObject.paths = paths;
            inputObject.faces = [];
            inputObject.faceSize = 0;
        
            addFrameGIF( inputObject, false, gifFileName, saveGif)
        end
        
        if( isWall )
            break;
        end
    end
    
    character = rotate( character, rotation_ii);
end

rowInd = character.position(1);
colInd = character.position(2);
direction = character.direction;

right = all( direction == [0;1] );
left = all( direction == [0;-1] );
up = all( direction == [-1;0] );
down = all( direction == [1;0] );

if( right )
    directionScore = 0;
elseif( down )
    directionScore = 1;
elseif( left )
    directionScore = 2;
elseif( up )
    directionScore = 3;
end
    
    
password = 1000 * rowInd + 4 * colInd + directionScore

function [ character, isWall, isVoid] = move( character, map)

    v = character.direction;
    
    nextPosition = character.position + v;
    nextII = nextPosition(1);
    nextJJ = nextPosition(2);
    
    [ mapII, mapJJ] = size( map );
    
    if( nextII < 1 )
        nextII = mapII;
    elseif( nextII > mapII )
        nextII = 1;
    elseif( nextJJ < 1 )
        nextJJ = mapJJ;
    elseif( nextJJ > mapJJ )
        nextJJ = 1;
    end
    
    isWall = map( nextII, nextJJ) == 0;
    isVoid = map( nextII, nextJJ) == -1;
    
    if( isWall )
        return;
    end
    
    if( isVoid )
        
        rowDirection = v(1) == 0;
        [ maxII, maxJJ] = size( map );

        if( rowDirection )
            
            positiveDirection = v(2) == 1;

            rowInd = character.position(1);
            row = map( rowInd, :);

            inds = find( row == 1 | row == 0 );
            
            if( positiveDirection )
                nextJJ = inds(1);
            else
                nextJJ = inds(end);
            end
            
            nextPosition = [ nextII; nextJJ];
        else
            
            positiveDirection = v(1) == 1;

            colInd = character.position(2);
            col = map( :, colInd);

            inds = find( col == 1 | col == 0 );
            
            if( positiveDirection )
                nextII = inds(1);
            else
                nextII = inds(end);
            end
            
            nextPosition = [ nextII; nextJJ];
        end
        
        isWall = map( nextII, nextJJ) == 0;
    
        if( isWall )
            return;
        end
    end
    
    character.position = nextPosition;
end

function [character] = rotate( character, rotation)

    switch rotation
        case "R"
            R = [0 1; -1 0];
            character.direction = R * character.direction;
        case "L"
            R = [0 -1; 1 0];
            character.direction = R * character.direction;
        otherwise
            
            character.direction = character.direction;
    end
end

function [character] = makeCharacter( map, rowIndex)

    row = map( rowIndex, :);
    startJJ = find( row == 1, 1);

    character = {};
    character.position = [1; startJJ];
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