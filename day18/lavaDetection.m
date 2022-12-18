
clc
clear
close all

data = readmatrix("input.txt");

cubes = data;
nCubes = size( cubes, 1);
nChecked = -Inf( nCubes, 3);

kernel = [0,0,-1;
              0,-1,0;
              -1,0,0;
              1,0,0;
              0,1,0;
              0,0,1];

maxNeighbours = size( kernel, 1);

nSidesPart1 = 0;
nSidesPart2 = 0;
nNeighbours = size( kernel, 1);

stops = [0,0,0; max(data) + 1];
intStops = [NaN, NaN, NaN];

for ii = 1:nCubes

    ii

    p_ii = data( ii, :);

    neighbours_ii = p_ii + kernel;
    inds_ii = ismember( neighbours_ii, cubes, "rows");

    emptyPoints_ii = neighbours_ii( ~inds_ii, :);
    nEmpties = size( emptyPoints_ii, 1);
    
    nInteriors_ii = 0;

    for jj = 1:nEmpties
        
        ne_ii_jj = emptyPoints_ii( jj, :);
        [ interiorPoint, stops, intStops] = checkInteriorPoint( ne_ii_jj, stops, intStops, kernel, cubes);

        if( interiorPoint )
            nInteriors_ii = nInteriors_ii + 1;
        end
    end

    nSidesPart1_ii = nEmpties;
    nSidesPart2_ii = nSidesPart1_ii - nInteriors_ii;

    nSidesPart1 = nSidesPart1 + nSidesPart1_ii;
    nSidesPart2 = nSidesPart2 + nSidesPart2_ii;
end

nSidesPart1
nSidesPart2

function [ interiorPoint, target, intTarget] = checkInteriorPoint( start, target, intTarget, kernel, points)

    paths = start + kernel;
    
    validPathInds = ~ismember( paths, points, "rows");
    paths = paths( validPathInds, :);           

    includesTarget = ismember( target, paths, "rows");
    includesTarget = any( includesTarget );          

    interiorPoint = ismember( intTarget, paths, "rows");
    interiorPoint = any( interiorPoint );
    
    visited = [ start; paths];
    pathsNext = paths;
    
    distance = 1;
    
    while( ~includesTarget && ~interiorPoint)
        
        distance = distance + 1;
        
        paths = pathsNext;
        pathsNext = [];

        nPaths = size( paths, 1);

        if( nPaths == 0 )
            interiorPoint = true;
            break;
        end
        
        for ii = 1:nPaths
            
            path_ii = paths(ii,:);
            paths_ii = path_ii + kernel;
    
            validPathInds_ii = ~ismember( paths_ii, points, "rows");
            paths_ii = paths_ii( validPathInds_ii, :);
            
            includesTarget = ismember( target, paths_ii, "rows");
            includesTarget = any( includesTarget );        

            interiorPoint = ismember( intTarget, paths, "rows");
            interiorPoint = any( interiorPoint );
            
            if( ~includesTarget && ~interiorPoint )
                
                inds = ~ismember( paths_ii, visited, "rows");
                
                newVisited = paths_ii( inds, :);
                pathsNext_ii = paths_ii( inds, :);
                
                visited = [ visited; newVisited];
                pathsNext = [ pathsNext; pathsNext_ii];
            else
                interiorPoint = false;
                break;
            end
        end  
    end

    if( ~interiorPoint )
        target = [ target; visited];
    else
        intTarget = [ intTarget; visited];
    end
end