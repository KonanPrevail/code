function main()
	%% ================== Reset the workspace ===================
	clear all; close all; clc;
	%% ================== Loading data ==========================
	data = csvread('..\data\CAPMuniverse.csv',1);
	[m, n] = size(data); % number of observations x number of variables
	% y is the return of an individual stock; X is the return of the market
	y = data(:, 13)-data(:, 15); % 13th is YHOO, 15th is the risk-free rate
	X = data(:, 14)-data(:, 15); % 14th is the market return

	%% ================== Gradient Descent =======================
	X = [ones(m, 1), X]; % now add a column of 1 to X so it becomes [x0,x1]
	maxrun = 1e+6; % maximum number of iterations
	step = 0.1; 
	theta = zeros(2, 1); % parameters for x0 and x1 respectively
	[theta cost_range]= optimizeCost(X,y,theta,step,maxrun); % matrix form function
	pred = X*theta; % predicted y or the hypothesis
	%% =============== Plot the data and results =================
	% plot y against X;
	figure;
	plot(X(:,2), y, 'rx', 'MarkerSize', 1);  
	ylabel('Individual Security'); 
	xlabel('S&P500');
	hold on;

	% now plot the regression line
	plot(X(:,2),pred,'.')
	legend('Training data', 'Predicted regression line')
	hold off 

	% plot the cost vs the number of iterations
	figure;
	plot(cost_range);
	ylabel('Cost'); 
	xlabel('Number of interations');

	% cost function vs thetas
	th0 = linspace(theta(1)-10, theta(1)+10, 100);
	th1 = linspace(theta(2)-10, theta(2)+10, 100);
	cost = zeros(length(th0), length(th1));
	for i=1:length(th0)
		for j=1:length(th1)
			cost(i,j) = computeCost(X,y,[th0(i);th1(j)]);
		end
	end
	figure;
	surf(th0,th1,cost);
	xlabel('\theta_0'); 
	ylabel('\theta_1');
	
	function cost = computeCost(X,y,theta)
		m = length(y);
		cost = 0;
		h = X*theta;  
		diff = (h-y);
		cost = 1/2/m*(diff'*diff);
	end
	function [theta,cost_range] = optimizeCost(X,y,theta,step,maxrun)
		m = length(y); 
		cost_range = zeros(maxrun,1);

		for iter = 1:maxrun
			h = X*theta;
			grad = 1/m * (h-y)' * X; % grad is 1 x d
			theta = theta - step * grad';
			diff = (h-y);
			cost_range(iter) = 1/2/m*(diff'*diff);
		end
	end
end
