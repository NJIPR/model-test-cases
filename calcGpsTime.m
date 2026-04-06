function GpsTime = calcGpsTime(time)

% Входные параметры
%   time - текущее время, yyyy:mm:dd hh:mm:ss

% Выходные параметры
%   GpsTime - число секунд с начала GPS недели, сек

    % Дата и время начала отсчета времени в системе GPS 1980-01-06 00:00:00
    t_GPS_eph = datetime(1980,1,6,0,0,0);

    % Число секунд в неделе
    week_seconds = 7*24*3600;
    
    % Число секунд от начала эпохи GPS
    delta_seconds = seconds(duration(time - t_GPS_eph));

    % Число високосных секунд на момент 2026 года
    leap_seconds = 18;

    % Число секунд от начала эпохи с учетом високосных секунд
    gps_seconds = delta_seconds + leap_seconds;

    % Число секунд от начала недели
    GpsTime = mod(gps_seconds,week_seconds);

   
end