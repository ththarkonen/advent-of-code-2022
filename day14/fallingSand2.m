
clc
clear
close all

data = readlines("input.txt");

[minXY, maxXY] = getMaxCoordinates( data );
[ rocksMatrix, sourceInd] = constructRocks( minXY, maxXY, data);

overflow = false;

counter = 0;
fileName = "part2.gif";
animate = false;

while( ~overflow )
   
    [ rocksMatrix, overflow, sourceInd] = dropSand( rocksMatrix, sourceInd);
    counter = counter + 1;
    
    if( animate )
        
        animateInterval = mod( counter, 100) == 0;
        
        if( counter == 1 )
            addFrameGIF( rocksMatrix, true, fileName);
        elseif( animateInterval )
            addFrameGIF( rocksMatrix, false, fileName);
        end
    end
    
    steadyState = any( rocksMatrix(1,:) );
    
    if( steadyState )
        
        if( animate )
            addFrameGIF( rocksMatrix, false, fileName); 
        end
        
        break;
    end
end

counter

function [ rocks, overflow, sourceInd] = dropSand( rocks, sourceInd)
    
    maxX = size( rocks, 2);
    maxY = size( rocks, 1);
    
    stopRock = false;
    overflow =  false;
       
    sand_ii = 1;
    sand_jj = sourceInd;
        
    while( ~stopRock )
        
        rockInd_ii = sand_ii + 1;
        rockInd_jj = sand_jj;
            
        if( sand_jj <= 1 )
            
            rockPad = zeros( maxY, 1);
            rockPad(end) = 1;
            sand_jj = 2;
            rockInd_jj = 2;
            
            rocks = [ rockPad, rocks];
            sourceInd = sourceInd + 1;
        end
        
        if( sand_jj >= maxX )
            
            rockPad = zeros( maxY, 1);
            rockPad(end) = 1;
            
            rocks = [ rocks, rockPad];
            
        end
        
        rock_ii_jj = rocks( rockInd_ii, rockInd_jj);
        rockLeft = rocks( rockInd_ii, rockInd_jj - 1);
        rockRight = rocks( rockInd_ii, rockInd_jj + 1);
        
        if( rock_ii_jj == 0 )
            
            sand_ii = sand_ii + 1;
            
        elseif( rockLeft == 0 )
            
            sand_ii = sand_ii + 1;
            sand_jj = sand_jj - 1;
        elseif( rockRight == 0 )
            
            sand_ii = sand_ii + 1;
            sand_jj = sand_jj + 1;
        else
           stopRock = true; 
        end
    end
    
    rocks( sand_ii, sand_jj) = 2;
end

function [ minXY, maxXY] = getMaxCoordinates( data )

    nLines = length( data );
    
    xy = [];
    for ii = 1:nLines
        
       line_ii = data(ii);
       nodes_ii = split( line_ii, "->");
       xyStr_ii = split( nodes_ii, ",");
       
       xy_ii = double( xyStr_ii );
       xy = [xy; xy_ii];
    end
    
    minXY = min(xy);
    maxXY = max(xy);
end

function [rocks, sourceInd] = constructRocks( minXY, maxXY, data)
    
    nLines = length( data );
    
    minX = minXY(1);
    maxX = maxXY(1);
    
    sourceInd = 500 - minX + 2;
    
    xInterval = maxX - minX + 1;
    
    maxY = maxXY(2);
    
    nCols = maxX - minX + 1;
    nRows = maxXY(2);
    
    rocks = zeros( nRows, nCols);
    
    for ii = 1:nLines
        
       line_ii = data(ii);
       nodes_ii = split( line_ii, "->");
       xyStr_ii = split( nodes_ii, ",");
       
       xy_ii = double( xyStr_ii );
       
       nNodes = length( nodes_ii );
       
       for jj = 2:nNodes
          
           nodePrev = xy_ii(jj - 1, :);
           nodeNext  = xy_ii(jj, :);
           
           xPrev = nodePrev(1) - minX + 1;
           xNext = nodeNext(1) - minX + 1;
               
           
           yPrev = nodePrev(2);
           yNext = nodeNext(2);
           
           xInds = xPrev:xNext;
           yInds = yPrev:yNext;
           
           if( isempty(xInds) )
               xInds = xNext:xPrev;
           end
           
           if( isempty(yInds) )
               yInds = yNext:yPrev;
           end
           
           rocks( yInds, xInds) = 1;
       end
    end
    
    rocksPadSides = zeros( maxY, 1);
    rocksPadBot = zeros( 1, xInterval + 2);
    rocksPadBotRock = ones( 1, xInterval + 2);
    
    rocks = [ rocksPadSides, rocks, rocksPadSides];
    rocks = [ rocksPadBot; rocks];
    rocks = [ rocks; rocksPadBot];
    rocks = [ rocks; rocksPadBotRock];
end