function [coord] = findHole(img,x,y,fator)

    x = x/fator;
    y = y/fator;

    window = 2;
    step = 1;
    for step=0:(320/fator) 
        hole1 = find(img([x-step-window:1:x-step+window],[y-window:1:y+window])==1);
        hole2 = find(img([x+step-window:1:x+step+window],[y-window:1:y+window])==1);
        if length(hole1) == 0 %img(x+step,y) == 0 % 0 - file, 1 - robot
            findX = x+step;
            break;
        elseif length(hole2) == 0 %img(x-step,y) == 0
            findX = x-step;
            break;
        else
            step = step + 1;
        end
    end;

    if findX < 320/fator
        findX = findX - ceil(0.7*step);
    elseif findX > 320/fator
        findX = findX - ceil(0.7*step);    
    end;
    
    coord.xi = 320/fator;
    coord.yi = 470/fator;
    coord.xf = findX;
    coord.yf = 370/fator;
    
    if findX > 600/fator | findX < 150/fator
        coord.lines = 'two';
        coord.xm = findX;
        coord.ym = 470/fator;
    else
        coord.lines = 'one';
    end;
    
end
