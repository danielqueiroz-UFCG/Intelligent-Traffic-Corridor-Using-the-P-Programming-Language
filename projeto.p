// ======================================================
// Disciplina: Modelagem de Sistemas Fisicos-Ciberneticos
// Aluno: Daniel de Queiroz Cavalcanti
// ======================================================

// ======================================================
// Eventos de comando dos semaforos veiculares
// ======================================================

event TurnGreenI1Main;
event TurnRedI1Main;
event TurnGreenI1Cross;
event TurnRedI1Cross;

event TurnGreenI2Main;
event TurnRedI2Main;
event TurnGreenI2Cross;
event TurnRedI2Cross;

// Eventos antigos mantidos para compatibilidade conceitual:
// A = corredor principal, B = vias transversais.
event TurnGreenA;
event TurnRedA;
event TurnGreenB;
event TurnRedB;

// ======================================================
//
// Eventos de ambiente e sensores
//
// ======================================================

event PeakHour;          // periodo 06h00 ate 22h00
event NormalHour;        // periodo 06h00 ate 22h00
event NightHour;         // periodo noturno com baixo fluxo
event DawnPeriod;        // periodo 22h01 ate 05h59

event HighTraffic;
event MediumTraffic;
event LowTraffic;
event PedestrianRequest;

event SirenDetected;
event BeaconDetected;
event AuthorizedEmergency;

event BusDetected;
event TrafficAccident;
event AccidentResolved;
event PedestrianRescued;

// ======================================================
//
// Placa digital e onda verde
//
// ======================================================

event Speed50;
event UpdateSign;
event SyncPhase;

event AllowRightTurnA;
event ForbidRightTurnA;
event AllowRightTurnB;
event ForbidRightTurnB;

event AllowLeftTurnA;
event ForbidLeftTurnA;
event AllowLeftTurnB;
event ForbidLeftTurnB;

event AllowTurns22To0559;
event ForbidTurns06To22;

// ======================================================
// Eventos internos do controlador
//
// ======================================================

event Start;
event Timeout;
event Tick;

event ApplyMainGreen;
event ApplyCrossGreen;
event ApplyAllRed;
event ApplyPedestriansForMainGreen;
event ApplyPedestriansForCrossGreen;
event ApplyAllPedestriansWalk;
event ApplyAllPedestriansStop;
event ApplyTurnPolicyAllowed;
event ApplyTurnPolicyForbidden;

// ======================================================
//
// Eventos de anuncio para observadores
//
// ======================================================

event I1MainGreen;
event I1MainRed;
event I1CrossGreen;
event I1CrossRed;

event I2MainGreen;
event I2MainRed;
event I2CrossGreen;
event I2CrossRed;

event GreenA;
event RedA;
event GreenB;
event RedB;

event Walk;
event DontWalk;

event AmbulanceDispatched;
event PoliceDispatched;
event FirefightersDispatched;
event DispatchAmbulance;
event DispatchPolice;
event DispatchFirefighters;
event SceneSecured;
event StandDown;

// ======================================================
// Semaforos veiculares
// Cada cruzamento tem 4 semaforos:
// - 2 no corredor principal
// - 2 na via transversal
// ======================================================

machine TrafficLightI1Main {
    start state Red {
        on TurnRedI1Main do {}
        on TurnRedA do {}

        on TurnGreenI1Main goto Green;
        on TurnGreenA goto Green;
        on Timeout do {}
    }

    state Green {
        on TurnGreenI1Main do {}
        on TurnGreenA do {}

        on TurnRedI1Main goto Red;
        on TurnRedA goto Red;
        on Timeout goto Red;
    }
}

machine TrafficLightI1Cross {
    start state Red {
        on TurnRedI1Cross do {}
        on TurnRedB do {}

        on TurnGreenI1Cross goto Green;
        on TurnGreenB goto Green;
        on Timeout do {}
    }

    state Green {
        on TurnGreenI1Cross do {}
        on TurnGreenB do {}

        on TurnRedI1Cross goto Red;
        on TurnRedB goto Red;
        on Timeout goto Red;
    }
}

machine TrafficLightI2Main {
    start state Red {
        on TurnRedI2Main do {}
        on TurnRedA do {}

        on TurnGreenI2Main goto Green;
        on TurnGreenA goto Green;
        on Timeout do {}
    }

    state Green {
        on TurnGreenI2Main do {}
        on TurnGreenA do {}

        on TurnRedI2Main goto Red;
        on TurnRedA goto Red;
        on Timeout goto Red;
    }
}

