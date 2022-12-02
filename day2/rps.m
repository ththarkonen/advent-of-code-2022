
clear
close all

data = importdata("input.txt");
data = split( data, ' ');

nGames = size( data, 1);

opponent = data(:,1);
response = data(:,2);

oppponentNumeric = zeros( nGames, 1);
responseNumeric = zeros( nGames, 1);
responseChoicePoints = zeros( nGames, 1);

aInds = opponent == "A";
bInds = opponent == "B";
cInds = opponent == "C";

xInds = response == "X";
yInds = response == "Y";
zInds = response == "Z";

oppponentNumeric( aInds ) = 1;
oppponentNumeric( bInds ) = 2;
oppponentNumeric( cInds ) = 3;

responseNumeric( xInds ) = 1;
responseNumeric( yInds ) = 2;
responseNumeric( zInds ) = 3;

responseChoicePoints = responseNumeric;
results = responseNumeric - oppponentNumeric;

drawInds = results == 0;
lossInds = results == -1 | results == 2;
winInds = results == 1 | results == -2;

drawPoints = 3 * drawInds + responseChoicePoints .* drawInds;
lossPoints = responseChoicePoints .* lossInds;
winPoints = 6 * winInds + responseChoicePoints .* winInds;

totalScore = sum( drawPoints ) + sum( lossPoints ) + sum( winPoints )
