
clear
close all

stacks = importdata("stacks.txt");
moves = readmatrix("moves.txt");

nStacks = 9;
nMoves = size( moves, 1);

times = moves(:,2);
from = moves(:,4);
to = moves(:,6);

stacks9000 = formatStackData( stacks, nStacks);
stacks9001 = stacks9000;

for ii = 1:nMoves

    n_ii = times(ii);
    from_ii = from(ii);
    to_ii = to(ii);

    stacks9000 = move9000( stacks9000, n_ii, from_ii, to_ii);
    stacks9001 = move9001( stacks9001, n_ii, from_ii, to_ii);
end

printTopItems( stacks9000 )
printTopItems( stacks9001 )


function [stackData] = formatStackData( stacks, nStacks)

    maxStackHeight = size( stacks, 1);
    stackMatrix = cell( maxStackHeight, nStacks);
    stackData = cell( 1, nStacks);

    for ii = 1:maxStackHeight

        row_ii = stacks( ii, :);
        row_ii = split( row_ii, " ");
        nElements_ii = length( row_ii );

        emptyInds_ii = cellfun( @isempty, row_ii );
        emptyInds_ii = find( emptyInds_ii );

        nEmpties_ii = length( emptyInds_ii );
        deleteInds_ii = false( nElements_ii, 1);

        for jj = 1:4:nEmpties_ii
            
            tempInds_jj = (jj + 1):(jj + 3);
            inds_jj = emptyInds_ii( tempInds_jj );
            deleteInds_ii( inds_jj ) = 1;
        end

        row_ii( deleteInds_ii ) = [];
        stackMatrix( ii, :) = row_ii;
    end

    for ii = 1:nStacks
        
        stack_ii = stackMatrix( :, ii);
        emptyInds_ii = cellfun( @isempty, stack_ii);

        stackData{ii} = stack_ii( ~emptyInds_ii );
    end
end

function [stacks] = move9000( stacks, n, from, to)

    startStack = stacks{ from };
    targetStack = stacks{ to };

    movedItems = startStack(1:n);
    movedItems = flipud( movedItems );

    startStack(1:n) = [];
    targetStack = vertcat( movedItems, targetStack);

    stacks{ from } = startStack;
    stacks{ to } = targetStack;
end

function [stacks] = move9001( stacks, n, from, to)

    startStack = stacks{ from };
    targetStack = stacks{ to };

    movedItems = startStack(1:n);

    startStack(1:n) = [];
    targetStack = vertcat( movedItems, targetStack);

    stacks{ from } = startStack;
    stacks{ to } = targetStack;
end

function [] = printTopItems( stacks )

    nStacks = length( stacks );

    for ii = 1:nStacks
    
        stack_ii = stacks{ii};
        topItem_ii = stack_ii{1};
        topItem_ii = strrep( topItem_ii, "[", "");
        topItem_ii = strrep( topItem_ii, "]", "");
    
        fprintf( topItem_ii );
    end

    disp(' ');
end