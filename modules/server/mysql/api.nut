/*
    8/5/2022
    Author: RTSR
    Gothic Online: ARPG
*/

// Events
addEvent("MySQL.onDumpCreate");
addEvent("MySQL.onInit");

// Functions

addEventHandler("MySQL.onInit", function()
{
    ModuleAPI.Add("MySQL.Query", 1, MySQL.get().Query, MySQL.get());
    ModuleAPI.Add("MySQL.Insert", 3, MySQL.get().Insert, MySQL.get());
});