
clc
clear
close all

data = readlines("input.txt");
initialMonkeys = createMonkeys( data );

tic
res = 1;
while( res ~= 0 )

    x0 = 10000 + randi(1e15);
    [ hvOptimal, res] = fminsearch( @(humanValue) monkeyResidual( humanValue, initialMonkeys), x0);
    humanValueOptimal = round( hvOptimal );
end
toc

format long g
res
humanValueOptimal
format default

function [residual] = monkeyResidual( humanValue, initialMonkeys)
    
    monkeys = initialMonkeys;
    monkeys.humn.value = round( humanValue );

    iterate = true;
    
    while( iterate )

       [ monkeys, iterate] = iterateMonkeys( monkeys );
    end
    
    yellers = monkeys.root.yellers;
    yellerFirst = yellers(1);
    yellerSecond = yellers(2);

    valueFirst = monkeys.( yellerFirst ).value;
    valueSecond = monkeys.( yellerSecond ).value;

    residual = abs( valueFirst - valueSecond )
end


function [ monkeys, iterate] = iterateMonkeys( monkeys )

    iterate = false;
    
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

            if( op_ii == "=" )
                iterate = false;
                break;
            end
            
            monkey_ii.value = doAction( op_ii, a, b);
            monkey_ii.ready = true;
            
            monkeys.( name_ii ) = monkey_ii;
            iterate = true;
            continue;
        end
    end
end

function [value] = doAction( operator, a, b)

    switch operator
        case "+"
            value = a + b;
        case "-"
            value = a - b;
        case "*"
            value = a * b;
        case "/"
            value = a / b;
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