machine Timer
{
    var controller: machine;

    start state Running
    {
        entry(payload: machine)
        {
            controller = payload;

            while(true)
            {
                send controller, Tick;
            }
        }
    }
}
