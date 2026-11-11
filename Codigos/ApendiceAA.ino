//  MOVIMIENTO ANTAGONISTA ECA MISA
// Control coordinado y posicionamiento de los actuadores ECA y MISA.

// CONFIGURACION ECA

#define RPWM 5
#define LPWM 6
#define REN 7
#define LEN 8

// CONFIGURACION MISA

#define PWMA 9
#define AIN1 10
#define AIN2 11
#define STBY 12

// PARAMETROS MISA

float velocidadRealMMS_MISA = 7.8;
int velocidadMotor_MISA = 86;

// PARAMETROS ECA

float velocidadRealMMS_ECA = 7.8;
int velocidadMotor_ECA = 255;

// DIRECCION

#define DIR_MISA 1
#define DIR_ECA 1

// POSICIONES

float posicionActual_MISA = 0.0;
float posicionActual_ECA = 0.0;

float origen_MISA = 0.0;
float origen_ECA = 0.0;

float posicionInicio_MISA = 50.0;
float posicionInicio_ECA = 0.0;

bool origenDefinido = false;
bool sistemaReady = false;

// CONFIGURACION INICIAL

void setup() {
  Serial.begin(9600);
  Serial.setTimeout(100);

  pinMode(RPWM, OUTPUT);
  pinMode(LPWM, OUTPUT);
  pinMode(REN, OUTPUT);
  pinMode(LEN, OUTPUT);

  pinMode(PWMA, OUTPUT);
  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(STBY, OUTPUT);

  digitalWrite(REN, HIGH);
  digitalWrite(LEN, HIGH);
  digitalWrite(STBY, HIGH);

  detenerMISA();
  detenerECA();

  Serial.println("SISTEMA ANTAGONISTA LISTO");
  Serial.println("MISA TB6612");
  Serial.println("ECA BTS7960");

  imprimirAyuda();
}

// CICLO PRINCIPAL

void loop() {
  if (Serial.available() > 0) {
    String comando = Serial.readStringUntil('\n');
    comando.trim();

    if (comando.length() > 0) {
      procesarComando(comando);
    }
  }
}

// AYUDA

void imprimirAyuda() {
  Serial.println("");
  Serial.println("COMANDOS");
  Serial.println("M 5   MISA +5 mm");
  Serial.println("M -5  MISA -5 mm");
  Serial.println("E 5   ECA +5 mm");
  Serial.println("E -5  ECA -5 mm");
  Serial.println("O     DEFINIR ORIGEN");
  Serial.println("READY POSICION INICIAL");
  Serial.println("30    MOVIMIENTO COORDINADO +30 mm");
  Serial.println("-30   MOVIMIENTO COORDINADO -30 mm");
  Serial.println("H     MOSTRAR AYUDA");
}

// PROCESAMIENTO DE COMANDOS

void procesarComando(String comando) {
  comando.trim();

  if (comando.equalsIgnoreCase("H")) {
    imprimirAyuda();
    return;
  }

  if (comando.equalsIgnoreCase("O")) {
    origen_MISA = posicionActual_MISA;
    origen_ECA = posicionActual_ECA;
    origenDefinido = true;
    sistemaReady = false;

    Serial.println("NUEVO ORIGEN GUARDADO");
    imprimirPosiciones();
    return;
  }

  if (comando.equalsIgnoreCase("READY")) {
    if (!origenDefinido) {
      Serial.println("ERROR: DEFINIR ORIGEN CON O");
      return;
    }

    ejecutarReady();
    return;
  }

  int espacio = comando.indexOf(' ');

  if (espacio != -1) {
    String actuador = comando.substring(0, espacio);
    String valorStr = comando.substring(espacio + 1);

    actuador.trim();
    valorStr.trim();

    float distanciaMM = valorStr.toFloat();

    if (distanciaMM == 0.0) {
      Serial.println("DISTANCIA INVALIDA");
      return;
    }

    sistemaReady = false;

    if (actuador.equalsIgnoreCase("M")) {
      moverManualMISA(distanciaMM);
      return;
    }

    if (actuador.equalsIgnoreCase("E")) {
      moverManualECA(distanciaMM);
      return;
    }

    Serial.println("COMANDO INVALIDO");
    return;
  }

  if (esNumero(comando)) {
    if (!sistemaReady) {
      Serial.println("ERROR: EJECUTAR READY");
      return;
    }

    float deltaMM = comando.toFloat();

    if (deltaMM == 0.0) {
      Serial.println("DISTANCIA COORDINADA INVALIDA");
      return;
    }

    movimientoCoordinado(deltaMM);
    return;
  }

  Serial.println("COMANDO NO RECONOCIDO");
}

