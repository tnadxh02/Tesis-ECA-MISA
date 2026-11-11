%% Factor de Wahl e indice del resorte
clear; clc; close all;

d_mm = 3.0;
Dm_mm = 35.5;
C = linspace(3,20,500);
Kw = ((4.*C - 1)./(4.*C - 4)) + (0.615./C);

C_real = Dm_mm/d_mm;
Kw_real = ((4*C_real - 1)/(4*C_real - 4)) + (0.615/C_real);

TablaWahl = table(C_real,Kw_real,'VariableNames',{'IndiceResorte_C','FactorWahl_K'});

disp(TablaWahl)

figure('Name','Factor de Wahl','NumberTitle','off');
plot(C,Kw,'LineWidth',2)
hold on
plot(C_real,Kw_real,'o','MarkerSize',8,'LineWidth',2)
grid on
box on

xlabel('Indice del resorte, C')
ylabel('Factor de Wahl, K')
title('Factor de Wahl en funcion del indice del resorte')
legend('Curva de Wahl','Resorte ECA','Location','northeast')
set(gca,'FontSize',11)