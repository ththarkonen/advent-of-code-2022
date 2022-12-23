function [] = addFrameGIF( data, start, fileName, saveGif)
    
    map = data.map;
    character = data.character;
    paths = data.paths;
    faces = data.faces;
    faceSize = data.faceSize;

    if( start )
        hFig = figure();
        hFig.Units = "normalized";
        hFig.Position = [0 0 1 1];
    end

    cla reset
    h = imagesc( map );
    xticks([]);
    yticks([]);
    axis equal
    axis tight

    hold on

    for kk = 1:length(paths)

        p_kk = paths{kk};

        h2 = plot( p_kk(2,:), p_kk(1,:));
        h2.Color = "red";
        h2.LineWidth = 2;
    end

    if( ~isempty( faces ) )
    
    offset = [ faceSize * ( faces.( character.face ).II - 1);
               faceSize * ( faces.( character.face ).JJ - 1) ];
    else
        offset = [0;0];
    end

    x = character.position(2) + offset(2);
    y = character.position(1) + offset(1);

    h = plot( x, y, '.');
    h.MarkerSize = 30;
    h.Color = "red";
    

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