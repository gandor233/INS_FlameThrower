# INS_FlameThrower
Flamethrower plugin for insurgency(2014)

WeaponAttachmentAPI plugin is modified from [MitchDizzle's plugin](https://github.com/MitchDizzle/WeaponAttachmentAPI)

## Required Mod
[其他 Extra | 喷火器 Flamethrower](https://steamcommunity.com/sharedfiles/filedetails/?id=2509783984)

## Convar
```
"sm_flamethrower_range" - FlameThrower fire range (Default value: 700.0)
"sm_flamethrower_angle" - FlameThrower fire angle (Default value: 36.0)
"sm_flamethrower_burn_time" - Burn duration (Default value: 5.0)
```
## Guide
To use this plugin you need to modify the original theater and create your own theater mod. If you don't know how to do it, please check the [theater modding guide](https://steamcommunity.com/sharedfiles/filedetails/?id=424392708).
### 1. Subscribe the [required mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2509783984) for your server or download it and edit it into your own mod
### 2. Add "#base", "sounds" and "localize" to your mod main theater file
```
"#base" "base/gandor233_flamethrower.theater"
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
}
```
### 3. Add "flame" to your mod ammo theater file
```
"theater"
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
}
```
### 4. Add "weapon_flamethrower_***" to player templates allowed items
```
"theater"
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
}
```
### 5. Install plugin
Remove other versions of flamethrower plugin
<br>Put FlameThrower_public.smx and WeaponAttachmentAPI.smx into "insurgency\addons\sourcemod\plugins\"
### 6. Particles file
Put custom\Flamethrower_Particles_dir.vpk and custom\Flamethrower_Particles_000.vpk to your fastdl folder, and make sure player is forced to download these two vpk files to them custom folder when they join your server.

If you don't have a fastdl server, player also need to subscribe the required mod by themself, otherwise the flamethrower fire particles effect won't show up if player didn't reconnect to your server when they first join your server erverytime after they start the game program.


中文INS服务器如使用此插件请注明作者。