/*
    Author: RTSR
    8/6/2022
    Gothic Online: ARPG
*/

local callTable = {};

class ModuleAPI_Call
{
    constructor(name, args, ref)
    {
        this.name       = name;
        this.args       = args;
        this.ref        = ref;

        if (!callTable.rawin(name))
            callTable[name] <- this;
        else
            ModuleAPI.Error("Function with this name is already exist (" + name + ")");
    }

    function Call(vargv)
    {
        if (vargv.len() != args)
        {
            ModuleAPI.Error("Wrong number of parameters in function " + name + " (" + vargv.len() + " != " + args + ")");
            return null;
        }

        if (typeof ref != "function")
        {
            ModuleAPI.Error("Reference in function " + name + " is not actual function (typeof = " + (typeof ref) + ")");
            return null;
        }

        local argString = "";
        for(local i = 0; i < vargv.len(); i++)
        {
            if (argString != "")
                argString += ",";
            argString += "vargv[1][" + i + "]";
        }

        local compileString     = "return vargv[0](" + argString + ");";
        local compiledFunc      = compilestring(compileString);
        return compiledFunc(ref, vargv);
    }

    name        = "";
    args        = -1;
    ref         = -1;
}

class ModuleAPI
{
    static function Add(name, args, ref)
    {
        ModuleAPI_Call(name, args, ref);
    }

    static function Call(name, ...)
    {
        if (callTable.rawin(name))
            return callTable.rawget(name).Call(vargv);
        else
            return null;
    }

    static function Error(str)
    {
        print("[ModuleAPI]: Unexpected error: " + str);
    }
}

getroottable()["ModuleAPI"] <- ModuleAPI;