%% credit
% author: Sun Hwi Bang (sbang@psu.edu)
% created: 2022-01-07 using Matlab 9.10.0.1710957

%% data cleaning (preparing raw excel data for Matlab implementation):
% imported_data = readtable('raw_data');
% measured_displacement = imported_data.Var6( ~isnan( imported_data.Var6)); 
% (~ is tilde and Var6 is the data column of displacement in imported_data)
% measured_displacement  = measured_displacement - measured_displacement(1);
% (first data point of measured_displacement is set to be 0)
% measured_temperature = imported_data.Var10( ~isnan( imported_data.Var10));
% (~ is tilde and Var10 is the data column of temperature in imported_data)
% measured_temperature = measured_temperature( 1:length( measured_displacement));
% (length of measured_temperature is equal to length of measured_displacement)

%% displacement_sampling.m
% description: function 'displacement_sampling.m' takes measured displacement and temperature data and approximates displacement data at a given sampled temperature, which allows accurate synchronized processing of displacement versus temperature data during heating.
% input: measured_displacement, measured_temperature, sampled_temperature
%   example of defining sampled_temperature
%   sample_temperature = [30:0.1:200]' ;
%   30 (inital temperature), 0.1 (sampling spacing), 200 (isothermal temperature)
% output: sampled_displacement

function [sampled_displacement] = displacement_sampling( measured_displacement, measured_temperature, sampled_temperature)

for i = 1 : length( sampled_temperature);
    % current value of sampled temperature
    current_temperature = sampled_temperature(i);
    
    % check whether measured_temperature is equal to current_temperature 
    if isempty( find( measured_temperature == current_temperature)) == 1;
    
    % sort to find the near neighbor to the current temperature
    [ sorted_value , index ] = sort( abs( measured_temperature - current_temperature));
        
    % find the second nearest neighbot such that the target number is
    % placed between those two indexes.
    
    near_trigger = 0;
    while near_trigger == 0;
        for j = 2 : length( measured_temperature)
            if (current_temperature - measured_temperature( index(1))) * (current_temperature - measured_temperature( index(j))) < 0 
                near_trigger = 1;
                first_nearest_index = index(1);
                second_nearest_index = index(j);
                break
            end
            continue
        end
    end
    
    % find the coefficients for the linear approximation
    coefficients = polyfit(  measured_temperature([first_nearest_index, second_nearest_index]), ...
                             measured_displacement( [first_nearest_index, second_nearest_index]), 1 );
    
    sampled_displacement(i) = (coefficients(1) * current_temperature) + coefficients(2);

    else
        index_of_found_temperature = find( measured_temperature == current_temperature);
        sampled_displacement(i) = mean( [measured_displacement( index_of_found_temperature ) ] );
    end
end
end