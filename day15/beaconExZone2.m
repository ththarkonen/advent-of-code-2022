
clc
clear
close all

data = readlines("input.txt");

n = 4000000;

tic
[ sensorsYX, beaconsYX] = getLocations( data );
[ edges, ranges] = computeEdges( sensorsYX, beaconsYX);
[ x, y] = computeUniquePoint( sensorsYX, edges, ranges, n);
toc
    
format long g
tuningFrequency = 4000000 * x + y
format default


function [ sensorsYX, beaconsYX] = getLocations( lines )

    nSensors = length( lines );
    
    sensorsYX = zeros( nSensors, 2);
    beaconsYX = zeros( nSensors, 2);
    
    for ii = 1:nSensors
       
        line_ii = lines(ii);
        line_ii = split( line_ii, ":");
        line_ii = split( line_ii, ",");
        line_ii = split( line_ii, "=");
        
        sensorXY = line_ii(1,:,2);
        beaconXY = line_ii(2,:,2);
        
        sensorYX = fliplr( sensorXY );
        beaconYX = fliplr( beaconXY );
        
        sensorYX = double( sensorYX );
        beaconYX = double( beaconYX );
        
        sensorsYX( ii, :) = sensorYX;
        beaconsYX( ii, :) = beaconYX;
    end
end

function [edges, ranges] = computeEdges( sensorsYX, beaconsYX)
    
    nSensors = size( sensorsYX, 1);
    
    edges = cell( nSensors, 1);
    ranges = zeros( nSensors, 1);
    
    disp("Starting edge computation...");
    
    parfor ii = 1:nSensors
       
        sensor_ii = sensorsYX( ii, :);
        beacon_ii = beaconsYX( ii, :);
        
        sensorX_ii = sensor_ii(2);
        sensorY_ii = sensor_ii(1);
        
        range_ii = sensor_ii - beacon_ii;
        range_ii = norm( range_ii, 1);
        
        cornerTop_ii = [ sensorY_ii + range_ii + 1, sensorX_ii];
        cornerBot_ii = [ sensorY_ii - range_ii - 1, sensorX_ii];
        
        cornerLeft_ii = [ sensorY_ii, sensorX_ii - range_ii - 1];
        cornerRight_ii = [ sensorY_ii, sensorX_ii + range_ii + 1];
        
        edgeTopLeftY = cornerTop_ii(1):-1:cornerLeft_ii(1);
        edgeTopLeftX = cornerTop_ii(2):-1:cornerLeft_ii(2);
        edgeTopLeftYX = [ edgeTopLeftY', edgeTopLeftX'];
        
        edgeLeftBotY = cornerLeft_ii(1):-1:cornerBot_ii(1);
        edgeLeftBotX = cornerLeft_ii(2):cornerBot_ii(2);
        edgeLeftBotYX = [ edgeLeftBotY', edgeLeftBotX'];
        
        edgeBotRightY = cornerBot_ii(1):cornerRight_ii(1);
        edgeBotRightX = cornerBot_ii(2):cornerRight_ii(2);
        edgeBotRightYX = [edgeBotRightY', edgeBotRightX'];
        
        edgeRightTopY = cornerRight_ii(1):cornerTop_ii(1);
        edgeRightTopX = cornerRight_ii(2):-1:cornerTop_ii(2);
        edgeRightTopYX = [ edgeRightTopY', edgeRightTopX'];
        
        edges_ii = [ edgeTopLeftYX; edgeLeftBotYX; edgeBotRightYX; edgeRightTopYX];
        edges_ii = unique( edges_ii, 'rows');
        
        edges{ii} = edges_ii;
        ranges(ii) = range_ii;
    end
    
    disp("Done");
end

function [x,y] = computeUniquePoint( sensorsYX, edges, ranges, limit)

    nSensors = length( edges );
    
    allPoints = cell2mat( edges );
    validInds = allPoints(:,1) >= 0 & allPoints(:,1) <= limit;
    validInds = validInds & allPoints(:,2) >= 0 & allPoints(:,2) <= limit;
    
    allPoints = allPoints( validInds, :);
    
    intersections = cell( nSensors, nSensors);
    
    disp("Computing intersections...");
    
    for ii = 1:nSensors
        for jj = 1:nSensors
            
            if( ii == jj )
                continue;
            end

            range_ii = ranges(ii);
            range_jj = ranges(jj);

            sensor_ii = sensorsYX( ii, :);
            sensor_jj = sensorsYX( jj, :);
            
            d = norm( sensor_ii - sensor_jj, 1);
            range_ii_jj = range_ii + range_jj;
            
            if( d > range_ii_jj + 1 )
                continue;
            end
            
            points_ii = edges{ii};
            points_jj = edges{jj};

            inds = ismember( points_ii, points_jj, "rows");
            nInds = sum( inds );
            
            if( nInds > 2 )
                continue;
            end
            
            intersections{ ii, jj} = points_ii(inds,:);
        end
        
        progress = [num2str(100 * ii / nSensors), '%'];
        disp( progress );
    end
    
    intersections = [intersections(:)];
    intersections = cell2mat( intersections );
    
    intersections = unique( intersections, "rows");
    inds = ismember( allPoints, intersections, "rows");
    
    intersections = allPoints( inds, :);
    intersections = unique( intersections, "rows");
    
    nIntersections = size( intersections, 1);
    
    valid = ones( nIntersections, 1);
    
    disp("Computing unique point...");
    
    for ii = 1:nSensors
        
        range_ii = ranges(ii);
        edges_ii = edges{ii};
        
        for jj = 1:nIntersections
            
            valid_jj = valid(jj);
            
            if( ~valid_jj )
                continue;
            end
           
            p_jj = intersections(jj, :);
            
            d_ii_jj = abs( edges_ii - p_jj);
            d_ii_jj = sum( d_ii_jj, 2);
            inEdges = d_ii_jj <= 2 * range_ii + 1;
            inEdges = all( inEdges );
            
            if( inEdges )
                valid(jj) = 0;
            end
        end
        
        progress = [num2str(100 * ii / nSensors), '%'];
        disp( progress );
    end
    
    valid = min( valid, [], 2);
    valid = logical( valid );
    
    validP = intersections( logical(valid),:);
    
    x = validP(2);
    y = validP(1);
end