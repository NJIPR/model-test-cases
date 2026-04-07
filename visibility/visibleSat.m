function [numberSat,flagVisible] = visibleSat(time, rinexFile, orbitLeo, widthLobeLeo, widthLobeGps)

% Входные парметры
%   time - текущее время, yyyy:mm:dd hh:mm:ss
%   orbitLeo.h - высота орбиты над уровнем моря, км
%   orbitLeo.i - наклон орбиты, градусы
%   orbitLeo.Omega0 - долгота восходящего узла, градусы
%   orbitLeo.u0 - аргумент широты, градусы
%   rinexFile   - строка с именем файла эфемерид в формате RINEX 3.02
%   widthLobeLeo   - ширина диаграммы направленности LEO спутника, градусы
%   widthLobeGps   - ширина диаграммы направленности GPS спутника, градусы

% Выходные параметры
%   numberSat - номер спутника GPS
%   flagVisible - флаг радиовидимости LEO спутника, 1 - виден, 0 - не виден

    % Выделение ближайших к текущему времени эфемерид
    eph = getEphemeris(rinexFile, time);
    
    % Сохранение номеров спутников GPS
    numberSat = [eph.numberSat]';

    % Расчет координат GPS спутников на момент времени time
    coordGps = calcGpsCoordinates(eph, time);
    
    % Расчет координат GPS спутников на момент времени time
    coordLeo = calcLeoCoordinates(time, orbitLeo);
    
    % По умолчанию выставляем видимость всех GPS спутников 0
    flagVisible = zeros(size(coordGps,1),1);  
    
    % Маска по углу места для GPS спутников - 
    % GPS спутник виден, если попадает в диаграмму направленности LEO спутника
    angleMaskGps = 90 - widthLobeLeo/2;
    
    % Маска по углу возвышения для LEO спутника 
    % LEO спутник виден, если попадает в диаграмму направленности GPS спутника
    angleMaskLeo = widthLobeGps/2;

    % Нормированный вектор от LEO спутника до GPS спутника
    vectorDelta = (coordGps - coordLeo)./vecnorm(coordGps - coordLeo,2,2);
    
    % Нормированный вектор из центра Земли от LEO спутника
    vectorLeo = coordLeo/norm(coordLeo);

    % Угол места GPS спутника относительно LEO спутника: 
    % 90 град - GPS спутник находится в зените
    evaluationGps = asind(sum(vectorDelta.*vectorLeo,2));
    
    % Нормированный вектор от GPS спутника до центра Земли
    vectorGps = -coordGps./vecnorm(coordGps,2,2);

    % Угол возвышения LEO спутника относительно GPS спутника
    % 0 град - LEO спутник находится под GPS спутником
    evaluationLeo = acosd(sum(-vectorDelta.*vectorGps,2));
    
    % Условие радиовидимости - одновременное выполнение обоих условий
    flagVisible(evaluationGps > angleMaskGps & evaluationLeo < angleMaskLeo) = 1;


end
