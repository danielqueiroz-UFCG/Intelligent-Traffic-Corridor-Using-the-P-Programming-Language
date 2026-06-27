//=====================================================
// VehicleLight.p
//=====================================================
// Descrição: Controlador concorrente avançado para semáforos 
// automotivos e de pedestres com suporte a multi-regimes, 
// detecção de falhas e priorização de emergência.
//=====================================================

//-----------------------------------------------------
// 1. Declaração de Eventos (Eventos de Entrada/Saída)
//-----------------------------------------------------
event MainGreen;
event MainYellow;
event MainRed;
event CrossGreen;
event CrossYellow;
event CrossRed;

// Eventos de Controle de Modo Remoto/Central
event SwitchToNormalMode;
event SwitchToRushHourMode;
event SwitchToNightMode;
event SwitchToMaintenanceMode;

// Eventos de Sensores e Telemetria
event VehicleDetected: LaneId;
event PedestrianButtonPressed: PedestrianButtonId;
event EmergencyApproaching: EmergencyRequest;
event EmergencyCleared: MessageId;

// Eventos de Diagnóstico de Hardware e Monitoramento
event HardwareFailureDetected: ComponentErrorType;
event HardwareCleared;
event WatchdogTick;
event SynchronizationSignal: SynchronizationToken;

