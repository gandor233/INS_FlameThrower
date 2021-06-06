[SIZE="4"]Flamethrower plugin for insurgency(2014)[/SIZE]
A Flamethrower plugin made of "Day of Infamy" model and particles for insurgency(2014)

This plugin uses a modified version of Mitchell's plugin [URL="https://forums.alliedmods.net/showthread.php?p=2410870"][CS:GO] Weapon Attachment API[/URL]
(Just for the credits, don't need to download his version)

[ATTACH]189544[/ATTACH]

[SIZE="4"]Feature list[/SIZE]
[LIST]
[*]Ignite and kill other players
[*]Ignite and kill yourself (if you fire a flamethrower too close to wall)
[*]Ignite map entity (like weapon cache or bush)
[*]Ignite player dead body ragdoll if he dies of burn damage
[/LIST]

[SIZE="4"]Convar[/SIZE]
[CODE]"sm_flamethrower_range" - Flamethrower fire damage range (Default value: 700.0)
"sm_flamethrower_angle" - Flamethrower fire damage angle (Default value: 36.0)
"sm_flamethrower_burn_time" - Burn duration (Default value: 5.0)[/CODE]

[SIZE="4"]Required Mod[/SIZE]
[LIST]
[*][URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2509783984"]其他 Extra | 喷火器 Flamethrower[/URL] (steam workshop id=2509783984)
[/LIST]

[SIZE="4"]Installation Guide[/SIZE]
To use this plugin you need to modify the original theater and create your own theater mod.
If you don't know how to do it, please check the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=424392708"]theater modding guide[/URL].
[SPOILER][LIST=1][*][SIZE="2"]Subscribe the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2509783984"]required mod[/URL] for your server or download it and edit it into your own mod[/SIZE]
[*][SIZE="2"]Add "#base", "sounds" and "localize" to your mod main theater file[/SIZE]
[SPOILER][CODE]"#base" "base/gandor233_flamethrower.theater"
...
"theater"
{
    "core"
    {
        "precache"
        {
            ...
            "sounds"      "scripts/gandor233_flamethrower_sounds.txt"
            "localize"    "resource/gandor233_flamethrower_%language%.txt"
        }
    }
}[/CODE][/SPOILER]
[*][SIZE="2"]Add "flame" to your mod ammo theater file[/SIZE]
[SPOILER][CODE]"theater"
{
    "ammo"
    {
        "flame"
        {
            "flags_clear"    "AMMO_USE_MAGAZINES"
            "carry"          "500"
            "tracer_type"    "none"
        }
    }
}[/CODE][/SPOILER]
[*][SIZE="2"]Add "weapon_flamethrower_***" to player templates allowed items[/SIZE]
[SPOILER][CODE]"theater"
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
                "weapon"    "weapon_flamethrower_british"
                "weapon"    "weapon_flamethrower_american"
                "weapon"    "weapon_flamethrower_german"
                ...
            }
        }
    }
}[/CODE][/SPOILER]
[*][SIZE="2"]Install Plugin[/SIZE]
Put FlameThrower_public.smx and WeaponAttachmentAPI.smx to "insurgency\addons\sourcemod\plugins\"


[*][SIZE="2"]Custom Particles File[/SIZE]
Download Flamethrower_Particles.zip or clone from [URL="https://github.com/gandor233/INS_FlameThrower"]github[/URL]. put Flamethrower_Particles_dir.vpk and Flamethrower_Particles_000.vpk to your fastdl folder, and make sure player is forced to download these two vpk files to them [B]insurgency/custom/[/B] folder when they join your server.

If you don't have a fastdl server, player also need to subscribe the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2509783984"]required mod[/URL] by themself, otherwise the flamethrower fire particles effect won't show up if player didn't reconnect to your server when they first join your server erverytime after they restart the game program.[/LIST][/SPOILER]

中文INS服务器如使用此插件请注明作者。

[SIZE="4"]Download Link[/SIZE]
[LIST]
[*][SIZE="4"][URL="https://github.com/gandor233/INS_FlameThrower"]Github[/URL][/SIZE]
[*][SIZE="4"][URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2509783984"]Required Mod[/URL][/SIZE]
[/LIST]

[ATTACH]189542[/ATTACH]