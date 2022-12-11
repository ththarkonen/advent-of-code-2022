
clear
close all

filePath = "input.txt";

worryDivisor = 3;
monkeys = constructMonkeys( filePath, worryDivisor);

nMonkeys = length( monkeys );
nMoves = 20;

for ii = 1:nMoves
    
    for jj = 1:nMonkeys
        
        monkey_jj = monkeys{jj};
        monkeys = monkeyTurn( monkey_jj, jj, monkeys);
    end
end

nInspections = getInspectionAmounts( monkeys )
nInspections = sort( nInspections, 'descend');

totalMonkeyBusiness = nInspections(1) * nInspections(2)

function [inspections] = getInspectionAmounts( monkeys )

    nMonkeys = length( monkeys );
    inspections = zeros( nMonkeys, 1);

    for ii = 1:nMonkeys
        
        monkey_ii = monkeys{ii};
        inspections(ii) = monkey_ii.nInspections;
    end
end

function [monkeys] = constructMonkeys( filePath, worryDivisor)

    data = readlines( filePath );

    nLines = length( data );
    monkeyLines = contains( data, "Monkey");
    nMonkeys = sum( monkeyLines );
    
    startingMonkeyInds = find( monkeyLines );
    stopMonkeyInds = startingMonkeyInds(2:end) - 1;
    stopMonkeyInds = [ stopMonkeyInds; nLines];
    
    monkeys = cell( nMonkeys, 1);
    
    for ii = 1:nMonkeys
    
        startInd_ii = startingMonkeyInds(ii);
        stopInd_ii = stopMonkeyInds(ii);
        inds_ii = startInd_ii:stopInd_ii;
        
        monkeysLines_ii = data( inds_ii );
        
        items_ii = monkeysLines_ii(2);
        items_ii = split( items_ii, ":");
        items_ii = items_ii(2);
        items_ii = str2num( items_ii );
        items_ii = items_ii(:);

        operation_ii = monkeysLines_ii(3);
        operation_ii = split( operation_ii, "=");
        operation_ii = operation_ii(2);

        sumTrue = contains( operation_ii, "+");
        sumTrue = any( sumTrue );

        if( sumTrue )
            
            amount_ii = split( operation_ii, "+");
            amount_ii = amount_ii(2);
            amount_ii = str2double( amount_ii );

            op_ii = @(items) floor( (items + amount_ii) / worryDivisor );
        else

            amount_ii = split( operation_ii, "*");
            amount_ii = amount_ii(2);

            exponentation = contains( amount_ii, "old"  );
            exponentation = any( exponentation );

            if( exponentation )
                op_ii = @(items) floor( (items .* items) / worryDivisor );
            else
                amount_ii = str2double( amount_ii );
                op_ii = @(items) floor( (items * amount_ii) / worryDivisor );
            end
        end

        testNumber_ii = monkeysLines_ii(4);
        testNumber_ii = split( testNumber_ii, " ");
        testNumber_ii = testNumber_ii(end);
        testNumber_ii = str2double( testNumber_ii );

        test_ii = @(items) ~mod( items, testNumber_ii);

        targetTrue_ii = monkeysLines_ii(5);
        targetTrue_ii = split( targetTrue_ii, " ");
        targetTrue_ii = targetTrue_ii(end);
        targetTrue_ii = str2double( targetTrue_ii ) + 1;

        targetFalse_ii = monkeysLines_ii(6);
        targetFalse_ii = split( targetFalse_ii, " ");
        targetFalse_ii = targetFalse_ii(end);
        targetFalse_ii = str2double( targetFalse_ii ) + 1;

        monkey_ii = {};
        monkey_ii.items = items_ii;
        monkey_ii.operation = op_ii;
        monkey_ii.test = test_ii;
        monkey_ii.targetTrue = targetTrue_ii;
        monkey_ii.targetFalse = targetFalse_ii;
        monkey_ii.nInspections = 0;

        monkeys{ii} = monkey_ii;
    end
end

function [monkeys] = monkeyTurn( monkey, monkeyInd, monkeys)

    items = monkey.items;
    nInspections = length( items );
    worryLevels = monkey.operation( items );

    itemTests = monkey.test( worryLevels );
    itemsTrue = worryLevels( itemTests );
    itemsFalse = worryLevels( ~itemTests );

    indTrue = monkey.targetTrue;
    indFalse = monkey.targetFalse;

    monkeys{ indTrue }.items = [ monkeys{ indTrue }.items; itemsTrue];
    monkeys{ indFalse }.items = [ monkeys{ indFalse }.items; itemsFalse];

    monkeys{ monkeyInd }.items = [];
    monkeys{ monkeyInd }.nInspections = monkeys{ monkeyInd }.nInspections + nInspections;
end
