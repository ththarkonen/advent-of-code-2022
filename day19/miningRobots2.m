
clc
clear
close all

data = readlines("input.txt");
time = 32;

blueprints = constructBlueprints( data );
blueprints = blueprints(1:3);
nBlueprints = length( blueprints );

geodes = zeros( nBlueprints, 1);
operations = cell( nBlueprints, 1);

tic
parfor ii = 1:nBlueprints

    miningOp_ii = initilizeOperation( blueprints{ii} );
    [ geodes_ii, miningOp_ii] = getGeodes( miningOp_ii, time)

    geodes(ii) = geodes_ii;
    operations{ii} = miningOp_ii;
end
toc

result = prod( geodes )


function [operation] = initilizeOperation( blueprints )

    operation = {};

    operation.robots = [1 0 0 0];
    operation.resources = [0 0 0 0];
    operation.blueprints = blueprints;
    operation.ignoredMoves = [];

    operation.addResources = @(op) addResources( op );
    operation.possibleActions = @(op) getPossibleActions( op );
    operation.doAction = @( op, action) doAction( op, action);
end

function [op] = addResources( op )
    op.resources = op.resources + op.robots;
end

function [op] = doAction( op, action)
    
    switch action
        case "ore robot"
            op.robots = op.robots + [1 0 0 0];
            op.resources = op.resources - op.blueprints.robots.ore;
        case "clay robot"
            op.robots = op.robots + [0 1 0 0];
            op.resources = op.resources - op.blueprints.robots.clay;
        case "obsidian robot"
            op.robots = op.robots + [0 0 1 0];
            op.resources = op.resources - op.blueprints.robots.obsidian;
        case "geode robot"
            op.robots = op.robots + [0 0 0 1];
            op.resources = op.resources - op.blueprints.robots.geode;
    end
end

function [possibleActions] = getPossibleActions( op )

    possibleActions = "wait";
    
    blueprint = op.blueprints;
    resources = op.resources;
    robots = op.robots;

    canBuildOre = all( blueprint.robots.ore <= resources );
    canBuildClay = all( blueprint.robots.clay <= resources );
    canBuildObsidian = all( blueprint.robots.obsidian <= resources );
    canBuildGeode = all( blueprint.robots.geode <= resources );

    oreRobotLimit = robots(1) <= blueprint.max(1);
    clayRobotLimit = robots(2) <= blueprint.max(2);
    obsidianRobotLimit = robots(3) <= blueprint.max(3);

    oreLimit = resources(1) <= 2 * blueprint.max(1);
    clayLimit = resources(2) <= 2 * blueprint.max(2);
    obsidianLimit = resources(3) <= 2 * blueprint.max(3);

    if( canBuildOre && oreRobotLimit && oreLimit )
        possibleActions = [ possibleActions, "ore robot"];
    end

    if( canBuildClay && clayRobotLimit && clayLimit )
        possibleActions = [ possibleActions, "clay robot"];
    end

    if( canBuildObsidian && obsidianRobotLimit && obsidianLimit )
        possibleActions = [ possibleActions, "obsidian robot"];
    end

    if( canBuildGeode )
        possibleActions = ["geode robot"];
    end
end

