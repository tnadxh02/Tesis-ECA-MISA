%% Comparacion experimental ECA y MISA

clc; clear; close all;

R_tendon = 1.522;
r_codo_mm = 35;

ECA = calcularMetricas(procesarActuador('datos_ECA.xlsx'), R_tendon, r_codo_mm);
MISA = calcularMetricas(procesarActuador('datos_MISA.xlsx'), R_tendon, r_codo_mm);

n_datos = max(numel(ECA.x_mm), numel(MISA.x_mm));
n_incremental = max(numel(ECA.x_medio_mm), numel(MISA.x_medio_mm));

%% Tablas comparativas

Tabla_FD = table(completarNaN(ECA.x_mm,n_datos), completarNaN(ECA.F_N,n_datos), ...
    completarNaN(MISA.x_mm,n_datos), completarNaN(MISA.F_N,n_datos), ...
    'VariableNames', {'Desplazamiento_ECA_mm','Fuerza_ECA_N','Desplazamiento_MISA_mm','Fuerza_MISA_N'});

Tabla_Rigidez_Aparente = table(completarNaN(ECA.x_mm,n_datos), completarNaN(ECA.k_ap_Nmm,n_datos), ...
    completarNaN(MISA.x_mm,n_datos), completarNaN(MISA.k_ap_Nmm,n_datos), ...
    'VariableNames', {'Desplazamiento_ECA_mm','Rigidez_aparente_ECA_N_mm','Desplazamiento_MISA_mm','Rigidez_aparente_MISA_N_mm'});

Tabla_Rigidez_Incremental = table(completarNaN(ECA.x_medio_mm,n_incremental), completarNaN(ECA.k_inc_Nmm,n_incremental), ...
    completarNaN(MISA.x_medio_mm,n_incremental), completarNaN(MISA.k_inc_Nmm,n_incremental), ...
    'VariableNames', {'Desplazamiento_medio_ECA_mm','Rigidez_incremental_ECA_N_mm','Desplazamiento_medio_MISA_mm','Rigidez_incremental_MISA_N_mm'});

Tabla_Energia = table(completarNaN(ECA.x_mm,n_datos), completarNaN(ECA.E_J,n_datos), ...
    completarNaN(MISA.x_mm,n_datos), completarNaN(MISA.E_J,n_datos), ...
    'VariableNames', {'Desplazamiento_ECA_mm','Energia_ECA_J','Desplazamiento_MISA_mm','Energia_MISA_J'});

Tabla_Flexion = table(completarNaN(ECA.theta_deg,n_datos), completarNaN(ECA.F_N,n_datos), ...
    completarNaN(MISA.theta_deg,n_datos), completarNaN(MISA.F_N,n_datos), ...
    'VariableNames', {'Flexion_ECA_deg','Fuerza_ECA_N','Flexion_MISA_deg','Fuerza_MISA_N'});

Tabla_Torque = table(completarNaN(ECA.theta_deg,n_datos), completarNaN(ECA.Torque_Nm,n_datos), ...
    completarNaN(MISA.theta_deg,n_datos), completarNaN(MISA.Torque_Nm,n_datos), ...
    'VariableNames', {'Flexion_ECA_deg','Torque_ECA_Nm','Flexion_MISA_deg','Torque_MISA_Nm'});

%% Mostrar tablas

disp('TABLA COMPARATIVA FUERZA-DESPLAZAMIENTO'); disp(Tabla_FD);
disp('TABLA COMPARATIVA RIGIDEZ APARENTE'); disp(Tabla_Rigidez_Aparente);
disp('TABLA COMPARATIVA RIGIDEZ INCREMENTAL'); disp(Tabla_Rigidez_Incremental);
disp('TABLA COMPARATIVA ENERGIA ACUMULADA'); disp(Tabla_Energia);
disp('TABLA COMPARATIVA FUERZA-FLEXION'); disp(Tabla_Flexion);
disp('TABLA COMPARATIVA TORQUE TEORICO'); disp(Tabla_Torque);

%% Fuerza-desplazamiento

figure;
plot(ECA.x_mm,ECA.F_N,'-o','LineWidth',2,'DisplayName','ECA'); hold on;
plot(MISA.x_mm,MISA.F_N,'-s','LineWidth',2,'DisplayName','MISA');