machine TrafficLightI2Cross {
    start state Red {
        on TurnRedI2Cross do {}
        on TurnRedB do {}

        on TurnGreenI2Cross goto Green;
        on TurnGreenB goto Green;
        on Timeout do {}
    }

    state Green {
        on TurnGreenI2Cross do {}
        on TurnGreenB do {}

        on TurnRedI2Cross goto Red;
        on TurnRedB goto Red;
        on Timeout goto Red;
    }
}

machine PedestrianLight {
    start state DontWalkState {
        on Walk goto WalkState;
        on DontWalk do {}
    }

    state WalkState {
        on Walk do {}
        on DontWalk goto DontWalkState;
    }
}

// ======================================================
// Placa digital
// 06h00-22h00: proibido virar a direita e a esquerda.
// 22h01-05h59: permitido virar a direita e a esquerda.
// ======================================================

machine DigitalSign {
    var rightTurnsAllowed : bool;
    var leftTurnsAllowed : bool;
    var speedLimit : int;

    start state TurnsForbidden {
        entry {
            rightTurnsAllowed = false;
            leftTurnsAllowed = false;
            speedLimit = 50;
        }

        on ForbidTurns06To22 do {
            rightTurnsAllowed = false;
            leftTurnsAllowed = false;
        }

        on AllowTurns22To0559 do {
            rightTurnsAllowed = true;
            leftTurnsAllowed = true;
            goto TurnsAllowed;
        }

        on Speed50 do {
            speedLimit = 50;
        }

        on UpdateSign do {}
    }

    state TurnsAllowed {
        on AllowTurns22To0559 do {
            rightTurnsAllowed = true;
            leftTurnsAllowed = true;
        }

        on ForbidTurns06To22 do {
            rightTurnsAllowed = false;
            leftTurnsAllowed = false;
            goto TurnsForbidden;
        }

        on Speed50 do {
            speedLimit = 50;
        }

        on UpdateSign do {}
    }
}

// ======================================================
//
// Equipes de emergencia para acidentes com pedestre
// Bombeiros, Policia, Samu, Corpo de Bombeiros
// ======================================================

machine AmbulanceResponder {
    start state Available {
        on DispatchAmbulance goto RescuingPedestrian;
        on StandDown do {}
    }

    state RescuingPedestrian {
        on PedestrianRescued goto Returning;
        on StandDown goto Available;
        on DispatchAmbulance do {}
    }

    state Returning {
        on StandDown goto Available;
        on DispatchAmbulance do {}
    }
}

machine PoliceResponder {
    start state Available {
        on DispatchPolice goto SecuringScene;
        on StandDown do {}
    }

    state SecuringScene {
        on SceneSecured goto OnScene;
        on StandDown goto Available;
        on DispatchPolice do {}
    }

    state OnScene {
        on StandDown goto Available;
        on DispatchPolice do {}
    }
}

machine FirefighterResponder {
    start state Available {
        on DispatchFirefighters goto SupportingRescue;
        on StandDown do {}
    }

    state SupportingRescue {
        on SceneSecured goto OnScene;
        on StandDown goto Available;
        on DispatchFirefighters do {}
    }

    state OnScene {
        on StandDown goto Available;
        on DispatchFirefighters do {}
    }
}

// ======================================================
// CONTROLADOR GLOBAL DO CORREDOR
// Dois cruzamentos, cada um com 4 semaforos veiculares
// e 4 semaforos de pedestres.
// ======================================================

