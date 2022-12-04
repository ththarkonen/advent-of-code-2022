
clear
close all

data = importdata("input.txt");

sections = split( data, ',');

leftColumn = sections(:,1);
rightColumn = sections(:,2);

leftColumnSections = split( leftColumn, '-');
rightColumnSections = split( rightColumn, '-');

leftMin = leftColumnSections(:,1);
leftMax = leftColumnSections(:,2);

rightMin = rightColumnSections(:,1);
rightMax = rightColumnSections(:,2);

leftMin = cellfun( @str2num, leftMin);
leftMax = cellfun( @str2num, leftMax);

rightMin = cellfun( @str2num, rightMin);
rightMax = cellfun( @str2num, rightMax);

containedLeft = ( rightMin <= leftMin ) & ( leftMax <= rightMax );
containedRight = ( leftMin <= rightMin ) & ( rightMax <= leftMax );
contained = containedLeft | containedRight;

overlappingLeft = ( leftMin <= rightMin ) & ( rightMin <= leftMax );
overlappingRight = ( leftMin <= rightMax ) & ( rightMax <= leftMax );
overlapping = overlappingLeft | overlappingRight | contained;

sum( contained )
sum( overlapping )

