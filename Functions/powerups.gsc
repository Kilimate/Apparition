PowerUpSpawnLocation(location)
{
    self.PowerUpSpawnLocation = location;
}

SpawnPowerUp(powerup, loc)
{
    if(!isDefined(loc))
        loc = (self.PowerUpSpawnLocation == "Self") ? self.origin : self TraceBullet();
    
    drop = level zm_powerups::specific_powerup_drop(powerup, loc);

    if(isDefined(level.powerup_drop_count) && level.powerup_drop_count)
        level.powerup_drop_count--;
}