machine Controller {
    var i1MainEast : machine;
    var i1MainWest : machine;
    var i1CrossNorth : machine;
    var i1CrossSouth : machine;

    var i2MainEast : machine;
    var i2MainWest : machine;
    var i2CrossNorth : machine;
    var i2CrossSouth : machine;

    var i1PedAcrossMainNorth : machine;
    var i1PedAcrossMainSouth : machine;
    var i1PedAcrossCrossEast : machine;
    var i1PedAcrossCrossWest : machine;

    var i2PedAcrossMainNorth : machine;
    var i2PedAcrossMainSouth : machine;
    var i2PedAcrossCrossEast : machine;
    var i2PedAcrossCrossWest : machine;

    var sign : machine;
    var ambulance : machine;
    var police : machine;
    var firefighters : machine;

    var queueMain : int;
    var queueCross : int;
    var phase : int;
    var accidentIntersection : int;

    var sirenOn : bool;
    var beaconOn : bool;
    var accidentOpen : bool;
    var pedestrianAlreadyRescued : bool;

    var rtAAllowed : bool;
    var rtBAllowed : bool;
    var ltAAllowed : bool;
    var ltBAllowed : bool;

    // ======================================================
    // SISTEMA DE TIMESTAMP PARA ANIMAÇÃO C++
    // ======================================================
    var simulation_time : int;

    start state Init {
        entry {
            i1MainEast = new TrafficLightI1Main();
            i1MainWest = new TrafficLightI1Main();
            i1CrossNorth = new TrafficLightI1Cross();
            i1CrossSouth = new TrafficLightI1Cross();

            i2MainEast = new TrafficLightI2Main();
            i2MainWest = new TrafficLightI2Main();
            i2CrossNorth = new TrafficLightI2Cross();
            i2CrossSouth = new TrafficLightI2Cross();

            i1PedAcrossMainNorth = new PedestrianLight();
            i1PedAcrossMainSouth = new PedestrianLight();
            i1PedAcrossCrossEast = new PedestrianLight();
            i1PedAcrossCrossWest = new PedestrianLight();

            i2PedAcrossMainNorth = new PedestrianLight();
            i2PedAcrossMainSouth = new PedestrianLight();
            i2PedAcrossCrossEast = new PedestrianLight();
            i2PedAcrossCrossWest = new PedestrianLight();

            sign = new DigitalSign();
            ambulance = new AmbulanceResponder();
            police = new PoliceResponder();
            firefighters = new FirefighterResponder();

            queueMain = 0;
            queueCross = 0;
            phase = 0;
            accidentIntersection = 0;

            sirenOn = false;
            beaconOn = false;
            accidentOpen = false;
            pedestrianAlreadyRescued = false;

            rtAAllowed = false;
            rtBAllowed = false;
            ltAAllowed = false;
            ltBAllowed = false;

            // Inicializar timestamp
            simulation_time = 0;

            raise Start;
        }

        on Start goto ControlLoop;
    }

    state ControlLoop {
        on ApplyMainGreen do {
            // Onda verde no corredor principal dos dois cruzamentos.
            phase = 0;

            send i1MainEast, TurnGreenI1Main;
            send i1MainWest, TurnGreenI1Main;
            send i1CrossNorth, TurnRedI1Cross;
            send i1CrossSouth, TurnRedI1Cross;

            send i2MainEast, TurnGreenI2Main;
            send i2MainWest, TurnGreenI2Main;
            send i2CrossNorth, TurnRedI2Cross;
            send i2CrossSouth, TurnRedI2Cross;

            send i1MainEast, TurnGreenA;
            send i1MainWest, TurnGreenA;
            send i2MainEast, TurnGreenA;
            send i2MainWest, TurnGreenA;

            send i1CrossNorth, TurnRedB;
            send i1CrossSouth, TurnRedB;
            send i2CrossNorth, TurnRedB;
            send i2CrossSouth, TurnRedB;

            send i1PedAcrossMainNorth, DontWalk;
            send i1PedAcrossMainSouth, DontWalk;
            send i2PedAcrossMainNorth, DontWalk;
            send i2PedAcrossMainSouth, DontWalk;

            // ======================================================
            // SAÍDA PARA ANIMADOR C++
            // ======================================================
            announce("TurnGreenI1Main:1:" + to_string(simulation_time));
            announce("TurnRedI1Cross:1:" + to_string(simulation_time));
            announce("TurnGreenI2Main:2:" + to_string(simulation_time));
            announce("TurnRedI2Cross:2:" + to_string(simulation_time));
            announce("DontWalk:1:" + to_string(simulation_time));
            announce("DontWalk:2:" + to_string(simulation_time));
        }

        on ApplyCrossGreen do {
            // Onda verde nas vias transversais dos dois cruzamentos.
            phase = 1;

            send i1CrossNorth, TurnGreenI1Cross;
            send i1CrossSouth, TurnGreenI1Cross;
            send i1MainEast, TurnRedI1Main;
            send i1MainWest, TurnRedI1Main;

            send i2CrossNorth, TurnGreenI2Cross;
            send i2CrossSouth, TurnGreenI2Cross;
            send i2MainEast, TurnRedI2Main;
            send i2MainWest, TurnRedI2Main;

            send i1CrossNorth, TurnGreenB;
            send i1CrossSouth, TurnGreenB;
            send i2CrossNorth, TurnGreenB;
            send i2CrossSouth, TurnGreenB;

            send i1MainEast, TurnRedA;
            send i1MainWest, TurnRedA;
            send i2MainEast, TurnRedA;
            send i2MainWest, TurnRedA;

            send i1PedAcrossCrossEast, Walk;
            send i1PedAcrossCrossWest, Walk;
            send i2PedAcrossCrossEast, Walk;
            send i2PedAcrossCrossWest, Walk;

            // ======================================================
            // SAÍDA PARA ANIMADOR C++
            // ======================================================
            announce("TurnRedI1Main:1:" + to_string(simulation_time));
            announce("TurnGreenI1Cross:1:" + to_string(simulation_time));
            announce("TurnRedI2Main:2:" + to_string(simulation_time));
            announce("TurnGreenI2Cross:2:" + to_string(simulation_time));
            announce("Walk:1:" + to_string(simulation_time));
            announce("Walk:2:" + to_string(simulation_time));
        }

        on ApplyAllRed do {
            // Todos os semaforos em vermelho.
            phase = 2;

            send i1MainEast, TurnRedI1Main;
            send i1MainWest, TurnRedI1Main;
            send i1CrossNorth, TurnRedI1Cross;
            send i1CrossSouth, TurnRedI1Cross;

            send i2MainEast, TurnRedI2Main;
            send i2MainWest, TurnRedI2Main;
            send i2CrossNorth, TurnRedI2Cross;
            send i2CrossSouth, TurnRedI2Cross;

            send i1MainEast, TurnRedA;
            send i1MainWest, TurnRedA;
            send i1CrossNorth, TurnRedB;
            send i1CrossSouth, TurnRedB;

            send i2MainEast, TurnRedA;
            send i2MainWest, TurnRedA;
            send i2CrossNorth, TurnRedB;
            send i2CrossSouth, TurnRedB;

            send i1PedAcrossMainNorth, DontWalk;
            send i1PedAcrossMainSouth, DontWalk;
            send i1PedAcrossCrossEast, DontWalk;
            send i1PedAcrossCrossWest, DontWalk;

            send i2PedAcrossMainNorth, DontWalk;
            send i2PedAcrossMainSouth, DontWalk;
            send i2PedAcrossCrossEast, DontWalk;
            send i2PedAcrossCrossWest, DontWalk;

            // ======================================================
            // SAÍDA PARA ANIMADOR C++
            // ======================================================
            announce("TurnRedI1Main:1:" + to_string(simulation_time));
            announce("TurnRedI1Cross:1:" + to_string(simulation_time));
            announce("TurnRedI2Main:2:" + to_string(simulation_time));
            announce("TurnRedI2Cross:2:" + to_string(simulation_time));
            announce("DontWalk:1:" + to_string(simulation_time));
            announce("DontWalk:2:" + to_string(simulation_time));
        }

        on ApplyPedestriansForMainGreen do {
            send i1PedAcrossMainNorth, DontWalk;
            send i1PedAcrossMainSouth, DontWalk;
            send i2PedAcrossMainNorth, DontWalk;
            send i2PedAcrossMainSouth, DontWalk;

            announce("DontWalk:1:" + to_string(simulation_time) + ":MainGreenActive");
            announce("DontWalk:2:" + to_string(simulation_time) + ":MainGreenActive");
        }

        on ApplyPedestriansForCrossGreen do {
            send i1PedAcrossCrossEast, Walk;
            send i1PedAcrossCrossWest, Walk;
            send i2PedAcrossCrossEast, Walk;
            send i2PedAcrossCrossWest, Walk;

            announce("Walk:1:" + to_string(simulation_time) + ":CrossGreenActive");
            announce("Walk:2:" + to_string(simulation_time) + ":CrossGreenActive");
        }

        on ApplyAllPedestriansWalk do {
            send i1PedAcrossMainNorth, Walk;
            send i1PedAcrossMainSouth, Walk;
            send i1PedAcrossCrossEast, Walk;
            send i1PedAcrossCrossWest, Walk;

            send i2PedAcrossMainNorth, Walk;
            send i2PedAcrossMainSouth, Walk;
            send i2PedAcrossCrossEast, Walk;
            send i2PedAcrossCrossWest, Walk;

            announce("Walk:1:" + to_string(simulation_time) + ":AllPedestriansWalk");
            announce("Walk:2:" + to_string(simulation_time) + ":AllPedestriansWalk");
        }

        on ApplyAllPedestriansStop do {
            send i1PedAcrossMainNorth, DontWalk;
            send i1PedAcrossMainSouth, DontWalk;
            send i1PedAcrossCrossEast, DontWalk;
            send i1PedAcrossCrossWest, DontWalk;

            send i2PedAcrossMainNorth, DontWalk;
            send i2PedAcrossMainSouth, DontWalk;
            send i2PedAcrossCrossEast, DontWalk;
            send i2PedAcrossCrossWest, DontWalk;

            announce("DontWalk:1:" + to_string(simulation_time) + ":AllPedestriansStop");
            announce("DontWalk:2:" + to_string(simulation_time) + ":AllPedestriansStop");
        }

        on ApplyTurnPolicyAllowed do {
            rtAAllowed = true;
            ltAAllowed = true;
            rtBAllowed = true;
            ltBAllowed = true;

            send sign, AllowTurns22To0559;

            announce("AllowRightTurnA:1:" + to_string(simulation_time));
            announce("AllowLeftTurnA:1:" + to_string(simulation_time));
        }

        on ApplyTurnPolicyForbidden do {
            rtAAllowed = false;
            ltAAllowed = false;
            rtBAllowed = false;
            ltBAllowed = false;

            send sign, ForbidTurns06To22;

            announce("ForbidRightTurnA:1:" + to_string(simulation_time));
            announce("ForbidLeftTurnA:1:" + to_string(simulation_time));
        }

        on HighTraffic do {
            announce("HighTraffic:1:" + to_string(simulation_time) + ":VehicleQueueHigh");
        }

        on MediumTraffic do {
            announce("MediumTraffic:1:" + to_string(simulation_time) + ":VehicleQueueMedium");
        }

        on LowTraffic do {
            announce("LowTraffic:1:" + to_string(simulation_time) + ":VehicleQueueLow");
        }

        on PedestrianRequest do {
            announce("PedestrianRequest:1:" + to_string(simulation_time) + ":ButtonPressed");
        }

        on BusDetected do {
            announce("BusDetected:1:" + to_string(simulation_time) + ":PriorityBus");
        }

        on SirenDetected do {
            sirenOn = true;
            announce("SirenDetected:1:" + to_string(simulation_time) + ":EmergencySiren");
        }

        on BeaconDetected do {
            beaconOn = true;
            announce("BeaconDetected:1:" + to_string(simulation_time) + ":EmergencyBeacon");
        }

        on AuthorizedEmergency do {
            raise ApplyAllRed;
            raise ApplyAllPedestriansStop;

            send ambulance, DispatchAmbulance;
            send police, DispatchPolice;
            send firefighters, DispatchFirefighters;

            accidentOpen = true;
            pedestrianAlreadyRescued = false;

            announce("AmbulanceDispatched:1:" + to_string(simulation_time) + ":Emergency");
            announce("PoliceDispatched:1:" + to_string(simulation_time) + ":Emergency");
            announce("FirefightersDispatched:1:" + to_string(simulation_time) + ":Emergency");
        }

        on TrafficAccident do {
            announce("TrafficAccident:1:" + to_string(simulation_time) + ":AccidentDetected");
        }

        on PedestrianRescued do {
            pedestrianAlreadyRescued = true;

            announce("PedestrianRescued:1:" + to_string(simulation_time) + ":RescueSuccess");
        }

        on AccidentResolved do {
            accidentOpen = false;
            sirenOn = false;
            beaconOn = false;

            send ambulance, StandDown;
            send police, StandDown;
            send firefighters, StandDown;

            announce("AccidentResolved:1:" + to_string(simulation_time) + ":SceneCleared");
            announce("StandDown:1:" + to_string(simulation_time) + ":EmergencyOver");
        }

        on Tick do {
            // Incrementar tempo de simulação
            simulation_time = simulation_time + 100;
            raise Tick;
        }

        on PeakHour do {
            announce("PeakHour:0:" + to_string(simulation_time) + ":TrafficPeakHours");
        }

        on NormalHour do {
            announce("NormalHour:0:" + to_string(simulation_time) + ":TrafficNormalHours");
        }

        on NightHour do {
            announce("NightHour:0:" + to_string(simulation_time) + ":TrafficNightHours");
        }

        on DawnPeriod do {
            announce("DawnPeriod:0:" + to_string(simulation_time) + ":TrafficDawnPeriod");
        }

        on SyncPhase do {
            // Sincronizar fases dos cruzamentos para onda verde
            announce("SyncPhase:0:" + to_string(simulation_time) + ":GreenWaveSync");
            raise ApplyMainGreen;
        }
    }
}

