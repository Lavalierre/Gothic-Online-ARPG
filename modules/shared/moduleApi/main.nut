/*
    Author: RTSR
    8/6/2022
    Gothic Online: ARPG
*/

local callTable = {};

class ModuleAPI_Call
{
    constructor(name, args, ref, env)
    {
        this.name       = name;
        this.args       = args + 1;
        this.ref        = ref;
        this.env        = env;

        if (!callTable.rawin(name))
            callTable[name] <- this;
        else
            ModuleAPI.Error("Function with this name is already exist (" + name + ")");
    }

    function Call(vargv)
    {
        vargv.insert(0, env);
        local end = vargv.len();

        if (end != args)
        {
            ModuleAPI.Error("Wrong number of parameters in function " + name + " (expecting " + (args - 1) + ")");
            return null;
        }

        if (typeof ref != "function")
        {
            ModuleAPI.Error("Reference in function " + name + " is not an actual function (typeof: " + (typeof ref) + ")");
            return null;
        }

        return ref.acall(vargv);
    }

    name        = "";
    args        = -1;
    ref         = -1;
    env         = -1;
}

class ModuleAPI
{
    static function Add(name, args, ref, env = getroottable())
    {
        ModuleAPI_Call(name, args, ref, env);
    }

    static function Call(name, ...)
    {
        if (name in callTable)
            return callTable[name].Call(vargv);
        else
            return null;
    }

    static function Error(str)
    {
        print("[ModuleAPI]: Unexpected error: " + str);
    }
}