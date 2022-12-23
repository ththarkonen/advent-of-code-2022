
clc
clear
close all

fileName = "input.txt";
data = readlines("input.txt");
faceSize = 50;

[ map, moves, rotations] = constructMap( data );
nMoves = length( moves );

faces = getCubeFaces( map, faceSize);
faces = makeFaceConnections( faces, fileName);

character = makeCharacter( map, 1);

offset = [ faceSize * ( faces.( character.face ).II - 1);
           faceSize * ( faces.( character.face ).JJ - 1) ];

p = character.position + offset;
paths = {p};

animate = true;
saveGif = false;
gifFileName = "monkey-map-2.gif";

if( animate )

    inputObject = {};
    inputObject.map = map;
    inputObject.character = character;
    inputObject.paths = paths;
    inputObject.faces = faces;
    inputObject.faceSize = faceSize;

    addFrameGIF( inputObject, true, gifFileName, saveGif)
end

for ii = 1:nMoves
    
    moves_ii = moves(ii);
    rotation_ii = rotations(ii);
    
    for jj = 1:moves_ii
    
        [ character, isWall, isEdge] = move( character, faces);
        
        
        offset = [ faceSize * ( faces.( character.face ).II - 1);
                   faceSize * ( faces.( character.face ).JJ - 1) ];

        if( ~isEdge )
            p = [ p, character.position + offset];
            paths{end} = p;
        else
            paths{ end + 1 } = p;
            p = [character.position + offset];
        end

        if( animate )
        
            inputObject = {};
            inputObject.map = map;
            inputObject.character = character;
            inputObject.paths = paths;
            inputObject.faces = faces;
            inputObject.faceSize = faceSize;
        
            addFrameGIF( inputObject, false, gifFileName, saveGif)
        end
        
        if( isWall )
            break;
        end
    end
    
    character = rotate( character, rotation_ii);
end

offset = [ faceSize * ( faces.( character.face ).II - 1);
           faceSize * ( faces.( character.face ).JJ - 1) ];

rowInd = character.position(1) + offset(1) 
colInd = character.position(2) + offset(2)
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

function [ character, isWall, isEdge] = move( character, faces)

    v = character.direction;
    face = character.face;
    map = faces.( character.face ).map;
    
    nextPosition = character.position + v;
    nextII = nextPosition(1);
    nextJJ = nextPosition(2);
    
    [ mapII, mapJJ] = size( map );
    faceSize = mapII;

    isEdge = false;
    
    if( nextII < 1 )
        [ nextII, nextJJ, character] = faceChange( nextPosition, "north", character, faces, faceSize);
        isEdge = true;
    elseif( nextII > mapII )
        [ nextII, nextJJ, character] = faceChange( nextPosition, "south", character, faces, faceSize);
        isEdge = true;
    elseif( nextJJ < 1 )
        [ nextII, nextJJ, character] = faceChange( nextPosition, "west", character, faces, faceSize);
        isEdge = true;
    elseif( nextJJ > mapJJ )
        [ nextII, nextJJ, character] = faceChange( nextPosition, "east", character, faces, faceSize);
        isEdge = true;
    end
    
    map = faces.( character.face ).map;
    isWall = map( nextII, nextJJ) == 0;
    
    if( isWall )
        character.direction = v;
        character.face = face;
        return;
    end
    
    nextPosition = [nextII; nextJJ];
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
    offsetJJ = find( row == -1);
    offsetJJ = offsetJJ( offsetJJ < startJJ );
    offsetJJ = offsetJJ(end);

    character = {};
    character.face = "A";
    character.position = [1; startJJ - offsetJJ];
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