spec TrafficLightObserver observes
    I1MainGreen, I1MainRed, I1CrossGreen, I1CrossRed,
    I2MainGreen, I2MainRed, I2CrossGreen, I2CrossRed {

    var i1MainIsGreen : bool;
    var i1CrossIsGreen : bool;
    var i2MainIsGreen : bool;
    var i2CrossIsGreen : bool;

    start state Monitoring {
        on I1MainGreen do {
            i1MainIsGreen = true;
            assert !(i1MainIsGreen && i1CrossIsGreen),
                "ERRO: cruzamento 1 ficou com principal e transversal verdes!";
        }

        on I1MainRed do {
            i1MainIsGreen = false;
        }

        on I1CrossGreen do {
            i1CrossIsGreen = true;
            assert !(i1MainIsGreen && i1CrossIsGreen),
                "ERRO: cruzamento 1 ficou com principal e transversal verdes!";
        }

        on I1CrossRed do {
            i1CrossIsGreen = false;
        }

        on I2MainGreen do {
            i2MainIsGreen = true;
            assert !(i2MainIsGreen && i2CrossIsGreen),
                "ERRO: cruzamento 2 ficou com principal e transversal verdes!";
        }

        on I2MainRed do {
            i2MainIsGreen = false;
        }

        on I2CrossGreen do {
            i2CrossIsGreen = true;
            assert !(i2MainIsGreen && i2CrossIsGreen),
                "ERRO: cruzamento 2 ficou com principal e transversal verdes!";
        }

        on I2CrossRed do {
            i2CrossIsGreen = false;
        }
    }
}

