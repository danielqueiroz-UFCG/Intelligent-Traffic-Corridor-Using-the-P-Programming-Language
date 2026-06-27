//=====================================================
// Constants.p
//=====================================================
// Descrição: Configurações globais e limites para o
// sistema de controle de tráfego distribuído (P-Traffic)
//=====================================================

//-----------------------------------------------------
// 1. Temporização Padrão dos Semáforos (Segundos)
//-----------------------------------------------------
const GREEN_TIME = 30;
const YELLOW_TIME = 5;
const RED_TIME = 2;
const ALL_RED_CLEARANCE_TIME = 3;

//-----------------------------------------------------
// 2. Temporização para Pedestres
//-----------------------------------------------------
const PEDESTRIAN_TIME = 20;
const PEDESTRIAN_FLASH_GREEN = 5;
const PEDESTRIAN_MIN_WALK = 7;
const PEDESTRIAN_CLEARANCE = 4;

//-----------------------------------------------------
// 3. Dimensionamento da Rede Viária
//-----------------------------------------------------
const INTERSECTION_COUNT = 2;
const MAX_INTERSECTIONS = 64;
const LANES_PER_INTERSECTION = 4;
const MAX_APPROACHES_PER_INTERSECTION = 4;

//-----------------------------------------------------
// 4. Modos de Operação Horária (Multi-regime)
//-----------------------------------------------------
const MODE_NORMAL = 0;
const MODE_RUSH_HOUR = 1;
const MODE_NIGHT_FLASH = 2;
const MODE_EMERGENCY_EVAC = 3;
const MODE_MAINTENANCE = 4;

//-----------------------------------------------------
// 5. Ajustes para Horário de Pico (Rush Hour)
//-----------------------------------------------------
const RUSH_GREEN_TIME_MAIN = 50;
const RUSH_GREEN_TIME_SIDE = 20;
const RUSH_YELLOW_TIME = 5;
const RUSH_RED_TIME = 3;

//-----------------------------------------------------
// 6. Ajustes para Operação Noturna (Eco/Low-flow)
//-----------------------------------------------------
const NIGHT_GREEN_TIME_MAIN = 15;
const NIGHT_GREEN_TIME_SIDE = 10;
const NIGHT_FLASHING_INTERVAL_MS = 500;

//-----------------------------------------------------
// 7. Parâmetros de Sensores e Detecção de Presença
//-----------------------------------------------------
const SENSOR_POLLING_RATE_MS = 100;
const LOOP_DETECTOR_THRESHOLD_SEC = 2;
const CAMERA_DEBOUNCE_FRAMES = 5;
const RADAR_MIN_VELOCITY_KMH = 5;

//-----------------------------------------------------
// 8. Priorização de Veículos de Emergência (Preemption)
//-----------------------------------------------------
const PRIORITY_LEVEL_AMBULANCE = 3;
const PRIORITY_LEVEL_FIRE_TRUCK = 3;
const PRIORITY_LEVEL_POLICE = 2;
const PRIORITY_LEVEL_TRANSIT_BUS = 1;
const EMERGENCY_MAX_GREEN_HOLD = 60;
const EMERGENCY_MIN_GREEN_BEFORE_CUT = 10;

//-----------------------------------------------------
// 9. Configurações de Onda Verde (Sincronismo)
//-----------------------------------------------------
const DEFAULT_OFFSET_SECONDS = 12;
const MAX_NETWORK_JITTER_MS = 50;
const MAX_SYNC_DRIFT_MS = 200;

//-----------------------------------------------------
// 10. Limites de Velocidade e Segurança (Métrica)
//-----------------------------------------------------
const SPEED_LIMIT_URBAN = 50;
const SPEED_LIMIT_AVENUE = 70;
const SPEED_LIMIT_SCHOOL_ZONE = 30;

