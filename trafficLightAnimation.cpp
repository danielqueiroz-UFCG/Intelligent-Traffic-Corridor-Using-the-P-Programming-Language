#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <queue>
#include <sstream>

// ======================================================
// ESTRUTURAS DE DADOS   trafficLightAnimation.cpp
// ======================================================

enum TrafficLightState {
    RED,
    GREEN,
    YELLOW,
    OFF
};

struct Intersection {
    int id;
    int centerX, centerY;
    
    // Semáforos veiculares
    TrafficLightState mainRoad;      // Via principal (East-West)
    TrafficLightState crossRoad;     // Via transversal (North-South)
    
    // Semáforos de pedestres
    TrafficLightState pedestrianNorth;
    TrafficLightState pedestrianSouth;
    TrafficLightState pedestrianEast;
    TrafficLightState pedestrianWest;
    
    // Contadores de tempo
    int greenTimeMain;
    int greenTimeCross;
    
    // Estados adicionais
    bool busDetected;
    bool emergencyActive;
    std::string emergencyType;
};

struct TrafficEvent {
    std::string eventName;
    int intersectionId;
    TrafficLightState newState;
    long long timestamp;
};

// ======================================================
// CLASSE PRINCIPAL DO CONTROLADOR DE ANIMAÇÃO
// ======================================================

class TrafficLightAnimator {
private:
    std::vector<Intersection> intersections;
    std::queue<TrafficEvent> eventQueue;
    bool isRunning;
    long long simulationTime;
    int fps;
    
public:
    TrafficLightAnimator() : isRunning(true), simulationTime(0), fps(30) {
        initializeIntersections();
    }
    
    void initializeIntersections() {
        // Cruzamento 1
        Intersection i1;
        i1.id = 1;
        i1.centerX = 250;
        i1.centerY = 250;
        i1.mainRoad = RED;
        i1.crossRoad = GREEN;
        i1.pedestrianNorth = RED;
        i1.pedestrianSouth = RED;
        i1.pedestrianEast = RED;
        i1.pedestrianWest = RED;
        i1.greenTimeMain = 0;
        i1.greenTimeCross = 30;
        i1.busDetected = false;
        i1.emergencyActive = false;
        
        intersections.push_back(i1);
        
        // Cruzamento 2
        Intersection i2;
        i2.id = 2;
        i2.centerX = 650;
        i2.centerY = 250;
        i2.mainRoad = GREEN;
        i2.crossRoad = RED;
        i2.pedestrianNorth = RED;
        i2.pedestrianSouth = RED;
        i2.pedestrianEast = RED;
        i2.pedestrianWest = RED;
        i2.greenTimeMain = 30;
        i2.greenTimeCross = 0;
        i2.busDetected = false;
        i2.emergencyActive = false;
        
        intersections.push_back(i2);
    }
    
    void processEvent(const std::string& eventLine) {
        // Formato esperado: "EventName:IntersectionID:NewState:Timestamp"
        // Exemplo: "TurnGreenI1Main:1:GREEN:1000"
        
        std::istringstream iss(eventLine);
        std::string eventName, idStr, stateStr, timeStr;
        
        if (!std::getline(iss, eventName, ':')) return;
        if (!std::getline(iss, idStr, ':')) return;
        if (!std::getline(iss, stateStr, ':')) return;
        if (!std::getline(iss, timeStr, ':')) return;
        
        try {
            int intId = std::stoi(idStr);
            long long timestamp = std::stoll(timeStr);
            
            // Encontrar o cruzamento
            for (auto& intersection : intersections) {
                if (intersection.id == intId) {
                    // Processar baseado no nome do evento
                    if (eventName.find("MainGreen") != std::string::npos) {
                        intersection.mainRoad = GREEN;
                        intersection.crossRoad = RED;
                        intersection.greenTimeMain = 30;
                        intersection.greenTimeCross = 0;
                    } 
                    else if (eventName.find("MainRed") != std::string::npos) {
                        intersection.mainRoad = RED;
                        intersection.greenTimeMain = 0;
                    }
                    else if (eventName.find("CrossGreen") != std::string::npos) {
                        intersection.crossRoad = GREEN;
                        intersection.mainRoad = RED;
                        intersection.greenTimeCross = 30;
                        intersection.greenTimeMain = 0;
                    }
                    else if (eventName.find("CrossRed") != std::string::npos) {
                        intersection.crossRoad = RED;
                        intersection.greenTimeCross = 0;
                    }
                    else if (eventName.find("Walk") != std::string::npos) {
                        intersection.pedestrianNorth = GREEN;
                        intersection.pedestrianSouth = GREEN;
                        intersection.pedestrianEast = GREEN;
                        intersection.pedestrianWest = GREEN;
                    }
                    else if (eventName.find("DontWalk") != std::string::npos) {
                        intersection.pedestrianNorth = RED;
                        intersection.pedestrianSouth = RED;
                        intersection.pedestrianEast = RED;
                        intersection.pedestrianWest = RED;
                    }
                    else if (eventName.find("Emergency") != std::string::npos) {
                        intersection.emergencyActive = true;
                        if (eventName.find("Ambulance") != std::string::npos)
                            intersection.emergencyType = "AMBULANCIA";
                        else if (eventName.find("Police") != std::string::npos)
                            intersection.emergencyType = "POLICIA";
                        else if (eventName.find("Firefighters") != std::string::npos)
                            intersection.emergencyType = "BOMBEIROS";
                    }
                    else if (eventName.find("StandDown") != std::string::npos) {
                        intersection.emergencyActive = false;
                        intersection.emergencyType = "";
                    }
                    
                    break;
                }
            }
        } catch (...) {
            // Erro ao fazer parse
        }
    }
    