spec RescueObserver observes
    TrafficAccident, AmbulanceDispatched, PoliceDispatched,
    FirefightersDispatched, PedestrianRescued, AccidentResolved {

    var accidentActive : bool;
    var ambulanceSent : bool;
    var policeSent : bool;
    var firefightersSent : bool;

    start state Monitoring {
        on TrafficAccident do {
            accidentActive = true;
            ambulanceSent = false;
            policeSent = false;
            firefightersSent = false;
        }

        on AmbulanceDispatched do {
            if (accidentActive) {
                ambulanceSent = true;
            }
        }

        on PoliceDispatched do {
            if (accidentActive) {
                policeSent = true;
            }
        }

        on FirefightersDispatched do {
            if (accidentActive) {
                firefightersSent = true;
            }
        }

        on PedestrianRescued do {
            assert ambulanceSent,
                "ERRO: pedestre resgatado sem ambulancia enviada!";
            assert policeSent,
                "ERRO: pedestre resgatado sem policia enviada!";
            assert firefightersSent,
                "ERRO: pedestre resgatado sem bombeiros enviados!";
        }

        on AccidentResolved do {
            assert ambulanceSent && policeSent && firefightersSent,
                "ERRO: acidente resolvido sem todas as equipes!";

            accidentActive = false;
            ambulanceSent = false;
            policeSent = false;
            firefightersSent = false;
        }
    }
}

