
clc
clear
close all

data = readlines("input.txt");
numbers = parseSNAFU( data );
fuelSum = sum( numbers );

snafuInput = snafu2decimal( fuelSum );
disp("The snafu input is " + snafuInput);

function [snafuOutput] = snafu2decimal( number )

    snafuStr = dec2base( number, 5);
    nPowers = length( snafuStr );

    snafu = zeros( 1, nPowers);
    
    for ii = 1:nPowers
        snafuStr_ii = snafuStr(ii);
        snafu(ii) = str2double( snafuStr_ii );
    end

    snafu = fliplr( snafu );
    formatOK = ~any( snafu > 2 );

    while( ~formatOK )

        for ii = 1:nPowers
    
            power_ii = snafu(ii);
    
            if( power_ii > 2 )

                snafu(ii) = power_ii - 5;
                
                try
                    snafu(ii + 1) = snafu(ii + 1) + 1;
                catch
                    snafu(ii + 1) = 1;
                end
            end
        end

        nPowers = length( snafu );
        formatOK = ~any( snafu > 2 );
    end
    
    zeroInds = snafu == 0;
    oneInds = snafu == 1;
    twoInds = snafu == 2;
    minusInds = snafu == -1;
    minus2Inds = snafu == -2;
    
    snafuOutput = blanks( nPowers );
    snafuOutput( zeroInds ) = '0';
    snafuOutput( oneInds ) = '1';
    snafuOutput( twoInds ) = '2';

    snafuOutput( minusInds ) = '-';
    snafuOutput( minus2Inds ) = '=';

    snafuOutput = fliplr( snafuOutput );
end

function [numbers] = parseSNAFU( lines )

    nLines = length( lines );
    numbers = zeros( nLines, 1);

    for ii = 1:nLines

        line_ii = lines(ii);
        line_ii = char( line_ii );
        number_ii = 0;

        nPowers = length( line_ii ) - 1;

        for jj = nPowers:-1:0
            
            ind_jj = nPowers - jj + 1;
            marker_jj = line_ii( ind_jj );

            switch marker_jj
                case "0"
                    number_ii = number_ii + 0;
                case "1"
                    number_ii = number_ii + 5^jj;
                case "2"
                    number_ii = number_ii + 2 * 5^jj;
                case "-"
                    number_ii = number_ii - 5^jj;
                case "="
                    number_ii = number_ii - 2 * 5^jj;
            end
        end

        numbers(ii) = number_ii;
    end
end