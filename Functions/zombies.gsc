EditZombieHealth(health)
{
    level notify("EndZombieHealth");
    level endon("EndZombieHealth");
    
    if(health)
    {
        while(1)
        {
            level thread SetZombieHealth(health);
            wait 0.1;
        }
    }
    else
        level thread SetZombieHealth(GetZombieHealthFromRound(level.round_number));
}

GetZombieHealthFromRound(round_number)
{
    zombie_health = level.zombie_vars["zombie_health_start"];

    for(a = 2; a <= round_number; a++)
    {
        if(a >= 10)
        {
            old_health = zombie_health;
            zombie_health = zombie_health + (Int(level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"]));

            if(level.zombie_health < old_health)
                return old_health;
        }
        else
            zombie_health = Int(zombie_health + level.zombie_vars["zombie_health_increase"]);
    }

    return zombie_health;
}

SetZombieHealth(health)
{
    level.zombie_health = health;
    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]) && IsAlive(zombies[a]) && zombies[a].maxhealth != level.zombie_health)
        {
            zombies[a].maxhealth = level.zombie_health;
            zombies[a].health = zombies[a].maxhealth;
        }
    }
}

KillZombies(type)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        switch(type)
        {
            case "Head Gib":
                zombies[a] thread zombie_utility::zombie_head_gib();
                break;
            
            case "Flame":
                zombies[a] thread zombie_death::flame_death_fx();
                break;
            
            case "Delete":
                zombies[a] delete();
                break;
            
            default:
                break;
        }
        
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] DoDamage((zombies[a].health + 666), zombies[a].origin);
    }
}

SetZombieRunSpeed(speed)
{
    speed = ToLower(speed);

    if(speed == "super sprint")
        speed = "super_sprint";

    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] zombie_utility::set_zombie_run_cycle(speed);
}

SetZombieAnimationSpeed(rate)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        zombies[a] thread ZombieAnimationWait(rate);
    }

    spawner::remove_global_spawn_function("zombie", ::ZombieAnimationWait);
    spawner::add_archetype_spawn_function("zombie", ::ZombieAnimationWait, rate);
}

ZombieAnimationWait(rate)
{
    while(!self CanControl() && IsAlive(self))
        wait 0.1;
    
    if(IsAlive(self))
        self ASMSetAnimationRate(rate);
}

ForceZombieCrawlers()
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        zombies[a] zombie_utility::makezombiecrawler(true);
}

ZombieGibBone(bone)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
            continue;
        
        switch(bone)
        {
            case "Random":
                switch(RandomInt(5))
                {
                    case 0:
                        zombies[a] thread zombie_utility::zombie_head_gib();
                        break;
                    
                    case 1:
                        thread gibserverutils::gibrightleg(zombies[a]);
                        break;
                    
                    case 2:
                        thread gibserverutils::gibleftleg(zombies[a]);
                        break;
                    
                    case 3:
                        thread gibserverutils::gibrightarm(zombies[a]);
                        break;
                    
                    case 4:
                        thread gibserverutils::gibleftarm(zombies[a]);
                        break;
                    
                    default:
                        zombies[a] thread zombie_utility::zombie_head_gib();
                        break;
                }
                break;
            
            case "Head":
                zombies[a] thread zombie_utility::zombie_head_gib();
                break;
            
            case "Right Leg":
                thread gibserverutils::gibrightleg(zombies[a]);
                break;
            
            case "Left Leg":
                thread gibserverutils::gibleftleg(zombies[a]);
                break;
            
            case "Right Arm":
                thread gibserverutils::gibrightarm(zombies[a]);
                break;
            
            case "Left Arm":
                thread gibserverutils::gibleftarm(zombies[a]);
                break;
            
            default:
                zombies[a] thread zombie_utility::zombie_head_gib();
        }
    }
}

SetZombieModel(model)
{
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
        if(isDefined(zombies[a]) && IsAlive(zombies[a]))
            zombies[a] SetModel(model);
}

DisableZombieSpawning()
{
    SetDvar("ai_disableSpawn", (GetDvarString("ai_disableSpawn") == "0") ? "1" : "0");
    KillZombies();
}

TeleportZombies(loc)
{
    origin = self.origin;

    if(loc == "Crosshairs")
        origin = self TraceBullet();
    
    zombies = GetAITeamArray(level.zombie_team);

    for(a = 0; a < zombies.size; a++)
    {
        if(isDefined(zombies[a]))
        {
            zombies[a] ForceTeleport(origin);
            zombies[a].find_flesh_struct_string = "find_flesh";
            zombies[a].ai_state = "find_flesh";
            zombies[a] notify("zombie_custom_think_done", "find_flesh");
        }
    }
}