// VALIDACION NUMERICA

bool esNumero(String s) {
  if (s.length() == 0) {
    return false;
  }

  bool puntoEncontrado = false;

  for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);

    if (c >= '0' && c <= '9') {
      continue;
    }

    if (c == '.' && !puntoEncontrado) {
      puntoEncontrado = true;
      continue;
    }

    if (c == '-' && i == 0) {
      continue;
    }

    return false;
  }

  return true;
}

// POSICIONES

void imprimirPosiciones() {
  Serial.print("POSICION MISA: ");
  Serial.print(posicionActual_MISA);
  Serial.println(" mm");

  Serial.print("POSICION RELATIVA MISA: ");
  Serial.print(posicionActual_MISA - origen_MISA);
  Serial.println(" mm");

  Serial.print("POSICION ECA: ");
  Serial.print(posicionActual_ECA);
  Serial.println(" mm");

  Serial.print("POSICION RELATIVA ECA: ");
  Serial.print(posicionActual_ECA - origen_ECA);
  Serial.println(" mm");

  Serial.print("ORIGEN DEFINIDO: ");
  Serial.println(origenDefinido ? "SI" : "NO");

  Serial.print("SISTEMA READY: ");
  Serial.println(sistemaReady ? "SI" : "NO");
}

// MOVIMIENTO MANUAL MISA

void moverManualMISA(float distanciaMM) {
  detenerECA();

  Serial.print("MOVIMIENTO MISA: ");
  Serial.print(distanciaMM);
  Serial.println(" mm");

  moverMISA(distanciaMM);
  posicionActual_MISA += distanciaMM;

  imprimirPosiciones();
}

// MOVIMIENTO MANUAL ECA

void moverManualECA(float distanciaMM) {
  detenerMISA();

  Serial.print("MOVIMIENTO ECA: ");
  Serial.print(distanciaMM);
  Serial.println(" mm");

  moverECA(distanciaMM);
  posicionActual_ECA += distanciaMM;

  imprimirPosiciones();
}

// POSICION READY

void ejecutarReady() {
  float objetivo_MISA = origen_MISA + posicionInicio_MISA;
  float objetivo_ECA = origen_ECA + posicionInicio_ECA;

  float delta_MISA = objetivo_MISA - posicionActual_MISA;
  float delta_ECA = objetivo_ECA - posicionActual_ECA;

  if (abs(delta_MISA) > 0.01) {
    Serial.print("POSICIONANDO MISA EN ");
    Serial.print(posicionInicio_MISA);
    Serial.println(" mm");

    moverMISA(delta_MISA);
    posicionActual_MISA = objetivo_MISA;
  }

  delay(300);

  if (abs(delta_ECA) > 0.01) {
    Serial.print("POSICIONANDO ECA EN ");
    Serial.print(posicionInicio_ECA);
    Serial.println(" mm");

    moverECA(delta_ECA);
    posicionActual_ECA = objetivo_ECA;
  }

  sistemaReady = true;

  Serial.println("SISTEMA EN READY");
  imprimirPosiciones();
}

// MOVIMIENTO COORDINADO

void movimientoCoordinado(float deltaMM) {
  Serial.print("MOVIMIENTO COORDINADO: ");
  Serial.print(deltaMM);
  Serial.println(" mm");

  if (deltaMM > 0) {
    Serial.println("MISA REGRESA ECA AVANZA");
  } else {
    Serial.println("MISA AVANZA ECA REGRESA");
  }

  float nuevaPosicion_MISA = posicionActual_MISA - deltaMM;
  float nuevaPosicion_ECA = posicionActual_ECA + deltaMM;

  moverSimultaneo(-deltaMM, deltaMM);

  posicionActual_MISA = nuevaPosicion_MISA;
  posicionActual_ECA = nuevaPosicion_ECA;

  Serial.println("MOVIMIENTO COORDINADO COMPLETADO");
  imprimirPosiciones();
}

