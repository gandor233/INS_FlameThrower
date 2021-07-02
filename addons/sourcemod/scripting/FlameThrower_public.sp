/*
 * @Description: Models and scripts are modified by axotn1k
 * @Author: Gandor
 * @Github: https://github.com/gandor233
 */
#define PLUGIN_NAME "Flamethrower"
#define PLUGIN_VERSION "Public 2.6"
public Plugin myinfo = 
{
    name = "Flamethrower",
    author = "游而不擊 轉進如風",
    description = "FlameThrower plugin for insurgency(2014)",
    version = PLUGIN_VERSION,
    url = "https://github.com/gandor233"
};

#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

// Team
#define NO_TEAM 0
#define TEAM_SPEC 1
#define TEAM_1_SEC 2
#define TEAM_2_INS 3
#define TEAM_ALL 4
#define MAX_TEAM 5
// Player input
#define MAX_BUTTONS         32
#define INPUT_ATTACK        (1 << 0)     //  (鼠左)     开火
#define INPUT_JUMP          (1 << 1)     //  (空格)     跳
#define INPUT_DUCK          (1 << 2)     //  (CTRL)     蹲下
#define INPUT_PRONE         (1 << 3)     //  (Z)        趴下 prostrate
#define INPUT_FORWARD       (1 << 4)     //  (W)        向前移动
#define INPUT_BACKWARD      (1 << 5)     //  (S)        向后移动
#define INPUT_USE           (1 << 6)     //  (F)        使用
#define INPUT_MOVELEFT      (1 << 9)     //  (A)        向左移动
#define INPUT_MOVERIGHT     (1 << 10)    //  (D)        向右移动
#define INPUT_RELOAD        (1 << 11)    //  (R)        换弹
#define INPUT_FIREMODE      (1 << 12)    //  (X)        开火模式
#define INPUT_LEANLEFT      (1 << 13)    //  (Q)        左侧身
#define INPUT_LEANRIGHT     (1 << 14)    //  (E)        右侧身
#define INPUT_SPRINT        (1 << 15)    //  (SHIFT)    屏息、冲刺跑（按住）
#define INPUT_WALK          (1 << 16)    //  (ALT)      静步（按住）
#define INPUT_MOUSE3        (1 << 17)    //  (鼠中)     特殊开火
#define INPUT_AIM           (1 << 18)    //  (鼠右)     瞄准（按住）
#define INPUT_TAB           (1 << 19)    //  (TAB)      排名
#define INPUT_BULLRUSH      (1 << 22)    //  (G)        手电筒、激光
#define INPUT_WALK_L        (1 << 25)    //  (ALT)      静步（切换）
#define INPUT_SPRINT_L      (1 << 26)    //  (SHIFT)    屏息、冲刺跑（切换）
#define INPUT_AIM_L         (1 << 27)    //  (鼠右)     瞄准（切换）
#define INPUT_ACCESSORY     (1 << 28)    //  (B)        使用配件(夜视仪)
#define INPUT_ATTITUDE      (1 << 29)    //  ()         改变姿态
// Player Flags
#define INS_PF_AIM           (1 << 0)     // 0瞄准                 // 1       // Force to zoom
#define INS_PF_BIPOD         (1 << 1)     // 1脚架                 // 2       // Using biood
#define INS_PF_RUN           (1 << 2)     // 2跑步                 // 4       // Force to run if keep setting this, player cant normal walk or slow walk
#define INS_PF_WALK          (1 << 3)     // 3静步                 // 8       // Force to walk only but player still can run just cannot normal walking
#define INS_PF_4             (1 << 4)     // 4                     // 16      // Unknow
#define INS_PF_FOCUS         (1 << 5)     // 5屏息                 // 32      // Zoom Focus (Buggy)
#define INS_PF_SLIDE         (1 << 6)     // 6滑行                 // 64      // Force to sliding, if you keep setting this, player forever sliding lol
#define INS_PF_BUYZONE       (1 << 7)     // 7购买区               // 128     // Buyzone, Resupply everywhere! (Note: Buyzone makes no friendlyfire damage)
#define INS_PF_8             (1 << 8)     // 8出生并离开过出生区域 // 256     // spawned and never left the spawn zone
#define INS_PF_BLOCKZONE     (1 << 9)     // 9禁区                 // 512     // Restricted Zone, Player will be restricted, (Note: This flag applied with INS_PF_LOWERZONE)
#define INS_PF_PUTDOWNWEAPON (1 << 10)    // 10强制放下武器        // 1024    // Weapon Lower Zone
#define INS_PF_SPAWNZONE     (1 << 11)    // 11出生区              // 2048    // ENTER SPAWN ZONE (Also can resupply)
#define INS_PF_12            (1 << 12)    // 12                    // 4096    // Unknow

bool g_bFlameThrowerIgniteEnemy;
bool g_bFlameThrowerIgniteFriend;
bool g_bFlameThrowerSelfIgnite;
float g_fFlameThrowerBurnDuration;
float g_fFlameThrowerFireInterval;
float g_fFlameThrowerEnemyDamageMultiplier;
float g_fFlameThrowerFriendDamageMultiplier;
float g_fFlameThrowerSelfDamageMultiplier;
char g_cFlameThrowerAmmoName[MAX_NAME_LENGTH];

