
clear
close all

data = importdata("input.txt");
nPacks = length( data );
nPacksPerGroup = 3;

numericData = cellfun( @double, data, 'UniformOutput', false);
prioritiesData = cellfun( @formatPriority, numericData, 'UniformOutput', false);
groupData = formatGroupData( prioritiesData, nPacksPerGroup);

commonPriorityPerPack = cellfun( @getPriority, prioritiesData);
badgeData = cellfun( @getBadge, groupData);

totalCommonPriorities = sum( commonPriorityPerPack )
totalBadgePriorities = sum( badgeData )

function [priorities] = formatPriority( row )

    lowerCaseInds = row >= 97 & row <= 122;
    upperCaseInds = row >= 65 & row <= 90;

    row( lowerCaseInds ) = row( lowerCaseInds ) - 97 + 1;
    row( upperCaseInds ) = row( upperCaseInds ) - 65 + 27;

    priorities = row;
end

function [priority] = getPriority( row )

    nItems = length( row );
    middlePoint = 0.5 * nItems;

    firstCompartmentInds = 1:middlePoint;
    secondCompartmentInds = ( middlePoint + 1 ):nItems;

    itemsFirst = row( firstCompartmentInds );
    itemsSecond = row( secondCompartmentInds );

    commonInd = ismember( itemsFirst, itemsSecond);
    commonInd = find( commonInd, 1);

    priority = row( commonInd );
end

function [groupData] = formatGroupData( priorities, nPacksPerGroup)
    
    nPacks = length( priorities );
    nGroups = nPacks / nPacksPerGroup;

    groupData = cell( nGroups, 1);

    counter = 1;
    for ii = 1:nPacksPerGroup:nPacks
        
        group_ii = cell( nPacksPerGroup, 1);

        for jj = 1:nPacksPerGroup
            
            shift_jj = jj - 1;
            group_ii{jj} = priorities{ii + shift_jj};
        end

        groupData{counter} = group_ii;
        counter = counter + 1;
    end
end

function [badge] = getBadge( group )

    nPacks = length( group );
    firstPack = group{1};
    nItems = length( firstPack );

    commonInds = ones( 1, nItems);
        
    for ii = 2:nPacks

        pack_ii = group{ii};
        commonInds = commonInds & ismember( firstPack, pack_ii);
    end

    badgeInd = find( commonInds, 1);
    badge = firstPack( badgeInd );
end

