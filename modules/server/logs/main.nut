/*
    Author: RTSR
    8/6/2022
    Gothic Online: ARPG
*/

class Logs
{

    static function Entry(type, sender, message);
    static function CreateDump();
}

function Logs::Entry(type, sender, message)
{
    ModuleAPI.Call("MySQL.Insert", "logs", ["type", "sender", "message"], [type, sender, message]);
}