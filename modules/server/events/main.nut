/*
    Author: RTSR
    8/6/2022
    Gothic Online: ARPG
*/

// Registering new Init events
addEvent("onPreInit");
addEvent("onPostInit");

addEventHandler("onInit", function()
{
    callEvent("onPreInit");
    callEvent("onPostInit");
});