ConVar DEBUG = null;
ConVar sm_ft_fastdl_file_path;
ConVar sm_ft_particle_file_path;
ConVar sm_ft_particle_effect_name;
ConVar sm_ft_burn_time;
ConVar sm_ft_self_ignite;
ConVar sm_ft_ignite_enemy;
ConVar sm_ft_ignite_friend;
ConVar sm_ft_ammo_class_name;
ConVar sm_ft_enemy_damage_mult;
ConVar sm_ft_friend_damage_mult;
ConVar sm_ft_self_damage_mult;
ConVar sm_ft_fire_interval;
ConVar sm_ft_sound_enable;
ConVar sm_ft_start_sound_sec;
ConVar sm_ft_loop_sound_sec;
ConVar sm_ft_end_sound_sec;
ConVar sm_ft_empty_sound_sec;
ConVar sm_ft_start_sound_ins;
ConVar sm_ft_loop_sound_ins;
ConVar sm_ft_end_sound_ins;
ConVar sm_ft_empty_sound_ins;
bool g_bIsClientFiringFlamethrower[MAXPLAYERS+1];
public void OnPluginStart()
{
    DEBUG = CreateConVar("sm_flamethrower_debug", "0", "");
    
    sm_ft_fastdl_file_path = CreateConVar("sm_ft_fastdl_file_path", "", "The path of the file you want the player to download in the fastdl server. Use \"|\" to separate. Up to 20 paths. The character length of a single path cannot exceed 512. Closed if empty.");
    sm_ft_particle_file_path = CreateConVar("sm_ft_particle_file_path", "particles/ins_flamethrower.pcf", "The path of the particle file you want server to precache. Use \"|\" to separate. Up to 20 paths. The character length of a single path cannot exceed 512. Closed if empty.");
    sm_ft_particle_effect_name = CreateConVar("sm_ft_particle_effect_name", "flamethrower", "Flamethrower fire particle effect name. Don't change it if you didn't edit the particle file.");
    sm_ft_burn_time = CreateConVar("sm_ft_burn_time", "2.0", "Burn duration");
    sm_ft_self_ignite = CreateConVar("sm_ft_self_ignite", "0", "Can player ignite himself by firing flamethrower?");
    sm_ft_ignite_enemy = CreateConVar("sm_ft_ignite_enemy", "1", "Can player ignite enemy players by firing flamethrower?");
    sm_ft_ignite_friend = CreateConVar("sm_ft_ignite_friend", "1", "Can player ignite friend players by firing flamethrower?");
    sm_ft_ammo_class_name = CreateConVar("sm_ft_ammo_class_name", "flame_proj", "Flamethrower ammo entity class name. You must set this convar if you use a different ammo class name in your theater.");
    sm_ft_self_damage_mult = CreateConVar("sm_ft_self_damage_mult", "0.2", "Flamethrower self direct damage multiplier.");
    sm_ft_enemy_damage_mult = CreateConVar("sm_ft_enemy_damage_mult", "5.0", "Flamethrower direct damage multiplier for enemies.");
    sm_ft_friend_damage_mult = CreateConVar("sm_ft_friend_damage_mult", "1.0", "Flamethrower direct damage multiplier for friends.");
    sm_ft_fire_interval = CreateConVar("sm_ft_fire_interval", "0.12", "Flamethrower launch interval. Closed if less than 0.08.");
    sm_ft_burn_time.AddChangeHook(OnConVarChanged);
    sm_ft_self_ignite.AddChangeHook(OnConVarChanged);
    sm_ft_ignite_enemy.AddChangeHook(OnConVarChanged);
    sm_ft_ignite_friend.AddChangeHook(OnConVarChanged);
    sm_ft_ammo_class_name.AddChangeHook(OnConVarChanged);
    sm_ft_enemy_damage_mult.AddChangeHook(OnConVarChanged);
    sm_ft_friend_damage_mult.AddChangeHook(OnConVarChanged);
    sm_ft_self_damage_mult.AddChangeHook(OnConVarChanged);
    sm_ft_fire_interval.AddChangeHook(OnConVarChanged);
    OnConVarChanged(null, "", "");
    
    sm_ft_sound_enable = CreateConVar("sm_ft_sound_enable", "1", "Is all plugin flamethrower fire sound enable?");
    sm_ft_start_sound_sec = CreateConVar("sm_ft_start_sound_sec", "weapons/flamethrowerno2/flamethrower_start.wav", "Flamethrower fire START sound file path for team sec. Closed if empty.");
    sm_ft_loop_sound_sec = CreateConVar("sm_ft_loop_sound_sec", "weapons/flamethrowerno2/flamethrower_looping.wav", "Flamethrower fire LOOP sound file path for team sec. Closed if empty.");
    sm_ft_end_sound_sec = CreateConVar("sm_ft_end_sound_sec", "weapons/flamethrowerno2/flamethrower_end.wav", "Flamethrower fire END sound file path for team sec. Closed if empty.");
    sm_ft_empty_sound_sec = CreateConVar("sm_ft_empty_sound_sec", "", "Flamethrower fire EMPTY sound file path for team sec. Closed if empty."); // weapons/FlamethrowerNo2/handling/flamethrower_empty.wav
    sm_ft_start_sound_ins = CreateConVar("sm_ft_start_sound_ins", "weapons/flamethrowerno41/flamethrower_start.wav", "Flamethrower fire START sound file path for team ins. Closed if empty.");
    sm_ft_loop_sound_ins = CreateConVar("sm_ft_loop_sound_ins", "weapons/flamethrowerno41/flamethrower_looping.wav", "Flamethrower fire LOOP sound file path for team ins. Closed if empty.");
    sm_ft_end_sound_ins = CreateConVar("sm_ft_end_sound_ins", "weapons/flamethrowerno41/flamethrower_end.wav", "Flamethrower fire END sound file path for team ins. Closed if empty.");
    sm_ft_empty_sound_ins = CreateConVar("sm_ft_empty_sound_ins", "", "Flamethrower fire EMPTY sound file path for team ins. Closed if empty."); // weapons/FlamethrowerNo41/handling/flamethrower_empty.wav

    HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
    HookEvent("weapon_fire_on_empty", Event_WeaponFireOnEmpty, EventHookMode_Post);
    HookEvent("player_spawn", Event_PlayerSpawnorDeath, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerSpawnorDeath, EventHookMode_Post);
    HookEvent("grenade_detonate", Event_GrenadeDetonate, EventHookMode_Post);
    HookEvent("missile_launched", Event_MissileLaunched, EventHookMode_Post);
    AddTempEntHook("World Decal", TE_OnDecal);
    AddTempEntHook("Entity Decal", TE_OnDecal);
    
    MoreFire_OnPluginStart();
    return;
}
public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bFlameThrowerSelfIgnite = sm_ft_self_ignite.BoolValue;
    g_bFlameThrowerIgniteEnemy = sm_ft_ignite_enemy.BoolValue;
    g_bFlameThrowerIgniteFriend = sm_ft_ignite_friend.BoolValue;
    g_fFlameThrowerBurnDuration = sm_ft_burn_time.FloatValue;
    g_fFlameThrowerFireInterval = sm_ft_fire_interval.FloatValue;
    g_fFlameThrowerSelfDamageMultiplier = sm_ft_self_damage_mult.FloatValue;
    g_fFlameThrowerEnemyDamageMultiplier = sm_ft_enemy_damage_mult.FloatValue;
    g_fFlameThrowerFriendDamageMultiplier = sm_ft_friend_damage_mult.FloatValue;
    sm_ft_ammo_class_name.GetString(g_cFlameThrowerAmmoName, sizeof(g_cFlameThrowerAmmoName));
    return;
}
public void OnAllPluginsLoaded()
{
    for (int client = 0; client <= MaxClients; client++)
    {
        if (IsValidClient(client))
            OnClientPutInServer(client);
    }
    return;
}
public void OnClientPutInServer(int client) 
{
    g_bIsClientFiringFlamethrower[client] = false;
    if (IsValidClient(client))
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

    MoreFire_OnClientPutInServer(client);
    return;
}
public void OnClientDisconnect(int client)
{
    g_bIsClientFiringFlamethrower[client] = false;
    StopClientFlamethrowerSound(client, true);
    return;
}
public void OnMapStart()
{
    PrecacheFile();
    MoreFire_OnMapStart();
    return;
}
public void OnMapEnd()
{
    return;
}
public void PrecacheFile()
{
    char cPathString[2048];
    sm_ft_fastdl_file_path.GetString(cPathString, sizeof(cPathString));
    if (strlen(cPathString) > 0)
    {
        char cPathList[20][512];
        int iCount = ExplodeString(cPathString, "|", cPathList, sizeof(cPathList), sizeof(cPathList[]), true);
        for (int i = 0; i < iCount; i++)
        {
            if (strlen(cPathList[i]) > 0)
            {
                AddFileToDownloadsTable(cPathList[i]);
                PrintToServer("[ %s (%s) ] Added file to downloads table - %s.", PLUGIN_NAME, PLUGIN_VERSION, cPathList[i]);
            }
        }
    }
    
    sm_ft_particle_file_path.GetString(cPathString, sizeof(cPathString));
    if (strlen(cPathString) > 0)
    {
        char cPathList[20][512];
        int iCount = ExplodeString(cPathString, "|", cPathList, sizeof(cPathList), sizeof(cPathList[]), true);
        for (int i = 0; i < iCount; i++)
        {
            if (strlen(cPathList[i]) > 0)
            {
                PrecacheParticleFile(cPathList[i]);
                PrintToServer("[ %s (%s) ] Precached Particle File - %s.", PLUGIN_NAME, PLUGIN_VERSION, cPathList[i]);
            }
        }
    }
    
    char cEffectName[2048];
    sm_ft_particle_effect_name.GetString(cEffectName, sizeof(cEffectName));
    PrecacheParticleEffect(cEffectName);
    PrintToServer("[ %s (%s) ] Precached Particle Effect - %s.", PLUGIN_NAME, PLUGIN_VERSION, cEffectName);

    PrecacheSoundByConVar(sm_ft_start_sound_sec);
    PrecacheSoundByConVar(sm_ft_loop_sound_sec);
    PrecacheSoundByConVar(sm_ft_end_sound_sec);
    PrecacheSoundByConVar(sm_ft_empty_sound_sec);
    PrecacheSoundByConVar(sm_ft_start_sound_ins);
    PrecacheSoundByConVar(sm_ft_loop_sound_ins);
    PrecacheSoundByConVar(sm_ft_end_sound_ins);
    PrecacheSoundByConVar(sm_ft_empty_sound_ins);
    return;
}