function [blueprints] = constructBlueprints( data )

    nBlueprints = length( data );
    blueprints = cell( nBlueprints, 1);

    for ii = 1:nBlueprints
        
        bp_ii = data(ii);
        bp_ii = split( bp_ii, "robot");

        ore_ii = bp_ii(2);
        clay_ii = bp_ii(3);
        obsidian_ii = bp_ii(4);
        geode_ii = bp_ii(5);

        ore_ii = split( ore_ii, " ");
        ore_ii = double( ore_ii );
        ore_ii = [ ore_ii(3) 0 0 0];

        clay_ii = split( clay_ii, " ");
        clay_ii = double( clay_ii );
        clay_ii = [ clay_ii(3) 0 0 0];

        obsidian_ii = split( obsidian_ii, " ");
        obsidian_ii = double( obsidian_ii );
        obsidian_ii = [ obsidian_ii(3) obsidian_ii(6) 0 0];

        geode_ii = split( geode_ii, " ");
        geode_ii = double( geode_ii );
        geode_ii = [ geode_ii(3) 0 geode_ii(6) 0];

        blueprint_ii = {};

        blueprint_ii.robots.ore = ore_ii;
        blueprint_ii.robots.clay = clay_ii;
        blueprint_ii.robots.obsidian = obsidian_ii;
        blueprint_ii.robots.geode = geode_ii;
        blueprint_ii.max = max( [ore_ii; clay_ii; obsidian_ii; geode_ii] );
        blueprint_ii.max(end) = Inf;

        blueprints{ii} = blueprint_ii;
    end
end

function [ geodes, op, history] = getGeodesWithHistory( op, time, history)

    actions = op.possibleActions( op );
    nActions = length( actions );
    
    geodesForActions = zeros( nActions, 1);
    
    if( time <= 0 )
        geodes = op.resources(4);
        return;
    end

    operations = cell( nActions, 1);
    histories = cell( nActions, 1);

    for ii = 1:nActions
        
        action_ii = actions(ii);
        op_ii = op;
        op_ii = op_ii.addResources( op_ii );

        if( action_ii == "wait" )

            ignoredMoves = actions(2:end);
            op_ii.ignoredMoves = ignoredMoves;

            [ geodesForActions_ii, op_ii, history_ii] = getGeodesWithHistory( op_ii, time - 1, history);

            geodesForActions(ii) = geodesForActions_ii;
            operations{ii} = op_ii;
            histories{ii} = history_ii;

        elseif( isempty( op_ii.ignoredMoves ) || ~ismember( action_ii, op_ii.ignoredMoves) )
            
            op_ii.ignoredMoves = [];
            op_ii = op_ii.doAction( op_ii, action_ii);

            [ geodesForActions_ii, op_ii, history_ii] = getGeodesWithHistory( op_ii, time - 1, history);

            geodesForActions(ii) = geodesForActions_ii;
            operations{ii} = op_ii;
            histories{ii} = history_ii;
        end
    end
    
    [ geodes, ind] = max( geodesForActions );
    ope = operations{ind};

    history = histories{ind};

    if( isempty(ope) )

        history.("min_" + num2str(time)).action = actions(ind);
        history.("min_" + num2str(time)).resources = op.resources;
        history.("min_" + num2str(time)).robots = op.robots;
    else

        history.("min_" + num2str(time)).action = actions(ind);
        history.("min_" + num2str(time)).resources = ope.resources;
        history.("min_" + num2str(time)).robots = ope.robots;
    end
end

function [ geodes, op] = getGeodes( op, time)

    actions = op.possibleActions( op );
    nActions = length( actions );
    
    geodesForActions = zeros( nActions, 1);
    
    if( time <= 0 )
        geodes = op.resources(4);
        return;
    end

    operations = cell( nActions, 1);

    for ii = 1:nActions
        
        action_ii = actions(ii);
        op_ii = op;
        op_ii = op_ii.addResources( op_ii );

        if( action_ii == "wait" )

            ignoredMoves = actions(2:end);
            op_ii.ignoredMoves = ignoredMoves;

            [ geodesForActions_ii, op_ii] = getGeodes( op_ii, time - 1);

            geodesForActions(ii) = geodesForActions_ii;
            operations{ii} = op_ii;

        elseif( isempty( op_ii.ignoredMoves ) || ~ismember( action_ii, op_ii.ignoredMoves) )
            
            op_ii.ignoredMoves = [];
            op_ii = op_ii.doAction( op_ii, action_ii);

            [ geodesForActions_ii, op_ii] = getGeodes( op_ii, time - 1);

            geodesForActions(ii) = geodesForActions_ii;
            operations{ii} = op_ii;
        end
    end
    
    geodes = max( geodesForActions );
end