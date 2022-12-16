
clc
clear
close all

data = readlines("input.txt");

tic
graph = constructGraph( data );
maxPressure = travelGraph( graph )
toc

function [ maxPressure ] = travelGraph( graph )

    start = graph.AA;
    time = 26;
    
    names = fieldnames( graph );
    nNodes = length( names );
    
    reducedGraph = graph;
    
    for ii = 1:nNodes
       
        name_ii = names{ii};
        
        if( graph.( name_ii ).flow == 0 )
           reducedGraph = rmfield( reducedGraph, name_ii);
        end
    end
    
    names = fieldnames( reducedGraph );
    nNodes = length( names );
    
    nNodesElf = floor( 0.5 * nNodes);
    subgraphs = nchoosek( 2:nNodes, nNodesElf)';
    
    nSubgraphs = size( subgraphs, 2);
    pressures = zeros( nSubgraphs, 1);
    
    parfor ii = 1:nSubgraphs
    
        subgraphInds_ii = subgraphs(:,ii);
        namesElf_ii = names( subgraphInds_ii );
        inds = ~ismember( names, namesElf_ii);
        
        namesElf_ii = [ "AA"; namesElf_ii];
        namesEle_ii = names( inds );
        
        graphElf_ii = {};
        graphEle_ii = {};
        
        for jj = 1:length( namesElf_ii)
            
            name_jj = namesElf_ii(jj);
            graphElf_ii.( name_jj ) = graph.( name_jj );
        end
        
        for jj = 1:length( namesEle_ii)
            
            name_jj = namesEle_ii{jj};
            graphEle_ii.( name_jj ) = graph.( name_jj );
        end        
        
        maxPressureElf = getPressure( start, graphElf_ii, time);
        maxPressureEle = getPressure( start, graphEle_ii, time);

        maxPressure_ii = maxPressureElf + maxPressureEle;
        pressures(ii) = maxPressure_ii;
    end
    
    maxPressure = max( pressures );
end

function [pressure] = getPressure( currentNode, graph, time)
    
    nodes = fieldnames( graph );
    nNodes = length( nodes );
    
    pressures = zeros( nNodes, 1);
    
    reducedGraph = graph;
    distances = currentNode.distances;
    
    for ii = 1:nNodes
        
        name_ii = nodes{ ii };
        node_ii = graph.( name_ii );

        distance_ii = distances.( name_ii );
        pressure_ii = node_ii.value( time, distance_ii);

        if( pressure_ii <= 0 )
            reducedGraph = rmfield( reducedGraph, name_ii);
        end

        pressures(ii) = pressure_ii;
    end
    
    zeroInds = pressures <= 0;
    pressures( zeroInds ) = [];
    
    nodes = fieldnames( reducedGraph );
    nNodes = length( nodes );
    
    if( nNodes == 0 )
        pressure = 0;
        return;
    end
    
    for jj = 1:nNodes
        
        name_ii = nodes{jj};
        currentNode = reducedGraph.( name_ii );
        
        time_ii = time - distances.( name_ii ) - 1;
        reducedGraph_jj = rmfield( reducedGraph, name_ii);
        
        pressure_jj = getPressure( currentNode, reducedGraph_jj, time_ii);
        pressures(jj) = pressures(jj) + pressure_jj;
    end
    
    pressure = max( pressures );
end

function [ graph ] = constructGraph( data )

    nNodes = length( data );
    graph = {};
    
    for ii = 1:nNodes
       
        line_ii = data(ii);
        line_ii = split( line_ii, ";");
        
        valve_ii = line_ii(1);
        valve_ii = split( valve_ii, " ");
        
        flow_ii = split( valve_ii(end), "=");
        
        nodes0_ii = line_ii(2);
        nodes_ii = split( nodes0_ii, "valve ");
        
        if( nodes_ii == nodes0_ii )
            
            nodes_ii = split( nodes0_ii, "valves ");
            nodes_ii = nodes_ii(2);
            nodes_ii = split( nodes_ii, ",");
            nodes_ii = strtrim( nodes_ii );
            
        else
            nodes_ii = nodes_ii( end );
        end
        
        name_ii = valve_ii(2);
        flow_ii  = flow_ii(end);
        flow_ii = double( flow_ii );
        
        graph.(name_ii).name = name_ii;
        graph.(name_ii).flow = flow_ii;
        graph.(name_ii).nodes = nodes_ii;
        graph.(name_ii).value = @( time, d) ( time - d - 1) * flow_ii;
    end
    
    fields = fieldnames( graph );
    
    for ii = 1:nNodes
        
        name_ii = fields{ii};
        node_ii = graph.( name_ii );
        
        for jj = 1:nNodes
            
            if( ii == jj )
                graph.( name_ii).distances.( name_ii ) = 0;
                continue;
            end
            
            name_jj = fields{jj};
            node_jj = graph.( name_jj );
            
            d_ii_jj = computeNodeDistances( node_ii, node_jj, graph);
            graph.( name_ii).distances.( name_jj ) = d_ii_jj;
        end
    end
    
end

function [ distance ] = computeNodeDistances( startNode, targetNode, graph)

    paths = startNode.nodes;
    target = targetNode.name;
    
    includesTarget = ismember( target, paths);
    
    visited = [ startNode.name; paths];
    pathsNext = paths;
    
    distance = 1;
    
    while( ~includesTarget )
        
        distance = distance + 1;
        
        paths = pathsNext;
        pathsNext = [];
        
        nPaths = length( paths );
        
        for ii = 1:nPaths
            
            path_ii = paths(ii);
            paths_ii = graph.( path_ii ).nodes;
            
            includesTarget = ismember( target, paths_ii);
            
            if( ~includesTarget )
                
                inds = ~ismember( paths_ii, visited);
                
                newVisited = paths_ii(inds);
                pathsNext_ii = paths_ii(inds);
                
                visited = [ visited; newVisited];
                pathsNext = [ pathsNext; pathsNext_ii];
            else
                break;
            end
        end  
    end
end