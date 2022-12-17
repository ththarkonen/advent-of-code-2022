
clc
clear
close all

winds = importdata("input.txt");
data = readlines("shapes.txt");

winds = winds{1};
winds = double( winds );

leftInds = winds == 60;
rightInds = winds == 62;

winds( leftInds ) = -1;
winds( rightInds )= 1;

shapes = createShapes( data )

nBlocks = 2022;
% nBlocks = 1000000000000;

xDim = 7;
blockInds = zeros( xDim, 2);
blockInds(:,2) = 1:xDim;

for ii = 1:nBlocks

    stopBlock = false;
    shape_ii = shapes{1};

    while( ~stopBlock )
        
        [ blockInds, winds, stopBlock] = moveShape( shape_ii, winds, blockInds);
    end
%     axis equal

    shapes = circshift( shapes, -1);
    ii
end

maxHeight = max( blockInds );
maxHeight = maxHeight(1)

imageMatrix = zeros( maxHeight + 1, 7);
pblockInds = blockInds;
pblockInds(:,1) = pblockInds(:,1) + 1;
inds = sub2ind( [maxHeight + 1, 7], pblockInds(:,1), pblockInds(:,2));
imageMatrix( inds ) = 1;

imagesc( flipud(imageMatrix) )
axis equal

function [ blockInds, winds, stopBlock] = moveShape( shape, winds, blockInds)

    blockHeights = blockInds(:,1);
    maxHeight = max( blockHeights );

    position = shape;
    position(:,1) = position(:,1) + maxHeight + 3;
    position(:,2) = position(:,2) + 2;

    leftPos = min( position(:,2) );
    rightPos = max( position(:,2) );

    stopBlock = false;
    while( ~stopBlock )

        wind_ii = winds(1);

        if( wind_ii == -1 && leftPos > 1 )

            newPosition = position;
            newPosition(:,2) = newPosition(:,2) + wind_ii;

            inds = ismember( blockInds, newPosition, "rows");
            stopWind = any( inds );

            if( ~stopWind )
                position = newPosition;
                leftPos = leftPos + wind_ii;
                rightPos = rightPos + wind_ii;
            end

        elseif( wind_ii == 1 && rightPos < 7 )

            newPosition = position;
            newPosition(:,2) = newPosition(:,2) + wind_ii;

            inds = ismember( blockInds, newPosition, "rows");
            stopWind = any( inds );

            if( ~stopWind )
                position = newPosition;
                leftPos = leftPos + wind_ii;
                rightPos = rightPos + wind_ii;
            end
        end

        winds = circshift( winds, - 1);

        newPosition = position;
        newPosition(:,1) = newPosition(:,1) - 1;

        inds = ismember( blockInds, newPosition, "rows");
        stopBlock = any( inds );

        

        if( stopBlock )
            blockInds = [ blockInds; position];
%             blocksInds = max( blockInds )

            
            for ii = 1:7
                
            end

%             imageMatrix = zeros( maxHeight + max(position(:,1)) + 1, 7);
%             pblockInds = [ blockInds; position];
%             pblockInds(:,1) = pblockInds(:,1) + 1;
%             inds = sub2ind( [maxHeight + max(position(:,1)) + 1, 7], pblockInds(:,1), pblockInds(:,2));
%             imageMatrix( inds ) = 1;
%         
%             imagesc( flipud(imageMatrix) )
%             axis equal
        else
            position = newPosition;

%             imageMatrix = zeros( maxHeight + max(position(:,1)) + 1, 7);
%             pblockInds = [ blockInds; position];
%             pblockInds(:,1) = pblockInds(:,1) + 1;
%             inds = sub2ind( [maxHeight + max(position(:,1)) + 1, 7], pblockInds(:,1), pblockInds(:,2));
%             imageMatrix( inds ) = 1;
%         
%             imagesc( flipud(imageMatrix) )
%             axis equal
        end
    end
end

function [shapes] = createShapes( data )

    splitInds = data == "";
    splitInds = find( splitInds );
    startInds = [ 1; splitInds(1:end-1) + 1];
    stopInds = splitInds(1:end) - 1;

    nShapes = length( startInds );
    shapes = cell( nShapes, 1);

    for ii = 1:nShapes

        startInd_ii = startInds(ii);
        stopInd_ii = stopInds(ii);
        shapeInds_ii = startInd_ii:stopInd_ii;

        shapeStr_ii = data( shapeInds_ii );
        shapeStr_ii = char( shapeStr_ii );

        [ nRows, nCols] = size( shapeStr_ii );
        
        shape_ii = [];
        for jj = 1:nRows
            for kk = 1:nCols
                
                e_ii = shapeStr_ii( jj, kk);

                if( e_ii == "#" )
                    shape_ii = [shape_ii; [nRows - jj + 1,kk]];
                end
            end
        end
        
        shapes{ii} = shape_ii;

%         plot( shape_ii(:,2) + ii * 5, shape_ii(:,1), '.')
%         hold on
%         axis equal
    end
end