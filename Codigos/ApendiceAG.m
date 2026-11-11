%% Curva Fuerza-Desplazamiento SIMULADO ECA
% DATOS DE FORCE REACTION

clear; clc; close all;
% Datos de desplazamiento y fuerza 
x_ECA_FEM = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100 107]';
F_ECA_FEM = [0 8.33 16.65 24.95 33.24 41.51 49.77 58.02 66.25 74.46 82.72 90.87 99.06 107.25 115.39 123.58 131.74 148.04 165.16 176.21]';


TablaECA_FEM = table(x_ECA_FEM,F_ECA_FEM,'VariableNames',{'Distancia_mm','Fuerza_N'});

disp('TABLA FUERZA DE REACCION SIMULADA ECA:')
disp(TablaECA_FEM)

figure('Name','Curva FEM ECA','NumberTitle','off');
plot(x_ECA_FEM,F_ECA_FEM,'b','LineWidth',2)
grid on

xlabel('Desplazamiento (mm)','FontSize',12)
ylabel('Fuerza (N)','FontSize',12)
title('Curva Fuerza-Desplazamiento de simulacion Fuerza de reaccion')
set(gca,'FontSize',11)