//-----------------------------------------------------
// 2. Máquina de Estados Principal: VehicleLight
//-----------------------------------------------------
machine VehicleLight
{
    // Variáveis de Estado Interno da Máquina
    var color: LightColor;
    var currentMode: SystemMode;
    var currentIntersection: IntersectionId;
    var isEmergencyActive: bool;
    var activeEmergencyData: EmergencyRequest;
    var cycleTimer: int;
    var consecutiveErrorCount: int;
    var lastSensorReading: TrafficMetrics;
    
    // Coleções para rastreamento de infraestrutura local
    var activeLanes: seq[LaneId];
    var pedestrianQueue: seq[PedestrianButtonId];

    //-------------------------------------------------
    // Estado Inicial: Inicialização do Hardware
    //-------------------------------------------------
    start state Booting
    {
        entry
        {
            color = OFF;
            currentMode = MODE_BOOTING;
            isEmergencyActive = false;
            cycleTimer = 0;
            consecutiveErrorCount = 0;
            print "SYSTEM_LOG: Inicializando controlador VehicleLight...";
            
            // Simulação de inicialização de portas digitais
            color = FLASHING_YELLOW;
            print "SYSTEM_LOG: Auto-teste de lâmpadas concluído.";
            
            goto Red;
        }
    }

    //-------------------------------------------------
    // Estado RED (Vermelho - Parada Obrigatória)
    //-------------------------------------------------
    state Red
    {
        entry
        {
            color = RED;
            cycleTimer = 0;
            print "LIGHT_STATE: Semáforo em VERMELHO. Tráfego retido.";
            
            // Notifica o subsistema de pedestres que eles podem solicitar travessia
            print "INTERFACE_EVENT: Sinalizador de pedestres liberado para travessia segura.";
        }

        // Transições de Tráfego Padrão
        on MainGreen goto Green;
        on CrossGreen goto Green;
        
        // Mudanças de Modo sob demanda enquanto retido
        on SwitchToNightMode goto FlashingNightMode;
        on SwitchToMaintenanceMode goto MaintenanceMode;
        
        // Tratamento de interrupções de sensores e emergências
        on EmergencyApproaching do {
            payload: EmergencyRequest ->
            print "PREEMPTION_LOG: Emergência detectada no estado Vermelho.";
            isEmergencyActive = true;
            activeEmergencyData = payload;
            // Mantém em vermelho para segurança da rota cruzada se necessário
        };

        on VehicleDetected do {
            lane: LaneId ->
            print "SENSOR_LOG: Veículo aguardando na faixa registrada.";
        };

        on HardwareFailureDetected goto FailSafeFlashingMode;
        
        exit
        {
            print "LIGHT_STATE: Encerrando fase VERMELHO.";
        }
    }

    //-------------------------------------------------
    // Estado GREEN (Verde - Fluxo Livre)
    //-------------------------------------------------
    state Green
    {
        entry
        {
            color = GREEN;
            cycleTimer = 0;
            print "LIGHT_STATE: Semáforo em VERDE. Fluxo livre permitido.";
        }

        // Transições de Tráfego Padrão
        on MainYellow goto Yellow;
        on CrossYellow goto Yellow;
        
        // Resposta imediata para aproximação de ambulâncias/bombeiros
        on EmergencyApproaching do {
            payload: EmergencyRequest ->
            print "PREEMPTION_LOG: Alerta de emergência de alta prioridade recebido!";
            isEmergencyActive = true;
            activeEmergencyData = payload;
            
            // Se a emergência vem da direção oposta à atual, força transição para amarelo
            if (payload.approachingFrom == Direction.EAST || payload.approachingFrom == Direction.WEST) {
                print "PREEMPTION_LOG: Forçando corte do sinal verde para rota de emergência.";
                goto Yellow;
            }
        };

        on PedestrianButtonPressed do {
            button: PedestrianButtonId ->
            print "INTERFACE_EVENT: Botão de pedestre pressionado. Agendando troca de fase.";
            // Adiciona à fila de processamento interna
        };

        on HardwareFailureDetected goto FailSafeFlashingMode;
        on SwitchToMaintenanceMode goto MaintenanceMode;

        exit
        {
            print "LIGHT_STATE: Encerrando fase VERDE de fluxo.";
        }
    }

    //-------------------------------------------------
    // Estado YELLOW (Amarelo - Atenção / Desaceleração)
    //-------------------------------------------------
    state Yellow
    {
        entry
        {
            color = YELLOW;
            cycleTimer = 0;
            print "LIGHT_STATE: Semáforo em AMARELO. Reduza a velocidade.";
        }

        // Transições de Tráfego Padrão
        on MainRed goto Red;
        on CrossRed goto Red;
        
        // Ignora solicitações secundárias no amarelo por motivos de segurança física
        on PedestrianButtonPressed do {
            button: PedestrianButtonId ->
            print "SYSTEM_WARN: Solicitação de pedestre ignorada temporariamente (Fase Amarelo).";
        };

        on EmergencyApproaching do {
            payload: EmergencyRequest ->
            print "PREEMPTION_LOG: Emergência detectada no Amarelo. Mantendo transição segura para o Vermelho.";
            isEmergencyActive = true;
            activeEmergencyData = payload;
        };

        on HardwareFailureDetected goto FailSafeFlashingMode;

        exit
        {
            print "LIGHT_STATE: Encerrando fase AMARELO.";
        }
    }

    //-------------------------------------------------
    // Estado FLUSHING_NIGHT (Modo Noturno Econômico)
    //-------------------------------------------------
    state FlashingNightMode
    {
        entry
        {
            color = FLASHING_YELLOW;
            currentMode = MODE_NIGHT_ECONOMY;
            print "MODE_LOG: Entrando em Regime Noturno Econômico (Amarelo Piscante).";
        }

        // Eventos que provocam a saída do modo noturno de baixo fluxo
        on SwitchToNormalMode goto Booting;
        on SwitchToRushHourMode do {
            currentMode = MODE_RUSH_HOUR_MORNING;
            goto Booting;
        };

        // Se um veículo se aproxima na via secundária, ativa temporariamente o ciclo normal
        on VehicleDetected do {
            lane: LaneId ->
            print "SENSOR_LOG: Veículo detectado na madrugada. Ativando ciclo sob demanda.";
            goto Booting;
        };

        on EmergencyApproaching do {
            payload: EmergencyRequest ->
            print "PREEMPTION_LOG: Emergência na madrugada. Priorizando rota.";
            isEmergencyActive = true;
            activeEmergencyData = payload;
            goto Booting;
        };

        on HardwareFailureDetected goto FailSafeFlashingMode;

        exit
        {
            print "MODE_LOG: Saindo do Regime Noturno Econômico.";
        }
    }

    //-------------------------------------------------
    // Estado FAIL_SAFE (Modo de Pane / Falha Crítica)
    //-------------------------------------------------
    state FailSafeFlashingMode
    {
        entry
        {
            color = FLASHING_RED;
            currentMode = MODE_FAIL_SAFE_FLASHING;
            print "CRITICAL_LOG: CRASH DETECTADO OU ERRO DE CONFLITO! Entrando em modo de segurança.";
            print "CRITICAL_LOG: Enviando alerta de hardware via telemetria para a central urbana.";
        }

        // Tentativa de recuperação baseada em comando remoto de limpeza de erro
        on HardwareCleared do {
            consecutiveErrorCount = 0;
            print "RECOVERY_LOG: Sinais de erro limpos pela central de controle.";
            goto Booting;
        };

        // Registra ocorrências repetidas de falha para auditoria
        on HardwareFailureDetected do {
            err: ComponentErrorType ->
            consecutiveErrorCount = consecutiveErrorCount + 1;
            print "CRITICAL_LOG: Falha persistente detectada no barramento.";
        };

        // Bloqueia comandos normais de tráfego por segurança enquanto estiver em pane
        on MainGreen do { print "REJECT_LOG: Comando MainGreen ignorado. Sistema em Falha Segura."; };
        on MainYellow do { print "REJECT_LOG: Comando MainYellow ignorado. Sistema em Falha Segura."; };
        on MainRed do { print "REJECT_LOG: Comando MainRed ignorado. Sistema em Falha Segura."; };

        exit
        {
            print "RECOVERY_LOG: Saindo do modo de falha segura. Reiniciando atuadores.";
        }
    }

    //-------------------------------------------------
    // Estado MAINTENANCE (Manutenção de Campo Local)
