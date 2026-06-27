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

        ///////////////////////////////////////////////////////////
    // BUS PRIORITY
    ///////////////////////////////////////////////////////////

    state BusPriority
    {

        entry
        {

            print "===================================";
            print "BUS PRIORITY MODE";
            print "===================================";

            busPriority = true;

            busCounter = busCounter + 1;

            cycleCounter = 0;

            if(phase == 0)
            {

                send I1, MainGreen;
                send I2, MainGreen;

            }
            else
            {

                send I1, CrossGreen;
                send I2, CrossGreen;

            }

        }

        on Tick do
        {

            cycleCounter = cycleCounter + 1;

            totalTicks = totalTicks + 1;

            if(cycleCounter >= 10)
            {

                send this, BusPriorityFinished;

            }

        }

        on BusPriorityFinished do
        {

            busPriority = false;

            cycleCounter = 0;

            goto Running;

        }

        on EmergencyStart goto Emergency;

    }

    ///////////////////////////////////////////////////////////
    // EMERGENCY MODE
    ///////////////////////////////////////////////////////////

    state Emergency
    {

        entry
        {

            print "===================================";
            print "EMERGENCY MODE";
            print "===================================";

            emergencyMode = true;

            emergencyCounter = emergencyCounter + 1;

            cycleCounter = 0;

            if(ambulanceDetected)
            {

                print "Ambulance Priority";

                send I1, MainGreen;
                send I2, MainGreen;

            }

            if(policeDetected)
            {

                print "Police Priority";

                send I1, CrossGreen;
                send I2, CrossGreen;

            }

            if(firefighterDetected)
            {

                print "Firefighters Priority";

                send I1, CrossGreen;
                send I2, CrossGreen;

            }

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

            cycleCounter = cycleCounter + 1;

            if(cycleCounter >= 20)
            {

                send this, EmergencyFinished;

            }

        }

        on EmergencyFinished do
        {

            emergencyMode = false;

            ambulanceDetected = false;

            policeDetected = false;

            firefighterDetected = false;

            cycleCounter = 0;

            goto Running;

        }

    }

    ///////////////////////////////////////////////////////////
    // NIGHT MODE
    ///////////////////////////////////////////////////////////

    state Night
    {

        entry
        {

            print "===================================";
            print "NIGHT MODE";
            print "===================================";

            nightMode = true;

            cycleCounter = 0;

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

            cycleCounter = cycleCounter + 1;

            if(cycleCounter % 2 == 0)
            {

                send I1, MainYellow;

                send I2, MainYellow;

            }
            else
            {

                send I1, MainRed;

                send I2, MainRed;

            }

        }

        on DayMode do
        {

            nightMode = false;

            goto Running;

        }

    }

    ///////////////////////////////////////////////////////////
    // MAINTENANCE MODE
    ///////////////////////////////////////////////////////////

    state Maintenance
    {

        entry
        {

            maintenanceMode = true;

            print "Maintenance Mode";

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

        }

        on Resume do
        {

            maintenanceMode = false;

            goto Running;

        }

    }

    ///////////////////////////////////////////////////////////
    // GREEN WAVE
    ///////////////////////////////////////////////////////////

    state GreenWave
    {

        entry
        {

            print "Green Wave Enabled";

            greenWaveEnabled = true;

            cycleCounter = 0;

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

            cycleCounter = cycleCounter + 1;

            if(cycleCounter == 5)
            {

                send I1, MainGreen;

            }

            if(cycleCounter == 10)
            {

                send I2, MainGreen;

            }

            if(cycleCounter >= 30)
            {

                cycleCounter = 0;

            }

        }

        on DisableGreenWave do
        {

            greenWaveEnabled = false;

            goto Running;

        }

    }

    ///////////////////////////////////////////////////////////
    // SENSOR EVENTS
    ///////////////////////////////////////////////////////////

    on NorthVehicleDetected do
    {

        northVehicles = northVehicles + 1;

        northQueue = northQueue + 1;

    }

    on SouthVehicleDetected do
    {

        southVehicles = southVehicles + 1;

        southQueue = southQueue + 1;

    }

    on EastVehicleDetected do
    {

        eastVehicles = eastVehicles + 1;

        eastQueue = eastQueue + 1;

    }

    on WestVehicleDetected do
    {

        westVehicles = westVehicles + 1;

        westQueue = westQueue + 1;

    }

        ///////////////////////////////////////////////////////////
    // ADAPTIVE TRAFFIC CONTROL
    ///////////////////////////////////////////////////////////

    state AdaptiveControl
    {

        entry
        {

            print "===================================";
            print "ADAPTIVE CONTROL";
            print "===================================";

            cycleCounter = 0;

            averageNorth = (averageNorth + northQueue) / 2;
            averageSouth = (averageSouth + southQueue) / 2;
            averageEast  = (averageEast  + eastQueue ) / 2;
            averageWest  = (averageWest  + westQueue ) / 2;

            if((northQueue + southQueue) >
               (eastQueue + westQueue))
            {

                mainGreenTime = 45;
                crossGreenTime = 20;

            }
            else
            {

                mainGreenTime = 20;
                crossGreenTime = 45;

            }

        }

        on Tick do
        {

            cycleCounter = cycleCounter + 1;

            if(cycleCounter >= 5)
            {

                goto Running;

            }

        }

    }

    ///////////////////////////////////////////////////////////
    // TRAFFIC MONITOR
    ///////////////////////////////////////////////////////////

    state Monitor
    {

        entry
        {

            print "Traffic Monitor";

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

            if(northQueue > 30)
            {

                print "North Congestion";

            }

            if(southQueue > 30)
            {

                print "South Congestion";

            }

            if(eastQueue > 30)
            {

                print "East Congestion";

            }

            if(westQueue > 30)
            {

                print "West Congestion";

            }

        }

        on ReturnController goto Running;

    }

    ///////////////////////////////////////////////////////////
    // FAILURE MODE
    ///////////////////////////////////////////////////////////

    state FailureMode
    {

        entry
        {

            print "System Failure";

            running = false;

        }

        on Tick do
        {

            totalTicks = totalTicks + 1;

        }

        on Recover goto Recovery;

    }

    ///////////////////////////////////////////////////////////
    // RECOVERY
    ///////////////////////////////////////////////////////////

    state Recovery
    {

        entry
        {

            print "Recovering";

            cycleCounter = 0;

        }

        on Tick do
        {

            cycleCounter = cycleCounter + 1;

            if(cycleCounter >= 10)
            {

                running = true;

                goto Running;

            }

        }

    }

    ///////////////////////////////////////////////////////////
    // UPDATE STATISTICS
    ///////////////////////////////////////////////////////////

    fun UpdateStatistics()
    {

        averageNorth =
            (averageNorth + northQueue) / 2;

        averageSouth =
            (averageSouth + southQueue) / 2;

        averageEast =
            (averageEast + eastQueue) / 2;

        averageWest =
            (averageWest + westQueue) / 2;

    }

    ///////////////////////////////////////////////////////////
    // RESET QUEUES
    ///////////////////////////////////////////////////////////

    fun ResetQueues()
    {

        northQueue = 0;

        southQueue = 0;

        eastQueue = 0;

        westQueue = 0;

    }

    ///////////////////////////////////////////////////////////
    // CALCULATE GREEN TIMES
    ///////////////////////////////////////////////////////////

    fun CalculateGreenTime()
    {

        if(northQueue > 40)
        {

            mainGreenTime = 60;

        }

        if(southQueue > 40)
        {

            mainGreenTime = 60;

        }

        if(eastQueue > 40)
        {

            crossGreenTime = 60;

        }

        if(westQueue > 40)
        {

            crossGreenTime = 60;

        }

        if(northQueue < 10 &&
           southQueue < 10)
        {

            mainGreenTime = 20;

        }

        if(eastQueue < 10 &&
           westQueue < 10)
        {

            crossGreenTime = 20;

        }

    }

    ///////////////////////////////////////////////////////////
    // EMERGENCY EVENTS
    ///////////////////////////////////////////////////////////

    on AmbulanceDetected do
    {

        ambulanceDetected = true;

        emergencyCounter = emergencyCounter + 1;

        goto Emergency;

    }

    on PoliceDetected do
    {

        policeDetected = true;

        emergencyCounter = emergencyCounter + 1;

        goto Emergency;

    }

    on FireTruckDetected do
    {

        firefighterDetected = true;

        emergencyCounter = emergencyCounter + 1;

        goto Emergency;

    }

    ///////////////////////////////////////////////////////////
    // BUS EVENTS
    ///////////////////////////////////////////////////////////

    on BusDetected do
    {

        busCounter = busCounter + 1;

        goto BusPriority;

    }

    ///////////////////////////////////////////////////////////
    // NIGHT EVENTS
    ///////////////////////////////////////////////////////////

    on EnableNightMode goto Night;

    on DisableNightMode goto Running;

    ///////////////////////////////////////////////////////////
    // MAINTENANCE EVENTS
    ///////////////////////////////////////////////////////////

    on EnableMaintenance goto Maintenance;

    on DisableMaintenance goto Running;

    ///////////////////////////////////////////////////////////
    // GREEN WAVE EVENTS
    ///////////////////////////////////////////////////////////

    on EnableGreenWave goto GreenWave;

    on DisableGreenWave goto Running;
