LiquidsLoop(player)
{
    player.LiquidsLoop = isDefined(player.LiquidsLoop) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.LiquidsLoop))
    {
        player ReportLootReward("3", 200);

        wait 0.1;
    }
}

UnlockAchievements(player)
{
    achievements = ["CP_COMPLETE_PROLOGUE", "CP_COMPLETE_NEWWORLD", "CP_COMPLETE_BLACKSTATION", "CP_COMPLETE_BIODOMES", "CP_COMPLETE_SGEN", "CP_COMPLETE_VENGEANCE", "CP_COMPLETE_RAMSES", "CP_COMPLETE_INFECTION", "CP_COMPLETE_AQUIFER", "CP_COMPLETE_LOTUS", "CP_HARD_COMPLETE", "CP_REALISTIC_COMPLETE", "CP_CAMPAIGN_COMPLETE", "CP_FIREFLIES_KILL", "CP_UNSTOPPABLE_KILL", "CP_FLYING_WASP_KILL", "CP_TIMED_KILL", "CP_ALL_COLLECTIBLES", "CP_DIFFERENT_GUN_KILL", "CP_ALL_DECORATIONS", "CP_ALL_WEAPON_CAMOS", "CP_CONTROL_QUAD", "CP_MISSION_COLLECTIBLES", "CP_DISTANCE_KILL", "CP_OBSTRUCTED_KILL", "CP_MELEE_COMBO_KILL", "CP_COMPLETE_WALL_RUN", "CP_TRAINING_GOLD", "CP_COMBAT_ROBOT_KILL", "CP_KILL_WASPS", "CP_CYBERCORE_UPGRADE", "CP_ALL_WEAPON_ATTACHMENTS", "CP_TIMED_STUNNED_KILL", "CP_UNLOCK_DOA", "ZM_COMPLETE_RITUALS", "ZM_SPOT_SHADOWMAN", "ZM_GOBBLE_GUM", "ZM_STORE_KILL", "ZM_ROCKET_SHIELD_KILL", "ZM_CIVIL_PROTECTOR", "ZM_WINE_GRENADE_KILL", "ZM_MARGWA_KILL", "ZM_PARASITE_KILL", "MP_REACH_SERGEANT", "MP_REACH_ARENA", "MP_SPECIALIST_MEDALS", "MP_MULTI_KILL_MEDALS", "ZM_CASTLE_EE", "ZM_CASTLE_ALL_BOWS", "ZM_CASTLE_MINIGUN_MURDER", "ZM_CASTLE_UPGRADED_BOW", "ZM_CASTLE_MECH_TRAPPER", "ZM_CASTLE_SPIKE_REVIVE", "ZM_CASTLE_WALL_RUNNER", "ZM_CASTLE_ELECTROCUTIONER", "ZM_CASTLE_WUNDER_TOURIST", "ZM_CASTLE_WUNDER_SNIPER", "ZM_ISLAND_COMPLETE_EE", "ZM_ISLAND_DRINK_WINE", "ZM_ISLAND_CLONE_REVIVE", "ZM_ISLAND_OBTAIN_SKULL", "ZM_ISLAND_WONDER_KILL", "ZM_ISLAND_STAY_UNDERWATER", "ZM_ISLAND_THRASHER_RESCUE", "ZM_ISLAND_ELECTRIC_SHIELD", "ZM_ISLAND_DESTROY_WEBS", "ZM_ISLAND_EAT_FRUIT", "ZM_STALINGRAD_NIKOLAI", "ZM_STALINGRAD_WIELD_DRAGON", "ZM_STALINGRAD_TWENTY_ROUNDS", "ZM_STALINGRAD_RIDE_DRAGON", "ZM_STALINGRAD_LOCKDOWN", "ZM_STALINGRAD_SOLO_TRIALS", "ZM_STALINGRAD_BEAM_KILL", "ZM_STALINGRAD_STRIKE_DRAGON", "ZM_STALINGRAD_FAFNIR_KILL", "ZM_STALINGRAD_AIR_ZOMBIES", "ZM_GENESIS_EE", "ZM_GENESIS_SUPER_EE", "ZM_GENESIS_PACKECTOMY", "ZM_GENESIS_KEEPER_ASSIST", "ZM_GENESIS_DEATH_RAY", "ZM_GENESIS_GRAND_TOUR", "ZM_GENESIS_WARDROBE_CHANGE", "ZM_GENESIS_WONDERFUL", "ZM_GENESIS_CONTROLLED_CHAOS", "DLC2_ZOMBIE_ALL_TRAPS", "DLC2_ZOM_LUNARLANDERS", "DLC2_ZOM_FIREMONKEY", "DLC4_ZOM_TEMPLE_SIDEQUEST", "DLC4_ZOM_SMALL_CONSOLATION", "DLC5_ZOM_CRYOGENIC_PARTY", "DLC5_ZOM_GROUND_CONTROL", "ZM_DLC4_TOMB_SIDEQUEST", "ZM_DLC4_OVERACHIEVER", "ZM_PROTOTYPE_I_SAID_WERE_CLOSED", "ZM_ASYLUM_ACTED_ALONE", "ZM_THEATER_IVE_SEEN_SOME_THINGS"];
    
    for(a = 0; a < achievements.size; a++)
        player GiveAchievement(achievements[a]);
}

