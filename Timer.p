/////////////////////////////////////////////////////////////
// Timer.p
/////////////////////////////////////////////////////////////

machine Timer
{

    /////////////////////////////////////////////////////////
    // VARIÁVEIS
    /////////////////////////////////////////////////////////

    var controller: machine;

    var running: bool;
    var paused: bool;
    var maintenance: bool;

    var tickCounter: int;
    var secondCounter: int;
    var minuteCounter: int;

    var timerInterval: int;

    var watchdogCounter: int;

    var generatedTicks: int;

    /////////////////////////////////////////////////////////
    // ESTADO INICIAL
    /////////////////////////////////////////////////////////

    start state Init
    {

        entry(payload: machine)
        {

            print "================================";

            print "Initializing Timer";

            print "================================";

            controller = payload;

            running = false;

            paused = false;

            maintenance = false;

            tickCounter = 0;

            secondCounter = 0;

            minuteCounter = 0;

            watchdogCounter = 0;

            generatedTicks = 0;

            timerInterval = 1;

            goto Idle;

        }

    }

    /////////////////////////////////////////////////////////
    // IDLE
    /////////////////////////////////////////////////////////

    state Idle
    {

        entry
        {

            print "Timer Idle";

        }

        on StartTimer goto Running;

    }

    /////////////////////////////////////////////////////////
    // RUNNING
    /////////////////////////////////////////////////////////

    state Running
    {

        entry
        {

            running = true;

            print "Timer Running";

        }

        on Tick do
        {

            tickCounter = tickCounter + 1;

            generatedTicks = generatedTicks + 1;

            watchdogCounter = watchdogCounter + 1;

            send controller, Tick;

            if(tickCounter >= timerInterval)
            {

                tickCounter = 0;

                secondCounter = secondCounter + 1;

            }

            if(secondCounter >= 60)
            {

                secondCounter = 0;

                minuteCounter = minuteCounter + 1;

            }

            if(watchdogCounter >= 100)
            {

                send this, Watchdog;

            }

        }

        on PauseTimer goto Paused;

        on MaintenanceStart goto MaintenanceMode;

        on StopTimer goto Stopped;

    }

    /////////////////////////////////////////////////////////
    // PAUSED
    /////////////////////////////////////////////////////////

    state Paused
    {

        entry
        {

            paused = true;

            print "Timer Paused";

        }

        on ResumeTimer do
        {

            paused = false;

            goto Running;

        }

        on StopTimer goto Stopped;

    }

    /////////////////////////////////////////////////////////
    // STOPPED
    /////////////////////////////////////////////////////////

    state Stopped
    {

        entry
        {

            running = false;

            print "Timer Stopped";

        }

        on StartTimer goto Running;

    }

    /////////////////////////////////////////////////////////
    // MAINTENANCE
    /////////////////////////////////////////////////////////

    state MaintenanceMode
    {

        entry
        {

            maintenance = true;

            print "Timer Maintenance";

            watchdogCounter = 0;

        }

        on Tick do
        {

            watchdogCounter = watchdogCounter + 1;

            if(watchdogCounter % 10 == 0)
            {

                print "Maintenance Check";

            }

        }

        on MaintenanceEnd do
        {

            maintenance = false;

            goto Running;

        }

    }

    /////////////////////////////////////////////////////////
    // WATCHDOG
    /////////////////////////////////////////////////////////

    state Watchdog
    {

        entry
        {

            print "Watchdog Activated";

            watchdogCounter = 0;

        }

        on Tick do
        {

            watchdogCounter = watchdogCounter + 1;

            if(watchdogCounter >= 5)
            {

                goto Running;

            }

        }

    }
