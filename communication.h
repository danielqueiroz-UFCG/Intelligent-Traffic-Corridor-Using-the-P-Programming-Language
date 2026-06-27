#ifndef TRAFFIC_COMMUNICATION_H
#define TRAFFIC_COMMUNICATION_H

#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <chrono>

/** communication.h
 * ======================================================
 * INTERFACE DE COMUNICAÇÃO - P <-> C++
 * ======================================================
 * 
 * Este arquivo define como o programa P (Principal)
 * comunica eventos para o C++ (Animador Visual)
 * 
 * Dois modos de operação:
 * 1. STDIN - Eventos enviados pela entrada padrão
 * 2. ARQUIVO - Eventos lidos de um arquivo de log
 * 3. SOCKET - Comunicação em tempo real (TCP/IP)
 */

namespace TrafficComm {
    
    // ======================================================
    // DEFINIÇÃO DE EVENTOS
    // ======================================================
    
    enum EventType {
        // Semáforos Intersection 1
        TURN_GREEN_I1_MAIN,
        TURN_RED_I1_MAIN,
        TURN_GREEN_I1_CROSS,
        TURN_RED_I1_CROSS,
        
        // Semáforos Intersection 2
        TURN_GREEN_I2_MAIN,
        TURN_RED_I2_MAIN,
        TURN_GREEN_I2_CROSS,
        TURN_RED_I2_CROSS,
        
        // Semáforos de Pedestres
        WALK,
        DONT_WALK,
        
        // Emergências
        AMBULANCE_DISPATCHED,
        POLICE_DISPATCHED,
        FIREFIGHTERS_DISPATCHED,
        STAND_DOWN,
        
        // Tráfego
        HIGH_TRAFFIC,
        MEDIUM_TRAFFIC,
        LOW_TRAFFIC,
        BUS_DETECTED,
        
        // Acidentes
        TRAFFIC_ACCIDENT,
        ACCIDENT_RESOLVED,
        PEDESTRIAN_RESCUED,
        
        // Sistema
        TICK,
        START,
        TIMEOUT,
        SYNC_PHASE,
        
        // Período do dia
        PEAK_HOUR,
        NORMAL_HOUR,
        NIGHT_HOUR,
        DAWN_PERIOD,
        
        UNKNOWN
    };
    
    // ======================================================
    // ESTRUTURA DE EVENTO
    // ======================================================
    
    struct Event {
        EventType type;
        int intersectionId;
        std::string eventName;
        long long timestamp;
        std::string metadata;
        
        Event() : type(UNKNOWN), intersectionId(0), timestamp(0) {}
        
        Event(EventType t, int id, const std::string& name, long long ts)
            : type(t), intersectionId(id), eventName(name), timestamp(ts) {}
        
        std::string toString() const {
            std::stringstream ss;
            ss << eventName << ":" << intersectionId << ":" << timestamp;
            if (!metadata.empty()) {
                ss << ":" << metadata;
            }
            return ss.str();
        }
        
        static Event fromString(const std::string& line) {
            std::istringstream iss(line);
            std::string name, id, ts, meta;
            
            Event evt;
            if (std::getline(iss, name, ':') &&
                std::getline(iss, id, ':') &&
                std::getline(iss, ts, ':')) {
                
                evt.eventName = name;
                evt.intersectionId = std::stoi(id);
                evt.timestamp = std::stoll(ts);
                
                if (std::getline(iss, meta, ':')) {
                    evt.metadata = meta;
                }
                
                evt.type = parseEventType(name);
            }
            
            return evt;
        }
        
