%% MISA - Modelo teorico dipolar simplificado
clc; clear; close all;

% Parametros magneticos
mu0 = 4*pi*1e-7; % Permeabilidad del vacio [T*m/A]
Br = 1.17; % Remanencia magnetica [T]

% Dimensiones del iman de anillo
Do_mm = 30; % Diametro exterior [mm]
Di_mm = 10; % Diametro interior [mm]
t_mm = 9; % Espesor del iman [mm]

% Conversion de unidades
Do_m = Do_mm/1000; % Diametro exterior [m]
Di_m = Di_mm/1000; % Diametro interior [m]
t_m = t_mm/1000; % Espesor del iman [m]

% Calculo del volumen y momento magnetico
V_m3 = (pi/4)*(Do_m^2 - Di_m^2)*t_m; % Volumen del iman [m^3]
m_Am2 = (Br*V_m3)/mu0; % Momento magnetico [A*m^2]

fprintf('Volumen del iman = %.6e m^3\n', V_m3);
fprintf('Momento magnetico = %.4f A*m^2\n', m_Am2);

% Datos de desplazamiento
x_mm = [0 5 10 15 20 25 30 35 40 45 50]; % Desplazamiento del actuador [mm]
d0_mm = 50; % Distancia inicial entre caras de los imanes [mm]

% Distancia entre caras y centros magneticos
d_caras_mm = d0_mm - x_mm; % Distancia entre caras de los imanes [mm]
d_caras_mm(d_caras_mm < 0) = 0; % Correccion para evitar distancias negativas
d_centros_mm = t_mm + d_caras_mm; % Distancia entre centros magneticos [mm]
d_centros_m = d_centros_mm/1000; % Distancia entre centros magneticos [m]

% Calculo de fuerza magnetica teorica
F_teorica_N = (3*mu0/(2*pi)).*(m_Am2^2)./(d_centros_m.^4); % Fuerza teorica [N]

% Tabla de resultados
tabla_resultados = table(x_mm', d_caras_mm', d_centros_mm', F_teorica_N', 'VariableNames', {'Desplazamiento_mm','Distancia_entre_caras_mm','Distancia_entre_centros_mm','Fuerza_teorica_N'});
disp(tabla_resultados);

% Curva suavizada
x_suave_mm = linspace(0, 50, 300); % Desplazamiento suavizado [mm]
d_caras_suave_mm = d0_mm - x_suave_mm; % Distancia entre caras suavizada [mm]
d_caras_suave_mm(d_caras_suave_mm < 0) = 0; % Correccion para evitar distancias negativas
d_centros_suave_mm = t_mm + d_caras_suave_mm; % Distancia entre centros suavizada [mm]
d_centros_suave_m = d_centros_suave_mm/1000; % Distancia entre centros suavizada [m]
F_suave_N = (3*mu0/(2*pi)).*(m_Am2^2)./(d_centros_suave_m.^4); % Fuerza teorica suavizada [N]

% Grafica del modelo teorico
figure;
plot(x_suave_mm, F_suave_N, 'LineWidth', 1.8);
grid on;
xlabel('Desplazamiento del actuador (mm)');
ylabel('Fuerza magnetica teorica (N)');
title('Modelo teorico fuerza-desplazamiento del MISA');