void Event_PlayerSpawnorDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    g_bIsClientFiringFlamethrower[client] = false;
    return;
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if (damage > 0)
{
        if (inflictor > MaxClients && IsValidEntity(inflictor))
        {
            if (IsValidClient(victim))
            {
                char cWeaponName[MAX_NAME_LENGTH];
                GetEdictClassname(inflictor, cWeaponName, sizeof(cWeaponName));
                if (StrContains(cWeaponName, g_cFlameThrowerAmmoName, false) > -1)
                {
                    if (attacker == victim)
                    {
                        if (g_bFlameThrowerSelfIgnite)
                            BurnPlayer(attacker, victim, g_fFlameThrowerBurnDuration);
                        damage = damage * g_fFlameThrowerSelfDamageMultiplier;
                    }
                    else
                    {
                        if (IsValidClient(attacker) && GetClientTeam(attacker) == GetClientTeam(victim))
                        {
                            if (g_bFlameThrowerIgniteFriend)
                                BurnPlayer(attacker, victim, g_fFlameThrowerBurnDuration);
                            damage = damage * g_fFlameThrowerFriendDamageMultiplier;
                        }
                        else
                        {
                            if (g_bFlameThrowerIgniteEnemy)
                                BurnPlayer(attacker, victim, g_fFlameThrowerBurnDuration);
                            damage = damage * g_fFlameThrowerEnemyDamageMultiplier;
                        }
                    }
                    
                    return Plugin_Changed;
                }
            }
        }
    }
    return Plugin_Continue;
}
public void Event_WeaponFire(Event event, char[] name, bool Broadcast)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (IsValidClient(client))
    {
        int iWeaponID = GetPlayerActiveWeapon(client);
        if (iWeaponID > MaxClients && IsValidEntity(iWeaponID))
        {
            if (!g_bIsClientFiringFlamethrower[client])
            {
                char cWeaponName[256];
                GetEntityClassname(iWeaponID, cWeaponName, sizeof(cWeaponName));
                if (StrContains(cWeaponName, "weapon_flamethrower", false) > -1)
                {
                    g_bIsClientFiringFlamethrower[client] = true;
                    
                    DataPack hDataPack = new DataPack();
                    hDataPack.WriteCell(userid);
                    hDataPack.WriteCell(EntIndexToEntRef(iWeaponID));
                    hDataPack.WriteCell(true);
                    CreateTimer(0.3, CheckPlayerFireDelay_Timer, hDataPack, TIMER_FLAG_NO_MAPCHANGE);
                    
                    if (sm_ft_sound_enable.BoolValue)
                    {
                        char cStartSoundPath[512];
                        if (GetClientTeam(client) == TEAM_1_SEC)
                            sm_ft_start_sound_sec.GetString(cStartSoundPath, sizeof(cStartSoundPath));
                        else
                            sm_ft_start_sound_ins.GetString(cStartSoundPath, sizeof(cStartSoundPath));
                        
                        if (strlen(cStartSoundPath) > 0)
                            GiveEntitySound(client, cStartSoundPath, 1.0, 80, SNDCHAN_STATIC);
                    }
                }
            }
            else
            {
                // PrintToServer("%0.2fs", GetEntPropFloat(iWeaponID, Prop_Data, "m_flNextPrimaryAttack") - GetGameTime());
                if (g_fFlameThrowerFireInterval > 0.08)
                    SetEntPropFloat(iWeaponID, Prop_Data, "m_flNextPrimaryAttack", GetGameTime() + g_fFlameThrowerFireInterval);
            }
        }
    }
    
    return;
}
public void Event_WeaponFireOnEmpty(Event event, char[] name, bool Broadcast)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (IsValidClient(client))
    {
        static float s_fClientLastEmptySoundTime[MAXPLAYERS+1];
        if (GetEngineTime() - s_fClientLastEmptySoundTime[client] < 1.0)
            return;
        
        g_bIsClientFiringFlamethrower[client] = false;
        
        int iWeaponID = GetPlayerActiveWeapon(client);
        if (iWeaponID > MaxClients && IsValidEntity(iWeaponID))
        {
            char cWeaponName[256];
            GetEntityClassname(iWeaponID, cWeaponName, sizeof(cWeaponName));
            if (StrContains(cWeaponName, "weapon_flamethrower", false) > -1)
            {
                if (sm_ft_sound_enable.BoolValue)
                {
                    s_fClientLastEmptySoundTime[client] = GetEngineTime();

                    char cEmptySoundPath[512];
                    if (GetClientTeam(client) == TEAM_1_SEC)
                        sm_ft_empty_sound_sec.GetString(cEmptySoundPath, sizeof(cEmptySoundPath));
                    else
                        sm_ft_empty_sound_ins.GetString(cEmptySoundPath, sizeof(cEmptySoundPath));
                    
                    if (strlen(cEmptySoundPath) > 0)
                        GiveEntitySound(client, cEmptySoundPath, 1.0, 80, SNDCHAN_STATIC);
                }
            }
        }
    }
    return;
}
public Action CheckPlayerFireDelay_Timer(Handle timer, DataPack hDataPack)
{
    if (hDataPack == null)
        return Plugin_Stop;
    
    hDataPack.Reset();
    int userid = hDataPack.ReadCell();
    int iWeaponRef = hDataPack.ReadCell();
    int client = GetClientOfUserId(userid);
    int iWeaponId = EntRefToEntIndex(iWeaponRef);
    bool bIsFirstDelay = hDataPack.ReadCell();
    delete hDataPack;
    
    if (!IsValidClient(client))
    {
        g_bIsClientFiringFlamethrower[client] = false;
        return Plugin_Stop;
    }
    
    if (!g_bIsClientFiringFlamethrower[client])
    {
        StopClientFlamethrowerSound(client, true);
        return Plugin_Stop;
    }
    
    if (!IsPlayerAlive(client) || !(GetClientButtons(client) & INPUT_ATTACK) || iWeaponId <= MaxClients || !IsValidEntity(iWeaponId) || GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon") != iWeaponId)
    {
        StopClientFlamethrowerSound(client);
        g_bIsClientFiringFlamethrower[client] = false;
        return Plugin_Stop;
    }
    
    if (bIsFirstDelay)
    {
        if (sm_ft_sound_enable.BoolValue)
        {
            char cLoopSoundPath[512];
            if (GetClientTeam(client) == TEAM_1_SEC)
                sm_ft_loop_sound_sec.GetString(cLoopSoundPath, sizeof(cLoopSoundPath));
            else
                sm_ft_loop_sound_ins.GetString(cLoopSoundPath, sizeof(cLoopSoundPath));
            
            if (strlen(cLoopSoundPath) > 0)
                GiveEntitySound(client, cLoopSoundPath, 1.0, 80, SNDCHAN_STATIC);
        }
    }

    // Create hurt to map entity
    int iEntityID;
    float fClientEyeAngles[3];
    float fClientEyePosition[3];
    GetClientEyeAngles(client, fClientEyeAngles);
    GetClientEyePosition(client, fClientEyePosition);
    Handle trace = TR_TraceRayFilterEx(fClientEyePosition, fClientEyeAngles, CONTENTS_SOLID|CONTENTS_MOVEABLE , RayType_Infinite, TraceEntityFilter_ExceptClientAndSelf, client);
    if (TR_DidHit(trace))
        iEntityID = TR_GetEntityIndex(trace);
    CloseHandle(trace);
    if (iEntityID > MaxClients && IsValidEntityEx(iEntityID) && GetEntitiesDistance(client, iEntityID) < 500.0)
    {
        CreateHurt(client, iEntityID, 50, iWeaponId, g_cFlameThrowerAmmoName, DMG_BURN|DMG_BLAST);
        if (!IsEntityOnFire(iEntityID))
        {
            ExtinguishEntity(iEntityID);
            ExtinguishEntityEx(iEntityID);
            IgniteEntity(iEntityID, 5.0);
        }
    }
    
    DataPack hDataPack2 = new DataPack();
    hDataPack2.WriteCell(userid);
    hDataPack2.WriteCell(iWeaponRef);
    hDataPack2.WriteCell(false);
    CreateTimer(0.3, CheckPlayerFireDelay_Timer, hDataPack2, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Stop;
}
public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    if (g_bIsClientFiringFlamethrower[client])
    {
        if (!(buttons & INPUT_ATTACK))
        {
            if (IsValidClient(client))
            {
                StopClientFlamethrowerSound(client);
                g_bIsClientFiringFlamethrower[client] = false;
                return;
            }
        }
    }
    return;
}

// Block the scorch decal
bool g_bBlockDecal = false;
bool g_bIsFlameEntity[2048];
public void Event_MissileLaunched(Event event, char[] name, bool Broadcast)
{
    int entityid = event.GetInt("entityid");
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients && g_bIsClientFiringFlamethrower[client])
        g_bIsFlameEntity[entityid] = true;
    return;
}
public void Event_GrenadeDetonate(Event event, char[] name, bool Broadcast)
{
    int entityid = event.GetInt("entityid");
    if (g_bIsFlameEntity[entityid])
    {
        g_bBlockDecal = true;
        g_bIsFlameEntity[entityid] = false;
    }
    return;
}
public Action TE_OnDecal(const char[] te_name, const int[] Players, int numClients, float delay)
{
    if (g_bBlockDecal)
    {
        g_bBlockDecal = false;
        return Plugin_Handled;
    }
    
    return Plugin_Continue;
}

