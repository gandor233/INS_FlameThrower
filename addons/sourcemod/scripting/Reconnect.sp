
public Plugin myinfo = {
    name= "Reconnect",
    author  = "游而不擊 轉進如風",
    description = "Force player reconnect",
    version = "1.0",
    url = "https://github.com/gandor233"
};

#pragma semicolon 1

ConVar DEBUG;
ConVar sm_firstconnect_forward_enable;

enum struct PLAY_CONNECT_INFO_STRUCT
{
    int userid;
    int account;
}
PLAY_CONNECT_INFO_STRUCT g_PlayerConnectInfo[MAXPLAYERS];

bool g_bPlayerNeedReconnect[MAXPLAYERS+1];
int g_iPlayerLastReconnectTime[MAXPLAYERS+1];

Handle g_hOnPlayerFirstConnect;
int g_iFullConnectClientAccountIDList[MAXPLAYERS+1];
int g_iFullConnectClientUserIDList[MAXPLAYERS+1];

// This is a global forward. you can use it in other plugin if you running this plugin.
public void OnPlayerFirstConnect(int client)
{
    if (IsValidClient(client))
    {
        int iUserID = GetClientUserId(client);
        int iAccountID = GetSteamAccountID(client);
        if (DEBUG.BoolValue)
            PrintToServer("[OnPlayerFirstConnect] Client = %d | Time = %0.2f | iUserID = %d | iAccountID = %d", client, GetEngineTime(), iUserID, iAccountID);
    }
    return;
}

public void OnPluginStart()
{
    DEBUG = CreateConVar("reconnect_debug", "0", "(bool) Is reconnect debugging?");
    sm_firstconnect_forward_enable = CreateConVar("sm_firstconnect_forward_enable", "1", "(bool) Is first connect global forward enable?");
    g_hOnPlayerFirstConnect = CreateGlobalForward("OnPlayerFirstConnect", ET_Ignore, Param_Cell);
    HookEvent("player_connect_full", Event_PlayerConnectFull, EventHookMode_Post);
    
    for (int client = 0; client <= MaxClients; client++)
    {
        if (IsValidClient(client))
        {
            int iUserID = GetClientUserId(client);
            int iAccountID = GetSteamAccountID(client);
            AddPlayerConnectInfo(iUserID, iAccountID);
            g_iFullConnectClientUserIDList[client] = iUserID;
            g_iFullConnectClientAccountIDList[client] = iAccountID;
        }
    }
    
    return;
}
public void OnClientPutInServer(int client)
{
    if (IsValidClient(client))
    {
        if (IsPlayerFirstConnect(client))
            g_bPlayerNeedReconnect[client] = true;
        else
            g_bPlayerNeedReconnect[client] = false;
    }
    
    return;
}
public Action Event_PlayerConnectFull(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        if (g_bPlayerNeedReconnect[client])
        {
            g_bPlayerNeedReconnect[client] = false;
            g_iPlayerLastReconnectTime[client] = GetTime();
            if (DEBUG.BoolValue)
                PrintToServer("[Forece Reconnecting] Client = %d", client);
            ClientCommand(client, "retry");
            return Plugin_Continue;
        }
        
        int iUserID = GetClientUserId(client);
        int iAccountID = GetSteamAccountID(client);
        if (DEBUG.BoolValue)
            PrintToServer("[PlayerConnectFull] Client = %d | Time = %0.2f | iUserID = %d | iAccountID = %d", client, GetEngineTime(), iUserID, iAccountID);
        if (g_iFullConnectClientUserIDList[client] != iUserID || g_iFullConnectClientAccountIDList[client] != iAccountID)
        {
            g_iFullConnectClientUserIDList[client] = iUserID;
            g_iFullConnectClientAccountIDList[client] = iAccountID;
            if (sm_firstconnect_forward_enable.BoolValue)
            {
                Call_StartForward(g_hOnPlayerFirstConnect);
                Call_PushCell(client);
                Call_Finish();
            }
        }
    }
    
    return Plugin_Continue;
}

public bool IsPlayerFirstConnect(int client)
{
    bool bIsPlayerFirstConnect = true;
    int iUserID = GetClientUserId(client);
    int iAccountID = GetSteamAccountID(client);
    for (int i = 0; i < MaxClients; i++)
    {
        if (g_PlayerConnectInfo[i].account == iAccountID)
        {
            if (g_PlayerConnectInfo[i].userid == iUserID)
                bIsPlayerFirstConnect = false;
            else if (GetTime() - g_iPlayerLastReconnectTime[client] < 150)
                bIsPlayerFirstConnect = false; 
        }
    }
    if (DEBUG.BoolValue)
        PrintToServer("[IsPlayerFirstConnect] Client = %d | %s | Time = %0.2f | iUserID = %d | iAccountID = %d", client, bIsPlayerFirstConnect?"YES":"NO", GetEngineTime(), iUserID, iAccountID);
    AddPlayerConnectInfo(iUserID, iAccountID);
    return bIsPlayerFirstConnect;
}
public int AddPlayerConnectInfo(int iUserID, int iAccountID)
{
    static int iPoint = 0;
    g_PlayerConnectInfo[iPoint].userid = iUserID;
    g_PlayerConnectInfo[iPoint].account = iAccountID;
    if (++iPoint >= sizeof(g_PlayerConnectInfo))
        iPoint = 0;
    return iPoint;
}
stock bool IsValidClient(int client)
{
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
        return true;

    return false;
}