machine TrafficController
{
    var I1: machine;
    var I2: machine;

    var phase:int;

    start state Init
    {
        entry
        {
            I1 = new Intersection();
            I2 = new Intersection();

            phase = 0;

            goto Running;
        }
    }

    state Running
    {
        on Tick do
        {
            if(phase == 0)
            {
                send I1, MainGreen;
                send I2, CrossGreen;

                phase = 1;
            }
            else
            {
                send I1, CrossGreen;
                send I2, MainGreen;

                phase = 0;
            }
        }

        on BusDetected do
        {
            print "Priority Bus";
        }

        on Emergency do
        {
            send I1, Emergency;
            send I2, Emergency;
        }

        on EmergencyEnd do
        {
            send I1, EmergencyEnd;
            send I2, EmergencyEnd;
        }
    }
}
