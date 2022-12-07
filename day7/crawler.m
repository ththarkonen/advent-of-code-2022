
clear
close all

limit = 100000;
requiredSpace = 30000000;
maxSpace = 70000000;

data = importdata("input.txt");

pathContents = computeFolderContents( data );
folderSizes = computeFolderSizes( pathContents );

sizeTotal = countFolderSizes( folderSizes, limit)
deleteSize = getDeleteFolderSize( folderSizes, requiredSpace, maxSpace)

function [folderSizes] = computeFolderSizes( pathContents )

    paths = fieldnames( pathContents );
    folderSizes = pathContents;

    nFields = length( paths );

    for ii = 1:nFields
    
        path_ii = paths{ii};
        size_ii = 0;
    
        subFolderInds = contains( paths, path_ii);
        subFolders = paths( subFolderInds );
        nSubFolders = length( subFolders );

        for jj = 1:nSubFolders
            
            subfolder_jj = subFolders{jj};
            subSize_jj = pathContents.( subfolder_jj );
            size_ii = size_ii + subSize_jj;
        end

        folderSizes.( path_ii ) = size_ii;
    end

end

function [folderContents] = computeFolderContents( data )

    nSteps = length( data );

    currentPath = "";
    folderContents = {};
    resetField = true;
    
    for ii = 1:nSteps
    
        line_ii = data{ii};
        line_ii = split( line_ii, " ");
    
        firstSymbol = line_ii{1};
        if( firstSymbol == "$" )
            
            command_ii = line_ii{2};
            
            switch command_ii
                case "cd"
                    argument = line_ii{3};
                    currentPath = parseCD( currentPath, argument);
                    
                case "ls"
                    resetField = true;
            end
        else
            
            size_ii = parseFolderContent( firstSymbol );
    
            if( resetField )
                folderContents.( "p" + currentPath ) = size_ii;
                resetField = false;
            else
                size_ii = folderContents.( "p" + currentPath ) + size_ii;
                folderContents.( "p" + currentPath ) = size_ii;
            end
        end
    end
end

function [path] = parseCD( path, argument)

    switch argument
        case "/"
            path = "_";
        case ".."
            path = char(path);
            path = split( path, "_");
            path = path([1:end-2, end]);
            path = strjoin( path, '_');
        otherwise
            targetFolder = argument;
            path = path + targetFolder + "_";
    end

    path = string( path );
end

function [contentSize] = parseFolderContent( symbol )

    if( symbol == "dir" )
        contentSize = 0;
    else
        contentSize = str2double( symbol );
    end
end

function [totalSize] = countFolderSizes( folderSizes, limit)

    paths = fieldnames( folderSizes );
    nFields = length( paths );

    totalSize = 0;

    for ii = 1:nFields
        
        path_ii = paths{ii};
        size_ii = folderSizes.( path_ii );

        if( size_ii <= limit )
            totalSize = totalSize + size_ii;
        end
    end
end

function [deleteSize] =  getDeleteFolderSize( folderSizes, requiredSpace, maxSpace)
    
    usedSpace = folderSizes.p_;
    deleteRequirement = requiredSpace - (maxSpace - usedSpace);

    paths = fieldnames( folderSizes );
    nFields = length( paths );

    deleteSize = usedSpace;

    for ii = 1:nFields
        
        path_ii = paths{ii};
        size_ii = folderSizes.( path_ii );

        smaller = size_ii <= deleteSize;
        enough = size_ii >= deleteRequirement;

        if( enough && smaller )
            deleteSize = size_ii;
        end
    end
end