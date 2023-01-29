NachtUndoneSong()
{
    if(isDefined(level.NachtUndoneSong))
        return self iPrintlnBold("^1ERROR: ^7Undone Song Already Activated");

    level.NachtUndoneSong = true;
    
    a_barrels = GetEntArray("explodable_barrel", "targetname");
    b_barrels = GetEntArray("explodable_barrel", "script_noteworthy");
    array = ArrayCombine(a_barrels, b_barrels, 0, 1);
    
    foreach(index, barrel in array)
        barrel DoDamage(barrel.health + 666, barrel.origin, self);
}