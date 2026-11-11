%% MISA - Curva semiempirica fuerza-desplazamiento
clc; clear; close all;

% Datos de entrada
x_mm = [0 5 10 15 20 25 30 35 40 45 50]; % Desplazamiento del actuador [mm]
A = 0.8537; % Coeficiente del modelo [N]
B = 0.06706; % Coeficiente del modelo [1/mm]

% Calculo de la fuerza semiempirica
F_semiempirica_N = A.*(exp(B.*x_mm) - 1); % Fuerza magnetica calculada [N]

% Tabla de resultados
tabla_resultados = table(x_mm', F_semiempirica_N', 'VariableNames', {'Desplazamiento_mm','Fuerza_semiempirica_N'});
disp(tabla_resultados);

% Grafica de puntos calculados
figure;
plot(x_mm, F_semiempirica_N, 'o-', 'LineWidth', 1.8, 'MarkerSize', 7);
grid on;
xlabel('Desplazamiento del actuador (mm)');
ylabel('Fuerza magnetica (N)');
title('Curva semiempirica fuerza-desplazamiento del MISA');

% Etiquetas de fuerza en cada punto
for i = 1:length(x_mm)
    text(x_mm(i), F_semiempirica_N(i), sprintf(' %.2f', F_semiempirica_N(i)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end

% Exportacion de la grafica
exportgraphics(gcf, 'curva_semiempirica_misa.png', 'Resolution', 300);

% Curva suavizada del modelo
x_suave_mm = linspace(0, 50, 300);
F_suave_N = A.*(exp(B.*x_suave_mm) - 1);

% Grafica de la curva suavizada
figure;
plot(x_suave_mm, F_suave_N, 'LineWidth', 1.8);
grid on;
xlabel('Desplazamiento del actuador (mm)');
ylabel('Fuerza magnetica (N)');
title('Modelo semiempirico fuerza-desplazamiento del MISA');

% Exportacion de la grafica suavizada
exportgraphics(gcf, 'curva_suavizada_modelo_misa.png', 'Resolution', 300);