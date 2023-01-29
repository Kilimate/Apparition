
/*
	UPGRADE STAFFS:

		- ICE ~ https://www.kronorium.com/img/ice_staff.png
			- Complete Ice Puzzle(Crazy Place)
			- Destroy 3 Tombstones
			- Align 115 Rings
			- Charge Staff With Souls In Crazy Place
		
		- WIND ~ https://www.kronorium.com/img/wind_staff.png
			- Complete Wind Puzzle(Crazy Place)
			- Shoot 3 Smoking
			- Align 115 Rings
			- Charge Staff With Souls In Crazy Place
		
		- LIGHTNING ~ https://www.kronorium.com/img/lightning_staff.png
			- Complete Lightning Puzzle(Crazy Place)
				- 1, 3, 6
				- 3, 5, 7
				- 2, 4, 6
			
			- Turn Dials Around Map
				- Tank Station ~ Down
				- Spawn ~ Left
				- Gen. 4 ~ Up
				- Upstairs Church ~ Up
				- Downstairs Church ~ Right
				- Gen. 5 ~ Down
				- Mound Wall ~ Up
			
			- Align 115 Rings
			- Charge Staff With Souls In Crazy Place
		
		- FIRE ~ https://www.kronorium.com/img/fire_staff.png
			- Fill Cauldrons(Crazy Place)
			- Light Torches
			- Align 115 Rings
			- Charge Staff With Souls In Crazy Place
*/

CompleteSoulbox(box)
{
	if(!isDefined(box) || box.n_souls_absorbed >= 30)
		return;
	
	curs = self getCursor();
    menu = self getCurrent();
	
	while(isDefined(box))
	{
		if(box.n_souls_absorbed < 30)
			box notify("soul_absorbed", self);
		
		wait 0.01;
	}

	self RefreshMenu(menu, curs);
}

OriginsSetWeather(weather)
{
    level.last_snow_round = 0;
    level.last_rain_round = 0;
    int = RandomIntRange(1, 5);
    
    switch(weather)
    {
        case "Rain":
            level.weather_snow = 0;
            level.weather_rain = int;
            level.weather_vision = 1;

            level util::set_lighting_state(1);
            break;
		
        case "Snow":
            level.weather_snow = int;
            level.weather_rain = 0;
            level.weather_vision = 2;

            level util::set_lighting_state(0);
            break;
		
        case "None":
            level.weather_snow = 0;
            level.weather_rain = 0;
            level.weather_vision = 3;

            level util::set_lighting_state(0);
            break;
		
        default:
            break;
    }
    
    level clientfield::set("rain_level", level.weather_rain);
    level clientfield::set("snow_level", level.weather_snow);
    
    foreach(player in level.players)
        if(zombie_utility::is_player_valid(player, 0, 1))
            player clientfield::set_to_player("player_weather_visionset", level.weather_vision);
}

SetGeneratorState(generator)
{
    generators = struct::get_array("s_generator", "targetname");

    struct = generators[generator];

    if(struct flag::get("zone_contested"))
        struct kill_all_capture_zombies();
    
    struct flag::clear("zone_contested");

    foreach(e_player in level.players)
        e_player thread zm_craftables::player_show_craftable_parts_ui(undefined, "zmInventory.capture_generator_wheel_widget", 0);
    
    if(!struct flag::get("player_controlled"))
    {
        level.zone_capture.last_zone_captured = struct;

        struct flag::set("player_controlled");
        struct flag::clear("attacked_by_recapture_zombies");
        level clientfield::set("zone_capture_hud_generator_" + struct.script_int, 1);
        level clientfield::set("zone_capture_monolith_crystal_" + struct.script_int, 0);

        if(!isDefined(struct.perk_fx_func) || [[ struct.perk_fx_func ]]())
            level clientfield::set("zone_capture_perk_machine_smoke_fx_" + struct.script_int, 1);

        struct flag::set("player_controlled");

        struct enable_perk_machines_in_zone();
        struct enable_random_perk_machines_in_zone();
        struct enable_mystery_boxes_in_zone();
        struct function_c3b54f6d();

        level notify("zone_captured_by_player", struct.str_zone);
        PlayFX(level._effect["capture_complete"], struct.origin);

		struct reward_players_in_capture_zone();
    }
    else
    {
        struct flag::clear("player_controlled");
        level clientfield::set("zone_capture_hud_generator_" + struct.script_int, 2);
        level clientfield::set("zone_capture_monolith_crystal_" + struct.script_int, 1);
        level clientfield::set("zone_capture_perk_machine_smoke_fx_" + struct.script_int, 0);

        struct disable_perk_machines_in_zone();
        struct disable_random_perk_machines_in_zone();
        struct disable_mystery_boxes_in_zone();
        struct function_1138b343();
    }

    update_captured_zone_count();
    struct.n_current_progress = struct flag::get("player_controlled") ? 100 : 0;
    struct.n_last_progress = struct.n_current_progress;
    level clientfield::set("state_" + struct.script_noteworthy, struct flag::get("player_controlled") ? 2 : 4);
    level clientfield::set(struct.script_noteworthy, struct.n_current_progress / 100);
    play_pap_anim(struct flag::get("player_controlled"));
}

