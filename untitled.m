%% MCM 2026 Problem A: OCV-SOC Curve Visualization
% This script reads the battery state table and plots the OCV-SOC curves
% for 'New' vs 'EOL' states as per Figure 1 instructions.

clear; clc; close all;

% 1. Load the Data
filename = 'MCM2026_battery_state_table.csv';
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve'; % Preserve original column headers
data = readtable(filename, opts);

% 2. Select Sample Rows (Comparing New vs. EOL)
% Find the index of the first 'new' cell and first 'eol' cell
idx_new = find(strcmp(data.battery_state_label, 'new'), 1);
idx_eol = find(strcmp(data.battery_state_label, 'eol'), 1);

if isempty(idx_new) || isempty(idx_eol)
    error('Could not find both "new" and "eol" states in the CSV.');
end

% 3. Extract Coefficients
% Note: CSV has [c0, c1, c2, c3, c4, c5] (Ascending order)
% MATLAB polyval needs [c5, c4, c3, c2, c1, c0] (Descending order)

function coeffs = get_coeffs(T, idx)
    coeffs = [T.ocv_c5(idx), T.ocv_c4(idx), T.ocv_c3(idx), ...
              T.ocv_c2(idx), T.ocv_c1(idx), T.ocv_c0(idx)];
end

p_new = get_coeffs(data, idx_new);
p_eol = get_coeffs(data, idx_eol);

% 4. Calculate OCV over SOC range [0, 1]
soc = linspace(0, 1, 100); % SOC from 0.00 to 1.00
ocv_new_curve = polyval(p_new, soc);
ocv_eol_curve = polyval(p_eol, soc);

% 5. Plotting (Reproducing Figure 1)
figure('Color', 'w');
plot(soc*100, ocv_new_curve, 'b-', 'LineWidth', 2); hold on;
plot(soc*100, ocv_eol_curve, 'r--', 'LineWidth', 2);

% Formatting
grid on;
ax = gca;
ax.FontSize = 12;
xlabel('State of Charge (SOC) [%]', 'FontWeight', 'bold');
ylabel('Open Circuit Voltage (V)', 'FontWeight', 'bold');
title('OCV vs. SOC Relationship (Model Parameters)', 'FontSize', 14);

% Legend with SOH info
legend_new = sprintf('New Cell (SOH = %.2f)', data.SOH(idx_new));
legend_eol = sprintf('EOL Cell (SOH = %.2f)', data.SOH(idx_eol));
legend({legend_new, legend_eol}, 'Location', 'southeast');

% Optional: Add annotation for the model type
dim = [0.2, 0.5, 0.3, 0.3];
str = {'Model: 5th-Order Polynomial', '$$V(z) = \sum_{i=0}^{5} c_i z^i$$'};
annotation('textbox', dim, 'String', str, 'Interpreter', 'latex', ...
           'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black');

hold off;