grid on; box on;
xlabel('Desplazamiento (mm)'); ylabel('Fuerza (N)');
title('Comparacion fuerza-desplazamiento experimental');
legend('Location','northwest');

%% Rigidez aparente

figure;
plot(ECA.x_mm,ECA.k_ap_Nmm,'-o','LineWidth',2,'DisplayName','ECA'); hold on;
plot(MISA.x_mm,MISA.k_ap_Nmm,'-s','LineWidth',2,'DisplayName','MISA');

grid on; box on;
xlabel('Desplazamiento (mm)'); ylabel('Rigidez aparente (N/mm)');
title('Comparacion de rigidez aparente experimental');
legend('Location','best');

%% Rigidez incremental

figure;
plot(ECA.x_medio_mm,ECA.k_inc_Nmm,'-o','LineWidth',2,'DisplayName','ECA'); hold on;
plot(MISA.x_medio_mm,MISA.k_inc_Nmm,'-s','LineWidth',2,'DisplayName','MISA');

grid on; box on;
xlabel('Desplazamiento medio del intervalo (mm)'); ylabel('Rigidez incremental (N/mm)');
title('Comparacion de rigidez incremental experimental');
legend('Location','best');

%% Energia acumulada

figure;
plot(ECA.x_mm,ECA.E_J,'-o','LineWidth',2,'DisplayName','ECA'); hold on;
plot(MISA.x_mm,MISA.E_J,'-s','LineWidth',2,'DisplayName','MISA');

grid on; box on;
xlabel('Desplazamiento (mm)'); ylabel('Energia (J)');
title('Comparacion de energia acumulada');
legend('Location','best');

%% Fuerza-flexion teorica

figure;
plot(ECA.theta_deg,ECA.F_N,'-o','LineWidth',2,'DisplayName','ECA'); hold on;
plot(MISA.theta_deg,MISA.F_N,'-s','LineWidth',2,'DisplayName','MISA');

grid on; box on;
xlabel('Flexion teorica del codo (deg)'); ylabel('Fuerza (N)');
title('Fuerza vs flexion teorica del codo');
legend('Location','best');

%% Torque teorico

figure;
plot(ECA.theta_deg,ECA.Torque_Nm,'-o','LineWidth',2,'DisplayName','ECA'); hold on;
plot(MISA.theta_deg,MISA.Torque_Nm,'-s','LineWidth',2,'DisplayName','MISA');

grid on; box on;
xlabel('Flexion teorica del codo (deg)'); ylabel('Torque (N*m)');
title('Torque articular teorico');
legend('Location','best');

%% Funciones

function A = procesarActuador(archivo)

datos = readtable(archivo,'Sheet',1,'VariableNamingRule','preserve');
datos.Properties.VariableNames(1:6) = {'Bloque','Prueba','Grupo','Distancia_nominal_mm','Carga_kg','Distancia_real_mm'};

datos.Fuerza_N = datos.Carga_kg .* 9.81;

[g1,~,x_nom_bloque_mm] = findgroups(datos.Bloque,datos.Distancia_nominal_mm);
x_bloque_mm = splitapply(@mean,datos.Distancia_real_mm,g1);
F_bloque_N = splitapply(@mean,datos.Fuerza_N,g1);

[g2,~] = findgroups(x_nom_bloque_mm);
x_mm = splitapply(@mean,x_bloque_mm,g2);
F_N = splitapply(@mean,F_bloque_N,g2);

[x_mm,orden] = sort(x_mm);
F_N = F_N(orden);

A.x_mm = [0; x_mm];
A.F_N = [0; F_N];

end

function A = calcularMetricas(A,R_tendon,r_codo_mm)

A.k_ap_Nmm = A.F_N ./ A.x_mm;
A.k_ap_Nmm(A.x_mm == 0) = 0;

A.k_inc_Nmm = diff(A.F_N) ./ diff(A.x_mm);
A.x_medio_mm = (A.x_mm(1:end-1) + A.x_mm(2:end)) / 2;

A.E_J = cumtrapz(A.x_mm,A.F_N) / 1000;
A.theta_deg = rad2deg((R_tendon .* A.x_mm) / r_codo_mm);
A.Torque_Nm = A.F_N .* (r_codo_mm / 1000);

end

function v_out = completarNaN(v_in,n)

v_out = NaN(n,1);
v_out(1:numel(v_in)) = v_in(:);

end