// MOVIMIENTO SIMULTANEO

void moverSimultaneo(float distanciaMM_MISA, float distanciaMM_ECA) {
  unsigned long tiempoMS_MISA =
    calcularTiempoMovimiento(distanciaMM_MISA, velocidadRealMMS_MISA);

  unsigned long tiempoMS_ECA =
    calcularTiempoMovimiento(distanciaMM_ECA, velocidadRealMMS_ECA);

  Serial.print("TIEMPO MISA: ");
  Serial.print(tiempoMS_MISA);
  Serial.println(" ms");

  Serial.print("TIEMPO ECA: ");
  Serial.print(tiempoMS_ECA);
  Serial.println(" ms");

  detenerMISA();
  detenerECA();

  delay(200);

  iniciarMISA(distanciaMM_MISA);
  iniciarECA(distanciaMM_ECA);

  unsigned long tiempoInicioMS = millis();

  bool MISAActiva = true;
  bool ECAActiva = true;

  while (MISAActiva || ECAActiva) {
    unsigned long tiempoTranscurridoMS = millis() - tiempoInicioMS;

    if (MISAActiva && tiempoTranscurridoMS >= tiempoMS_MISA) {
      detenerMISA();
      MISAActiva = false;
    }

    if (ECAActiva && tiempoTranscurridoMS >= tiempoMS_ECA) {
      detenerECA();
      ECAActiva = false;
    }
  }

  delay(200);
}

// CALCULO DE TIEMPO

unsigned long calcularTiempoMovimiento(float distanciaMM, float velocidadMMS) {
  float distanciaAbsolutaMM = abs(distanciaMM);
  float tiempoS = distanciaAbsolutaMM / velocidadMMS;
  unsigned long tiempoMS = (unsigned long)(tiempoS * 1000.0);

  return tiempoMS;
}

// INICIO MISA

void iniciarMISA(float distanciaMM) {
  if (distanciaMM > 0) {
    Serial.println("MISA ADELANTE");
    digitalWrite(AIN1, HIGH);
    digitalWrite(AIN2, LOW);
  } else {
    Serial.println("MISA REVERSA");
    digitalWrite(AIN1, LOW);
    digitalWrite(AIN2, HIGH);
  }

  analogWrite(PWMA, velocidadMotor_MISA);
}

// INICIO ECA

void iniciarECA(float distanciaMM) {
  if (distanciaMM > 0) {
    Serial.println("ECA ADELANTE");
    analogWrite(RPWM, velocidadMotor_ECA);
    analogWrite(LPWM, 0);
  } else {
    Serial.println("ECA REVERSA");
    analogWrite(RPWM, 0);
    analogWrite(LPWM, velocidadMotor_ECA);
  }
}

// MOVIMIENTO MISA

void moverMISA(float distanciaMM) {
  unsigned long tiempoMS =
    calcularTiempoMovimiento(distanciaMM, velocidadRealMMS_MISA);

  Serial.print("TIEMPO MISA: ");
  Serial.print(tiempoMS);
  Serial.println(" ms");

  detenerMISA();
  delay(200);

  iniciarMISA(distanciaMM);
  delay(tiempoMS);

  detenerMISA();
  delay(200);
}

// MOVIMIENTO ECA

void moverECA(float distanciaMM) {
  unsigned long tiempoMS =
    calcularTiempoMovimiento(distanciaMM, velocidadRealMMS_ECA);

  Serial.print("TIEMPO ECA: ");
  Serial.print(tiempoMS);
  Serial.println(" ms");

  detenerECA();
  delay(200);

  iniciarECA(distanciaMM);
  delay(tiempoMS);

  detenerECA();
  delay(200);
}

// DETENCION MISA

void detenerMISA() {
  analogWrite(PWMA, 0);
  digitalWrite(AIN1, HIGH);
  digitalWrite(AIN2, HIGH);
}

// DETENCION ECA

void detenerECA() {
  analogWrite(RPWM, 0);
  analogWrite(LPWM, 0);
}