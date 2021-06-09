
public Plugin myinfo = {
    name= "Reconnect",
    author  = "游而不擊 轉進如風",
    description = "Force player reconnect",
    version = "1.0",
    url = "https://github.com/gandor233"
};

#pragma semicolon 1

ConVar DEBUG;
ConVar sm_reconnect_max_interval;
ConVar sm_reconnect_when_changing_map;

enum struct PLAY_CONNECT_INFO_STRUCT
{
    int UserID;
    int AccountID;
    int LastConnectTime;
}
PLAY_CONNECT_INFO_STRUCT g_PlayerConnectInfo[2*MAXPLAYERS];

// Handle g_hOnPlayerFirstConnect;
// int g_iFullConnectClientUserIDList[MAXPLAYERS+1];
// int g_iFullConnectClientAccountIDList[MAXPLAYERS+1];
public void OnPluginStart()
{
    DEBUG = CreateConVar("reconnect_debug", "0", "(bool) Is reconnect debugging?");
    sm_reconnect_max_interval = CreateConVar("sm_reconnect_max_interval", "60", "(int) Force player reconnect maximum interval time");
    sm_reconnect_when_changing_map = CreateConVar("sm_reconnect_when_changing_map", "1", "(bool) Force player reconnect when changing map?");
    // g_hOnPlayerFirstConnect = CreateGlobalForward("OnPlayerFirstConnect", ET_Ignore, Param_Cell);
    // for (int client = 1; client <= MaxClients; client++)
    // {
    //     if (IsClientConnected(client) && IsClientInGame(client))
    //     {
    //         g_iFullConnectClientUserIDList[client] = GetClientUserId(client);
    //         g_iFullConnectClientAccountIDList[client] = GetSteamAccountID(client);
    //     }
    // }
    
    HookEvent("player_connect_full", Event_PlayerConnectFull, EventHookMode_Post);
    RegAdminCmd("listconnectinfo", Command_ListConnectInfo, ADMFLAG_ROOT);
    return;
}
public void OnMapEnd()
{
    if (sm_reconnect_when_changing_map.BoolValue)
        ClearAllConnectInfo();
}
public Action Event_PlayerConnectFull(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
    {
        if (IsPlayerFirstConnect(client))
        {
            if (DEBUG.BoolValue)
                LogMessage("[Forece Reconnecting] Client = %d - %N", client, client);
            ClientCommand(client, "retry");
            return Plugin_Continue;
        }
        
        int iUserID = GetClientUserId(client);
        int iAccountID = GetSteamAccountID(client);
        // if (g_iFullConnectClientUserIDList[client] != iUserID || g_iFullConnectClientAccountIDList[client] != iAccountID)
        // {
        //     g_iFullConnectClientUserIDList[client] = iUserID;
        //     g_iFullConnectClientAccountIDList[client] = iAccountID;
        //     Call_StartForward(g_hOnPlayerFirstConnect);
        //     Call_PushCell(client);
        //     Call_Finish();
        // }
        if (DEBUG.BoolValue)
            LogMessage("[PlayerConnectFull] Client = %d - %N | iUserID = %d | iAccountID = %d", client, client, iUserID, iAccountID);
    }
    
    return Plugin_Continue;
}
public Action Command_ListConnectInfo(int client, int args)
{
    for (int i = 0; i < sizeof(g_PlayerConnectInfo); i++)
    {
        int clients = GetClientOfUserId(g_PlayerConnectInfo[i].UserID);
        LogMessage("[%d] IsClientConnected %d | UserID: %d | AccountID: %d", i, (clients>0)?view_as<int>(IsClientConnected(clients)):0, g_PlayerConnectInfo[i].UserID, g_PlayerConnectInfo[i].AccountID);
    }
    
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
    {
        for (int i = 0; i < sizeof(g_PlayerConnectInfo); i++)
        {
            int clients = GetClientOfUserId(g_PlayerConnectInfo[i].UserID);
            PrintToConsole(client, "[%d] IsClientConnected %d | UserID: %d | AccountID: %d", i, (clients>0)?view_as<int>(IsClientConnected(clients)):0, g_PlayerConnectInfo[i].UserID, g_PlayerConnectInfo[i].AccountID);
        }
    }
    
    return Plugin_Handled;
}

public bool IsPlayerFirstConnect(int client)
{
    bool bIsPlayerFirstConnect = true;
    int iUserID = GetClientUserId(client);
    int iAccountID = GetSteamAccountID(client);
    for (int i = 0; i < sizeof(g_PlayerConnectInfo); i++)
    {
        if (g_PlayerConnectInfo[i].AccountID == iAccountID)
        {
            if (g_PlayerConnectInfo[i].UserID == iUserID)
                bIsPlayerFirstConnect = false;
            else if (GetTime() - g_PlayerConnectInfo[i].LastConnectTime < sm_reconnect_max_interval.IntValue)
                bIsPlayerFirstConnect = false; 
                
            if (DEBUG.BoolValue)
                LogMessage("[IsPlayerFirstConnect] %s | FOUND | Client = %d | TimeSinceLastConnect = %d | iUserID = %d | iAccountID = %d", bIsPlayerFirstConnect?"YES":"NO", client, GetTime() - g_PlayerConnectInfo[i].LastConnectTime, iUserID, iAccountID);
            
            g_PlayerConnectInfo[i].UserID = iUserID;
            g_PlayerConnectInfo[i].LastConnectTime = GetTime();
            return bIsPlayerFirstConnect;
        }
    }

    AddPlayerConnectInfo(iUserID, iAccountID);
    return bIsPlayerFirstConnect;
}
public int AddPlayerConnectInfo(int iUserID, int iAccountID)
{
    static int iPoint = 0;
    for (int i = iPoint+1; i != iPoint; i++)
    {
        if (i >= sizeof(g_PlayerConnectInfo))
            i = 0;
        
        int client = GetClientOfUserId(g_PlayerConnectInfo[i].UserID);
        if (client <= 0 || !IsClientConnected(client) || g_PlayerConnectInfo[i].AccountID == iAccountID)
        {
            g_PlayerConnectInfo[i].UserID = iUserID;
            g_PlayerConnectInfo[i].AccountID = iAccountID;
            g_PlayerConnectInfo[i].LastConnectTime = GetTime();
            if (DEBUG.BoolValue)
                LogMessage("[IsPlayerFirstConnect] %s | ADD | Client = %d | SettingConnectTime | iUserID = %d | iAccountID = %d", "YES", client, iUserID, iAccountID);
            iPoint = i;
            return i;
        }
    }
    return -1;
}
public void ClearAllConnectInfo()
{
    LogMessage("[Reconnecting] ClearAllConnectInfo......");
    for (int i = 0; i < sizeof(g_PlayerConnectInfo); i++)
    {
        g_PlayerConnectInfo[i].UserID = 0;
        g_PlayerConnectInfo[i].AccountID = 0;
        g_PlayerConnectInfo[i].LastConnectTime = 0;
    }
    return;
}