//-----------------------------------------------------
// 11. Constantes de Tolerância a Falhas e Diagnóstico
//-----------------------------------------------------
const STATUS_OK = 0;
const STATUS_WARNING = 1;
const STATUS_ERROR_LAMP_BURNED = 2;
const STATUS_ERROR_NO_COMMUNICATION = 3;
const STATUS_ERROR_CONFLICT_DETECTED = 4;

//-----------------------------------------------------
// 12. Prazos de Timeout do Protocolo de Rede (Heartbeat)
//-----------------------------------------------------
const HEARTBEAT_INTERVAL_MS = 1000;
const TIMEOUT_CONTROLLER_DEAD_MS = 3000;
const MAX_RETRY_ATTEMPTS = 3;

//-----------------------------------------------------
// 13. Capacidade Máxima de Filas e Tráfego
//-----------------------------------------------------
const MAX_VEHICLE_QUEUE_SIZE = 50;
const CONGESTION_THRESHOLD_PERCENT = 85;
const JAM_DETECTION_TIME_SEC = 15;

//-----------------------------------------------------
// 14. Modos de Iluminação das Lâmpadas (Hardware Map)
//-----------------------------------------------------
const LAMP_OFF = 0;
const LAMP_ON = 1;
const LAMP_FLASHING = 2;

//-----------------------------------------------------
// 15. Constantes de Hardware / GPIO Virtual
//-----------------------------------------------------
const PORT_NORTH_SOUTH_GREEN  = 101;
const PORT_NORTH_SOUTH_YELLOW = 102;
const PORT_NORTH_SOUTH_RED    = 103;
const PORT_EAST_WEST_GREEN    = 104;
const PORT_EAST_WEST_YELLOW   = 105;
const PORT_EAST_WEST_RED      = 106;

//-----------------------------------------------------
// 16. Portas de Pedestres
//-----------------------------------------------------
const PORT_PED_NORTH_SOUTH_WALK = 201;
const PORT_PED_NORTH_SOUTH_DONT = 202;
const PORT_PED_EAST_WEST_WALK   = 203;
const PORT_PED_EAST_WEST_DONT   = 204;

//-----------------------------------------------------
// 17. Parâmetros do Algoritmo de IA / Aprendizado
//-----------------------------------------------------
const LEARNING_WEIGHT_HISTORIC = 40;
const LEARNING_WEIGHT_REALTIME = 60;
const OPTIMIZATION_WINDOW_MINUTES = 15;

//-----------------------------------------------------
// 18. Constantes do Histórico de Dados (Logging)
//-----------------------------------------------------
const LOG_LEVEL_DEBUG = 0;
const LOG_LEVEL_INFO = 1;
const LOG_LEVEL_WARN = 2;
const LOG_LEVEL_FATAL = 3;
const MAX_LOG_ENTRIES_BEFORE_FLUSH = 100;

//-----------------------------------------------------
// 19. Simulação Ambiental
//-----------------------------------------------------
const WEATHER_DRY = 0;
const WEATHER_RAINY = 1;
const WEATHER_FOGGY = 2;
const WEATHER_SNOWY = 3;
const REACTION_TIME_MULTIPLIER_RAIN = 130; // 1.3x

//-----------------------------------------------------
// 20. Temporização Baseada no Clima
//-----------------------------------------------------
const RAIN_YELLOW_EXT_SEC = 2;
const FOG_ALL_RED_EXT_SEC = 3;

//-----------------------------------------------------
// 21. Configurações de Interface com Usuário (Painéis)
//-----------------------------------------------------
const DISPLAY_MSG_BLANK = 0;
const DISPLAY_MSG_SLOW_DOWN = 1;
const DISPLAY_MSG_ACCIDENT_AHEAD = 2;
const DISPLAY_MSG_DETOUR = 3;

//-----------------------------------------------------
// 22. ID de Grupos de Mensageria Inter-módulos
//-----------------------------------------------------
const MAILBOX_ROUTING_KEY_BROADCAST = 999;
const MAILBOX_ROUTING_KEY_LOCAL_CLUSTER = 500;

//-----------------------------------------------------
// End of Constants.p
//=====================================================
