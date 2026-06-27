//=====================================================
// VehicleLight.p
//=====================================================

machine VehicleLight
{

    var color: LightColor;

    start state Red
    {

        entry
        {
            color = RED;
            print "Vehicle RED";
        }

        on MainGreen goto Green;
        on CrossGreen goto Green;
    }

    state Green
    {

        entry
        {
            color = GREEN;
            print "Vehicle GREEN";
        }

        on MainYellow goto Yellow;
        on CrossYellow goto Yellow;
    }

    state Yellow
    {

        entry
        {
            color = YELLOW;
            print "Vehicle YELLOW";
        }

        on MainRed goto Red;
        on CrossRed goto Red;
    }

}
