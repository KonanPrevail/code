function [gain, max_gain_feature] = infogain(x,y)
    info_gains = zeros(1, size(x,2));

    % calculate information i(N)
    classes = unique(y)';
    iN = 0;
    for c=classes
        py = sum(y==c)/size(y,1);
        iN = iN - py*log2(py);
    end

    % iterate over all variables on columns
    for col=1:size(x,2)
        values = unique(x(:,col))';
        % entropy
        iNx = 0;
        for f=values % only binary 0/1 for now
            pf = sum(x(:,col)==f)/size(x,1);
            yf = y(find(x(:,col)==f));
            
            classes = unique(yf)';
            iNk = 0;
            for c=classes
                pyf = sum(yf==c)/size(yf,1);
                iNk = iNk - pyf*log2(pyf);
            end
            iNx = iNx + pf * iNk;
        end
        info_gains(col) = iN - iNx;
    end
    [gain, max_gain_feature] = max(info_gains);
end