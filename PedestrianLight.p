//=====================================================
// PedestrianLight.p
//=====================================================

machine PedestrianLight
{

    /////////////////////////////////////////////////////
    // VARIÁVEIS
    /////////////////////////////////////////////////////

    var enabled: bool;
    var emergency: bool;
    var maintenance: bool;
    var blinking: bool;

    var walkTime: int;
    var blinkTime: int;
    var stopTime: int;

    var counter: int;
    var totalCycles: int;

    /////////////////////////////////////////////////////
    // ESTADO INICIAL
    /////////////////////////////////////////////////////

    start state Init
    {

        entry
        {

            print "Initializing Pedestrian Light";

            enabled = true;
            emergency = false;
            maintenance = false;
            blinking = false;

            walkTime = 20;
            blinkTime = 5;
            stopTime = 30;

            counter = 0;
            totalCycles = 0;

            goto Stop;

        }

    }

    /////////////////////////////////////////////////////
    // STOP
    /////////////////////////////////////////////////////

    state Stop
    {

        entry
        {

            print "DON'T WALK";

            counter = 0;

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter >= stopTime)
            {

                goto Walk;

            }

        }

        on Walk goto Walk;

        on EmergencyStart goto EmergencyMode;

        on MaintenanceStart goto MaintenanceMode;

    }

    /////////////////////////////////////////////////////
    // WALK
    /////////////////////////////////////////////////////

    state Walk
    {

        entry
        {

            print "WALK";

            counter = 0;

            totalCycles = totalCycles + 1;

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter >= walkTime)
            {

                goto Blinking;

            }

        }

        on DontWalk goto Stop;

        on EmergencyStart goto EmergencyMode;

        on MaintenanceStart goto MaintenanceMode;

    }

    /////////////////////////////////////////////////////
    // BLINKING
    /////////////////////////////////////////////////////

    state Blinking
    {

        entry
        {

            print "FLASHING WALK";

            blinking = true;

            counter = 0;

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter >= blinkTime)
            {

                blinking = false;

                goto Stop;

            }

        }

        on EmergencyStart goto EmergencyMode;

    }

    /////////////////////////////////////////////////////
    // EMERGENCY MODE
    /////////////////////////////////////////////////////

    state EmergencyMode
    {

        entry
        {

            emergency = true;

            print "PEDESTRIAN EMERGENCY";

            counter = 0;

        }

        on Tick do
        {

            counter = counter + 1;

        }

        on EmergencyEnd do
        {

            emergency = false;

            goto Stop;

        }

    }

        /////////////////////////////////////////////////////
    // MAINTENANCE MODE
    /////////////////////////////////////////////////////

    state MaintenanceMode
    {

        entry
        {

            maintenance = true;

            counter = 0;

            print "PEDESTRIAN MAINTENANCE MODE";

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter % 5 == 0)
            {

                print "Maintenance Check";

            }

        }

        on MaintenanceEnd do
        {

            maintenance = false;

            goto Stop;

        }

    }

    /////////////////////////////////////////////////////
    // NIGHT MODE
    /////////////////////////////////////////////////////

    state NightMode
    {

        entry
        {

            print "PEDESTRIAN NIGHT MODE";

            blinking = true;

            counter = 0;

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter % 2 == 0)
            {

                print "FLASH";

            }
            else
            {

                print "OFF";

            }

        }

        on DayMode goto Stop;

    }

    /////////////////////////////////////////////////////
    // SELF TEST
    /////////////////////////////////////////////////////

    state SelfTest
    {

        entry
        {

            print "Running Self Test";

            counter = 0;

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter == 1)
            {

                print "Testing RED";

            }

            if(counter == 2)
            {

                print "Testing GREEN";

            }

            if(counter == 3)
            {

                print "Testing FLASH";

            }

            if(counter >= 4)
            {

                goto Stop;

            }

        }

    }

    /////////////////////////////////////////////////////
    // FAILURE MODE
    /////////////////////////////////////////////////////

    state Failure
    {

        entry
        {

            enabled = false;

            print "PEDESTRIAN FAILURE";

        }

        on Tick do
        {

            print "Waiting Recovery";

        }

        on Recover goto Recovery;

    }

    /////////////////////////////////////////////////////
    // RECOVERY
    /////////////////////////////////////////////////////

    state Recovery
    {

        entry
        {

            print "Recovering Pedestrian Light";

            counter = 0;

        }

        on Tick do
        {

            counter = counter + 1;

            if(counter >= 5)
            {

                enabled = true;

                goto Stop;

            }

        }

    }

    /////////////////////////////////////////////////////
    // SENSOR EVENTS
    /////////////////////////////////////////////////////

    on PedestrianDetected do
    {

        print "Pedestrian Waiting";

    }

    on CrossingFinished do
    {

        print "Crossing Completed";

    }

    /////////////////////////////////////////////////////
    // STATISTICS
    /////////////////////////////////////////////////////

    fun ResetStatistics()
    {

        totalCycles = 0;

    }

    fun IncrementCycle()
    {

        totalCycles = totalCycles + 1;

    }

    fun Diagnostics()
    {

        print "---------------";

        print "Enabled";
        print enabled;

        print "Emergency";
        print emergency;

        print "Maintenance";
        print maintenance;

        print "Blinking";
        print blinking;

        print "Cycles";
        print totalCycles;

        print "Counter";
        print counter;

        print "---------------";

    }

    /////////////////////////////////////////////////////
    // SAFETY
    /////////////////////////////////////////////////////

    fun VerifySafety()
    {

        assert(walkTime > 0);

        assert(stopTime > 0);

        assert(blinkTime > 0);

        assert(counter >= 0);

    }

    /////////////////////////////////////////////////////
    // PERIODIC TASKS
    /////////////////////////////////////////////////////

    on Tick do
    {

        VerifySafety();

        if(counter % 10 == 0)
        {

            Diagnostics();

        }

    }

    /////////////////////////////////////////////////////
    // RESET
    /////////////////////////////////////////////////////

    fun Reset()
    {

        enabled = true;

        emergency = false;

        maintenance = false;

        blinking = false;

        counter = 0;

    }

}
