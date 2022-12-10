
clear
close all

commands = readlines("input.txt");

noOps = contains( commands, "noop");
adds = contains( commands, "addx");

addValues = commands( adds );
addValues = split( addValues, " ");
addValues = addValues(:,2);
addValues = double( addValues );

nNoOps = sum( noOps );
nAdds = sum( adds );

nCycles = nNoOps + 2 * nAdds;
nCommands = length( commands );

registerX = ones( nCycles + 1, 1);
nCyclesPerCommand = ones( nCommands, 1);

values = zeros( nCommands, 1);
values( adds ) = addValues;

nCyclesPerCommand( adds ) = 2;

cmdCounter = 1;

cmd_ii = commands( cmdCounter );
cycleCounter = nCyclesPerCommand( cmdCounter );

for ii = 2:(nCycles + 1)

    cycleCounter = cycleCounter - 1;

    if( cycleCounter ~= 0 )

        registerX(ii) = registerX(ii - 1);
        continue;
    else

        switch cmd_ii
            case "noop"
                registerX(ii) = registerX(ii - 1);
            otherwise
                value_ii = values( cmdCounter );
                registerX(ii) = registerX(ii - 1) + value_ii;
        end

        if( ii == nCycles + 1 )
            break;
        end

        cmdCounter = cmdCounter + 1;
    
        cmd_ii = commands( cmdCounter );
        cycleCounter = nCyclesPerCommand( cmdCounter );
    end
end

inds = 20:40:220;
interestingRegister = registerX( inds );

signalStrength = sum( interestingRegister .* inds' )

screen = bufferedCRT( registerX );
printCRT( screen )

function [screen] = bufferedCRT( register )

    nCycles = length( register ) - 1;
    
    nRows = 6;
    nCols = 40;

    % Note, transposed for linear indexing
    screen = strings( nRows, nCols)';

    for ii = 1:nCycles
        
        pixel_ii = mod( ii - 1, nCols);
        register_ii = register(ii);

        distance_ii = abs( register_ii - pixel_ii );

        if( distance_ii <= 1 )
            screen(ii) = "#";
        else
            screen(ii) = ".";
        end
    end

    screen = screen';
end

function [] = printCRT( screen )

    [ nRows, ~] = size( screen );

    for ii = 1:nRows
        
        row_ii = screen( ii, :);
        fprintf( '%s', row_ii);
        fprintf("\n");
    end
end