ZombiesToCrosshairsLoop()
{
    level.ZombiesToCrosshairsLoop = isDefined(level.ZombiesToCrosshairsLoop) ? undefined : true;

    origin = self TraceBullet();

    while(isDefined(level.ZombiesToCrosshairsLoop))
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
            if(isDefined(zombies[a]))
                zombies[a] ForceTeleport(origin);

        wait 0.05;
    }
}

DisableZombiePush()
{
    level.DisableZombiePush = isDefined(level.DisableZombiePush) ? undefined : true;

    if(isDefined(level.DisableZombiePush))
    {
        while(isDefined(level.DisableZombiePush))
        {
            foreach(player in level.players)
                player SetClientPlayerPushAmount(0);

            wait 0.1;
        }
    }
    else
    {
        foreach(player in level.players)
            player SetClientPlayerPushAmount(1);
    }
}

ZombiesInvisibility()
{
    level.ZombiesInvisibility = isDefined(level.ZombiesInvisibility) ? undefined : true;

    if(isDefined(level.ZombiesInvisibility))
    {
        while(isDefined(level.ZombiesInvisibility))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
                if(isDefined(zombies[a]) && IsAlive(zombies[a]))
                    zombies[a] Hide();

            wait 0.5;
        }
    }
    else
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
            if(isDefined(zombies[a]) && IsAlive(zombies[a]))
                zombies[a] Show();
    }
}

FreezeZombies()
{
    SetDvar("g_ai", (GetDvarString("g_ai") == "1") ? "0" : "1");
}

DisappearingZombies()
{
    level.DisappearingZombies = isDefined(level.DisappearingZombies) ? undefined : true;

    if(isDefined(level.DisappearingZombies))
    {
        while(isDefined(level.DisappearingZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!IsAlive(zombies[a]) && isDefined(zombies[a].disappearing))
                    continue;
                
                zombies[a] thread DisappearingZombie();
            }

            wait 0.01;
        }
    }
    else
    {
        level notify("EndDisappearingZombies");
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            if(!isDefined(zombies[a]) || !IsAlive(zombies[a]))
                continue;
            
            zombies[a].disappearing = undefined;

            if(!isDefined(level.ZombiesInvisibility))
                zombies[a] Show();
            else
                zombies[a] Hide();
        }
    }
}

DisappearingZombie()
{
    if(!isDefined(self) || !IsAlive(self))
        return;
    
    self.disappearing = true;
    level endon("EndDisappearingZombies");
    
    while(isDefined(self) && IsAlive(self))
    {
        if(isDefined(self) && IsAlive(self))
            self Hide();
        
        wait RandomFloatRange(3, 5);

        if(isDefined(self) && IsAlive(self))
            self Show();
        
        wait RandomFloatRange(3, 5);
    }
}

ExplodingZombies()
{
    level.ExplodingZombies = isDefined(level.ExplodingZombies) ? undefined : true;

    if(isDefined(level.ExplodingZombies))
    {
        while(isDefined(level.ExplodingZombies))
        {
            zombies = GetAITeamArray(level.zombie_team);

            for(a = 0; a < zombies.size; a++)
            {
                if(!IsAlive(zombies[a]) || isDefined(zombies[a].explodingzombie))
                    continue;
                
                zombies[a].explodingzombie = true;

                zombies[a] clientfield::set("arch_actor_fire_fx", 1);
                zombies[a] clientfield::set("napalm_sfx", 1);
            }
            
            wait 0.01;
        }
    }
    else
    {
        zombies = GetAITeamArray(level.zombie_team);

        for(a = 0; a < zombies.size; a++)
        {
            zombies[a] clientfield::set("arch_actor_fire_fx", 0);
            zombies[a] clientfield::set("napalm_sfx", 0);

            zombies[a].explodingzombie = undefined;
        }
    }
}

ZombieRagdoll()
{
    level.ZombieRagdoll = isDefined(level.ZombieRagdoll) ? undefined : true;
}

ZombiesDeathEffect()
{
    level.ZombiesDeathEffect = isDefined(level.ZombiesDeathEffect) ? undefined : true;
}

SetZombiesDeathEffect(effect)
{
    level.ZombiesDeathFX = effect;
}

ZombiesDamageEffect()
{
    level.ZombiesDamageEffect = isDefined(level.ZombiesDamageEffect) ? undefined : true;
}

SetZombiesDamageEffect(effect)
{
    level.ZombiesDamageFX = effect;
}

DetachZombieHeads()
{
    zombies = GetAITeamArray(level.zombie_team);
    
    for(a = 0; a < zombies.size; a++)
        zombies[a] DetachAll();
}