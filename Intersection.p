//============================================================
// Intersection.p
//============================================================

machine Intersection
{

    var id:int;

    // Semáforos veiculares
    var northVehicle:machine;
    var southVehicle:machine;
    var eastVehicle:machine;
    var westVehicle:machine;

    // Semáforos de pedestres
    var northPedestrian:machine;
    var southPedestrian:machine;
    var eastPedestrian:machine;
    var westPedestrian:machine;

    var emergency:bool;
    var busPriority:bool;

    //--------------------------------------------------------

    start state Init
    {

        entry(payload:int)
        {

            id = payload;

            emergency = false;
            busPriority = false;

            northVehicle = new VehicleLight();
            southVehicle = new VehicleLight();

            eastVehicle = new VehicleLight();
            westVehicle = new VehicleLight();

            northPedestrian = new PedestrianLight();
            southPedestrian = new PedestrianLight();

            eastPedestrian = new PedestrianLight();
            westPedestrian = new PedestrianLight();

            goto MainRoadGreen;

        }

    }

    //--------------------------------------------------------

    state MainRoadGreen
    {

        entry
        {

            send eastVehicle, MainGreen;
            send westVehicle, MainGreen;

            send northVehicle, MainRed;
            send southVehicle, MainRed;

            send northPedestrian, Walk;
            send southPedestrian, Walk;

            send eastPedestrian, DontWalk;
            send westPedestrian, DontWalk;

            print format("Intersection {0}: MAIN GREEN", id);

        }

        on PhaseFinished goto MainRoadYellow;

        on EmergencyStart goto EmergencyMode;

    }

    //--------------------------------------------------------

    state MainRoadYellow
    {

        entry
        {

            send eastVehicle, MainYellow;
            send westVehicle, MainYellow;

            print format("Intersection {0}: MAIN YELLOW", id);

        }

        on PhaseFinished goto CrossRoadGreen;

        on EmergencyStart goto EmergencyMode;

    }

    //--------------------------------------------------------

    state CrossRoadGreen
    {

        entry
        {

            send eastVehicle, MainRed;
            send westVehicle, MainRed;

            send northVehicle, CrossGreen;
            send southVehicle, CrossGreen;

            send eastPedestrian, Walk;
            send westPedestrian, Walk;

            send northPedestrian, DontWalk;
            send southPedestrian, DontWalk;

            print format("Intersection {0}: CROSS GREEN", id);

        }

        on PhaseFinished goto CrossRoadYellow;

        on EmergencyStart goto EmergencyMode;

    }

    //--------------------------------------------------------

    state CrossRoadYellow
    {

        entry
        {

            send northVehicle, CrossYellow;
            send southVehicle, CrossYellow;

            print format("Intersection {0}: CROSS YELLOW", id);

        }

        on PhaseFinished goto MainRoadGreen;

        on EmergencyStart goto EmergencyMode;

    }

    //--------------------------------------------------------

    state EmergencyMode
    {

        entry
        {

            emergency = true;

            print format("Intersection {0}: EMERGENCY", id);

        }

        on AmbulanceDetected do
        {

            send northVehicle, MainRed;
            send southVehicle, MainRed;

            send eastVehicle, MainGreen;
            send westVehicle, MainGreen;

        }

        on PoliceDetected do
        {

            send northVehicle, CrossGreen;
            send southVehicle, CrossGreen;

            send eastVehicle, MainRed;
            send westVehicle, MainRed;

        }

        on FireTruckDetected do
        {

            send northVehicle, CrossGreen;
            send southVehicle, CrossGreen;

            send eastVehicle, MainRed;
            send westVehicle, MainRed;

        }

        on EmergencyEnd goto MainRoadGreen;

    }

}
