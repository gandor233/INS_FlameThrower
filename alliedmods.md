[SIZE="4"]A Flamethrower plugin made of "Day of Infamy" models and particles for insurgency(2014)[/SIZE]

[ATTACH]189544[/ATTACH]

[SIZE="4"]Version[/SIZE]
 [LIST][*]Public 2.3[/LIST]

[SIZE="4"]Feature list[/SIZE]
[LIST][*]Ignite and kill other players
[*]Ignite and kill yourself (if you fire a flamethrower too close to wall)
[*]Ignite map entity (like weapon cache or bush)
[*]Ignite player dead body ragdoll if he dies of burn damage[/LIST]

[SIZE="4"]Required Mod[/SIZE]
[LIST]
[*][URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647"]其他 Extra | 喷火器 Flamethrower[/URL] (steam workshop id=2392887647)
[/LIST]

[SIZE="4"]ConVar[/SIZE]
[SPOILER][CODE]
// Copy what you want to modify to your server.cfg

// If you are using the official mod of the plugin author, please set it to 1, then the plugin will run
// AddFileToDownloadsTable("custom/Flamethrower_Particles_***.vpk") and PrecacheParticleFile("particles/ins_flamethrower.pcf") automatically. 
// If set to 0, you need to deal the particles files by yourself.
// Default: "1"
sm_ft_using_official_mod "1"

// Flamethrower ammo entity class name. 
// You must set this convar if you use a different ammo class name in your theater.
// Default: "flame_proj"
sm_ft_ammo_class_name "flame_proj"

// Burn duration
// Default: "2.0"
sm_ft_burn_time "2.0"

// Flamethrower self damage multiplier.
// Default: "0.2"
sm_ft_self_damage_mult "0.2"

// Flamethrower launch interval. Closed if less than 0.08.
// Default: "0.12"
sm_ft_fire_interval "0.12"

// Is all plugin flamethrower fire sound enable?
// Default: "1"
sm_ft_sound_enable "1

// Flamethrower fire START sound file path for team sec. Closed if empty.
// Default: "weapons/flamethrowerno2/flamethrower_start.wav"
sm_ft_start_sound_sec "weapons/flamethrowerno2/flamethrower_start.wav"

// Flamethrower fire LOOP sound file path for team sec. Closed if empty.
// Default: "weapons/flamethrowerno2/flamethrower_looping.wav"
sm_ft_loop_sound_sec "weapons/flamethrowerno2/flamethrower_looping.wav""

// Flamethrower fire END sound file path for team sec. Closed if empty.
// Default: "weapons/flamethrowerno2/flamethrower_end.wav"
sm_ft_end_sound_sec "weapons/flamethrowerno2/flamethrower_end.wav"

// Flamethrower fire EMPTY sound file path for team sec. Closed if empty.
// Default: ""
sm_ft_empty_sound_sec ""

// Flamethrower fire START sound file path for team ins. Closed if empty.
// Default: "weapons/flamethrowerno41/flamethrower_start.wav"
sm_ft_start_sound_ins "weapons/flamethrowerno41/flamethrower_start.wav"

// Flamethrower fire LOOP sound file path for team ins. Closed if empty.
// Default: "weapons/flamethrowerno41/flamethrower_looping.wav"
sm_ft_loop_sound_ins "weapons/flamethrowerno41/flamethrower_looping.wav"

// Flamethrower fire END sound file path for team ins. Closed if empty.
// Default: "weapons/flamethrowerno41/flamethrower_end.wav"
sm_ft_end_sound_ins "weapons/flamethrowerno41/flamethrower_end.wav"

// Flamethrower fire EMPTY sound file path for team ins. Closed if empty.
// Default: ""
sm_ft_empty_sound_ins ""[/CODE][/SPOILER]

[SIZE="4"]Installation Guide[/SIZE]
[SPOILER]To use this plugin you need to modify the original theater and create your own theater mod.
If you don't know how to do it, please check the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=424392708"]theater modding guide[/URL].
[LIST=1][*][SIZE="2"]Subscribe the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=424392708"]required mod[/URL] for your server [B]OR[/B] download it and edit it into your own mod[/SIZE]
[*][SIZE="2"]Add "#base", "particles", "sounds" and "localize" to your mod's main theater file[/SIZE]
[CODE]"#base" "base/gandor233_flamethrower.theater"
...
"theater"
{
    "core"
    {
        "precache"
        {
            ...
            "particles"   "particles/ins_flamethrower.pcf"
            "sounds"      "scripts/gandor233_flamethrower_sounds.txt"
            "localize"    "resource/gandor233_flamethrower_%language%.txt"
        }
    }
}[/CODE]
[*][SIZE="2"]Add "flame" to your mod's ammo theater file[/SIZE]
[CODE]"theater"
{
    "ammo"
    {
        "flame_proj"
        {
            "flags_clear"    "AMMO_USE_MAGAZINES"
            "carry"          "500"
        }
    }
}[/CODE]
[*][SIZE="2"]Add "weapon_flamethrower_***" to your mod's player templates allowed items[/SIZE]
[CODE]"theater"
{
    "player_templates"
    {
        "template_security_1"
        {
            "team"    "security"
            "models"
            {
                ...
            }
            "buy_order"
            {
                ...
            }
            "allowed_items"
            {
                "gear"      "fuel_tank_sec"
                "weapon"    "weapon_flamethrower_sec"
                ...
            }
        }
        "template_insurgent_1"
        {
            "team"    "insurgents"
            "models"
            {
                ...
            }
            "buy_order"
            {
                ...
            }
            "allowed_items"
            {
                "gear"      "fuel_tank_ins"
                "weapon"    "weapon_flamethrower_ins"
                ...
            }
        }
    }
}[/CODE]
[*][SIZE="2"]Install Plugin[/SIZE]
Remove other versions of flamethrower plugin.
Put FlameThrower_public.smx into "insurgency\addons\sourcemod\plugins\"


[*][SIZE="2"]Custom Particles File[/SIZE]
Download version 2.1+ Flamethrower_Particles.zip or clone from [URL="https://github.com/gandor233/INS_FlameThrower"]github[/URL]. put Flamethrower_Particles_dir.vpk and Flamethrower_Particles_000.vpk to your fastdl folder, and make sure player is forced to download these two vpk files to them [B]insurgency/custom/[/B] folder when they join your server.

If you don't have a fastdl server, player also need to subscribe the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647"]required mod[/URL] by themself, otherwise the flamethrower fire particles effect won't show up if player didn't reconnect to your server when they first join your server erverytime after they restart the game program.[/LIST][/SPOILER]

[SIZE="4"]Changelog[/SIZE]
[CODE]
v2.3:
* Fixed flamethrower self damage multiplier.
* Prevent players from igniting themselves.

v2.2:
* Fixed the misspelled particle effect name.
* Added convar sm_ft_using_official_mod.

v2.1:
* Fixed missing particle effects in previous version.
* Fixed server crash when sound convar was set to null.
* Added flamethrower self damage multiplier convar.
* Added flamethrower launch interval convar.
* Added flamethrower ammo entity class name convar.
* Prevent flamethrowers from creating scorch decal.

v2.0:
* Add New player gerar - Fuel Tank
* The WeaponAttachmentAPI plugin is no longer needed.
* Fixed problems in the previous version models and particles files.
* Fixed the problem that the flame doesn't shoot from the muzzle in first person.
* Using theater scripts instead of plugin to create direct damage.
* Using theater scripts instead of plugin to create flamethrower effects.
* Using plugin instead of theater scripts to play the sound effect of flamethrower.

v1.0:
* Initial release.[/CODE]

[SIZE="4"]Credits[/SIZE]
[LIST]
[*]Models and scripts are modified by [B]axotn1k[/B]
[/LIST]

中文INS服务器如使用此插件请注明和鸣谢作者。

[SIZE="4"]Link[/SIZE]
[LIST]
[*][SIZE="4"][URL="https://github.com/gandor233/INS_FlameThrower"]Github[/URL][/SIZE]
[*][SIZE="4"][URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647"]Required Mod[/URL][/SIZE]
[/LIST]

[ATTACH]189542[/ATTACH]