
clc
clear
close all

data = readlines("input.txt");

n = 4000000 + 1;
checkVector = 1:n;
[ sensorsYX, beaconsYX] = getLocations( data );

for ii = 3205700:n
    
    [ nLocations, locations] = computeBeaconLocations( ii - 1, sensorsYX, beaconsYX, n);
    
    beaconLocation = find( ~locations );
    
    if( beaconLocation )
        
        x = checkVector( beaconLocation ) - 1
        y = ii - 1
        break;
    end
    
    ii
end

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

function [nLocations, locationsYX] = computeBeaconLocations( locationY, sensorsYX, beaconsYX, limit)
    
    locationsYX = zeros( limit, 1);
    nSensors = size( sensorsYX, 1);
    
    for ii = 1:nSensors
       
        sensor_ii = sensorsYX( ii, :);
        beacon_ii = beaconsYX( ii, :);
        
        sensorX_ii = sensor_ii(2);
        sensorY_ii = sensor_ii(1);
        
        range_ii = sensor_ii - beacon_ii;
        range_ii = norm( range_ii, 1);
        
        locationRange_ii = abs( locationY - sensorY_ii );
        d_x_ii = range_ii - locationRange_ii;
        
        if( d_x_ii > 0 )
           
            startInd_ii = sensorX_ii - d_x_ii;
            stopInd_ii = sensorX_ii + d_x_ii;
            
            startInd_ii = max( startInd_ii, 0);
            stopInd_ii = min( stopInd_ii, limit);
            
            if( startInd_ii == 0 && stopInd_ii == limit )
                locationsYX = 1;
                break;
            end
            
            noBeacons_ii = startInd_ii:stopInd_ii;         
            locationsYX( noBeacons_ii + 1 ) = 1;
        end
    end
    
    nLocations = size( locationsYX, 1);
end