SetClanTag(tag, player)
{
    switch(tag)
    {
        case "Black":
            tag = "^0";
            break;
        
        case "Red":
            tag = "^1";
            break;
        
        case "Green":
            tag = "^2";
            break;
        
        case "Yellow":
            tag = "^3";
            break;
        
        case "Blue":
            tag = "^4";
            break;
        
        case "Cyan":
            tag = "^5";
            break;
        
        case "Pink":
            tag = "^6";
            break;
        
        default:
            tag = tag;
            break;
    }
    
    player SetDStat("clanTagStats", "clanName", tag);
}

CustomStatsValue(value, player)
{
    player.CustomStatsValue = value;
}

AddToCustomStats(stat, player)
{
    if(!isDefined(player.CustomStatsArray))
        player.CustomStatsArray = [];
    
    if(isInArray(player.CustomStatsArray, stat))
        player.CustomStatsArray = ArrayRemove(player.CustomStatsArray, stat);
    else
        player.CustomStatsArray[player.CustomStatsArray.size] = stat;
}

SetCustomStats(player)
{
    if(!isDefined(player.CustomStatsArray) || !player.CustomStatsArray.size)
        return self iPrintlnBold("^1ERROR: ^7No Stats Have Selected");
    
    for(a = 0; a < player.CustomStatsArray.size; a++)
    {
        if(isInArray(level.MenuBGB, player.CustomStatsArray[a]))
            player SetDStat("ItemStats", level.bgb[player.CustomStatsArray[a]].item_index, "stats", "used", "StatValue", player.CustomStatsValue);
        else if(IsMapStat(player.CustomStatsArray[a], false))
            player SetDStat("PlayerStatsByMap", IsMapStat(player.CustomStatsArray[a], true), "stats", RemoveMapFromStat(player.CustomStatsArray[a]), "StatValue", player.CustomStatsValue);
        else
            player SetDStat("PlayerStatsList", player.CustomStatsArray[a], "StatValue", player.CustomStatsValue);
    }
    
    wait 0.1;

    UploadStats(player);
}

IsMapStat(stat, returnMap)
{
    for(a = 0; a < level.mapNames.size; a++)
        if(IsSubStr(stat, level.mapNames[a]))
            return returnMap ? level.mapNames[a] : true;
    
    return returnMap ? undefined : false;
}

