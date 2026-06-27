machine PedestrianLight
{
    start state Stop
    {
        entry
        {
            print "DON'T WALK";
        }

        on Walk goto Go;
    }

    state Go
    {
        entry
        {
            print "WALK";
        }

        on DontWalk goto Stop;
    }
}