stock void StopClientFlamethrowerSound(int client, bool bImmediately = false)
{
    if (!bImmediately && sm_ft_sound_enable.BoolValue)
    {
        char cEndSoundPath[512];
        if (GetClientTeam(client) == TEAM_1_SEC)
            sm_ft_end_sound_sec.GetString(cEndSoundPath, sizeof(cEndSoundPath));
        else
            sm_ft_end_sound_ins.GetString(cEndSoundPath, sizeof(cEndSoundPath));
        if (strlen(cEndSoundPath) > 0)
            GiveEntitySound(client, cEndSoundPath, 1.0, 80, SNDCHAN_STATIC);
        
        char cLoopSoundPath[512];
        sm_ft_loop_sound_sec.GetString(cLoopSoundPath, sizeof(cLoopSoundPath));
        StopEntitySound(client, cLoopSoundPath, SNDCHAN_STATIC);
        sm_ft_loop_sound_ins.GetString(cLoopSoundPath, sizeof(cLoopSoundPath));
        StopEntitySound(client, cLoopSoundPath, SNDCHAN_STATIC);
    }
    else
    {
        char cLoopSoundPath[512];
        sm_ft_loop_sound_sec.GetString(cLoopSoundPath, sizeof(cLoopSoundPath));
        StopEntitySound(client, cLoopSoundPath, SNDCHAN_STATIC);
        sm_ft_loop_sound_ins.GetString(cLoopSoundPath, sizeof(cLoopSoundPath));
        StopEntitySound(client, cLoopSoundPath, SNDCHAN_STATIC);
    }
    
    return;
}
public bool PrecacheSoundByConVar(ConVar hConVar)
{
    char cSoundPath[512];
    hConVar.GetString(cSoundPath, sizeof(cSoundPath));
    if (strlen(cSoundPath) > 1)
        return PrecacheSound(cSoundPath);
    else
        return false;
}

