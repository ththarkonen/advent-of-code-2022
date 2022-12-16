
clc
clear
close all

data = readlines("input.txt");
location = 2000000;

[ sensorsYX, beaconsYX] = getLocations( data );
[ nLocations, locations] = computeBeaconLocations( location, sensorsYX, beaconsYX);

nLocations

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

function [nLocations, locations] = computeBeaconLocations( locationY, sensorsYX, beaconsYX)
    
    locationsYX = [];
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
            noBeacons_ii = startInd_ii:stopInd_ii;
            noBeacons_ii = noBeacons_ii(:);
            
            nNoBeacons_ii = length( noBeacons_ii );
            locationsY = locationY * ones( nNoBeacons_ii, 1);
            
            noBeaconsYX_ii = [ locationsY, noBeacons_ii];
            locationsYX = [ locationsYX; noBeaconsYX_ii];
        end
    end
    
    locations = unique( locationsYX, "rows");
    beaconInds = ismember( locations, beaconsYX, "rows");
    
    locations( beaconInds, :) = [];
    nLocations = size( locations, 1);
end

