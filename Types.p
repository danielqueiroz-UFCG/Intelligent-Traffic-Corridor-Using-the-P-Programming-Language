//=====================================================
// Types.p
//=====================================================
// Descrição: Definição abrangente de tipos de dados, 
// estruturas e enums para o sistema P-Traffic.
//=====================================================

//-----------------------------------------------------
// 1. Tipos de Identificadores Básicos (IDs)
//-----------------------------------------------------
type IntersectionId = int;
type ControllerId = int;
type SensorId = int;
type LaneId = int;
type CameraId = int;
type LightGroupId = int;
type PedestrianButtonId = int;
type DisplayPanelId = int;
type VehicleId = int;
type RouteId = int;
type ClusterId = int;
type MessageId = int;
type LogId = int;
type DeviceId = int;
type TokenId = int;

//-----------------------------------------------------
// 2. Enumeradores Básicos de Controle Viário
//-----------------------------------------------------
enum LightColor {
    RED,
    YELLOW,
    GREEN,
    FLASHING_RED,
    FLASHING_YELLOW,
    OFF
}

enum Direction {
    NORTH,
    SOUTH,
    EAST,
    WEST,
    NORTH_EAST,
    NORTH_WEST,
    SOUTH_EAST,
    SOUTH_WEST
}

enum EmergencyType {
    NONE,
    AMBULANCE,
    POLICE,
    FIRETRUCK,
    MILITARY,
    CIVIL_DEFENSE
}

enum RoadType {
    MAIN,
    CROSS,
    HIGHWAY,
    AVENUE,
    RESIDENTIAL,
    ALLEY,
    ROUNDABOUT,
    SERVICE_ROAD
}

//-----------------------------------------------------
// 3. Enumeradores de Modos de Operação do Sistema
//-----------------------------------------------------
enum SystemMode {
    MODE_BOOTING,
    MODE_OPERATIONAL_DEFAULT,
    MODE_RUSH_HOUR_MORNING,
    MODE_RUSH_HOUR_EVENING,
    MODE_NIGHT_ECONOMY,
    MODE_EMERGENCY_PREEMPTION,
    MODE_MANUAL_OVERRIDE,
    MODE_FAIL_SAFE_FLASHING,
    MODE_MAINTENANCE_LOCKED,
    MODE_WEATHER_ADAPTIVE,
    MODE_HOLIDAY_SCHEDULE,
    MODE_VIP_CORRIDOR
}

//-----------------------------------------------------
// 4. Enumeradores de Diagnóstico, Hardware e Saúde
//-----------------------------------------------------
enum HardwareStatus {
    HW_STATUS_HEALTHY,
    HW_STATUS_WARNING_MINOR,
    HW_STATUS_DEGRADED,
    HW_STATUS_CRITICAL_FAILURE,
    HW_STATUS_UNKNOWN
}

enum ComponentErrorType {
    ERR_NONE,
    ERR_LAMP_BURNED_RED,
    ERR_LAMP_BURNED_YELLOW,
    ERR_LAMP_BURNED_GREEN,
    ERR_CONFLICT_GREEN_CONFLICT,
    ERR_SENSOR_TIMEOUT,
    ERR_CAMERA_OBSTRUCTION,
    ERR_POWER_VOLTAGE_DROP,
    ERR_NETWORK_DISCONNECT,
    ERR_WATCHDOG_RESET,
    ERR_STORAGE_FULL,
    ERR_TAMPERING_DETECTED
}

enum NetworkTopologyRole {
    ROLE_STANDALONE,
    ROLE_CLUSTER_MASTER,
    ROLE_CLUSTER_SLAVE,
    ROLE_CENTRAL_GATEWAY,
    ROLE_BACKUP_MASTER
}

