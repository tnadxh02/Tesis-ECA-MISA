%% Comparacion experimental y modelo semiempirico MISA

clear; clc; close all;

archivo_MISA = 'datos_MISA.xlsx';

datos_MISA = readtable(archivo_MISA,'Sheet',1,'VariableNamingRule','preserve');
datos_MISA.Properties.VariableNames(1:6) = {'Bloque','Prueba','Grupo','Distancia_nominal_mm','Carga_kg','Distancia_real_mm'};
datos_MISA.Fuerza_N = datos_MISA.Carga_kg .* 9.81;

% Promedios por bloque
[G_bloque,bloque,x_nom_bloque_mm] = findgroups(datos_MISA.Bloque,datos_MISA.Distancia_nominal_mm);
x_real_bloque_mm = splitapply(@mean,datos_MISA.Distancia_real_mm,G_bloque);
F_bloque_N = splitapply(@mean,datos_MISA.Fuerza_N,G_bloque);

% Promedio global

[G_global,x_nom_mm] = findgroups(x_nom_bloque_mm);
x_exp_mm = splitapply(@mean,x_real_bloque_mm,G_global);
F_exp_N = splitapply(@mean,F_bloque_N,G_global);

[x_nom_mm,orden] = sort(x_nom_mm);
x_exp_mm = x_exp_mm(orden);
F_exp_N = F_exp_N(orden);

x_nom_mm = [0; x_nom_mm];
x_exp_mm = [0; x_exp_mm];
F_exp_N = [0; F_exp_N];

% Modelo semiempirico

A_N = 0.8537;
B_mm_inv = 0.06706;

F_modelo_N = A_N .* (exp(B_mm_inv .* x_nom_mm) - 1);
x_modelo_mm = linspace(0,max(x_nom_mm),300);
F_modelo_cont_N = A_N .* (exp(B_mm_inv .* x_modelo_mm) - 1);

% Errores

error_abs_N = abs(F_exp_N - F_modelo_N);
error_pct = abs((F_exp_N - F_modelo_N) ./ F_exp_N) .* 100;
error_pct(F_exp_N == 0) = NaN;

% Tabla de fuerzas

TablaFuerzas = table(x_nom_mm,F_exp_N,F_modelo_N,...
    'VariableNames',{'Desplazamiento_mm','FuerzaExperimental_N','FuerzaModelo_N'});

disp(TablaFuerzas)

% Tabla de errores

TablaErrores = table(x_nom_mm,error_abs_N,error_pct,...
    'VariableNames',{'Desplazamiento_mm','ErrorAbsoluto_N','ErrorPorcentual_pct'});

disp(TablaErrores)

%% Comparacion experimental y modelo

figure('Name','Comparacion MISA','NumberTitle','off');
plot(x_modelo_mm,F_modelo_cont_N,'LineWidth',2); hold on
plot(x_nom_mm,F_exp_N,'o-','LineWidth',2,'MarkerSize',7);

grid on; box on
xlabel('Desplazamiento (mm)')
ylabel('Fuerza (N)')
title('Comparacion entre modelo semiempirico y datos experimentales del MISA')

legend('Modelo semiempirico','Experimental','Location','northwest')
set(gca,'FontSize',11)

%% Curvas experimentales por bloque

figure('Name','Bloques experimentales MISA','NumberTitle','off');
hold on

bloques = unique(bloque);

for i = 1:numel(bloques)
    indice = bloque == bloques(i);
    x_bloque_mm = x_nom_bloque_mm(indice);
    F_actual_N = F_bloque_N(indice);

    [x_bloque_mm,orden_bloque] = sort(x_bloque_mm);
    F_actual_N = F_actual_N(orden_bloque);

    plot(x_bloque_mm,F_actual_N,'o-','LineWidth',1.0,'MarkerSize',4);
end

plot(x_nom_mm,F_exp_N,'o-','LineWidth',2.2,'MarkerSize',7);

grid on; box on
xlabel('Desplazamiento (mm)')
ylabel('Fuerza magnetica (N)')
title('Curvas experimentales por bloque y promedio del MISA')

legend('Bloque 1','Bloque 2','Bloque 3','Bloque 4','Bloque 5',...
    'Promedio experimental','Location','northwest')

set(gca,'FontSize',11)