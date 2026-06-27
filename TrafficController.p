///////////////////////////////////////////////////////////////
// TrafficController.p
///////////////////////////////////////////////////////////////

machine TrafficController
{

    ///////////////////////////////////////////////////////////
    // MÁQUINAS DO SISTEMA
    ///////////////////////////////////////////////////////////

    var I1:machine;
    var I2:machine;

    var TimerMachine:machine;
    var EmergencyController:machine;
    var BusController:machine;
    var GreenWaveController:machine;

    ///////////////////////////////////////////////////////////
    // CONTROLE GERAL
    ///////////////////////////////////////////////////////////

    var initialized:bool;
    var running:bool;
    var emergencyMode:bool;
    var busPriority:bool;
    var greenWaveEnabled:bool;
    var nightMode:bool;
    var maintenanceMode:bool;

    ///////////////////////////////////////////////////////////
    // CONTADORES
    ///////////////////////////////////////////////////////////

    var phase:int;

    var cycleCounter:int;

    var totalTicks:int;

    var emergencyCounter:int;

    var busCounter:int;

    var pedestrianCounter:int;

    ///////////////////////////////////////////////////////////
    // TEMPOS
    ///////////////////////////////////////////////////////////

    var mainGreenTime:int;

    var crossGreenTime:int;

    var yellowTime:int;

    var pedestrianTime:int;

    var allRedTime:int;

    ///////////////////////////////////////////////////////////
    // DETECÇÃO DE VEÍCULOS
    ///////////////////////////////////////////////////////////

    var northVehicles:int;
    var southVehicles:int;
    var eastVehicles:int;
    var westVehicles:int;

    ///////////////////////////////////////////////////////////
    // FILAS
    ///////////////////////////////////////////////////////////

    var northQueue:int;
    var southQueue:int;
    var eastQueue:int;
    var westQueue:int;

    ///////////////////////////////////////////////////////////
    // ESTATÍSTICAS
    ///////////////////////////////////////////////////////////

    var averageNorth:int;

    var averageSouth:int;

    var averageEast:int;

    var averageWest:int;

    ///////////////////////////////////////////////////////////
    // FLAGS
    ///////////////////////////////////////////////////////////

    var ambulanceDetected:bool;

    var policeDetected:bool;

    var firefighterDetected:bool;

    ///////////////////////////////////////////////////////////
    // INICIALIZAÇÃO
    ///////////////////////////////////////////////////////////

    start state Init
    {

        entry
        {

            print "===================================";

            print "Traffic Controller";

            print "Initializing";

            print "===================================";

            initialized = false;

            running = false;

            emergencyMode = false;

            busPriority = false;

            greenWaveEnabled = true;

            nightMode = false;

            maintenanceMode = false;

            phase = 0;

            cycleCounter = 0;

            totalTicks = 0;

            emergencyCounter = 0;

            busCounter = 0;

            pedestrianCounter = 0;

            mainGreenTime = 30;

            crossGreenTime = 30;

            yellowTime = 5;

            pedestrianTime = 20;

            allRedTime = 2;

            northVehicles = 0;

            southVehicles = 0;

            eastVehicles = 0;

            westVehicles = 0;

            northQueue = 0;

            southQueue = 0;

            eastQueue = 0;

            westQueue = 0;

            averageNorth = 0;

            averageSouth = 0;

            averageEast = 0;

            averageWest = 0;

            ambulanceDetected = false;

            policeDetected = false;

            firefighterDetected = false;

            I1 = new Intersection(1);

            I2 = new Intersection(2);

            print "Intersection 1 Created";

            print "Intersection 2 Created";

            initialized = true;

            goto Boot;

        }

    }

    ///////////////////////////////////////////////////////////
    // BOOT
    ///////////////////////////////////////////////////////////

    state Boot
    {

        entry
        {

            print "Boot Sequence";

            send I1, MainGreen;

            send I2, CrossGreen;

            phase = 0;

            running = true;

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

            if(totalTicks > 5)
            {

                goto Running;

            }

        }

    }

    ///////////////////////////////////////////////////////////
    // RUNNING
    ///////////////////////////////////////////////////////////

    state Running
    {

        entry
        {

            print "Controller Running";

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

            cycleCounter = cycleCounter + 1;

            if(phase == 0)
            {

                send I1, MainGreen;

                send I2, CrossGreen;

            }
            else
            {

                send I1, CrossGreen;

                send I2, MainGreen;

            }

            if(cycleCounter >= mainGreenTime)
            {

                send this, PhaseFinished;

            }

        }

        on PhaseFinished do
        {

            cycleCounter = 0;

            if(phase == 0)
            {

                phase = 1;

            }
            else
            {

                phase = 0;

            }

        }

        on BusDetected goto BusPriority;

        on EmergencyStart goto Emergency;

        on NightMode goto Night;

    }