spec LivenessObserver observes I1MainGreen, I1CrossGreen, I2MainGreen, I2CrossGreen {
    var seenGreen : bool;

    start state Monitoring {
        on I1MainGreen do {
            seenGreen = true;
        }

        on I1CrossGreen do {
            seenGreen = true;
        }

        on I2MainGreen do {
            seenGreen = true;
        }

        on I2CrossGreen do {
            seenGreen = true;
        }
    }
}

// ======================================================
// MAQUINA PRINCIPAL
// ======================================================

machine Main {
    var ctrl : machine;

    start state Init {
        entry {
            // Enviar evento de inicialização para C++
            announce("Start:0:0:SystemInitialization");

            ctrl = new Controller();

            send ctrl, SyncPhase;

            new ClockEnvironment(ctrl);
            new VehicleSensor(ctrl);
            new PedestrianSensor(ctrl);
            new EmergencySensor(ctrl);
            new BusSensor(ctrl);
            new AccidentSensor(ctrl);
        }
    }
}

// ======================================================
// AMBIENTE - RELOGIO
// ======================================================

machine ClockEnvironment {
    var controller : machine;
    var counter : int;
    var sim_time : int;

    start state Init {
        entry(ctrl : machine) {
            controller = ctrl;
            sim_time = 0;
            goto Running;
        }
    }

    state Running {
        entry {
            counter = 0;
            raise Tick;
        }

        on Tick do {
            sim_time = sim_time + 100;

            if ($) {
                send controller, PeakHour;
            } else if ($) {
                send controller, NormalHour;
            } else if ($) {
                send controller, DawnPeriod;
            } else {
                send controller, NightHour;
            }

            counter = counter + 1;

            if (counter < 20) {
                raise Tick;
            }
        }
    }
}

