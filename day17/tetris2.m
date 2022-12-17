clc
clear
close all

winds = importdata("input.txt")
data = readlines("shapes.txt");

winds = winds{1};
winds = double( winds );

leftInds = winds == 60;
rightInds = winds == 62;

winds( leftInds ) = -1;
winds( rightInds )= 1;

windsStart = winds;

shapesStart = createShapes( data )
shapes = shapesStart;

nBlocks = 2023;
% nBlocks = 1000000000000;

blocksUltimate = 1000000000000;

xDim = 7;
blockInds = zeros( xDim, 2);
blockInds(:,2) = 1:xDim;

maxHeights = zeros( nBlocks, 1);

n = 32 * 1024;
for ii = 1:n

    stopBlock = false;
    shape_ii = shapes{1};

    while( ~stopBlock )
        
        [ blockInds, winds, stopBlock] = moveShape( shape_ii, winds, blockInds);
    end

    maxHeight = max( blockInds );
    maxHeights(ii) = maxHeight(1);

    shapes = circshift( shapes, -1);
    ii
end

%%
dHeights = diff( maxHeights );
% plot( dHeights )

dHeightsOffset = dHeights - mean( dHeights );
dHeightsOffset = dHeightsOffset(1:end);
fftDiffH = fft( dHeightsOffset );
fftDiffH = abs( fftDiffH );
fftDiffH = fftDiffH(1:0.5*n);

% [~, frequency] = max( fftDiffH );
% frequency = 2 * (frequency - 1)
frequency = 2000; ceil( 2 * n / 322 )

figure();
plot( fftDiffH )

%%
close all
figure();

blockInds = zeros( xDim, 2);
blockInds(:,2) = 1:xDim;

winds = windsStart;
shapes = shapesStart;

isPeriodic = false;
isTimePeriod = false;
stopFlag = false;
        
counter = 0;
for ii = 1:10e12

    stopBlock = false
    shape_ii = shapes{1};

    tic
    while( ~stopBlock )
        
        [ blockInds, winds, stopBlock] = moveShape( shape_ii, winds, blockInds);
    end
    toc
    
    if( ~isPeriodic )
        [ isPeriodic, periodicalShape] = checkPattern( blockInds, frequency, ii);

        heights = blockInds(:,1);
        heightOffset = max( heights )
    elseif( isTimePeriod )
        ii
        blockPeriod = counter

        heights = blockInds(:,1);
        heightCurrent = max( heights )
        periodHeightChange = heightCurrent - heightOffset - 1

        blocksLeft = blocksUltimate - ii
        periodsLeft = floor( blocksLeft / blockPeriod ) 
        
        nLastBlocks = blocksLeft - periodsLeft * blockPeriod
        lastHeights = maxHeights( ii + nLastBlocks )
        lastHeights = lastHeights - heightCurrent

        periodHeightsLeft = periodsLeft * periodHeightChange
        finalHeight = periodHeightsLeft + heightCurrent
        finalHeight = finalHeight + lastHeights

        break
    elseif( isPeriodic )
        isTimePeriod = comparePattern( blockInds, periodicalShape)
        counter = counter + 1
%         continue
    end
%     maxHeight = maxHeight(1)
% 
%     imageMatrix = zeros( maxHeight + 1, 7)
%     pblockInds = blockInds
%     pblockInds(:,1) = pblockInds(:,1) + 1
%     inds = sub2ind( [maxHeight + 1, 7], pblockInds(:,1), pblockInds(:,2))
%     imageMatrix( inds ) = 1;
% 
%     imagesc( flipud(imageMatrix) )
%     axis equal

    shapes = circshift( shapes, -1);
    ii
end