    void update() {
        simulationTime++;
        
        // Atualizar tempos dos semáforos
        for (auto& intersection : intersections) {
            if (intersection.mainRoad == GREEN && intersection.greenTimeMain > 0) {
                intersection.greenTimeMain--;
            }
            if (intersection.crossRoad == GREEN && intersection.greenTimeCross > 0) {
                intersection.greenTimeCross--;
            }
        }
    }
    
    void render() {
        system("clear"); // Para Linux/Mac
        // system("cls");   // Para Windows
        
        std::cout << "\n";
        std::cout << "╔════════════════════════════════════════════════════════════════════╗\n";
        std::cout << "║        ANIMADOR DE SEMÁFOROS - SISTEMA DE CONTROLE DE TRÁFEGO       ║\n";
        std::cout << "╠════════════════════════════════════════════════════════════════════╣\n";
        std::cout << "║ Tempo de Simulação: " << simulationTime << " ms\n";
        std::cout << "╠════════════════════════════════════════════════════════════════════╣\n";
        
        for (const auto& intersection : intersections) {
            renderIntersection(intersection);
        }
        
        std::cout << "╠════════════════════════════════════════════════════════════════════╣\n";
        std::cout << "║ [ESC] para sair | [ESPAÇO] pausa/retoma | Entrada de eventos por stdin ║\n";
        std::cout << "╚════════════════════════════════════════════════════════════════════╝\n";
    }
    
    void renderIntersection(const Intersection& inter) {
        std::cout << "\n┌─────────────────────────────────────────────┐\n";
        std::cout << "│ CRUZAMENTO " << inter.id << "\n";
        std::cout << "├─────────────────────────────────────────────┤\n";
        
        // Via Principal (East-West)
        std::cout << "│ Via Principal (L↔O):  ";
        renderTrafficLight(inter.mainRoad);
        std::cout << "  Tempo: " << inter.greenTimeMain << "s\n";
        
        // Via Transversal (North-South)
        std::cout << "│ Via Transversal (N↕S): ";
        renderTrafficLight(inter.crossRoad);
        std::cout << "  Tempo: " << inter.greenTimeCross << "s\n";
        
        // Pedestres
        std::cout << "│ Pedestres: ";
        if (inter.pedestrianNorth == GREEN || inter.pedestrianSouth == GREEN ||
            inter.pedestrianEast == GREEN || inter.pedestrianWest == GREEN) {
            std::cout << "🚶 ANDAR LIVRE 🚶\n";
        } else {
            std::cout << "⛔ NÃO ANDAR ⛔\n";
        }
        
        // Status de Emergência
        if (inter.emergencyActive) {
            std::cout << "│ ⚠️  EMERGÊNCIA ATIVA: " << inter.emergencyType << "\n";
        }
        
        // Bus Detector
        if (inter.busDetected) {
            std::cout << "│ 🚌 ÔNIBUS DETECTADO\n";
        }
        
        std::cout << "└─────────────────────────────────────────────┘\n";
    }
    
    void renderTrafficLight(TrafficLightState state) {
        switch (state) {
            case RED:
                std::cout << "🔴 VERMELHO";
                break;
            case GREEN:
                std::cout << "🟢 VERDE";
                break;
            case YELLOW:
                std::cout << "🟡 AMARELO";
                break;
            case OFF:
                std::cout << "⚪ DESLIGADO";
                break;
        }
    }
    
    void run() {
        std::cout << "\n═══════════════════════════════════════════════════════════════════\n";
        std::cout << "   SISTEMA DE ANIMAÇÃO DE SEMÁFOROS - PRONTO PARA RECEBER EVENTOS\n";
        std::cout << "═══════════════════════════════════════════════════════════════════\n";
        std::cout << "\nFormato de entrada:\n";
        std::cout << "  EventName:IntersectionID:NewState:Timestamp\n\n";
        std::cout << "Exemplos de eventos:\n";
        std::cout << "  - TurnGreenI1Main:1:GREEN:1000\n";
        std::cout << "  - TurnGreenI1Cross:1:GREEN:1000\n";
        std::cout << "  - Walk:1:GREEN:1000\n";
        std::cout << "  - AmbulanceDispatched:1:GREEN:1000\n\n";
        std::cout << "Digite 'quit' para sair, 'status' para ver estado atual.\n\n";
        
        std::string input;
        while (isRunning) {
            std::cout << "\n> Insira um evento (ou comando): ";
            
            if (!std::getline(std::cin, input)) {
                break;
            }
            
            if (input == "quit") {
                break;
            } else if (input == "status") {
                update();
                render();
            } else if (!input.empty()) {
                processEvent(input);
                update();
                render();
            }
        }
        
        std::cout << "\n\nAnimador finalizado. Obrigado por usar o sistema!\n";
    }
};

// ======================================================
// FUNÇÃO PRINCIPAL
// ======================================================

int main() {
    TrafficLightAnimator animator;
    animator.run();
    return 0;
}