// ======================================================
// SENSOR DE VEICULOS
// ======================================================

machine VehicleSensor {
    var controller : machine;
    var counter : int;
    var sim_time : int;

    start state Init {
        entry(ctrl : machine) {
            controller = ctrl;
            sim_time = 0;
            goto Running;
        }
    }

    state Running {
        entry {
            counter = 0;
            raise Tick;
        }

        on Tick do {
            sim_time = sim_time + 100;

            if ($) {
                if ($) {
                    send controller, HighTraffic;
                } else {
                    send controller, MediumTraffic;
                }
            } else {
                send controller, LowTraffic;
            }

            counter = counter + 1;

            if (counter < 20) {
                raise Tick;
            }
        }
    }
}

// ======================================================
// SENSOR DE PEDESTRES
// ======================================================

machine PedestrianSensor {
    var controller : machine;
    var counter : int;
    var sim_time : int;

    start state Init {
        entry(ctrl : machine) {
            controller = ctrl;
            sim_time = 0;
            goto Running;
        }
    }

    state Running {
        entry {
            counter = 0;
            raise Tick;
        }

        on Tick do {
            sim_time = sim_time + 100;

            if ($) {
                send controller, PedestrianRequest;
            }

            counter = counter + 1;

            if (counter < 20) {
                raise Tick;
            }
        }
    }
}

// ======================================================
// SENSOR DE EMERGENCIA
// ======================================================

machine EmergencySensor {
    var controller : machine;
    var counter : int;
    var sim_time : int;

    start state Init {
        entry(ctrl : machine) {
            controller = ctrl;
            sim_time = 0;
            goto Running;
        }
    }

    state Running {
        entry {
            counter = 0;
            raise Tick;
        }

        on Tick do {
            sim_time = sim_time + 100;

            if ($) {
                send controller, SirenDetected;
            }

            if ($) {
                send controller, BeaconDetected;
            }

            counter = counter + 1;

            if (counter < 20) {
                raise Tick;
            }
        }
    }
}

// ======================================================
// SENSOR DE ONIBUS
// ======================================================

machine BusSensor {
    var controller : machine;
    var counter : int;
    var sim_time : int;

    start state Init {
        entry(ctrl : machine) {
            controller = ctrl;
            sim_time = 0;
            goto Running;
        }
    }

    state Running {
        entry {
            counter = 0;
            raise Tick;
        }

        on Tick do {
            sim_time = sim_time + 100;

            if ($) {
                send controller, BusDetected;
            }

            counter = counter + 1;

            if (counter < 20) {
                raise Tick;
            }
        }
    }
}

// ======================================================
// SENSOR DE ACIDENTE ALEATORIO
// ======================================================

machine AccidentSensor {
    var controller : machine;
    var counter : int;
    var sim_time : int;

    start state Init {
        entry(ctrl : machine) {
            controller = ctrl;
            sim_time = 0;
            goto Running;
        }
    }

    state Running {
        entry {
            counter = 0;
            raise Tick;
        }

        on Tick do {
            sim_time = sim_time + 100;

            if ($) {
                send controller, TrafficAccident;
            }

            counter = counter + 1;

            if (counter < 20) {
                raise Tick;
            }
        }
    }
}