function [ isTimePeriod ] = comparePattern( blockInds, reference)

    blockIndsII = blockInds(:,1);
    blockIndsJJ = blockInds(:,2);

    maxHeightII = max( blockIndsII )
    bottomInds = blockIndsII == 0;
    
    imageMatrix = zeros( maxHeightII, 7);
    matrixSize = [maxHeightII, 7];

    blockIndsII( bottomInds, :) = [];
    blockIndsJJ( bottomInds, :) = [];

    inds = sub2ind( matrixSize, blockIndsII, blockIndsJJ);
    imageMatrix( inds ) = 1;

    period = size( reference, 1)
    topInds = ( maxHeightII - period + 1 ):maxHeightII;

    topMatrix = imageMatrix( topInds, :);
    isTimePeriod = all( reference(:) == topMatrix(:) );

    subplot( 1, 3, 1)
    imagesc( imageMatrix )
    axis equal

    subplot( 1, 3, 2)
    imagesc( reference )
    axis equal

    subplot( 1, 3, 3)
    imagesc( topMatrix )
    axis equal
    drawnow()
end

function [ isPeriodic, periodImage] = checkPattern( blockInds, period, time)
    
    isPeriodic = false;
    offset = 0;
    periodImage = [];

    blockIndsII = blockInds(:,1);
    blockIndsJJ = blockInds(:,2);

    maxHeightII = max( blockIndsII );
    bottomInds = blockIndsII == 0;
    
    enoughPoints = time >= 2 * period;

    if( enoughPoints )

        blockIndsII( bottomInds, :) = [];
        blockIndsJJ( bottomInds, :) = [];
    
        imageMatrix = zeros( maxHeightII, 7);
        matrixSize = [maxHeightII, 7];
    
        inds = sub2ind( matrixSize, blockIndsII, blockIndsJJ);
        imageMatrix( inds ) = 1;

        for ii = 0:period-1

            botInds = ( maxHeightII - 2 * period + 1):( maxHeightII - period );
            botInds = botInds - ii;
            topInds = ( maxHeightII - period + 1 ):maxHeightII;
    
            botMatrix = imageMatrix( botInds, :);
            topMatrix = imageMatrix( topInds, :);
    
            isPeriodic = all( botMatrix(:) == topMatrix(:) );
        
            if( isPeriodic )
                
                botInds = ( maxHeightII - 2 * period + 1 - ii):( maxHeightII - period );
                topInds = ( maxHeightII - period + 1 - ii):maxHeightII;
        
                botMatrix = imageMatrix( botInds, :);
                topMatrix = imageMatrix( topInds, :);

                periodImage = topMatrix;

                subplot( 1, 3, 1)
                imagesc( imageMatrix )
                axis equal
        
                subplot( 1, 3, 2)
                imagesc( botMatrix )
                axis equal
        
                subplot( 1, 3, 3)
                imagesc( topMatrix )
                axis equal
                drawnow()
                return
            end

        end
    end
end

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

%         inds2 = blockInds - newPosition'

        stopBlock = any( inds );

        

        if( stopBlock )
%             blockInds( inds, :) = [];
            blockInds = [ blockInds; position];
%             blockInds = getPerimeter( blockInds );

        else
            position = newPosition;
        end
    end
end

function [blockInds] = getPerimeter( blockInds )

    minHeight = min(blockInds(:,1));
    maxHeight = max(blockInds(:,1));

    height = maxHeight - minHeight + 1;
    
    sideIndsII = 1:height;
    sideIndsII = [ sideIndsII'; sideIndsII']

    sideIndsJJ = ones( height, 1)
    sideIndsJJ = [ sideIndsJJ; sideIndsJJ + 7]

    sideInds = [ sideIndsII, sideIndsJJ];

    blockInds(:,1) = blockInds(:,1) + 1;
    blockInds = [blockInds; sideInds];

    inds = sub2ind( [ height, 8], blockInds(:,1), blockInds(:,2));
    mat = zeros( height, 8);
    mat( inds ) = 1;
    
    perimeter = bwperim( mat );
    inds = find( perimeter );

    imagesc( perimeter )

    [ ii, jj] = ind2sub( [height, 7], inds);
    blockInds = [ii - 1, jj];
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