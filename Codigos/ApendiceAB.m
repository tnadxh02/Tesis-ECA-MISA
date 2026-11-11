%% Analisis de datos experimentales

clear; clc; close all;

archivo = 'datos_ECA.xlsx';
actuador = 'ECA';

% archivo = 'datos_MISA.xlsx';
% actuador = 'MISA';

datos = readtable(archivo,'Sheet',1,'VariableNamingRule','preserve');
datos.Properties.VariableNames(1:6) = {'Bloque','Prueba','Grupo','Distancia_nominal_mm','Carga_kg','Distancia_real_mm'};
datos.Fuerza_N = datos.Carga_kg .* 9.81;

%% Promedios por bloque

[G_bloque,bloque,distancia_nominal_mm] = findgroups(datos.Bloque,datos.Distancia_nominal_mm);
distancia_bloque_mm = splitapply(@mean,datos.Distancia_real_mm,G_bloque);
fuerza_bloque_N = splitapply(@mean,datos.Fuerza_N,G_bloque);

TablaBloques = table(bloque,distancia_nominal_mm,distancia_bloque_mm,fuerza_bloque_N,...
    'VariableNames',{'Bloque','DistanciaIdeal_mm','DistanciaPromedioBloque_mm','FuerzaPromedioBloque_N'});

%% Promedio global

[G_global,distancia_ideal_mm] = findgroups(TablaBloques.DistanciaIdeal_mm);
distancia_promedio_mm = splitapply(@mean,TablaBloques.DistanciaPromedioBloque_mm,G_global);
desv_distancia_mm = splitapply(@std,TablaBloques.DistanciaPromedioBloque_mm,G_global);

fuerza_promedio_N = splitapply(@mean,TablaBloques.FuerzaPromedioBloque_N,G_global);
desv_fuerza_N = splitapply(@std,TablaBloques.FuerzaPromedioBloque_N,G_global);

variacion_fuerza_pct = 100 .* desv_fuerza_N ./ fuerza_promedio_N;
error_posicion_pct = 100 .* abs(distancia_promedio_mm - distancia_ideal_mm) ./ distancia_ideal_mm;

variacion_fuerza_pct(fuerza_promedio_N == 0) = 0;
error_posicion_pct(distancia_ideal_mm == 0) = 0;

%% Tabla de resultados

TablaExperimental = table(distancia_ideal_mm,distancia_promedio_mm,desv_distancia_mm,...
    fuerza_promedio_N,desv_fuerza_N,variacion_fuerza_pct,error_posicion_pct,...
    'VariableNames',{'DistanciaIdeal_mm','DistanciaPromedio_mm','DesvDistancia_mm',...
    'FuerzaPromedio_N','DesvFuerza_N','VariacionFuerza_pct','ErrorPosicion_pct'});

disp(TablaExperimental)

%% Curva fuerza-desplazamiento

figure('Name',['Curva fuerza-desplazamiento ',actuador],'NumberTitle','off');
plot(distancia_promedio_mm,fuerza_promedio_N,'o-','LineWidth',2,'MarkerSize',7);

grid on; box on
xlabel('Desplazamiento experimental promedio (mm)')
ylabel('Fuerza experimental promedio (N)')
title(['Curva fuerza-desplazamiento experimental del ',actuador])
set(gca,'FontSize',11)

%% Dispersion experimental

figure('Name',['Dispersion ',actuador],'NumberTitle','off');
hold on

grupo_txt = string(datos.Grupo);
grupos = unique(grupo_txt,'stable');

for i = 1:numel(grupos)
    idx = grupo_txt == grupos(i);
    scatter(datos.Distancia_real_mm(idx),datos.Fuerza_N(idx),35,'filled');
end

grid on; box on
xlabel('Desplazamiento experimental (mm)')
ylabel('Fuerza experimental (N)')
title(['Dispersion de datos experimentales del ',actuador])

nombres_grupos = cellstr(grupos);
legend(nombres_grupos,'Location','northwest')
set(gca,'FontSize',11)