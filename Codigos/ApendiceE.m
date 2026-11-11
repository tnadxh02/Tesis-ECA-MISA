%% Curva analítica ECA

clear; clc; close all;

d  = 3.0;      
Dm = 35.5;     
Na = 11;       
G  = 79000;    

k = (G*d^4)/(8*Na*Dm^3);  %constante k del resorte
fprintf('Constante del resorte k = %.4f N/mm\n',k);

x_ECA = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 90 100 107]'; %desplazamiento ideal 
F_ECA = k*x_ECA; % Fuerza calculada segun ley de Hooke 

mitad = ceil(length(x_ECA)/2);

x_ECA_1 = x_ECA(1:mitad);
F_ECA_1 = F_ECA(1:mitad);
x_ECA_2 = x_ECA(mitad+1:end);
F_ECA_2 = F_ECA(mitad+1:end);

TablaECA = table(x_ECA_1,F_ECA_1,x_ECA_2,F_ECA_2,'VariableNames',{'Desplazamiento_mm','Fuerza_N','Desplazamiento_mm_2','Fuerza_N_2'});

disp('TABLA ECA:')
disp(TablaECA)
figure('Name','Curva ECA','NumberTitle','off');
plot(x_ECA,F_ECA,'LineWidth',2)

grid on

xlabel('Desplazamiento (mm)','FontSize',12)
ylabel('Fuerza (N)','FontSize',12)
title('Curva Fuerza-Desplazamiento del ECA')

set(gca,'FontSize',11)