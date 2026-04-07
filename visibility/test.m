clear

targetHour = 13;
targetMinute = 0;
targetSecond = 0;

t = datetime(2026,1,9,targetHour,targetMinute,targetSecond);

orbitLeo = struct();

orbitLeo.h = 800; % высота орбиты, км
orbitLeo.i0 = 82.3; % наклонение орбиты, град
orbitLeo.Omega0 = 50;
orbitLeo.u0 = 20;

widthMainLobeLeo = 130;
widthMainLobeGps = 90;

rinexFile = 'Brdc0090.26n';

eph = getEphemeris('Brdc0090.26n', t);


[numberSat,flagVisible] = visibleSat(t, rinexFile, orbitLeo, widthMainLobeLeo, widthMainLobeGps);