RemoveMapFromStat(stat)
{
    if(!IsMapStat(stat, false))
        return;
    
    mapStats = ["score", "total_games_played", "total_rounds_survived", "highest_round_reached", "time_played_total", "total_downs"];

    for(a = 0; a < mapStats.size; a++)
        if(IsSubStr(stat, mapStats[a]) || mapStats[a] == stat)
            return mapStats[a];
}

IsAllBGBStatsEnabled()
{
    if(isDefined(level.MenuBGB) && level.MenuBGB.size)
        for(a = 0; a < level.MenuBGB.size; a++)
            if(!isInArray(self.CustomStatsArray, level.MenuBGB[a]))
                return false;
    
    return true;
}

AllBGBStats(player)
{
    if(isDefined(level.MenuBGB) && level.MenuBGB.size)
    {
        if(!player IsAllBGBStatsEnabled())
        {
            for(a = 0; a < level.MenuBGB.size; a++)
                if(!isInArray(player.CustomStatsArray, level.MenuBGB[a]))
                    self AddToCustomStats(level.MenuBGB[a], player);
        }
        else
        {
            for(a = 0; a < level.MenuBGB.size; a++)
                if(isInArray(player.CustomStatsArray, level.MenuBGB[a]))
                    self AddToCustomStats(level.MenuBGB[a], player);
        }
    }
}

SetPlayerPrestige(prestige, player)
{
    player SetDStat("PlayerStatsList", "plevel", "StatValue", prestige);
    player SetRank(player rank::getRankForXp(player rank::getRankXP()), player GetDStat("PlayerStatsList", "plevel", "StatValue"));

    wait 0.1;

    UploadStats(player);
}

SetPlayerRank(rank, player)
{
    add = (rank > 35) ? Int(TableLookup("gamedata/tables/zm/zm_paragonranktable.csv", 0, (rank - 36), (rank == 100) ? 7 : 2)) : Int(TableLookup("gamedata/tables/zm/zm_ranktable.csv", 0, (rank - 1), (rank == 35) ? 7 : 2));
    current = (rank > 35) ? Int(player GetDStat("PlayerStatsList", "paragon_rankxp", "StatValue")) : Int(player GetDStat("PlayerStatsList", "rankxp", "StatValue"));

    player AddRankXPValue("win", (add - current));

    wait 0.1;

    UploadStats(player);
}

CompleteAllEasterEggs(player)
{
    stats = ["DARKOPS_GENESIS_SUPER_EE", "darkops_zod_ee", "darkops_factory_ee", "darkops_castle_ee", "darkops_island_ee", "darkops_stalingrad_ee", "darkops_genesis_ee", "darkops_zod_super_ee", "darkops_factory_super_ee", "darkops_castle_super_ee", "darkops_island_super_ee", "darkops_stalingrad_super_ee"];
    value = !Int(player GetDStat("PlayerStatsList", "DARKOPS_GENESIS_SUPER_EE", "StatValue"));
    
    foreach(stat in stats)
        player SetDStat("PlayerStatsList", stat, "StatValue", value);
}

CompleteDailyChallenges(player)
{
    for(a = 768; a < 809; a++)
        player AddPlayerStat(TableLookup("gamedata/stats/zm/statsmilestones4.csv", 0, a, 4), Int(TableLookup("gamedata/stats/zm/statsmilestones4.csv", 0, a, 2)));

    wait 0.1;
    UploadStats(player);
}

PlayerWeaponRanks(type, player)
{
    if(isDefined(player.PlayerWeaponRanks))
        return;
    player.PlayerWeaponRanks = true;

    player endon("disconnect");

    for(a = 512; a < 642; a++)
        foreach(weapon in StrTok(TableLookup("gamedata/stats/zm/statsmilestones3.csv", 0, a, 13), " "))
            player SetDStat("ItemStats", GetBaseWeaponItemIndex(GetWeapon(weapon)), "xp", (type == "Max") ? 665535 : 0);

    player.PlayerWeaponRanks = undefined;
}