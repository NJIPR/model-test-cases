function coordLeo = calcLeoCoordinates(time,orbitLeo)

% Входные парметры
%   time - текущее время, yyyy:mm:dd hh:mm:ss
%   orbitLeo.h - высота орбиты над уровнем моря, км
%   orbitLeo.i - наклонение орбиты, градусы
%   orbitLeo.Omega0 - долгота восходящего узла, градусы
%   orbitLeo.u0 - аргумент широты, градусы

% Выходные параметры
%   coordLeo - X,Y,Z координаты LEO спутника в системе координат ECEF, м

    %Инициализация массива координат
    coordLeo = zeros(1,3);

    % Радиус Земли, метры
    a_e = 6378137;


    % Радиус орбиты спутника, метры
    rOrbit = a_e + orbitLeo.h*1e3;


    % Координаты спутника в орбитальной системе координат
    x0 = rOrbit*cosd(orbitLeo.u0);
    y0 = rOrbit*sind(orbitLeo.u0);

    % Координаты спутника в системе координат ECI
    coordEci(1) = x0*cosd(orbitLeo.Omega0) - y0*cosd(orbitLeo.i0)*sind(orbitLeo.Omega0);
    coordEci(2) = x0*sind(orbitLeo.Omega0) + y0*cos(orbitLeo.i0)*cosd(orbitLeo.Omega0);
    coordEci(3) = y0*sind(orbitLeo.i0);

    % Вычисление Гринвичского звездного времени для перевода ECI в ECEF
    GMST_rad = calcGMST(time);

    % Координаты спутника в системе координат ECEF
    coordLeo(1) = coordEci(1)*cos(GMST_rad) - coordEci(2)*sin(GMST_rad);
    coordLeo(2) = coordEci(1)*sin(GMST_rad) + coordEci(2)*cos(GMST_rad);
    coordLeo(3) = coordEci(3);

end