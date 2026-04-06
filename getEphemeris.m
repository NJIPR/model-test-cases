function eph = getEphemeris(rinexFile, targetTime)
% getEphemeris - Поиск эфемерид GPS в RINEX 3.02 файле
%
% Входные параметры:
%   rinexFile   - строка с именем файла эфемерид в формате RINEX 3.02
%   time - текущее время, yyyy:mm:dd hh:mm:ss
%
% Выходные параметры:
%   eph - структура с эфемеридами, ближайшими по времени (округление на меньшее)

    % Выделение времени (часы:минуты:секунды) из текущей даты
    [targetHour, targetMinute, targetSecond] = hms(targetTime);      

    % Чтение файла RINEX
    fid = fopen(rinexFile, 'r');
    if fid == -1
        error('Не удалось открыть файл: %s', rinexFile);
    end
    
    % Преобразование целевого времени в минуты от начала дня
    targetTimeMinutes = targetHour * 60 + targetMinute + targetSecond/60;
    
    % Структура для хранения всех эфемерид
    allEph = struct();
    ephIndex = 0;
        
    % Чтение файла построчно
    lineEph = fgetl(fid);
    while ischar(lineEph)
        % Ищем первую строчку эфемерид
        if contains(lineEph, 'G') && contains(lineEph, '2026')
            % Извлекаем время эфемерид
            % Формат: YYYY MM DD HH MM 
            tokens = regexp(lineEph, '(\d{4})\s+(\d{2})\s+(\d{2})\s+(\d{2})\s+(\d{2})\s+', 'tokens');
            if ~isempty(tokens)
                t = tokens{1};
                year = str2double(t{1});
                month = str2double(t{2});
                day = str2double(t{3});
                hour = str2double(t{4});
                minute = str2double(t{5});
                second = str2double(lineEph(22:23));
                
                % Вычисляем время в минутах от начала дня
                currentTimeMinutes = hour * 60 + minute + second/60;
                
                
                % Сохраняем время
                ephIndex = ephIndex + 1;
                allEph(ephIndex).numberSat = str2double(lineEph(2:3));
                allEph(ephIndex).time = [year, month, day, hour, minute, second];
                allEph(ephIndex).timeMinutes = currentTimeMinutes;
                allEph(ephIndex).timeDiff = targetTimeMinutes - currentTimeMinutes;
                
                
                % Читаем три параметра орбиты из первой строчки
                for strIdx = 1:3
                            
                            startIdx = (strIdx-1)*19 + 24;
                            endIdx = strIdx*19 + 23;
                            
                           
                            if length(lineEph) >= endIdx
                                numStr = strtrim(lineEph(startIdx:endIdx));
                                if ~isempty(numStr)
                                    tempephData(strIdx) = str2double(numStr);
                                end
                            end
                end
                
                
                
                % Читаем следующие 7 строк эфемерид, 25 параметров орбиты
                ephData = zeros(1, 25);                             
                
                for strIdx = 1:7
                    dataLine = fgetl(fid);
                    if ischar(dataLine)
                        % Извлекаем 4 числа из строки (по 19 символов каждое)
                        for numIdx = 1:4
                            
                            startIdx = (numIdx-1)*19 + 4;
                            endIdx = numIdx*19 + 4;
                            
                            if(numIdx > 1)
                                startIdx = startIdx + 1;
                            end
                            
                            if length(dataLine) >= endIdx
                                numStr = strtrim(dataLine(startIdx:endIdx));
                                if ~isempty(numStr)
                                    ephData((strIdx-1)*4 + numIdx) = str2double(numStr);
                                end
                            end
                        end
                    end
                end
                
                % Объединение эфемерид в общий массив из 28 параметров
                ephData = [tempephData,ephData];
                
                % Сохраняем эфемеридные параметры
%                 allEph(ephIndex).ephParams = ephData;
                
                % Сохраняем также расшифрованные параметры
                if length(ephData) >= 28
                    allEph(ephIndex).M0 = ephData(7);      % Средняя аномалия
                    allEph(ephIndex).delta_n = ephData(6); % Поправка среднего движения
                    allEph(ephIndex).ecc = ephData(9);     % Эксцентриситет
                    allEph(ephIndex).sqrtA = ephData(11);   % Квадратный корень большой полуоси
                    allEph(ephIndex).omega0 = ephData(14);  % Долгота восходящего узла
                    allEph(ephIndex).i0 = ephData(16);      % Наклонение
                    allEph(ephIndex).omega = ephData(18);   % Аргумент перигея
                    allEph(ephIndex).idot = ephData(20);    % Скорость изменения наклонения
                    allEph(ephIndex).Cuc = ephData(8);     % Амплитуда косинуса широты
                    allEph(ephIndex).Cus = ephData(10);     % Амплитуда синуса широты
                    allEph(ephIndex).Crc = ephData(17);     % Амплитуда косинуса радиуса
                    allEph(ephIndex).Crs = ephData(5);     % Амплитуда синуса радиуса
                    allEph(ephIndex).Cic = ephData(13);     % Амплитуда косинуса наклонения
                    allEph(ephIndex).Cis = ephData(15);     % Амплитуда синуса наклонения
                    allEph(ephIndex).toe = ephData(12);     % Эпоха эфемерид
                    allEph(ephIndex).iodc = ephData(27);    % IODC
                    allEph(ephIndex).af0 = ephData(1);     % Смещение часов
                    allEph(ephIndex).af1 = ephData(2);     % Дрейф часов
                    allEph(ephIndex).af2 = ephData(3);     % Ускорение часов
                    allEph(ephIndex).omegadot = ephData(19); % Скорость изменения долготы восходящего узла
                    allEph(ephIndex).iode = ephData(4); %IODE
                    allEph(ephIndex).GpsWeek = ephData(22); %номер недели
                end
            end
        end
        
        lineEph = fgetl(fid);
    end
    
    fclose(fid);
    

    % Определение эфемерид, для которых разница между целевым временем
    % лежит в диапазоне от 0 до 120 минут
    ephTwoHour = allEph([allEph.timeDiff] >= 0 & [allEph.timeDiff] <= 120);
    
    % Сортировка массива эфемерид по возрастанию разницы между целевым
    % временем и временем эфемерид
    [B,index] = sort([ephTwoHour.timeDiff]);
    ephTwoHourSort = ephTwoHour(index);

    % Находим только неповторяющиеся спутники, так как в пределах 120 минут
    % у произвольного спутника могут быть обновлены эфемериды
    satUniq = unique([ephTwoHourSort.numberSat]);
    
    i=1;
    
    for ephIdx=1:numel([ephTwoHourSort.timeDiff])
        
        % Если спутник неповторяющийся, записываем его эфемериды в массив с
        % выходными данными
        if (ismember(ephTwoHourSort(ephIdx).numberSat,satUniq))
            
            eph(i) = ephTwoHourSort(ephIdx);
            i = i + 1;
            
            satUniq = setdiff(satUniq,ephTwoHourSort(ephIdx).numberSat);
            
        end

        % Если спутник уже есть в массиве с выходными данными
        if (ismember(ephTwoHourSort(ephIdx).numberSat,[eph.numberSat]))
            
            index = ismember(ephTwoHourSort(ephIdx).numberSat,[eph.numberSat]);
            
            % Обновляем выходной массив только в случае, когда разница по
            % времени минимальна
            if(ephTwoHourSort(ephIdx).timeDiff < eph(index).timeDiff)
                
                eph(index) = ephTwoHourSort(ephIdx);
                
            end
            
        end
        
        
    end
    
    
end