    private:
        static EventType parseEventType(const std::string& name) {
            if (name.find("TurnGreenI1Main") != std::string::npos) return TURN_GREEN_I1_MAIN;
            if (name.find("TurnRedI1Main") != std::string::npos) return TURN_RED_I1_MAIN;
            if (name.find("TurnGreenI1Cross") != std::string::npos) return TURN_GREEN_I1_CROSS;
            if (name.find("TurnRedI1Cross") != std::string::npos) return TURN_RED_I1_CROSS;
            
            if (name.find("TurnGreenI2Main") != std::string::npos) return TURN_GREEN_I2_MAIN;
            if (name.find("TurnRedI2Main") != std::string::npos) return TURN_RED_I2_MAIN;
            if (name.find("TurnGreenI2Cross") != std::string::npos) return TURN_GREEN_I2_CROSS;
            if (name.find("TurnRedI2Cross") != std::string::npos) return TURN_RED_I2_CROSS;
            
            if (name.find("Walk") != std::string::npos) return WALK;
            if (name.find("DontWalk") != std::string::npos) return DONT_WALK;
            
            if (name.find("AmbulanceDispatched") != std::string::npos) return AMBULANCE_DISPATCHED;
            if (name.find("PoliceDispatched") != std::string::npos) return POLICE_DISPATCHED;
            if (name.find("FirefightersDispatched") != std::string::npos) return FIREFIGHTERS_DISPATCHED;
            if (name.find("StandDown") != std::string::npos) return STAND_DOWN;
            
            if (name.find("HighTraffic") != std::string::npos) return HIGH_TRAFFIC;
            if (name.find("MediumTraffic") != std::string::npos) return MEDIUM_TRAFFIC;
            if (name.find("LowTraffic") != std::string::npos) return LOW_TRAFFIC;
            if (name.find("BusDetected") != std::string::npos) return BUS_DETECTED;
            
            if (name.find("TrafficAccident") != std::string::npos) return TRAFFIC_ACCIDENT;
            if (name.find("AccidentResolved") != std::string::npos) return ACCIDENT_RESOLVED;
            if (name.find("PedestrianRescued") != std::string::npos) return PEDESTRIAN_RESCUED;
            
            if (name.find("Tick") != std::string::npos) return TICK;
            if (name.find("Start") != std::string::npos) return START;
            if (name.find("Timeout") != std::string::npos) return TIMEOUT;
            if (name.find("SyncPhase") != std::string::npos) return SYNC_PHASE;
            
            if (name.find("PeakHour") != std::string::npos) return PEAK_HOUR;
            if (name.find("NormalHour") != std::string::npos) return NORMAL_HOUR;
            if (name.find("NightHour") != std::string::npos) return NIGHT_HOUR;
            if (name.find("DawnPeriod") != std::string::npos) return DAWN_PERIOD;
            
            return UNKNOWN;
        }
    };
    
    // ======================================================
    // LEITOR DE EVENTOS - DO ARQUIVO
    // ======================================================
    
    class EventLogReader {
    private:
        std::ifstream logFile;
        std::vector<Event> events;
        size_t currentIndex;
        
    public:
        EventLogReader(const std::string& filename)
            : currentIndex(0) {
            logFile.open(filename);
            if (logFile.is_open()) {
                loadEvents();
            }
        }
        
        ~EventLogReader() {
            if (logFile.is_open()) {
                logFile.close();
            }
        }
        
        void loadEvents() {
            std::string line;
            while (std::getline(logFile, line)) {
                if (!line.empty() && line[0] != '#') {  // Ignorar linhas vazias e comentários
                    Event evt = Event::fromString(line);
                    if (evt.type != UNKNOWN) {
                        events.push_back(evt);
                    }
                }
            }
        }
        
        bool hasNextEvent() const {
            return currentIndex < events.size();
        }
        
        Event getNextEvent() {
            if (hasNextEvent()) {
                return events[currentIndex++];
            }
            return Event();
        }
        
        std::vector<Event> getAllEvents() const {
            return events;
        }
        
        size_t getTotalEvents() const {
            return events.size();
        }
        
        void reset() {
            currentIndex = 0;
        }
    };
    
    // ======================================================
    // ESCRITOR DE EVENTOS - PARA ARQUIVO
    // ======================================================
    
    class EventLogWriter {
    private:
        std::ofstream logFile;
        
    public:
        EventLogWriter(const std::string& filename) {
            logFile.open(filename, std::ios::app);
            if (logFile.is_open()) {
                logFile << "# Log de Eventos - " 
                        << std::chrono::system_clock::now().time_since_epoch().count() 
                        << "\n";
            }
        }
        
        ~EventLogWriter() {
            if (logFile.is_open()) {
                logFile.close();
            }
        }
        
        void writeEvent(const Event& evt) {
            if (logFile.is_open()) {
                logFile << evt.toString() << "\n";
                logFile.flush();
            }
        }
        
        void writeComment(const std::string& comment) {
            if (logFile.is_open()) {
                logFile << "# " << comment << "\n";
                logFile.flush();
            }
        }
    };
    
} // namespace TrafficComm

#endif // TRAFFIC_COMMUNICATION_H
