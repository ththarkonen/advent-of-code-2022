
clear
close all

fileID = fopen("input.txt");

caloriesTotal = [];
calories_ii = 0;

line_in = fgetl( fileID );

emptyLine = isempty( line_in );
notEOF = sum( line_in ~= -1 );

while( notEOF | emptyLine )

    if( ~emptyLine )

        calories_ii = calories_ii + str2double( line_in );
    else

        caloriesTotal = [ caloriesTotal, calories_ii];
        calories_ii = 0;
    end

    line_in = fgetl( fileID );

    emptyLine = isempty( line_in );
    notEOF = sum( line_in ~= -1 );
end

caloriesTotal = sort( caloriesTotal, 'descend');

nTops = 3;
topInds = 1:nTops;
topCalories = caloriesTotal( topInds );

maxCalories = max( caloriesTotal )
sumTopCalories = sum( topCalories )