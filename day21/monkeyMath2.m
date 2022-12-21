
clc
clear
close all

data = readlines("input.txt");
monkeysInit = createMonkeys( data );

% for ii 
tic
counter = 3.3276e+12;
valid = false;

while( ~valid )
    
    monkeys = monkeysInit;
    monkeys.humn.value = counter;

    iterate = true;
    
    while( iterate )

       [ monkeys, iterate, valid] = iterateMonkeys( monkeys );

        if( valid )
            valid
            disp("Found human value.");
            break;
        end
    end
    
    counter = counter + 1;
    
    format long g
    monkeys.( monkeys.root.yellers(1) )
    monkeys.( monkeys.root.yellers(2) )
    format default
%     
end
toc

%%

[humanValueMin, res] = fminsearch( @(humanValue) computeResidual( humanValue, monkeysInit), 3.3276e+14)


function [residual] = computeResidual( humanValue, initialMonkeys)
    
    monkeys = initialMonkeys;
    monkeys.humn.value = humanValue;

    iterate = true;
    
    while( iterate )

       [ monkeys, iterate, valid] = iterateMonkeys( monkeys );
    end
    
    residual = abs( 21830569590923 - monkeys.mrnz.value )
end


function [ monkeys, iterate, valid] = iterateMonkeys( monkeys )

    iterate = false;
    valid = false;
    
    names = fieldnames( monkeys );
    nMonkeys = length( names );
    
    for ii = 1:nMonkeys
       
        name_ii = names{ii};
        monkey_ii = monkeys.( name_ii );
        
        if( monkey_ii.ready )
            continue;
        end
        
        yellers = monkey_ii.yellers;
        yeller1 = yellers(1);
        yeller2 = yellers(2);
        
        yellerFirst = monkeys.( yeller1 );
        yellerSecond = monkeys.( yeller2 );
        
        if( yellerFirst.ready && yellerSecond.ready )
            
            op_ii = monkey_ii.operator;
            a = yellerFirst.value;
            b = yellerSecond.value;
            
            [ value_ii, equal] = doAction( op_ii, a, b);
            
            monkey_ii.value = value_ii;
            monkey_ii.ready = true;
            
            if( equal == 0 )
                iterate = false;
                valid = false;
                break;
            elseif( equal == 1 )
                iterate = false;
                valid = true;
                break;
            end
            
            monkeys.( name_ii ) = monkey_ii;
            iterate = true;
            continue;
        end
    end
end

function [value, equal] = doAction( operator, a, b)

    equal = -1;
    switch operator
        case "+"
            value = a + b;
        case "-"
            value = a - b;
        case "*"
            value = a * b;
        case "/"
            value = a / b;
        case "="
            value = 0;
            equal = a == b;
    end
end

function [monkeys] = createMonkeys( data )

    nMonkeys = length( data );
    monkeys = {};
    
    for ii = 1:nMonkeys
       
        line_ii = data(ii);
        line_ii = split( line_ii, ":");
        
        name_ii = line_ii(1);
        
        value_ii = line_ii(2);
        value_ii = double( value_ii );
        isNumeric = ~isnan( value_ii );
        
        if( ~isNumeric )
            
            operation_ii = line_ii(2);
            operation_ii = split( operation_ii, " ");
            
            targets_ii = [ operation_ii(2), operation_ii(4)];
            operator_ii = operation_ii(3);
            
            value_ii = NaN;
            ready_ii = false;
        else
           targets_ii = []; 
           ready_ii = true;
           operator_ii = "";
        end
        
        if( name_ii == "root" )
            operator_ii = "=";
        end   
        
        monkey_ii = {};
        monkey_ii.name = name_ii;
        monkey_ii.value = value_ii;
        monkey_ii.yellers = targets_ii;
        monkey_ii.operator = operator_ii;
        monkey_ii.ready = ready_ii;
        
        monkeys.( name_ii ) = monkey_ii;
    end
end