function [ ii, jj, character] = faceChange( position, direction, character, faces, faceSize)

    orientation = "";

    switch direction
        case "north"
            orientation = "top";
        case "east"
            orientation = "right";
        case "south"
            orientation = "bot";
        case "west"
            orientation = "left";
    end

    orientation = orientation + "-to-";
    targetFace = faces.( character.face ).( direction );
    
    for targetBackDirection = ["north", "south", "east", "west"]

        targetDirection_ii = faces.( targetFace ).( targetBackDirection );

        if( targetDirection_ii == character.face )
            break;
        end
    end

    switch targetBackDirection
        case "north"
            orientation = orientation + "top";
        case "south"
            orientation = orientation + "bot";
        case "west"
            orientation = orientation + "left";
        case "east"
            orientation = orientation + "right";
    end

    switch orientation
        case "bot-to-top"
            position(1) = 1;
            position(2) = position(2);
            direction = [1; 0];
        case "top-to-bot"
            position(1) = faceSize;
            position(2) = position(2);
            direction = [-1; 0];
        case "right-to-left"
            position(1) = position(1);
            position(2) = 1;
            direction = [0; 1];
        case "left-to-right"
            position(1) = position(1);
            position(2) = faceSize;
            direction = [0; -1];
        case "right-to-top"
            position(2) = faceSize - position(1) + 1;
            position(1) = 1;
            direction = [1; 0];
        case "top-to-right"
            position(1) = position(2);
            position(2) = faceSize;
            direction = [0; -1];
        case "right-to-bot"
            position(2) = position(1);
            position(1) = faceSize;
            direction = [-1; 0];
        case "bot-to-right"
            position(1) = position(2);
            position(2) = faceSize;
            direction = [0; -1];
        case "top-to-left"
            position(1) = position(2);
            position(2) = 1;
            direction = [0; 1];
        case "left-to-top"
            position(2) = position(1);
            position(1) = 1;
            direction = [1; 0];
        case "bot-to-left"
            position(1) = faceSize - position(2) + 1;
            position(2) = faceSize;
            direction = [0; 1];
        case "left-to-bot"
            position(2) = faceSize - position(1) + 1;
            position(1) = faceSize;
            direction = [-1; 0];
        case "bot-to-bot"
            position(2) = faceSize - position(2) + 1;
            position(1) = faceSize;
            direction = [-1; 0];
        case "top-to-top"
            position(2) = faceSize - position(2) + 1;
            position(1) = 1;
            direction = [1; 0];
        case "right-to-right"
            position(1) = faceSize - position(1) + 1;
            position(2) = faceSize;
            direction = [0; -1];
        case "left-to-left"
            position(1) = faceSize - position(1) + 1;
            position(2) = 1;
            direction = [0; 1];
        otherwise
            error("Missing orientation");
    end
    
    ii = position(1);
    jj = position(2);

    character.direction = direction;
    character.face = targetFace;
end

function [faces] = getCubeFaces( map, faceSize)

    [ n, m] = size( map );

    faceNames = ["A", "B", "C", "D", "E", "F"];
    faces = {};
    
    counter = 1;
    counterII = 1;

    for ii = 1:faceSize:n

        counterJJ = 0;

        for jj = 1:faceSize:m

            counterJJ = counterJJ + 1;
            
            indsII = ii:( ii + faceSize - 1 );
            indsJJ = jj:( jj + faceSize - 1 );

            map_ii = map( indsII, indsJJ);
            empty_ii = all( map_ii(:) == -1 );

            if( empty_ii )
                continue;
            end

            name_ii = faceNames(counter);

            face_ii = {};
            face_ii.map = map_ii;
            face_ii.name = name_ii;
            face_ii.II = counterII;
            face_ii.JJ = counterJJ;
            
            counter = counter + 1;

            faces.( name_ii ) = face_ii;
        end

        counterII = counterII + 1;
    end
end

function [faces] = makeFaceConnections( faces, fileName)

    if( fileName == "test.txt" )

        faces.A.north = "B";
        faces.A.east = "F";
        faces.A.south = "D";
        faces.A.west = "C";

        faces.B.north = "A";
        faces.B.east = "C";
        faces.B.south = "E";
        faces.B.west = "F";

        faces.C.north = "A";
        faces.C.east = "D";
        faces.C.south = "E";
        faces.C.west = "B";

        faces.D.north = "A";
        faces.D.east = "F";
        faces.D.south = "E";
        faces.D.west = "C";

        faces.E.north = "D";
        faces.E.east = "F";
        faces.E.south = "B";
        faces.E.west = "C";

        faces.F.north = "D";
        faces.F.east = "A";
        faces.F.south = "B";
        faces.F.west = "E";
    else
        
        faces.A.north = "F";
        faces.A.east = "B";
        faces.A.south = "C";
        faces.A.west = "D";

        faces.B.north = "F";
        faces.B.east = "E";
        faces.B.south = "C";
        faces.B.west = "A";

        faces.C.north = "A";
        faces.C.east = "B";
        faces.C.south = "E";
        faces.C.west = "D";

        faces.D.north = "C";
        faces.D.east = "E";
        faces.D.south = "F";
        faces.D.west = "A";

        faces.E.north = "C";
        faces.E.east = "B";
        faces.E.south = "F";
        faces.E.west = "D";

        faces.F.north = "D";
        faces.F.east = "E";
        faces.F.south = "B";
        faces.F.west = "A";
    end
end

