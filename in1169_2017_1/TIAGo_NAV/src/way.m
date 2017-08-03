function [imgWay] = way()

%     coord.xi = 320;
%     coord.xm = 470;
%     coord.xf = 470;
%     coord.yi = 470;
%     coord.ym = 470;
%     coord.yf = 370;
%     coord.lines = 'one';

    xi = coord.xi;
    xf = coord.xf;
    xm = coord.xm;
    ym = coord.ym;
    yi = coord.yi;
    yf = coord.yf;
    lines = coord.lines;


    h = imshow(im)
    if strcmp(coord.lines,'one')
        disp('oi');
        line([xi xf], [yi yf],'LineWidth',5,'color', 'green')
        viscircles([xi yi], [10],'Color','green','LineWidth',10)
        viscircles([xf yf], [5],'Color','green','LineWidth',7)
    else
        line([xi xm], [yi ym],'LineWidth',5,'color', 'green')
        line([xm xf], [ym yf],'LineWidth',5,'color', 'green')
        viscircles([xi yi], [5],'Color','green','LineWidth',7)
        viscircles([xm ym], [5],'Color','green','LineWidth',7)
        viscircles([xf yf], [5],'Color','green','LineWidth',7)
    end;
    
end