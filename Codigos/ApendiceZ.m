%% Comparacion analitica, FEM y experimental del ECA

clear; clc; close all;

archivo = 'datos_ECA.xlsx';

datos = readtable(archivo,'Sheet',1,'VariableNamingRule','preserve');
datos.Properties.VariableNames(1:6) = {'Bloque','Prueba','Grupo','Distancia_nominal_mm','Carga_kg','Distancia_real_mm'};
datos.Fuerza_N = datos.Carga_kg .* 9.81;

%% Promedios experimentales

[G_bloque,bloque,distancia_nominal_mm] = findgroups(datos.Bloque,datos.Distancia_nominal_mm);
distancia_bloque_mm = splitapply(@mean,datos.Distancia_real_mm,G_bloque);
fuerza_bloque_N = splitapply(@mean,datos.Fuerza_N,G_bloque);

TablaBloques = table(bloque,distancia_nominal_mm,distancia_bloque_mm,fuerza_bloque_N,...
    'VariableNames',{'Bloque','DistanciaIdeal_mm','DistanciaPromedioBloque_mm','FuerzaPromedioBloque_N'});

[G_global,distancia_ideal_mm] = findgroups(TablaBloques.DistanciaIdeal_mm);
x_EXP_mm = splitapply(@mean,TablaBloques.DistanciaPromedioBloque_mm,G_global);
F_EXP_N = splitapply(@mean,TablaBloques.FuerzaPromedioBloque_N,G_global);

[x_EXP_mm,orden] = sort(x_EXP_mm);
F_EXP_N = F_EXP_N(orden);
distancia_ideal_mm = distancia_ideal_mm(orden);

%% Modelo analitico

k_Nmm = 1.6253;
F_analitica_N = k_Nmm .* x_EXP_mm;

%% Datos FEM

x_FEM_mm = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100 107]';
F_FEM_N = [0 8.33 16.65 24.95 33.24 41.51 49.77 58.02 66.25 74.46 82.72 90.87 99.06 107.25 115.39 123.58 131.74 148.04 165.16 176.21]';

F_FEM_interp_N = interp1(x_FEM_mm,F_FEM_N,x_EXP_mm,'linear');

%% Errores

error_analitico_N = abs(F_EXP_N - F_analitica_N);
error_FEM_N = abs(F_EXP_N - F_FEM_interp_N);

error_analitico_pct = 100 .* error_analitico_N ./ F_analitica_N;
error_FEM_pct = 100 .* error_FEM_N ./ F_FEM_interp_N;

error_analitico_pct(F_analitica_N == 0) = 0;
error_FEM_pct(F_FEM_interp_N == 0) = 0;

error_analitico_prom_pct = mean(error_analitico_pct);
error_FEM_prom_pct = mean(error_FEM_pct);

%% Tabla comparativa

TablaComparacion = table(x_EXP_mm,F_analitica_N,F_FEM_interp_N,F_EXP_N,...
    error_analitico_pct,error_FEM_pct,...
    'VariableNames',{'Desplazamiento_mm','FuerzaAnalitica_N','FuerzaFEM_N',...
    'FuerzaExperimental_N','ErrorAnalitico_pct','ErrorFEM_pct'});

disp(TablaComparacion)

fprintf('Error analitico promedio = %.2f %%\n',error_analitico_prom_pct);
fprintf('Error FEM promedio = %.2f %%\n',error_FEM_prom_pct);

%% Comparacion de curvas

figure('Name','Comparacion ECA','NumberTitle','off');
plot(x_EXP_mm,F_analitica_N,'LineWidth',2); hold on
plot(x_EXP_mm,F_FEM_interp_N,'LineWidth',2);
plot(x_EXP_mm,F_EXP_N,'o-','LineWidth',2,'MarkerSize',7);

grid on; box on
xlabel('Desplazamiento (mm)')
ylabel('Fuerza (N)')
title('Comparacion fuerza-desplazamiento del ECA')

legend('Modelo analitico','FEM','Experimental','Location','northwest')
set(gca,'FontSize',11)