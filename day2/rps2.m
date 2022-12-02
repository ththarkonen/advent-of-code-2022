
clear
close all

data = importdata("input.txt");
data = split( data, ' ');

nGames = size( data, 1);

opponent = data(:,1);
response = data(:,2);

oppponentNumeric = zeros( nGames, 1);
resultsNumeric = zeros( nGames, 1);
responseChoicePoints = NaN( nGames, 1);

aInds = opponent == "A";
bInds = opponent == "B";
cInds = opponent == "C";

xInds = response == "X";
yInds = response == "Y";
zInds = response == "Z";

oppponentNumeric( aInds ) = 1;
oppponentNumeric( bInds ) = 2;
oppponentNumeric( cInds ) = 3;

resultsNumeric( xInds ) = 0;
resultsNumeric( yInds ) = 3;
resultsNumeric( zInds ) = 6;

lossInds = resultsNumeric == 0;
drawInds = resultsNumeric == 3;
winInds = resultsNumeric == 6;

responseChoicePoints( lossInds ) = oppponentNumeric( lossInds ) - 1;
responseChoicePoints( responseChoicePoints == 0 ) = 3;

responseChoicePoints( drawInds ) = oppponentNumeric( drawInds );

responseChoicePoints( winInds ) = oppponentNumeric( winInds ) + 1;
responseChoicePoints( responseChoicePoints == 4 ) = 1;

drawPoints = 3 * drawInds + responseChoicePoints .* drawInds;
lossPoints = responseChoicePoints .* lossInds;
winPoints = 6 * winInds + responseChoicePoints .* winInds;

totalScore = sum( drawPoints ) + sum( lossPoints ) + sum( winPoints )

