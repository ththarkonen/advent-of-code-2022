
clear
close all

data = readlines("input.txt");
data = char( data );
trees = double( data ) - 48;

[ n, m] = size( trees );

visibleTrees = zeros( n, m);
scenicScores = zeros( n, m);

visibleTrees(:,1) = 1;
visibleTrees(:,end) = 1;

visibleTrees(1,:) = 1;
visibleTrees(end,:) = 1;

rowInds = 1:n;
colInds = 1:m;

for ii = 2:(n - 1)
    for jj = 2:(m - 1)
        
        tree_ii_jj = trees( ii, jj);

        topInds = 1:(ii - 1);
        botInds = (ii + 1):n;
        
        leftInds = 1:(jj - 1);
        rightInds = (jj + 1):m;
        
        treesTop = trees( topInds, jj);
        treesBot = trees( botInds, jj);

        treesLeft = trees( ii, leftInds);
        treesRight = trees( ii, rightInds);

        tallTreesTop = treesTop >= tree_ii_jj;
        tallTreesBot = treesBot >= tree_ii_jj;

        tallTreesLeft = treesLeft >= tree_ii_jj;
        tallTreesRight = treesRight >= tree_ii_jj;

        visibleTop = ~sum( tallTreesTop );
        visibleBot = ~sum( tallTreesBot );

        visibleLeft = ~sum( tallTreesLeft );
        visibleRight = ~sum( tallTreesRight );

        if( visibleTop )
            distanceTop = ii - 1;
        else
            distanceTop = find( tallTreesTop, 1, 'last');
            distanceTop = ii - distanceTop;
        end

        if( visibleBot )
            distanceBot = n - ii;
        else
            distanceBot = find( tallTreesBot, 1);
        end

        if( visibleLeft )
            distanceLeft = jj - 1;
        else
            distanceLeft = find( tallTreesLeft, 1, 'last');
            distanceLeft = jj - distanceLeft;
        end

        if( visibleRight )
            distanceRight = m - jj;
        else
            distanceRight = find( tallTreesRight, 1);
        end

        visible_ii_jj = visibleTop | visibleBot | visibleLeft | visibleRight;
        scenicScore_ii_jj = distanceTop * distanceBot * distanceLeft * distanceRight;
        
        visibleTrees( ii, jj) = visible_ii_jj;
        scenicScores( ii, jj) = scenicScore_ii_jj;
    end
end

totalVisibleTrees = sum( visibleTrees(:) )
maxScenicScore = max( scenicScores(:) )
