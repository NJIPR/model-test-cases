function coordGps = calcGpsCoordinates(ephemerisData,time)

% Входные параметры
%   ephemerisData - структура, содержащая массив эфемерид GPS, ближайшие к
%   моменту времени time
%   time - текущее время, yyyy:mm:dd hh:mm:ss

% Выходные параметры
%   coordGPS - X,Y,Z координаты GPS спутников в системе координат ECEF, м

    % Определение числа спутников в структуре эфемерид
    satelliteNumber = numel([ephemerisData.numberSat]);

    % Инициализация массива выходных данных
    coordGps = zeros(satelliteNumber,3);

    % Гравитационный параметр, м^3/c^2
    mu = 3.986005e14;

    % Скорость вращения Земли, рад/с
    omegaEarth = 7.2921151467e-5;

    % Расчет времени GPS от начала недели, с
    GpsTime = calcGpsTime(time);

        for idxSat = 1:satelliteNumber
            
            % Расчет большой полуоси, м
            a = (ephemerisData(idxSat).sqrtA)^2;
            
            % Расчет среднего движения, 1/с
            n0 = sqrt(mu/a^3);
            
            % Учитываем отклонение среднего движения от расчетного, 1/с
            n = n0 + ephemerisData(idxSat).delta_n;
            
            % Промежуток времени от эпохи из эфемерид, с
            tk = GpsTime - ephemerisData(idxSat).toe;
            
            % Средняя аномалия
            M = ephemerisData(idxSat).M0 + n*tk;
            
            % Итерационная процедура для нахождения аномалии с учетом
            % эксцентриситета орбиты чере итерационную процедуру
            ERR=1;
            E1=M;

            while(ERR > 1e-9)
                E = E1;
                E1 = E + (M - E + ephemerisData(idxSat).ecc*sin(E))/(1 - ephemerisData(idxSat).ecc*cos(E));
                ERR = abs(E1-E);
            end

            % Истинная аномалия, рад
            v = acos(((cos(E) - ephemerisData(idxSat).ecc)/(1 - ephemerisData(idxSat).ecc*cos(E))));

            % Невозмущенный аргумент широты орбиты, рад
            Fi = v + ephemerisData(idxSat).omega;

            % Возмущение к аргументу широты
            delta_u = ephemerisData(idxSat).Cus*sin(2*Fi) + ephemerisData(idxSat).Cuc*cos(2*Fi);
            
            % Возмущение к радиус-вектору орбиты, м
            delta_r = ephemerisData(idxSat).Crs*sin(2*Fi) + ephemerisData(idxSat).Crc*cos(2*Fi);
            
            % Возмущение к наклонению орбиты, рад
            delta_i = ephemerisData(idxSat).Cis*sin(2*Fi) + ephemerisData(idxSat).Cic*cos(2*Fi);

            % Возмущенный аргумент широты орбиты, рад
            u = Fi + delta_u;
            
            % Возмущенный радиус-вектор орбиты, м
            r = a*(1 - ephemerisData(idxSat).ecc*cos(E)) + delta_r;
            
            % Возмущенное наклонение орбиты, рад
            i = ephemerisData(idxSat).i0 + delta_i + tk*ephemerisData(idxSat).idot;

            % Орбитальные координаты спутника, м
            x0 = r*cos(u);
            y0 = r*sin(u);

            % Долгота восходящего узла орбиты с учетом вращения Земли, рад
            Omega = ephemerisData(idxSat).omega0 + (ephemerisData(idxSat).omegadot - omegaEarth)*tk - omegaEarth*ephemerisData(idxSat).toe;

            % X,Y,Z координаты GPS спутников в системе координат ECEF, м
            coordGps(idxSat,1) = x0*cos(Omega) - y0*cos(i)*sin(Omega);
            coordGps(idxSat,2) = x0*sin(Omega) + y0*cos(i)*cos(Omega);
            coordGps(idxSat,3) = y0*sin(i);

        end

end


