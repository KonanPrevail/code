function kmstock()
    clear all; close all; clc;
    [data,symbols,raw] = xlsread('sp500_short_period.xlsx','sp500');
    movement = double((data(2:end,:)-data(1:end-1,:))>0)';
    [m,n] = size(movement);

    K = 10; % 10 sectors
    max_iters = 100;

    [idx,centroids] = km(movement,K,max_iters);

    for i=1:K
        fprintf('\nStocks in group %d moving up together\n',i);
        char(symbols(idx == i))
    end


    function [idx,centroids] = km(X,K,max_iters)
        [m n] = size(X);
        centroids = rand(K,n);
        idx = zeros(m,1);
        old_idx = zeros(m,1);

        for j=1:max_iters
            change = false;
            for i=1:m
                [minval,idx(i)] = min(sum((repmat(X(i,:),K,1)-centroids).^2,2));
                if ((idx(i)~=old_idx(i)) && (change == false))
                    change = true;
                end
            end
            for i=1:K
               centroids(i,:) = mean(X(idx==i,:),1); 
            end

            if (change == false)  
               break;
            end

            old_idx = idx;
        end
    end
end

