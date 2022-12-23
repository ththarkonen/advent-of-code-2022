
clc
clear
close all

data = readlines("input.txt");
elves = getLocations( data );

time = 10;

kernelNorth = [-1, 0;
               -1, 1;
               -1,-1];

kernelSouth = [ 1, 0;
                1, 1;
                1,-1];

kernelWest = [ 0,-1;
               1,-1;
              -1,-1];

kernelEast = [ 0, 1;
               1, 1;
              -1, 1];

kernels = {};
kernels.north.kernel = kernelNorth;
kernels.north.move = [-1, 0];

kernels.south.kernel = kernelSouth;
kernels.south.move = [1, 0];

kernels.west.kernel = kernelWest;
kernels.west.move = [0, -1];

kernels.east.kernel = kernelEast;
kernels.east.move = [0, 1];

kernels.stop.kernel = [-1, 0;
                       -1, 1;
                       -1,-1;
                        1, 0;
                        1, 1;
                        1,-1;
                        0, 1;
                        0,-1];

order = ["north", "south", "west", "east"];

animate = true;
saveGif = false;

if( animate )
    plotElves( elves, true, saveGif);
end

for ii = 1:time
    
    [ elves, order] = move( elves, kernels, order);

    if( animate )
        plotElves( elves, false, saveGif);
    end
end

area = computeArea( elves )


function [area] = computeArea( elves )
        
    nElves = size( elves, 1);

    elvesII = elves(:,1);
    elvesJJ = elves(:,2);

    minII = min( elvesII );
    maxII = max( elvesII );

    minJJ = min( elvesJJ );
    maxJJ = max( elvesJJ );

    intervalII = maxII - minII + 1;
    intervalJJ = maxJJ - minJJ + 1;

    area = intervalJJ * intervalII - nElves;
end

function [] = plotElves( elves, start, saveGif)

    elvesII = elves(:,1);
    elvesJJ = elves(:,2);

    minII = min( elvesII );
    maxII = max( elvesII );

    minJJ = min( elvesJJ );
    maxJJ = max( elvesJJ );

    elvesII = elvesII - minII + 1;
    elvesJJ = elvesJJ - minJJ + 1;

    intervalII = maxII - minII + 1;
    intervalJJ = maxJJ - minJJ + 1;

    maxIIJJ = max( intervalII, intervalJJ);

    inds = sub2ind( [maxIIJJ, maxIIJJ], elvesII, elvesJJ);

    elfMatrix = zeros( maxIIJJ, maxIIJJ);
    elfMatrix( inds ) = 1;

    addFrameGIF( elfMatrix, start, "planting.gif", saveGif);
end


function [ elves, order] = move( elves, kernels, order)

    nElves = size( elves, 1);
    nKernels = length( order );

    proposals = elves;

    parfor ii = 1:nElves
        
        elf_ii = elves( ii, :);

        inds = elf_ii + kernels.stop.kernel;
        elvesPresent = ismember( elves, inds, "rows");
        elvesPresent = any( elvesPresent );
            
        if( ~elvesPresent )
            continue;
        end

        for jj = 1:nKernels
            
            order_jj = order(jj);
            kernel_jj = kernels.( order_jj ).kernel;
            move_jj = kernels.( order_jj ).move;

            inds = elf_ii + kernel_jj;
            elvesPresent = ismember( elves, inds, "rows");
            elvesPresent = any( elvesPresent );
            
            if( ~elvesPresent )
                proposals( ii, :) = elf_ii + move_jj;
                break;
            end
        end
    end
    
    [ ~, inds] = unique( proposals, "rows");
    duplicateInds = setdiff( 1:nElves, inds);
    duplicateInds = ismember( proposals, proposals(duplicateInds,:), "rows");

    proposals( duplicateInds, :) = elves( duplicateInds, :);

    elves = proposals;
    order = circshift( order, -1);
end

function [locations] = getLocations( lines )

    nLines = length( lines );
    nLineCharacters = strlength( lines );
    locations = [];

    for ii = 1:nLines
        
        line_ii = lines(ii);
        line_ii = char( line_ii );

        width_ii = nLineCharacters(ii);

        for jj = 1:width_ii
            
            marker_ii = line_ii(jj);

            if( marker_ii == "#" )
                location_ii = [ii,jj];
                locations = [ locations; location_ii];
            end
        end
    end
end