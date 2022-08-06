/*
    Author: RTSR
    8/6/2022
    Gothic Online: ARPG
*/

function Logs::CreateDump()
{
    ModuleAPI.Call("MySQL.Query", @"CREATE TABLE IF NOT EXISTS logs (
        `ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        type VARCHAR(24),
        sender VARCHAR(32),
        message TEXT
    );");
}

addEventHandler("MySQL.onDumpCreate", Logs.CreateDump);