//-----------------------------------------------------
// 5. Enumeradores de Sensores e Tráfego
//-----------------------------------------------------
enum SensorType {
    SENSOR_INDUCTION_LOOP,
    SENSOR_RADAR_SPEED,
    SENSOR_AI_CAMERA,
    SENSOR_LIDAR_CROSSWALK,
    SENSOR_PEDESTRIAN_PUSH_BUTTON,
    SENSOR_WEATHER_STATION,
    SENSOR_ACOUSTIC_SIREN
}

enum TrafficDensityLevel {
    DENSITY_EMPTY,
    DENSITY_LIGHT,
    DENSITY_FLUID,
    DENSITY_MODERATE,
    DENSITY_HEAVY,
    DENSITY_CONGESTED,
    DENSITY_GRIDLOCK
}

enum WeatherCondition {
    WEATHER_CLEAR,
    WEATHER_LIGHT_RAIN,
    WEATHER_HEAVY_RAIN,
    WEATHER_FOG,
    WEATHER_SNOW,
    WEATHER_ICE_ON_ROAD
}

enum PedestrianState {
    PED_STATE_WAITING,
    PED_STATE_CROSSING_START,
    PED_STATE_CROSSING_CLEARANCE,
    PED_STATE_NO_PEDESTRIANS
}

//-----------------------------------------------------
// 6. Estruturas Base de Geometria e Localização
//-----------------------------------------------------
struct GeoCoordinate {
    latitude: int;  // Multiplicado por 1.000.000 para precisão fixa
    longitude: int; // Multiplicado por 1.000.000 para precisão fixa
    altitude: int;
}

struct LaneConfiguration {
    laneId: LaneId;
    direction: Direction;
    roadType: RoadType;
    allowsLeftTurn: bool;
    allowsRightTurn: bool;
    allowsU_Turn: bool;
    isBusLane: bool;
    isBikeLane: bool;
}

struct ApproachVector {
    direction: Direction;
    roadName: string;
    numberOfLanes: int;
    speedLimit: int;
    hasPedestrianCrosswalk: bool;
}

//-----------------------------------------------------
// 7. Estruturas de Estado Físico e Atuadores
//-----------------------------------------------------
struct SignalLightState {
    groupId: LightGroupId;
    currentColor: LightColor;
    timeRemainingInState: int;
    isFlashing: bool;
    powerConsumptionWatts: int;
}

struct PedestrianSignalState {
    buttonId: PedestrianButtonId;
    isWalkSignalActive: bool;
    isCountdownActive: bool;
    countdownValue: int;
    hasAudioPromptEnabled: bool;
}

struct IntersectionHardwareState {
    intersectionId: IntersectionId;
    lights: seq[SignalLightState];
    pedestrianSignals: seq[PedestrianSignalState];
    isCabinetDoorOpen: bool;
    batteryBackupLevelPercent: int;
    temperatureCelsius: int;
}

//-----------------------------------------------------
// 8. Estruturas de Sensores e Telemetria
//-----------------------------------------------------
struct SensorReading {
    sensorId: SensorId;
    type: SensorType;
    isActive: bool;
    timestampMs: int;
    rawCount: int;
    occupancyRatio: int; // 0 a 100
}

struct VehicleTelemetry {
    vehicleId: VehicleId;
    speedKmh: int;
    lengthMeters: int;
    estimatedWeightKg: int;
    isPublicTransit: bool;
    isAutonomous: bool;
}

struct TrafficMetrics {
    laneId: LaneId;
    density: TrafficDensityLevel;
    averageSpeedKmh: int;
    queueLengthVehicles: int;
    waitingTimeSec: int;
}

//-----------------------------------------------------
// 9. Estruturas de Priorização e Emergência
//-----------------------------------------------------
struct EmergencyRequest {
    requestId: MessageId;
    type: EmergencyType;
    approachingFrom: Direction;
    targetIntersectionId: IntersectionId;
    estimatedTimeToArrivalSec: int;
    currentSpeedKmh: int;
    gpsLocation: GeoCoordinate;
}

struct PreemptionActiveState {
    isPreemptionActive: bool;
    activeEmergencyId: MessageId;
    grantedDirection: Direction;
    holdGreenTimeSec: int;
    safetyTimeoutTriggered: bool;
}