kill_all_capture_zombies()
{
	while(isDefined(self.capture_zombies) && self.capture_zombies.size > 0)
	{
		foreach(var_31f13232, zombie in self.capture_zombies)
		{
			if(isDefined(zombie) && IsAlive(zombie))
			{
				PlayFX(level._effect["tesla_elec_kill"], zombie.origin);
				zombie DoDamage(zombie.health + 100, zombie.origin);
			}

			util::wait_network_frame();
		}

		self.capture_zombies = array::remove_dead(self.capture_zombies);
	}

	self.capture_zombies = [];
}

update_captured_zone_count()
{
	level.total_capture_zones = get_captured_zone_count();

	if(level.total_capture_zones == 6)
		level flag::set("all_zones_captured");
	else
		level flag::clear("all_zones_captured");
}

get_captured_zone_count()
{
	n_player_controlled_zones = 0;

	foreach(var_df4e052f, generator in level.zone_capture.zones)
		if(generator flag::get("player_controlled"))
			n_player_controlled_zones++;

	return n_player_controlled_zones;
}

enable_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines) && IsArray(self.perk_machines))
	{
		a_keys = GetArrayKeys(self.perk_machines);

		i = 0;
		while(i < a_keys.size)
		{
			level notify(a_keys[i] + "_on");
			i++;
		}

		for(i = 0; i < a_keys.size; i++)
		{
			e_perk_trigger = self.perk_machines[a_keys[i]];
			e_perk_trigger.is_locked = 0;
			e_perk_trigger zm_perks::reset_vending_hint_string();
		}
	}
}

enable_random_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
	{
		foreach(var_f4b001f6, random_perk_machine in self.perk_machines_random)
		{
			random_perk_machine.is_locked = 0;

			if(isDefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
			{
				random_perk_machine set_perk_random_machine_state("idle");
				continue;
			}

			random_perk_machine set_perk_random_machine_state("away");
		}
	}
}

set_perk_random_machine_state(state)
{
	wait 0.1;

	for(i = 0; i < self GetNumZBarrierPieces(); i++)
		self HideZBarrierPiece(i);

	self notify("zbarrier_state_change");
	self [[ level.perk_random_machine_state_func ]](state);
}

enable_mystery_boxes_in_zone()
{
	foreach(var_ee5097f2, mystery_box in self.mystery_boxes)
	{
		mystery_box.is_locked = 0;
		mystery_box.zbarrier [[ level.magic_box_zbarrier_state_func ]]("player_controlled"); 
		mystery_box.zbarrier clientfield::set("magicbox_runes", 1);
	}
}

function_c3b54f6d()
{
	var_43157bc9 = "power_on" + self.script_int;
	level flag::set(var_43157bc9);
}

disable_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines) && IsArray(self.perk_machines))
	{
		a_keys = GetArrayKeys(self.perk_machines);

		i = 0;
		while(i < a_keys.size)
		{
			level notify(a_keys[i] + "_off");
			i++;
		}

		for(i = 0; i < a_keys.size; i++)
		{
			e_perk_trigger = self.perk_machines[a_keys[i]];
			e_perk_trigger.is_locked = 1;
			e_perk_trigger SetHintString(&"ZM_TOMB_ZC");
		}
	}
}

disable_random_perk_machines_in_zone()
{
	if(isDefined(self.perk_machines_random) && IsArray(self.perk_machines_random))
	{
		foreach(var_77085d2, random_perk_machine in self.perk_machines_random)
		{
			random_perk_machine.is_locked = 1;

			if(isDefined(random_perk_machine.current_perk_random_machine) && random_perk_machine.current_perk_random_machine)
			{
				random_perk_machine set_perk_random_machine_state("initial");
				continue;
			}

			random_perk_machine set_perk_random_machine_state("power_off");
		}
	}
}

disable_mystery_boxes_in_zone()
{
	foreach(var_c5cf7f78, mystery_box in self.mystery_boxes)
	{
		mystery_box.is_locked = 1;
		mystery_box.zbarrier [[ level.magic_box_zbarrier_state_func ]]("zombie_controlled");
		mystery_box.zbarrier clientfield::set("magicbox_runes", 0);
	}
}

function_1138b343()
{
	var_43157bc9 = "power_on" + self.script_int;
	level flag::clear(var_43157bc9);
}

play_pap_anim(b_assemble)
{
	level clientfield::set("packapunch_anim", get_captured_zone_count());
}

