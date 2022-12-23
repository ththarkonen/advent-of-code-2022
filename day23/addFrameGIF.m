function [] = addFrameGIF( data, start, fileName, saveGif)
    
    if( start )
        hFig = figure();
        hFig.Units = "normalized";
        hFig.Position = [0 0 1 1];
    end

    cla reset
    h = imagesc( data );
    xticks([]);
    yticks([]);
    axis equal
    axis tight

    drawnow();

    if( saveGif )
    
        frame = getframe( gca );
        im = frame2im( frame );
        
        [ imind, cm] = rgb2ind(im,256);
        type = 'gif';
        
        if( start ) 
            imwrite( imind, cm, fileName, type, 'Loopcount', inf);
        else
            imwrite( imind, cm, fileName, type, 'WriteMode', 'append');
        end
    end
end