///////////////////////////////////// MoreFire - Fix burn logic
int g_iPlayerFireAttacker[MAXPLAYERS+1];
float g_fPlayerEndFireTime[MAXPLAYERS+1];
public int BurnPlayer(int attacker, int victim, float time)
{
    if (victim < 0 || victim > MaxClients)
        return 0;
    
    g_iPlayerFireAttacker[victim] = attacker;
    g_fPlayerEndFireTime[victim] = GetEngineTime() + time;
    return RoundFloat(g_fPlayerEndFireTime[victim]);
}
void MoreFire_OnPluginStart()
{
    HookEvent("player_spawn", MoreFire_Event_PlayerSpawn, EventHookMode_Pre);
    HookEvent("player_death", MoreFire_Event_PlayerDeath, EventHookMode_Pre);
}
public void MoreFire_OnMapStart()
{
    CreateTimer(0.2, CheckPlayerFire_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return;
}
void MoreFire_OnClientPutInServer(int client) 
{
    g_fPlayerEndFireTime[client] = 0.0;
    
    if (IsValidClient(client))
    {
        ExtinguishEntityEx(client);
        SDKHook(client, SDKHook_OnTakeDamage, MoreFire_OnTakeDamage_CallBack);
    }
    
    return;
}
Action MoreFire_OnTakeDamage_CallBack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if (IsValidClient(victim))
    {
        if ((damagetype & DMG_BURN) && (damagetype & DMG_DIRECT))
        {
            if (!IsPlayerAlive(victim))
            {
                char cInflictorName[256];
                GetEntityClassname(attacker, cInflictorName, sizeof(cInflictorName));
                if (StrEqual(cInflictorName, "entityflame", false))
                {
                    SetEntPropFloat(inflictor, Prop_Data, "m_flLifetime", 0.0);
                    AcceptEntityInput(inflictor, "Kill");
                }
            }
            
            // 使用createhurt代替火焰伤害
            if (damage < 1.0)
                CreateHurt(g_iPlayerFireAttacker[victim], victim, 1, inflictor, "entityflame", DMG_BURN);
            else
                CreateHurt(g_iPlayerFireAttacker[victim], victim, RoundFloat(damage), inflictor, "entityflame", DMG_BURN);
            
            if (DEBUG.BoolValue)
                PrintToServer("OnFire %d | Time = %0.1f | attacker %d | victim %d | inflictor %d | damage %0.1f = %d", IsEntityOnFire(victim), g_fPlayerEndFireTime[victim] - GetEngineTime(), g_iPlayerFireAttacker[victim], victim, inflictor, damage, RoundFloat(damage));
            
            damage = 0.0;
            return Plugin_Changed;
        }
    }
    
    return Plugin_Continue;
}
void MoreFire_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        g_fPlayerEndFireTime[client] = 0.0;
        if (IsEntityOnFire(client))
            ExtinguishEntityEx(client);
    }
    
    return;
}
void MoreFire_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        g_fPlayerEndFireTime[client] = 0.0;
        if (IsEntityOnFire(client))
            ExtinguishEntityEx(client);
        
        // Ignite the dead body of a player who died of burns
        if (!IsFakeClient(client)) // Prevent PVE lag
        {
            int damagebits = event.GetInt("damagebits");
            if ((damagebits & DMG_BURN))
            {
                int m_hRagdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
                if (m_hRagdoll > MaxClients && IsValidEntity(m_hRagdoll))
                {
                    ExtinguishEntity(m_hRagdoll);
                    ExtinguishEntityEx(m_hRagdoll);
                    IgniteEntity(m_hRagdoll, 5.0);
                }
            }
        }
    }

    return;
}
Action CheckPlayerFire_Timer(Handle timer, any data)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsValidClient(client))
        {
            int iPlayerWaterLevel = GetEntProp(client, Prop_Send, "m_nWaterLevel");
            // PrintCenterText(client, "iPlayerWaterLevel %d | Time to fire %d | Player on fire %d", 
            // iPlayerWaterLevel, (iPlayerWaterLevel == 0 && g_fPlayerEndFireTime[client] > GetEngineTime() && IsPlayerAlive(client) && !IsCoopEnemy(client, g_iGameModeClass, g_iGameMode)), IsEntityOnFire(client));
            if (iPlayerWaterLevel == 0 && g_fPlayerEndFireTime[client] > GetEngineTime() && IsPlayerAlive(client))
            {
                if (!IsEntityOnFire(client))
                    IgniteEntity(client, g_fPlayerEndFireTime[client] - GetEngineTime() + 5.0);
            }
            else
            {
                if (IsEntityOnFire(client))
                    ExtinguishEntityEx(client);
                
                g_fPlayerEndFireTime[client] = 0.0;
            }
        }
    }
    
    return Plugin_Continue;
}
///////////////////////////////////// MoreFire - Fix burn logic