GivePlayerShovel(player)
{
    player.dig_vars["has_shovel"] = !player.dig_vars["has_shovel"];
    player.dig_vars["has_upgraded_shovel"] = player.dig_vars["has_shovel"];
    player.dig_vars["has_helmet"] = player.dig_vars["has_shovel"];

    level clientfield::set("player" + player GetEntityNumber() + "hasItem", player.dig_vars["has_shovel"]);
}

GetGatewayState(gateway)
{
    return level flag::get("enable_teleporter_" + gateway.script_int);
}

SetGatewayState(gateway)
{
    target = struct::get_array("stargate_gramophone_pos", "targetname")[gateway.script_int];

    if(!GetGatewayState(gateway))
    {
        level flag::set("enable_teleporter_" + gateway.script_int);

        if(isDefined(target.script_flag))
            level flag::set(target.script_flag);
    }
    else
    {
        level flag::clear("enable_teleporter_" + gateway.script_int);

        if(isDefined(target.script_flag))
            level flag::clear(target.script_flag);
    }
}

ReturnGatewayName(targetname)
{
    switch(targetname)
    {
        case "fire_teleport_player":
            return "Fire";
		
        case "air_teleport_player":
            return "Wind";
		
        case "water_teleport_player":
            return "Ice";
		
        case "electric_teleport_player":
            return "Lightning";
		
        default:
            return "Unknown";
    }
}

MudSlowdown()
{
    level.a_e_slow_areas = isDefined(level.a_e_slow_areas) ? undefined : GetEntArray("player_slow_area", "targetname");
}

CompleteOriginChallenge(challenge)
{
	stat = get_stat(challenge, self);

	if(stat.b_medal_awarded)
		return;
	
	if(stat.n_value < stat.s_parent.n_goal)
	{
		diff = (stat.s_parent.n_goal - stat.n_value);
		self increment_stat(challenge, diff);
	}
}

reward_players_in_capture_zone()
{
	b_challenge_exists = challenge_exists("zc_zone_captures");

	if(self flag::get("player_controlled"))
	{
		foreach(var_a6c07c28, player in GetPlayers())
		{
			player notify("completed_zone_capture");

			if(b_challenge_exists)
				player increment_stat("zc_zone_captures");
		}
	}
}

challenge_exists(str_name)
{
	return isDefined(level._challenges.a_stats[str_name]);
}

increment_stat(str_stat, n_increment = 1)
{
	s_stat = get_stat(str_stat, self);
    
	if(!s_stat.b_medal_awarded)
	{
		s_stat.n_value = s_stat.n_value + n_increment;
		check_stat_complete(s_stat);
	}
}

get_stat(str_stat, player)
{
	return level._challenges.a_stats[str_stat].b_team ? level._challenges.s_team.a_stats[str_stat] : level._challenges.a_players[player.characterindex].a_stats[str_stat];
}

check_stat_complete(s_stat)
{
	if(s_stat.b_medal_awarded)
		return 1;

	if(s_stat.n_value >= s_stat.s_parent.n_goal)
	{
		s_stat.b_medal_awarded = 1;

		if(s_stat.s_parent.b_team)
		{
			s_team_stats = level._challenges.s_team;
			s_team_stats.n_completed++;
			s_team_stats.n_medals_held++;
			a_players = GetPlayers();

			foreach(var_9df16521, player in a_players)
			{
				player clientfield::set_to_player(s_stat.s_parent.cf_complete, 1);
				player function_fbbc8608(s_stat.s_parent.str_hint, s_stat.s_parent.n_index);
				player PlaySound("evt_medal_acquired");
				util::wait_network_frame();
			}
		}
		else
		{
			s_player_stats = level._challenges.a_players[self.characterindex];
			s_player_stats.n_completed++;
			s_player_stats.n_medals_held++;
			self PlaySound("evt_medal_acquired");
			self clientfield::set_to_player(s_stat.s_parent.cf_complete, 1);
			self function_fbbc8608(s_stat.s_parent.str_hint, s_stat.s_parent.n_index);
		}

		foreach(var_b057f17e, m_board in level.a_m_challenge_boards)
			m_board ShowPart(s_stat.str_glow_tag);

		if(IsPlayer(self))
		{
			if(level._challenges.a_players[self.characterindex].n_completed + level._challenges.s_team.n_completed == level._challenges.a_stats.size)
				self notify("all_challenges_complete");
		}
		else
		{
			foreach(var_f51cc11b, player in GetPlayers())
				if(isDefined(player.characterindex))
					if(level._challenges.a_players[player.characterindex].n_completed + level._challenges.s_team.n_completed == level._challenges.a_stats.size)
						player notify("all_challenges_complete");
		}
		util::wait_network_frame();
	}
}

function_fbbc8608(str_hint, var_7ca2c2ae)
{
	self luinotifyevent(&"trial_complete", 3, &"ZM_TOMB_CHALLENGE_COMPLETED", str_hint, var_7ca2c2ae);
}