//-----------------------------------------------------
// 10. Estruturas de Configuração de Ciclos (Timing)
//-----------------------------------------------------
struct TimePhase {
    phaseId: int;
    allowedDirections: seq[Direction];
    greenDuration: int;
    yellowDuration: int;
    redClearanceDuration: int;
    minGreen: int;
    maxGreen: int;
}

struct CycleTimingPlan {
    planId: int;
    name: string;
    phases: seq[TimePhase];
    totalCycleLength: int;
    offsetFromMasterSec: int;
}

//-----------------------------------------------------
// 11. Estruturas de Rede, Mensageria e Comunicação (A-B)
//-----------------------------------------------------
struct NetworkHeader {
    messageId: MessageId;
    senderId: ControllerId;
    receiverId: ControllerId;
    timestampMs: int;
    sequenceNumber: int;
    ttl: int;
}

struct HeartbeatMessage {
    header: NetworkHeader;
    currentMode: SystemMode;
    hardwareHealth: HardwareStatus;
    syncToken: TokenId;
}

struct SynchronizationToken {
    tokenId: TokenId;
    masterClockTimeMs: int;
    networkJitterCompensation: int;
    epochId: int;
}

struct IntersectionStatusPayload {
    intersectionId: IntersectionId;
    activePlanId: int;
    activePhaseId: int;
    metrics: seq[TrafficMetrics];
    hardwareError: ComponentErrorType;
}

struct NetworkMessagePacket {
    header: NetworkHeader;
    payloadType: int; // Tipo mapeado por enum ou constante
    statusPayload: IntersectionStatusPayload;
    heartbeatPayload: HeartbeatMessage;
    emergencyPayload: EmergencyRequest;
}

//-----------------------------------------------------
// 12. Estruturas de Otimização Local e IA
//-----------------------------------------------------
struct AdaptiveAdjustment {
    targetPhaseId: int;
    greenExtensionSec: int;
    redReductionSec: int;
    confidenceFactorPercent: int;
    reasonCode: int;
}

struct OptimizationModelData {
    modelId: int;
    historicalWeight: int;
    realtimeWeight: int;
    adjustments: seq[AdaptiveAdjustment];
    isApprovedByCentral: bool;
}

//-----------------------------------------------------
// 13. Estruturas de Exibição e Interface Física (VMS)
//-----------------------------------------------------
struct VariableMessageSign {
    panelId: DisplayPanelId;
    isOnline: bool;
    displayedText: string;
    alertColorRgb: int;
    refreshRateMs: int;
}

//-----------------------------------------------------
// 14. Estruturas de Logs, Auditoria e Segurança
//-----------------------------------------------------
struct AuditLogEntry {
    logId: LogId;
    timestampMs: int;
    severity: int;
    sourceComponentId: DeviceId;
    eventCode: int;
    description: string;
    securitySignature: int;
}

struct FailSafeReport {
    reportId: int;
    intersectionId: IntersectionId;
    triggeringError: ComponentErrorType;
    timestampMs: int;
    forcedColorState: LightColor;
    wasCentralNotified: bool;
}

//-----------------------------------------------------
// 15. Estruturas Globais do Sistema (Top-Level Clusters)
//-----------------------------------------------------
struct IntersectionTopology {
    id: IntersectionId;
    name: string;
    coordinates: GeoCoordinate;
    approaches: seq[ApproachVector];
    lanes: seq[LaneConfiguration];
    neighborIntersections: seq[IntersectionId];
}

struct ControllerClusterContext {
    clusterId: ClusterId;
    role: NetworkTopologyRole;
    masterControllerId: ControllerId;
    monitoredIntersections: seq[IntersectionTopology];
    networkStatus: HardwareStatus;
}

struct CompleteSystemContext {
    systemName: string;
    versionMajor: int;
    versionMinor: int;
    globalMode: SystemMode;
