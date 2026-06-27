machine Intersection
{
    var mainRoad: machine;
    var crossRoad: machine;

    var northPed: machine;
    var southPed: machine;
    var eastPed: machine;
    var westPed: machine;

    start state Init
    {
        entry
        {
            mainRoad = new VehicleLight();
            crossRoad = new VehicleLight();

            northPed = new PedestrianLight();
            southPed = new PedestrianLight();
            eastPed = new PedestrianLight();
            westPed = new PedestrianLight();

            goto Normal;
        }
    }

    state Normal
    {
        on MainGreen do
        {
            send mainRoad, MainGreen;
            send crossRoad, CrossRed;

            send northPed, DontWalk;
            send southPed, DontWalk;
            send eastPed, Walk;
            send westPed, Walk;
        }

        on CrossGreen do
        {
            send crossRoad, CrossGreen;
            send mainRoad, MainRed;

            send northPed, Walk;
            send southPed, Walk;
            send eastPed, DontWalk;
            send westPed, DontWalk;
        }

        on Emergency goto EmergencyMode;
    }

    state EmergencyMode
    {
        entry
        {
            print "Emergency";
        }

        on EmergencyEnd goto Normal;
    }
}
