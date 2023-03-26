FeedDragons()
{
    for(a = 0; a < level.soul_catchers.size; a++)
    {
        level.soul_catchers[a] notify("first_zombie_killed_in_zone", self);
        
        wait GetAnimLength("rtrg_o_zm_dlc1_dragonhead_intro");
        
        for(b = 0; b < 8; b++)
        {
            level.soul_catchers[a].var_98730ffa++;
            
            wait 0.01;
        }
    }
}