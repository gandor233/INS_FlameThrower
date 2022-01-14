#include <sourcemod>
 
enum MsgCode
{
    MSG_INFO = 0,
    MSG_SUCCESS,
    MSG_FAILURE,
    MSG_HINT
};
 
const int _bufSize = 256;
 
static char _msg[ _bufSize ] = { 0 };
 
static ConVar _cvarEnable = null;
 
static ConVar _cvarRequiredConVarName = null;
 
static void _DebugMsg( MsgCode code, const char[] msg )
{
    char basePrefix[] = "[lol_reconnect]";
 
    char codePrefix[][] =
    {
        "[info]",
        "[success]",
        "[failure]",
        "[hint]"
    }
 
    PrintToServer( "%s %s %s", basePrefix, codePrefix[ code ], msg );
}
 
static void _OnConVarQueryFinished( QueryCookie cookie, int client, ConVarQueryResult result,
                                    const char[] cvarName, const char[] cvarValue,
                                    any value )
{
    if ( result > ConVarQuery_Okay )
    {
        return;
    }
 
    char clientName[ _bufSize ] = { 0 };
    GetClientName( client, clientName, sizeof( clientName ) );
 
    ConVar serverCvar = FindConVar( cvarName );
 
    char serverCvarValue[ _bufSize ] = { 0 };
    serverCvar.GetString( serverCvarValue, sizeof( serverCvarValue ) );
 
    if ( !StrEqual( cvarValue, serverCvarValue ) )
    {
        Format( _msg, sizeof( _msg ), "client \"%s\": convar value mismatched, reconnecting...",
                clientName, cvarValue );
        _DebugMsg( MSG_INFO, _msg );
 
        ClientCommand( client, "retry" );
    }
    else
    {
        Format( _msg, sizeof( _msg ), "client \"%s\": convar value matched, skipping...",
                clientName, cvarValue );
        _DebugMsg( MSG_INFO, _msg );
    }
}
 
static Action _Event_PlayerConnectFull( Event event, const char[] name, bool dontBroadcast )
{
    int userid = event.GetInt( "userid" );
    int client = GetClientOfUserId( userid );
 
    if ( !client )
    {
        return Plugin_Continue;
    }
 
    if ( IsFakeClient( client ) )
    {
        return Plugin_Continue;
    }
 
    if ( !_cvarEnable.BoolValue )
    {
        return Plugin_Continue;
    }
 
    char requiredConVarName[ _bufSize ];
    _cvarRequiredConVarName.GetString( requiredConVarName, sizeof( requiredConVarName ) );
 
    QueryClientConVar( client, requiredConVarName, _OnConVarQueryFinished );
 
    return Plugin_Continue;
}
 
public Plugin myinfo =
{
    name = "LOL Reconnect",
    author = "LOL Clan",
    description = "Reconnects players to correctly load workshop item",
    version = "2.0",
    url = "https://insurgency2.store/"
};
 
public void OnPluginStart()
{
    HookEvent( "player_connect_full", _Event_PlayerConnectFull, EventHookMode_Post );
 
    _cvarEnable = CreateConVar( "lol_reconnect_enable", "1",
                                "Enable reconnecting players to make them load workshop item correctly",
                                0 );
 
    _cvarRequiredConVarName = CreateConVar( "lol_reconnect_requiredcvar_name", "mp_theater_override",
                                            "Required convar name to check",
                                            0 );
}