///////////////////////////////////// Function
stock bool IsValidEntityEx(int entity)
{
    if (entity > 0 && IsValidEdict(entity) && IsValidEntity(entity))
        return true;
    
    return false;
}
stock bool IsValidClient(int client)
{
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
        return true;
    
    return false;
}
stock bool IsPlayerTeam(int team)
{
    if (team == TEAM_1_SEC || team == TEAM_2_INS)
        return true;
    
    return false;
}
stock bool IsClientInPlayerTeam(int client)
{
    if (IsPlayerTeam(GetClientTeam(client)))
        return true;
    
    return false;
}
stock bool IsCoopEnemy(int client, int iGameModeClass, int iGameMode)
{
    if (iGameModeClass == GAME_MODE_CLASS_PVE)
    {
        int iClientTeam = GetClientTeam(client);
        if (iGameMode == GAME_MODE_SURVIVAL)
        {
            if (iClientTeam == TEAM_1_SEC)
                return true;
        }
        else
        {
            if (iClientTeam == TEAM_2_INS)
                return true;
        }
    }

    return false;
}
public int GetPlayerActiveWeapon(int client)
{
    return GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
}
stock bool IsPlayerDeploying(int client)
{
    int iActiveWeapon = GetPlayerActiveWeapon(client);
    if (iActiveWeapon > MaxClients && IsValidEntity(iActiveWeapon) && HasEntProp(iActiveWeapon, Prop_Send, "m_timestamp") && GetEntPropFloat(iActiveWeapon, Prop_Send, "m_timestamp") > 0)
        return true;
    
    return false;
}
stock int GetPlayerFlags(int client)
{
    return GetEntProp(client, Prop_Send, "m_iPlayerFlags");
}
stock bool IsPlayerForcedToPuttingDownWeapon(int client)
{
    return view_as<bool>((GetPlayerFlags(client) & INS_PF_PUTDOWNWEAPON));
}
public int GetClipType(int client, int iWeaponID)
{
    return GetEntProp(iWeaponID, Prop_Data, "m_iPrimaryAmmoType");
}
public int GetClipCount(int client, int iWeaponID)
{
    int clipType = GetClipType(client, iWeaponID);
    if (clipType < 0 || clipType > 255)
        return 1;

    return GetEntProp(client, Prop_Data, "m_iAmmo", _, clipType);
}
stock float GetEntitiesDistance(EntityId1, EntityId2)
{
    float Entity1PositionVector[3];
    GetEntPropVector(EntityId1, Prop_Data, "m_vecOrigin", Entity1PositionVector);

    float Entity2PositionVector[3];
    GetEntPropVector(EntityId2, Prop_Data, "m_vecOrigin", Entity2PositionVector);

    return GetVectorDistance(Entity1PositionVector, Entity2PositionVector);
}
stock float GetDistance_ClientToPosition(int client, const float fPositionVector[3])
{
    if (!IsValidClient(client))
        return 0.0;
        
    float fClientPosition[3];
    GetClientAbsOrigin(client, fClientPosition);
    return GetVectorDistance(fPositionVector, fClientPosition);
}
public bool TraceEntityFilter_ExceptClientAndSelf(int entity, int mask, int date)
{
    if (entity == 0 || (entity != date && entity > MaxClients))
        return true;
    else
        return false;
}
public bool TraceEntityFilter_OnlyWorld(int entity, int mask, int date)
{
    if (entity == 0)
        return true;
    else
        return false;
}
stock void KillEntityEx(int entity)
{
    if (IsValidEntityEx(entity))
    {
        int IHammerID = GetEntProp(entity, Prop_Data, "m_iHammerID");
        if (IHammerID > 0)
            return;
        
        AcceptEntityInput(entity, "Kill");
    }
    return;
}
public void PrecacheParticleFile(const char[] cParticleFile)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ExtraParticleFilesTable");
    }
    
    if (FindStringIndex(table, cParticleFile) == INVALID_STRING_INDEX)
    {
        bool save = LockStringTables(false);
        AddToStringTable(table, cParticleFile);
        LockStringTables(save);
    }
    
    return;
}
public void PrecacheParticleEffect(const char[] cEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    
    if (FindStringIndex(table, cEffectName) == INVALID_STRING_INDEX)
    {
        bool save = LockStringTables(false);
        AddToStringTable(table, cEffectName);
        LockStringTables(save);
    }
    
    return;
}
stock bool CreateHurt(int attacker = 0, int victim = 0, int damage = 0, int weaponid = 0, char[] cCustomWeaponName = "\0", int iDamageType = DMG_BLAST)
{
    if (IsValidEntityEx(victim) && damage > 0)
    {
        char cDamageChar[16];
        IntToString(damage, cDamageChar, 32);

        char cDamageTypeChar[32];
        IntToString(iDamageType, cDamageTypeChar, 32);

        int pointHurt = CreateEntityByName("point_hurt");
        if (pointHurt > MaxClients && IsValidEntityEx(pointHurt))
        {
            if (strlen(cCustomWeaponName) > 0)
            {
                DispatchKeyValue(pointHurt, "classname", cCustomWeaponName);
            }
            else
            {
                if (IsValidEntityEx(weaponid))
                {
                    char cWeaponName[256];
                    GetEntityClassname(weaponid, cWeaponName, sizeof(cWeaponName));
                    DispatchKeyValue(pointHurt, "classname", cWeaponName);
                }
            }
            
            char cTargetEntityOldName[128];
            GetEntPropString(victim, Prop_Data, "m_iName", cTargetEntityOldName, sizeof(cTargetEntityOldName));
            
            char cTargetName[128];
            Format(cTargetName, sizeof(cTargetName), "hurtme_%d", EntIndexToEntRef(victim));
            DispatchKeyValue(victim, "targetname", cTargetName);
            DispatchKeyValue(pointHurt, "DamageTarget", cTargetName);
            
            DispatchKeyValue(pointHurt, "Damage", cDamageChar);
            DispatchKeyValue(pointHurt, "DamageType", cDamageTypeChar);
            DispatchSpawn(pointHurt);
            
            AcceptEntityInput(pointHurt, "Hurt", IsValidEntityEx(attacker) ? attacker : -1);
            AcceptEntityInput(pointHurt, "Kill");
            DispatchKeyValue(victim, "targetname", cTargetEntityOldName);
            // RemoveEdict(pointHurt);
            return true;
        }
    }

    return false;
}
public int IsEntityOnFire(int entity)
{
    if (IsValidEntity(entity))
    {
        int iFireEntity = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
        if (iFireEntity > MaxClients && IsValidEdict(iFireEntity))
        {
            char cClassname[256];
            GetEntityClassname(iFireEntity, cClassname, sizeof(cClassname));
            if (StrEqual(cClassname, "entityflame", false))
                return iFireEntity;
        }
    }
    return false;
}
public void ExtinguishEntityEx(int entity)
{
    if (IsValidEntity(entity))
    {
        // 玩家死亡时就算用的EventHookMode_Pre也无法使用m_hEffectEntity来获得火焰，只能遍历
        // 直接KILL会导致再次spawn前无法再着火
        int iFireEntity = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
        if (IsValidEdict(iFireEntity) && HasEntProp(iFireEntity, Prop_Data, "m_flLifetime"))
        {
            AcceptEntityInput(iFireEntity, "DisableDraw");
            AcceptEntityInput(iFireEntity, "DisableDamageForces");
            SetEntPropFloat(iFireEntity, Prop_Data, "m_flLifetime", 0.0);
            // AcceptEntityInput(iFireEntity, "Kill");
        }
        else
        {
            char cClassname[256];
            for (iFireEntity = 0; iFireEntity <= GetMaxEntities(); iFireEntity++)
            {
                if (IsValidEdict(iFireEntity))
                {
                    GetEntityClassname(iFireEntity, cClassname, sizeof(cClassname));
                    if (StrContains(cClassname, "entityflame", false) > -1)
                    {
                        if (GetEntPropEnt(iFireEntity, Prop_Data, "m_pParent") == entity)
                        {
                            AcceptEntityInput(iFireEntity, "DisableDraw");
                            AcceptEntityInput(iFireEntity, "DisableDamageForces");
                            SetEntPropFloat(iFireEntity, Prop_Data, "m_flLifetime", 0.0);
                            // AcceptEntityInput(iFireEntity, "Kill");
                        }
                    }
                }
            }
        }
    }

    return;
}
stock void GiveEntitySound(int entity, const char[] cPath, float fVolume = SNDVOL_NORMAL, int iLevel = SNDLEVEL_NORMAL, int iChannel = SNDCHAN_AUTO)
{
    if (strlen(cPath) <= 0)
        return;
    
    EmitSoundToAll(cPath, entity, iChannel, iLevel, _, fVolume);
    return;
}
int g_iSoundChannel[] =
{
    // SNDCHAN_REPLACE = -1,       /**< Unknown */
    SNDCHAN_AUTO,           /**< Auto */
    SNDCHAN_WEAPON,         /**< Weapons */
    SNDCHAN_VOICE,          /**< Voices */
    SNDCHAN_ITEM,           /**< Items */
    SNDCHAN_BODY,           /**< Player? */
    SNDCHAN_STREAM,         /**< "Stream iChannel from the static or dynamic area" */
    SNDCHAN_STATIC,         /**< "Stream iChannel from the static area" */
    SNDCHAN_VOICE_BASE,     /**< "Channel for network voice data" */
    SNDCHAN_USER_BASE,     /**< Anything >= this is allocated to game code */
};
stock void StopEntitySound(int entity, const char[] cPath, int iChannel = SNDCHAN_REPLACE)
{
    if (cPath[0] == '\0' || strlen(cPath) <= 0)
        return;

    if (iChannel == SNDCHAN_REPLACE)
    {
        for (int i = 0; i < sizeof(g_iSoundChannel); i++)
            StopSound(entity, g_iSoundChannel[i], cPath);
    }
    else
        StopSound(entity, iChannel, cPath);

    return;
}
///////////////////////////////////// Function