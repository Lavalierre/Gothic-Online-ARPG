/*
    8/5/2022
    Author: RTSR
    Gothic Online: ARPG
*/

MYSQL_MAN <- -1;

class MySQL
{
    constructor()
    {
        o_handler = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB, MYSQL_PORT);
        if (o_handler == null)
            Error("Error while trying to connect to the MySQL database!", -1);
        else
        {
            mysql_set_character_set(o_handler, "CP1251");
            print("[MySQL Module]: Successfully connected to the MySQL database!");
        }
    }

    o_handler = -1;

    static function get() { return MYSQL_MAN; }
    function handler() { return o_handler; }
}

// This method is calling by other methods, but not by the user himself
function MySQL::Error(error_string, error_id)
{
    print(format("[MySQL Module]: Unexpected error: %s (error id: %d)", error_string, error_id));
}

// This method makes a query to db and handles errors (return null in case of it)
function MySQL::Query(query_string)
{
    if (typeof query_string != "string")
        return null;
    
    local _query = mysql_query(o_handler, query_string);
    local _error = mysql_errno(o_handler);
    if (_error != 0)
    {
        Error(mysql_error(o_handler), _error);
        return null;
    }
    else
        return _query;
}

function MySQL::Insert(tab_name, names, values)
{
    local _query = -1;
    
    if (typeof tab_name != "string" ||
        typeof names    != "array"  ||
        typeof values   != "array")
        return null;

    foreach(i, val in names)
    {
        if (typeof val != "string") continue;

        if (_query == -1)
            _query = "INSERT INTO " + tab_name + " (" + val;
        else
            _query += "," + val;
    }

    _query += ") VALUES (";

    foreach(i, val in values)
    {
        if (typeof val != "string") continue;

        if (i != 0)
            _query += ",";
        
        _query += "'" + val + "'";
    }

    _query += ")";

    return Query(_query);
}

function MySQL::Update(tab_name, condition, set)
{
    if (typeof tab_name     != "string" ||
        typeof condition    != "string" ||
        typeof set          != "array")
        return null;
    
    local _query = -1;

    foreach(i, val in set)
    {
        if (typeof val != "string") continue;

        if (_query == -1)
            _query = "UPDATE " + tab_name + " SET " + val;
        else
            _query += "," + val;
    }

    _query += " " + condition;

    return Query(_query);
}

// *** EVENT HANDLING *** //

addEventHandler("onPreInit", function()
{
    MYSQL_MAN = MySQL();
    callEvent("MySQL.onInit");
    MYSQL_MAN.CreateDump();
});