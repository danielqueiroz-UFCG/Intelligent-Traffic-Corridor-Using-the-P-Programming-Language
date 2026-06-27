machine VehicleLight
{
    var state: LightState;

    start state Red
    {
        entry
        {
            state = RED;
            print "RED";
        }

        on MainGreen goto Green;
        on CrossGreen goto Green;
    }

    state Green
    {
        entry
        {
            state = GREEN;
            print "GREEN";
        }

        on MainYellow goto Yellow;
        on CrossYellow goto Yellow;
    }

    state Yellow
    {
        entry
        {
            state = YELLOW;
            print "YELLOW";
        }

        on MainRed goto Red;
        on CrossRed goto Red;
    }
}
