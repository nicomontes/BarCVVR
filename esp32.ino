#include <WiFi.h>
#include <HTTPClient.h>

// --- Paramètres à configurer ---
const char* ssid = "VOTRE_SSID_WIFI";
const char* password = "VOTRE_MOT_DE_PASSE_WIFI";
const char* serverUrlBase = "http://[URL]"; // Remplacez [URL] par votre adresse serveur

// --- Broches GPIO pour les débitmètres ---
// Choisissez n'importe quelles broches GPIO compatibles avec les entrées.
const int SENSOR_PIN_BLONDE = 22;  // Équivalent à 'inpt' (GPIO 8 sur RPi)
const int SENSOR_PIN_SPECIAL = 23; // Équivalent à 'inpt2' (GPIO 10 sur RPi)

// --- Constantes et variables globales ---
const float CALIBRATION_CONSTANT = 9230.0; // Impulsions par litre

// Les compteurs d'impulsions doivent être 'volatile' car ils sont modifiés par les interruptions
volatile unsigned long pulseCounterBlonde = 0;
volatile unsigned long pulseCounterSpecial = 0;

unsigned long lastSendTime = 0;
const long sendInterval = 1000; // Intervalle de mesure et d'envoi en millisecondes (1 seconde)

// --- Fonctions d'Interruption (ISR - Interrupt Service Routines) ---
// Ces fonctions s'exécutent à chaque impulsion du capteur.
// Elles doivent être aussi courtes et rapides que possible.
// IRAM_ATTR est une optimisation pour l'ESP32.
void IRAM_ATTR onPulseBlonde() {
  pulseCounterBlonde++;
}

void IRAM_ATTR onPulseSpecial() {
  pulseCounterSpecial++;
}

// --- Fonction pour se connecter au WiFi ---
void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connexion à ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connecté !");
  Serial.print("Adresse IP : ");
  Serial.println(WiFi.localIP());
}

// --- Fonction pour envoyer les données au serveur ---
void sendFlowData(const char* flowId, float quantity, const char* drinkId) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    String serverPath = String(serverUrlBase) + "/beerflows/" + String(flowId);
    
    // Commence la connexion
    http.begin(serverPath.c_str());
    
    // Ajoute le header nécessaire pour simuler un formulaire web
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");
    
    // Prépare le corps de la requête (payload)
    String postData = "_method=patch&beerflow[quantity]=" + String(quantity, 4) + "&beerflow[drink_id]=" + String(drinkId);

    // Envoie la requête POST (car PATCH est moins standard sur les clients HTTP simples)
    // Le framework serveur interprétera "_method=patch"
    int httpResponseCode = http.POST(postData);

    if (httpResponseCode > 0) {
      Serial.printf("Requête envoyée pour flow %s. Code de réponse: %d\n", flowId, httpResponseCode);
      String payload = http.getString();
      Serial.println(payload);
    } else {
      Serial.printf("Erreur sur la requête HTTP pour flow %s: %s\n", flowId, http.errorToString(httpResponseCode).c_str());
    }

    // Libère les ressources
    http.end();
  } else {
    Serial.println("Erreur: WiFi non connecté.");
  }
}


// --- SETUP : S'exécute une seule fois au démarrage ---
void setup() {
  Serial.begin(115200); // Démarre la communication série pour le débogage

  // Configuration des broches en entrée avec une résistance de PULL-UP interne.
  // C'est souvent nécessaire pour les capteurs à effet Hall.
  pinMode(SENSOR_PIN_BLONDE, INPUT_PULLUP);
  pinMode(SENSOR_PIN_SPECIAL, INPUT_PULLUP);

  // Attache les interruptions aux broches.
  // La fonction `onPulse` sera appelée à chaque front descendant (FALLING) du signal.
  attachInterrupt(digitalPinToInterrupt(SENSOR_PIN_BLONDE), onPulseBlonde, FALLING);
  attachInterrupt(digitalPinToInterrupt(SENSOR_PIN_SPECIAL), onPulseSpecial, FALLING);

  // Connexion au WiFi
  setup_wifi();

  lastSendTime = millis();
}

// --- LOOP : S'exécute en boucle indéfiniment ---
void loop() {
  // On exécute le code suivant toutes les 'sendInterval' millisecondes
  if (millis() - lastSendTime >= sendInterval) {
    lastSendTime = millis(); // Réinitialise le timer

    unsigned long currentPulsesBlonde;
    unsigned long currentPulsesSpecial;

    // --- Section Critique : Lecture et réinitialisation des compteurs ---
    // On désactive les interruptions pour lire les compteurs en toute sécurité
    noInterrupts(); 
    currentPulsesBlonde = pulseCounterBlonde;
    pulseCounterBlonde = 0;
    currentPulsesSpecial = pulseCounterSpecial;
    pulseCounterSpecial = 0;
    interrupts(); // On réactive les interruptions immédiatement

    // --- Calcul des litres ---
    float litersBlonde = (float)currentPulsesBlonde / CALIBRATION_CONSTANT;
    float litersSpecial = (float)currentPulsesSpecial / CALIBRATION_CONSTANT;

    // --- Envoi des données si un débit a été mesuré ---
    if (litersBlonde > 0) {
      Serial.printf("Blonde : %.4f L (pulsations: %lu)\n", litersBlonde, currentPulsesBlonde);
      sendFlowData("1", litersBlonde, "1"); // ID flow 1, ID boisson 1
    }
    
    if (litersSpecial > 0) {
      Serial.printf("Spéciale : %.4f L (pulsations: %lu)\n", litersSpecial, currentPulsesSpecial);
      sendFlowData("2", litersSpecial, "9"); // ID flow 2, ID boisson 9
    }
  }

  // La boucle principale est maintenant très légère.
  // On peut y ajouter d'autres tâches non bloquantes si besoin.
}
