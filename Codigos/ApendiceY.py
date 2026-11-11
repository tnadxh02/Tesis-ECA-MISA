// CONTROL INDIVIDUAL ECA MISA
// Control de movimiento y calibracion individual de los actuadores ECA y MISA.

// CONFIGURACION DEL MOTOR

#define PWMA 9
#define AIN1 10
#define AIN2 11
#define STBY 12

// PARAMETROS DE CONTROL

float velocidadRealMMS = 7.8;  // ECA
// float velocidadRealMMS = 36.0;  // MISA

float posicionActualMM = 0.0;
int velocidadMotor = 255;

// PARAMETROS SERIAL

unsigned long ultimoClearMS = 0;
const unsigned long intervaloClearMS = 30000;

// CONFIGURACION INICIAL

void setup() {
  Serial.begin(9600);
  Serial.setTimeout(100);

  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(PWMA, OUTPUT);
  pinMode(STBY, OUTPUT);

  digitalWrite(STBY, HIGH);
  detenerMotor();

  Serial.println("SISTEMA LISTO");
  imprimirAyuda();
}

// CICLO PRINCIPAL

void loop() {
  limpiarBufferAutomatico();

  if (Serial.available() > 0) {
    String comando = Serial.readStringUntil('\n');
    comando.trim();
    vaciarSerial();

    if (comando.equalsIgnoreCase("R")) {
      regresarOrigen();
    }
    else if (comando.equalsIgnoreCase("O")) {
      posicionActualMM = 0.0;
      Serial.println("ORIGEN RECALIBRADO");
    }
    else if (comando.equalsIgnoreCase("T")) {
      pruebaCalibracion();
    }
    else {
      float distanciaMM = comando.toFloat();

      if (distanciaMM != 0.0) {
        moverMM(distanciaMM);
      }
      else {
        Serial.println("COMANDO INVALIDO");
      }
    }
  }
}

// COMANDOS

void imprimirAyuda() {
  Serial.println("COMANDOS");
  Serial.println("VALOR POSITIVO: ADELANTE");
  Serial.println("VALOR NEGATIVO: REVERSA");
  Serial.println("R: REGRESAR AL ORIGEN");
  Serial.println("O: RECALIBRAR ORIGEN");
  Serial.println("T: PRUEBA DE TIEMPO");
}

// MOVIMIENTO EN MILIMETROS

void moverMM(float distanciaMM) {
  unsigned long tiempoInicioMS = millis();

  unsigned long tiempoMovimientoMS =
    calcularTiempoMovimiento(distanciaMM);

  Serial.print("MOVIMIENTO: ");
  Serial.print(distanciaMM);
  Serial.println(" mm");

  Serial.print("TIEMPO: ");
  Serial.print(tiempoMovimientoMS);
  Serial.println(" ms");

  if (distanciaMM > 0) {
    moverMotor(tiempoMovimientoMS);
  }
  else {
    moverMotorReversa(tiempoMovimientoMS);
  }

  posicionActualMM += distanciaMM;

  unsigned long tiempoRespuestaMS =
    millis() - tiempoInicioMS;

  Serial.print("POSICION: ");
  Serial.print(posicionActualMM);
  Serial.println(" mm");

  Serial.print("TIEMPO DE RESPUESTA: ");
  Serial.print(tiempoRespuestaMS);
  Serial.println(" ms");
}

// CALCULO DE TIEMPO

unsigned long calcularTiempoMovimiento(float distanciaMM) {
  float distanciaAbsolutaMM = abs(distanciaMM);
  float tiempoS = distanciaAbsolutaMM / velocidadRealMMS;

  return (unsigned long)(tiempoS * 1000.0);
}

// MOVIMIENTO ADELANTE

void moverMotor(unsigned long tiempoMS) {
  detenerMotor();
  delay(200);

  digitalWrite(AIN1, HIGH);
  digitalWrite(AIN2, LOW);
  analogWrite(PWMA, velocidadMotor);

  delay(tiempoMS);

  detenerMotor();
  delay(200);
}

// MOVIMIENTO REVERSA

void moverMotorReversa(unsigned long tiempoMS) {
  detenerMotor();
  delay(200);

  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, HIGH);
  analogWrite(PWMA, velocidadMotor);

  delay(tiempoMS);

  detenerMotor();
  delay(200);
}

// DETENCION DEL MOTOR

void detenerMotor() {
  analogWrite(PWMA, 0);
  digitalWrite(AIN1, HIGH);
  digitalWrite(AIN2, HIGH);
}

// REGRESO AL ORIGEN

void regresarOrigen() {
  if (posicionActualMM == 0.0) {
    Serial.println("ACTUADOR EN ORIGEN");
    return;
  }

  unsigned long tiempoInicioMS = millis();

  unsigned long tiempoMovimientoMS =
    calcularTiempoMovimiento(posicionActualMM);

  if (posicionActualMM > 0) {
    moverMotorReversa(tiempoMovimientoMS);
  }
  else {
    moverMotor(tiempoMovimientoMS);
  }

  posicionActualMM = 0.0;

  unsigned long tiempoRespuestaMS =
    millis() - tiempoInicioMS;

  Serial.println("ORIGEN ALCANZADO");

  Serial.print("TIEMPO DE REGRESO: ");
  Serial.print(tiempoRespuestaMS);
  Serial.println(" ms");
}

// PRUEBA DE TIEMPO

void pruebaCalibracion() {
  Serial.println("PRUEBA DE CALIBRACION");

  moverMotor(5000);
  //moverMotor(500); // Para prueba de MISA es de 0.5s
  Serial.println("PRUEBA TERMINADA");
}

// VACIADO SERIAL

void vaciarSerial() {
  while (Serial.available() > 0) {
    Serial.read();
  }
}

// LIMPIEZA SERIAL

void limpiarBufferAutomatico() {
  if (millis() - ultimoClearMS >= intervaloClearMS) {
    vaciarSerial();
    ultimoClearMS = millis();
  }
}